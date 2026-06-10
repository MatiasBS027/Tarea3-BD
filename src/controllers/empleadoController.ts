import { Request, Response } from 'express';
import { getPool, sql } from '../db/connection';
import { getErrorMessage } from '../utils/errorhelper';

type PuestoRow = {
    id: number;
    Nombre: string;
};

// Resolver el id del usuario a partir del username.
// Se usa en insert, update y delete porque los SPs guardan trazabilidad en BitacoraEvento.
async function resolveUsuarioId(pool: Awaited<ReturnType<typeof getPool>>, username: string): Promise<number | null> {
    const usuarioResult = await pool
        .request()
        .input('inUsername', sql.VarChar(128), username)
        .query('SELECT id FROM Usuario WHERE Username = @inUsername');

    return usuarioResult.recordset?.[0]?.id ?? null;
}

// GET /api/puestos
// Retorna el catálogo de puestos para llenar el select del formulario de edición.
export async function getPuestos(req: Request, res: Response): Promise<void> {
    try {
        const pool = await getPool();

        const result = await pool
            .request()
            .query('SELECT id, Nombre FROM dbo.Puesto ORDER BY Nombre ASC');

        res.status(200).json({
            success: true,
            outResultCode: 0,
            data: result.recordset as PuestoRow[]
        });
    } catch (error) {
        console.error('Error en getPuestos:', error);
        res.status(500).json({
            success: false,
            outResultCode: 50008,
            message: 'Error interno del servidor'
        });
    }
}

// GET /api/empleados
// Invoca sp_GetEmpleados y retorna el listado filtrado
export async function getEmpleados(req: Request, res: Response): Promise<void> {
    try {
        const filtro = String(req.query.filtro ?? '').trim();

        const pool = await getPool();

        const result = await pool
            .request()
            .input('inNombre', sql.VarChar(128), filtro)
            .output('outResultCode', sql.Int)
            .execute('sp_GetEmpleados');

        const outResultCode: number = result.output.outResultCode;

        if (outResultCode !== 0) {
            res.status(400).json({
                success: false,
                outResultCode,
                message: await getErrorMessage(outResultCode)
            });
            return;
        }

        res.status(200).json({
            success: true,
            outResultCode,
            data: result.recordset
        });
    } catch (error) {
        console.error('Error en getEmpleados:', error);
        res.status(500).json({
            success: false,
            outResultCode: 50008,
            message: 'Error interno del servidor'
        });
    }
}

// POST /api/empleados
// Invoca sp_InsertarEmpleado para crear un nuevo empleado
export async function insertEmpleado(req: Request, res: Response): Promise<void> {
    const { valorDocumentoIdentidad, nombre, idPuesto } = req.body;

    if (!valorDocumentoIdentidad || !nombre || idPuesto === undefined) {
        res.status(400).json({
            success: false,
            message: 'valorDocumentoIdentidad, nombre e idPuesto son requeridos'
        });
        return;
    }

    try {
        // Temporal para pruebas; luego se toma desde token/sesion
        const username = String(req.headers['x-username'] ?? 'UsuarioScripts');
        const ipPostIn = req.ip ?? '';
        const postTime = new Date();

        const pool = await getPool();

        // El SP necesita el id del usuario para dejar la traza en la bitácora.
        let idUsuario = await resolveUsuarioId(pool, username);

        if (!idUsuario) {
            const fallbackResult = await pool
                .request()
                .query('SELECT TOP 1 id FROM Usuario ORDER BY id');

            idUsuario = fallbackResult.recordset?.[0]?.id ?? null;
        }

        if (!idUsuario) {
            res.status(400).json({
                success: false,
                outResultCode: 50001,
                message: await getErrorMessage(50001)
            });
            return;
        }

        const result = await pool
            .request()
                .input('inValorDocumentoIdentidad', sql.NVarChar(32), String(valorDocumentoIdentidad))
            .input('inNombre', sql.VarChar(128), String(nombre))
            .input('inIdPuesto', sql.Int, Number(idPuesto))
            .input('inIdUsuario', sql.Int, idUsuario)
            .input('inIpPostIn', sql.VarChar(64), ipPostIn)
            .input('inPostTime', sql.DateTime, postTime)
            .output('outResultCode', sql.Int)
            .execute('sp_InsertarEmpleado');

        const outResultCode: number = result.output.outResultCode;

        if (outResultCode !== 0) {
            res.status(400).json({
                success: false,
                outResultCode,
                message: await getErrorMessage(outResultCode)
            });
            return;
        }

        res.status(201).json({
            success: true,
            outResultCode,
            message: 'Empleado creado exitosamente'
        });
    } catch (error) {
        console.error('Error en insertEmpleado:', error);
        res.status(500).json({
            success: false,
            outResultCode: 50008,
            message: 'Error interno del servidor'
        });
    }
}

// GET /api/empleados/:valorDocumentoIdentidad
// Invoca sp_GetEmpleadoById y retorna un empleado activo.
// Este endpoint nos sirve para cargar los formularios de consulta, edición y borrado.
export async function getEmpleadoById(req: Request, res: Response): Promise<void> {
    try {
        const valorDocumentoIdentidad = String(req.params.valorDocumentoIdentidad ?? '').trim();

        if (!valorDocumentoIdentidad) {
            res.status(400).json({
                success: false,
                message: 'valorDocumentoIdentidad es requerido'
            });
            return;
        }

        const pool = await getPool();

        const result = await pool
            .request()
                .input('inValorDocumento', sql.VarChar(32), valorDocumentoIdentidad)
            .output('outResultCode', sql.Int)
            .execute('sp_GetEmpleadoById');

        const outResultCode: number = result.output.outResultCode;

        if (outResultCode !== 0) {
            res.status(404).json({
                success: false,
                outResultCode,
                message: await getErrorMessage(outResultCode)
            });
            return;
        }

        res.status(200).json({
            success: true,
            outResultCode,
            data: result.recordset?.[0] ?? null
        });
    } catch (error) {
        console.error('Error en getEmpleadoById:', error);
        res.status(500).json({
            success: false,
            outResultCode: 50008,
            message: 'Error interno del servidor'
        });
    }
}

// PATCH /api/empleados/:valorDocumentoIdentidad
// Invoca sp_UpdateEmpleado.
// El SP recibe valores "antes" y "después" para validar duplicados y dejar la bitácora completa.
export async function updateEmpleado(req: Request, res: Response): Promise<void> {
    const valorDocumentoIdentidadAntes = String(req.params.valorDocumentoIdentidad ?? '').trim();
    const {
        valorDocumentoIdentidadDespues,
        nombreAntes,
        nombreDespues,
        idPuestoAntes,
        idPuestoDespues
    } = req.body;

    if (!valorDocumentoIdentidadAntes || !valorDocumentoIdentidadDespues || !nombreAntes || !nombreDespues || idPuestoAntes === undefined || idPuestoDespues === undefined) {
        res.status(400).json({
            success: false,
            message: 'Faltan datos para actualizar el empleado'
        });
        return;
    }

    try {
        // Igual que en insert, obtenemos el usuario para que el SP registre la operación.
        const username = String(req.headers['x-username'] ?? 'UsuarioScripts');
        const ipPostIn = req.ip ?? '';
        const postTime = new Date();

        const pool = await getPool();
        let idUsuario = await resolveUsuarioId(pool, username);

        if (!idUsuario) {
            const fallbackResult = await pool
                .request()
                .query('SELECT TOP 1 id FROM Usuario ORDER BY id');

            idUsuario = fallbackResult.recordset?.[0]?.id ?? null;
        }

        if (!idUsuario) {
            res.status(400).json({
                success: false,
                outResultCode: 50001,
                message: await getErrorMessage(50001)
            });
            return;
        }

        const result = await pool
            .request()
            .input('inValorDocumentoIdentidadAntes', sql.VarChar(32), valorDocumentoIdentidadAntes)
            .input('inValorDocumentoIdentidadDespues', sql.VarChar(32), String(valorDocumentoIdentidadDespues))
            .input('inNombreAntes', sql.VarChar(128), String(nombreAntes))
            .input('inNombreDespues', sql.VarChar(128), String(nombreDespues))
            .input('inIdPuestoAntes', sql.Int, Number(idPuestoAntes))
            .input('inIdPuestoDespues', sql.Int, Number(idPuestoDespues))
            .input('inIdUsuario', sql.Int, idUsuario)
            .input('inIpPostIn', sql.VarChar(64), ipPostIn)
            .input('inPostTime', sql.DateTime, postTime)
            .output('outResultCode', sql.Int)
            .execute('sp_UpdateEmpleado');

        const outResultCode: number = result.output.outResultCode;

        if (outResultCode !== 0) {
            res.status(400).json({
                success: false,
                outResultCode,
                message: await getErrorMessage(outResultCode)
            });
            return;
        }

        res.status(200).json({
            success: true,
            outResultCode,
            message: 'Empleado actualizado exitosamente'
        });
    } catch (error) {
        console.error('Error en updateEmpleado:', error);
        res.status(500).json({
            success: false,
            outResultCode: 50008,
            message: 'Error interno del servidor'
        });
    }
}

// DELETE /api/empleados/:valorDocumentoIdentidad
// Invoca sp_DeleteEmpleado.
// El SP maneja tanto el intento como el borrado real según el flag confirmado.
export async function deleteEmpleado(req: Request, res: Response): Promise<void> {
    const valorDocumentoIdentidad = String(req.params.valorDocumentoIdentidad ?? '').trim();
    const confirmado = Boolean(req.body?.confirmado);

    if (!valorDocumentoIdentidad) {
        res.status(400).json({
            success: false,
            message: 'valorDocumentoIdentidad es requerido'
        });
        return;
    }

    try {
        // Igual que en las demás operaciones, capturamos contexto para la bitácora.
        const username = String(req.headers['x-username'] ?? 'UsuarioScripts');
        const ipPostIn = req.ip ?? '';
        const postTime = new Date();

        const pool = await getPool();
        let idUsuario = await resolveUsuarioId(pool, username);

        if (!idUsuario) {
            const fallbackResult = await pool
                .request()
                .query('SELECT TOP 1 id FROM Usuario ORDER BY id');

            idUsuario = fallbackResult.recordset?.[0]?.id ?? null;
        }

        if (!idUsuario) {
            res.status(400).json({
                success: false,
                outResultCode: 50001,
                message: await getErrorMessage(50001)
            });
            return;
        }

        const result = await pool
            .request()
            .input('inValorDocumentoIdentidad', sql.VarChar(32), valorDocumentoIdentidad)
            .input('inIdUsuario', sql.Int, idUsuario)
            .input('inIpPostIn', sql.VarChar(64), ipPostIn)
            .input('inPostTime', sql.DateTime, postTime)
            .input('inConfirmado', sql.Bit, confirmado)
            .output('outResultCode', sql.Int)
            .execute('sp_DeleteEmpleado');

        const outResultCode: number = result.output.outResultCode;

        if (outResultCode !== 0) {
            res.status(400).json({
                success: false,
                outResultCode,
                message: await getErrorMessage(outResultCode)
            });
            return;
        }

        res.status(200).json({
            success: true,
            outResultCode,
            message: confirmado ? 'Empleado eliminado exitosamente' : 'Intento de borrado registrado'
        });
    } catch (error) {
        console.error('Error en deleteEmpleado:', error);
        res.status(500).json({
            success: false,
            outResultCode: 50008,
            message: 'Error interno del servidor'
        });
    }
}

// POST /api/empleados/impersonar
// Invoca sp_ImpersonarEmpleado para que un admin acceda como empleado.
export async function impersonarEmpleado(req: Request, res: Response): Promise<void> {
    try {
        const { valorDocumento } = req.body;

        if (!valorDocumento) {
            res.status(400).json({
                success: false,
                outResultCode: 50012,
                message: await getErrorMessage(50012)
            });
            return;
        }

        const username = String(req.headers['x-username'] ?? '');
        const pool = await getPool();
        const idUsuarioAdmin = await resolveUsuarioId(pool, username);

        if (!idUsuarioAdmin) {
            res.status(400).json({
                success: false,
                outResultCode: 50001,
                message: await getErrorMessage(50001)
            });
            return;
        }

        const result = await pool
            .request()
            .input('inValorDocumento', sql.VarChar(32), String(valorDocumento))
            .input('inIdUsuarioAdmin', sql.Int, idUsuarioAdmin)
            .input('inIpPostIn', sql.VarChar(64), req.ip ?? '')
            .input('inPostTime', sql.DateTime, new Date())
            .output('outIdEmpleado', sql.Int)
            .output('outResultCode', sql.Int)
            .execute('sp_ImpersonarEmpleado');

        const outResultCode: number = result.output.outResultCode;
        const outIdEmpleado: number | null = result.output.outIdEmpleado ?? null;

        if (outResultCode !== 0) {
            res.status(outResultCode === 50012 ? 404 : 400).json({
                success: false,
                outResultCode,
                message: await getErrorMessage(outResultCode)
            });
            return;
        }

        res.status(200).json({
            success: true,
            outResultCode,
            data: { idEmpleado: outIdEmpleado }
        });
    } catch (error) {
        console.error('Error en impersonarEmpleado:', error);
        res.status(500).json({
            success: false,
            outResultCode: 50008,
            message: 'Error interno del servidor'
        });
    }
}

// POST /api/empleados/regresar-admin
// Invoca sp_RegresarAdmin para volver a la interfaz de administrador.
export async function regresarAdmin(req: Request, res: Response): Promise<void> {
    try {
        const username = String(req.headers['x-username'] ?? '');
        const pool = await getPool();
        const idUsuarioAdmin = await resolveUsuarioId(pool, username);

        if (!idUsuarioAdmin) {
            res.status(400).json({
                success: false,
                outResultCode: 50001,
                message: await getErrorMessage(50001)
            });
            return;
        }

        const result = await pool
            .request()
            .input('inIdUsuarioAdmin', sql.Int, idUsuarioAdmin)
            .input('inIpPostIn', sql.VarChar(64), req.ip ?? '')
            .input('inPostTime', sql.DateTime, new Date())
            .output('outResultCode', sql.Int)
            .execute('sp_RegresarAdmin');

        const outResultCode: number = result.output.outResultCode;

        if (outResultCode !== 0) {
            res.status(outResultCode === 50013 ? 403 : 400).json({
                success: false,
                outResultCode,
                message: await getErrorMessage(outResultCode)
            });
            return;
        }

        res.status(200).json({
            success: true,
            outResultCode,
            message: 'Regreso a interfaz de administrador'
        });
    } catch (error) {
        console.error('Error en regresarAdmin:', error);
        res.status(500).json({
            success: false,
            outResultCode: 50008,
            message: 'Error interno del servidor'
        });
    }
}

// GET /api/tiposMovimiento
export async function getTiposMovimiento(req: Request, res: Response): Promise<void> {
    try {
        const pool = await getPool();

        const result = await pool
            .request()
            .output('outResultCode', sql.Int)
            .execute('sp_GetTiposMovimiento');

        const outResultCode: number = result.output.outResultCode;

        if (outResultCode !== 0){
            res.status(400).json({
                success: false,
                outResultCode,
                message: await getErrorMessage(outResultCode)
            });
            return;
        }

        res.status(200).json({
            success: true,
            outResultCode,
            data: result.recordset
        });

    } catch (error){
        console.error('Error en getTiposMovimiento:', error);
        res.status(500).json({
            success: false,
            outResultCode: 50008,
            message: 'Error interno del servidor'
        });
    }
}

// GET /api/empleados/by-id/:id
// Busca un empleado por id INT (para la vista de impersonación).
export async function getEmpleadoByIdInt(req: Request, res: Response): Promise<void> {
    try {
        const id = Number(req.params.id);

        if (!id || Number.isNaN(id)) {
            res.status(400).json({
                success: false,
                message: 'id es requerido y debe ser un número'
            });
            return;
        }

        const pool = await getPool();

        const result = await pool
            .request()
            .input('inId', sql.Int, id)
            .output('outResultCode', sql.Int)
            .execute('sp_GetEmpleadoByIdInt');

        const outResultCode: number = result.output.outResultCode;

        if (outResultCode !== 0) {
            res.status(500).json({
                success: false,
                outResultCode,
                message: await getErrorMessage(outResultCode)
            });
            return;
        }

        const empleado = result.recordset?.[0] ?? null;

        if (!empleado) {
            res.status(404).json({
                success: false,
                message: 'Empleado no encontrado'
            });
            return;
        }

        res.status(200).json({
            success: true,
            data: empleado
        });
    } catch (error) {
        console.error('Error en getEmpleadoByIdInt:', error);
        res.status(500).json({
            success: false,
            message: 'Error interno del servidor'
        });
    }
}
