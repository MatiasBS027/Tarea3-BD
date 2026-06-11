import { Request, Response } from 'express';
import { getPool, sql } from '../db/connection';
import type { IRecordSet } from 'mssql';

type BitacoraRow = {
    id: number;
    idTipoEvento: number;
    TipoEvento: string;
    idUsuario: number | null;
    Username: string | null;
    Descripcion: string;
    PostTime: string;
    IpPostIn: string;
};

export async function getTiposEvento(_req: Request, res: Response): Promise<void> {
    try {
        const pool = await getPool();
        const result = await pool
            .request()
            .execute('sp_GetTiposEvento');

        res.status(200).json({
            success: true,
            outResultCode: 0,
            data: result.recordset,
        });
    } catch (error) {
        console.error('Error en getTiposEvento:', error);
        res.status(500).json({
            success: false,
            outResultCode: 50008,
            message: 'Error interno del servidor',
        });
    }
}

export async function getBitacora(req: Request, res: Response): Promise<void> {
    try {
        const pool = await getPool();

        const result = await pool
            .request()
            .input('inIdTipoEvento', sql.Int, req.query.idTipoEvento ? Number(req.query.idTipoEvento) : null)
            .input('inIdUsuario', sql.Int, req.query.idUsuario ? Number(req.query.idUsuario) : null)
            .input('inFechaDesde', sql.DateTime, req.query.fechaDesde ? new Date(String(req.query.fechaDesde)) : null)
            .input('inFechaHasta', sql.DateTime, req.query.fechaHasta ? new Date(String(req.query.fechaHasta)) : null)
            .input('inIpPostIn', sql.VarChar(64), req.query.ip ? String(req.query.ip).trim() : null)
            .input('inPageSize', sql.Int, parseInt(String(req.query.pageSize)) || 50)
            .input('inPageNumber', sql.Int, parseInt(String(req.query.page)) || 1)
            .output('outResultCode', sql.Int)
            .execute('sp_GetBitacora');

        const recordsets = result.recordsets as IRecordSet<any>[];
        const outResultCode: number = result.output.outResultCode;
        const data = recordsets[0] as BitacoraRow[];
        const total = recordsets[1]?.[0]?.Total ?? 0;

        if (outResultCode !== 0) {
            res.status(500).json({
                success: false,
                outResultCode,
                message: 'Error al consultar la bitacora',
            });
            return;
        }

        res.status(200).json({
            success: true,
            outResultCode: 0,
            data,
            total,
        });
    } catch (error) {
        console.error('Error en getBitacora:', error);
        res.status(500).json({
            success: false,
            outResultCode: 50008,
            message: 'Error interno del servidor',
        });
    }
}
