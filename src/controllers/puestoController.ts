import { Request, Response } from 'express';
import { getPool, sql } from '../db/connection';

type PuestoRow = {
    id: number;
    Nombre: string;
};

export async function getPuestos(_req: Request, res: Response): Promise<void> {
    try {
        const pool = await getPool();

        const result = await pool
            .request()
            .execute('sp_GetPuestos');

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
