import { Request, Response } from 'express';
import { getPool, sql } from '../db/connection';
import { getErrorMessage } from '../utils/errorhelper';
import { resolveUsuarioId } from './usuarioHelper';

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

// GET /api/empleados/:valorDocumentoIdentidad
// Invoca sp_GetEmpleadoById y retorna un empleado activo.
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

// GET /api/empleados/by-id/:id
// Busca un empleado por id INT (para la vista de impersonacion).
export async function getEmpleadoByIdInt(req: Request, res: Response): Promise<void> {
    try {
        const id = Number(req.params.id);

        if (!id || Number.isNaN(id)) {
            res.status(400).json({
                success: false,
                message: 'id es requerido y debe ser un numero'
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
