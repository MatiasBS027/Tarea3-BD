import { Request, Response } from 'express';
import { getPool, sql } from '../db/connection';
import { getErrorMessage, getLastDbErrorForUser } from '../utils/errorhelper';

// GET /api/movimientos/:valorDocumentoIdentidad
// Llama sp_GetMovimientos y retorna todos los movimientos del empleado
export async function getMovimientos(req: Request, res: Response): Promise<void> {
    try {
        const valorDocumentoIdentidad = String(req.params.valorDocumentoIdentidad ?? '').trim();

        if (!valorDocumentoIdentidad) {
            res.status(400).json({
                success: false,
                message: 'valorDocumentoIdentidad es requerido'
            })
            return;
        }

        const pool = await getPool();

        const result = await pool
            .request()
                .input('inValorDocumentoIdentidad', sql.NVarChar(32), valorDocumentoIdentidad)
            .output('outResultCode', sql.Int)
            .execute('sp_GetMovimientos');

        const outResultCode: number = result.output.outResultCode;

        if (outResultCode !== 0) {
            res.status(400).json({
                success: false,
                outResultCode,
                message: await getErrorMessage(outResultCode)
            })
            return;
        }

        res.status(200).json({
            success: true,
            outResultCode,
            data: result.recordset
        });
    
    } catch (error) {
        console.error('Error en getMovimientos:', error);
        res.status(500).json ({
            success: false,
            outResultCode: 50008,
            message: 'Error interno del servidor'
        });
    }
}

// POST /api/movimientos
// Llama sp_InsertMovimiento para agregar un nuevo movimiento
export async function insertMovimiento(req: Request, res: Response): Promise<void> {
    const { valorDocumentoIdentidad, nombreTipoMovimiento, monto, fecha } = req.body;

    if (!valorDocumentoIdentidad || !nombreTipoMovimiento || monto === undefined || !fecha){
        res.status(400).json({
            success: false,
            message: 'valorDocumentoIdentidad, nombreTipoMovimiento, monto y fecha son requeridos'
        });
        return;
    }

    try {
        const username = String(req.headers['x-username'] ?? 'UsuarioScripts')
        const ipPostIn = req.ip ?? '';
        const postTime = new Date();

        const pool = await getPool();

        const result = await pool
            .request()
                .input('inValorDocumentoIdentidad', sql.NVarChar(32), String(valorDocumentoIdentidad))
            .input('inNombreTipoMovimiento', sql.VarChar(64), String(nombreTipoMovimiento))
            .input('inMonto', sql.Decimal(10, 2), Number(monto))
            .input('inUsername', sql.VarChar(64), username)
            .input('inIpPostIn', sql.VarChar(32), ipPostIn)
            .input('inPostTime', sql.DateTime, postTime)
            .input('inFecha', sql.Date, new Date(fecha))
            .output('outResultCode', sql.Int)
            .execute('sp_InsertMovimiento');

        const outResultCode: number = result.output.outResultCode;

        if (outResultCode !== 0) {
            // Try to get DB-level error details for debugging
            const dbErr = await getLastDbErrorForUser(username);
            const friendly = await getErrorMessage(outResultCode);

            res.status(400).json({
                success: false,
                outResultCode,
                message: dbErr ?? friendly
            });
            return;
        }

        res.status(201).json({
            success: true,
            outResultCode,
            message: 'Movimiento insertado exitosamente'
        });
        
    } catch (error) {
        console.error('Error en insertMovimiento:', error);
        res.status(500).json ({
            success: false,
            outResultCode: 50008,
            message: 'Error interno del servidor'
        });
    }
}