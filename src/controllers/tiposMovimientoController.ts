import { Request, Response } from 'express';
import { getPool, sql } from '../db/connection';
import { getErrorMessage, getHttpStatus } from '../utils/errorhelper';

export async function getTiposMovimiento(_req: Request, res: Response): Promise<void> {
    try {
        const pool = await getPool();

        const result = await pool
            .request()
            .output('outResultCode', sql.Int)
            .execute('sp_GetTiposMovimiento');

        const outResultCode: number = result.output.outResultCode;

        if (outResultCode !== 0) {
            res.status(getHttpStatus(outResultCode)).json({
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
        console.error('Error en getTiposMovimiento:', error);
        res.status(500).json({
            success: false,
            outResultCode: 50008,
            message: 'Error interno del servidor'
        });
    }
}
