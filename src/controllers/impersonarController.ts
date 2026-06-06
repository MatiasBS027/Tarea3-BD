/**
* controllers/impersonarController.ts
* Controlador de impersonación (R03) y regreso a admin (R06).
*
* - impersonarEmpleado: registra en BitacoraEvento la impersonación
*   y devuelve el id del empleado impersonado para que el frontend
*   sepa a quién está "viendo".
* - regresarAdmin: registra en BitacoraEvento el regreso a la vista admin.
*
* Ambos SPs dejan la traza correspondiente en BitacoraEvento; el id del
* usuario admin se resuelve a partir del header 'x-username', igual que
* en los demás controllers.
*/

import { Request, Response } from 'express';
import { getPool, sql } from '../db/connection';
import { getErrorMessage } from '../utils/errorhelper';

async function resolveUsuarioId(
    pool: Awaited<ReturnType<typeof getPool>>,
    username: string,
): Promise<number | null> {
    const usuarioResult = await pool
        .request()
        .input('inUsername', sql.VarChar(128), username)
        .query('SELECT id FROM Usuario WHERE Username = @inUsername');

    return usuarioResult.recordset?.[0]?.id ?? null;
}

// POST /api/auth/impersonar
// Body: { valorDocumentoIdentidad: "110011001" }
// Respuesta: { success, outResultCode, idEmpleado, message }
export async function impersonarEmpleado(req: Request, res: Response): Promise<void> {
    const valorDocumentoIdentidad = String(req.body?.valorDocumentoIdentidad ?? '').trim();

    if (!valorDocumentoIdentidad) {
        res.status(400).json({
            success: false,
            outResultCode: 50000,
            message: 'valorDocumentoIdentidad es requerido',
        });
        return;
    }

    const username = String(req.headers['x-username'] ?? '').trim();
    const ipPostIn = req.ip ?? '';
    const postTime = new Date();

    if (!username) {
        res.status(401).json({
            success: false,
            outResultCode: 50001,
            message: 'Sesión no válida. Vuelve a iniciar sesión.',
        });
        return;
    }

    try {
        const pool = await getPool();
        const idUsuarioAdmin = await resolveUsuarioId(pool, username);

        if (!idUsuarioAdmin) {
            res.status(401).json({
                success: false,
                outResultCode: 50001,
                message: 'Usuario de sesión no encontrado',
            });
            return;
        }

        const result = await pool
            .request()
            .input('inValorDocumento', sql.VarChar(32), valorDocumentoIdentidad)
            .input('inIdUsuarioAdmin', sql.Int, idUsuarioAdmin)
            .input('inIpPostIn', sql.VarChar(64), ipPostIn)
            .input('inPostTime', sql.DateTime, postTime)
            .output('outIdEmpleado', sql.Int)
            .output('outResultCode', sql.Int)
            .execute('sp_ImpersonarEmpleado');

        const outResultCode: number = Number(result.output.outResultCode ?? 50008);
        const outIdEmpleado: number | null = result.output.outIdEmpleado ?? null;

        if (outResultCode !== 0) {
            res.status(outResultCode === 50012 ? 404 : 400).json({
                success: false,
                outResultCode,
                message: await getErrorMessage(outResultCode),
            });
            return;
        }

        res.status(200).json({
            success: true,
            outResultCode,
            idEmpleado: outIdEmpleado,
            message: 'Impersonación iniciada correctamente',
        });
    } catch (error) {
        console.error('Error en impersonarEmpleado:', error);
        res.status(500).json({
            success: false,
            outResultCode: 50008,
            message: 'Error interno del servidor',
        });
    }
}

// POST /api/auth/regresar-admin
// Body: (ninguno)
// Respuesta: { success, outResultCode, message }
export async function regresarAdmin(req: Request, res: Response): Promise<void> {
    const username = String(req.headers['x-username'] ?? '').trim();
    const ipPostIn = req.ip ?? '';
    const postTime = new Date();

    if (!username) {
        res.status(401).json({
            success: false,
            outResultCode: 50001,
            message: 'Sesión no válida. Vuelve a iniciar sesión.',
        });
        return;
    }

    try {
        const pool = await getPool();
        const idUsuarioAdmin = await resolveUsuarioId(pool, username);

        if (!idUsuarioAdmin) {
            res.status(401).json({
                success: false,
                outResultCode: 50001,
                message: 'Usuario de sesión no encontrado',
            });
            return;
        }

        const result = await pool
            .request()
            .input('inIdUsuarioAdmin', sql.Int, idUsuarioAdmin)
            .input('inIpPostIn', sql.VarChar(64), ipPostIn)
            .input('inPostTime', sql.DateTime, postTime)
            .output('outResultCode', sql.Int)
            .execute('sp_RegresarAdmin');

        const outResultCode: number = Number(result.output.outResultCode ?? 50008);

        if (outResultCode !== 0) {
            res.status(outResultCode === 50013 ? 403 : 400).json({
                success: false,
                outResultCode,
                message: await getErrorMessage(outResultCode),
            });
            return;
        }

        res.status(200).json({
            success: true,
            outResultCode,
            message: 'Regreso a interfaz de administrador',
        });
    } catch (error) {
        console.error('Error en regresarAdmin:', error);
        res.status(500).json({
            success: false,
            outResultCode: 50008,
            message: 'Error interno del servidor',
        });
    }
}
