"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getTiposEvento = getTiposEvento;
exports.getBitacora = getBitacora;
const connection_1 = require("../db/connection");
async function getTiposEvento(_req, res) {
    try {
        const pool = await (0, connection_1.getPool)();
        const result = await pool
            .request()
            .execute('sp_GetTiposEvento');
        res.status(200).json({
            success: true,
            outResultCode: 0,
            data: result.recordset,
        });
    }
    catch (error) {
        console.error('Error en getTiposEvento:', error);
        res.status(500).json({
            success: false,
            outResultCode: 50008,
            message: 'Error interno del servidor',
        });
    }
}
async function getBitacora(req, res) {
    try {
        const pool = await (0, connection_1.getPool)();
        const result = await pool
            .request()
            .input('inIdTipoEvento', connection_1.sql.Int, req.query.idTipoEvento ? Number(req.query.idTipoEvento) : null)
            .input('inIdUsuario', connection_1.sql.Int, req.query.idUsuario ? Number(req.query.idUsuario) : null)
            .input('inFechaDesde', connection_1.sql.DateTime, req.query.fechaDesde ? new Date(String(req.query.fechaDesde)) : null)
            .input('inFechaHasta', connection_1.sql.DateTime, req.query.fechaHasta ? new Date(String(req.query.fechaHasta)) : null)
            .input('inIpPostIn', connection_1.sql.VarChar(64), req.query.ip ? String(req.query.ip).trim() : null)
            .input('inPageSize', connection_1.sql.Int, parseInt(String(req.query.pageSize)) || 50)
            .input('inPageNumber', connection_1.sql.Int, parseInt(String(req.query.page)) || 1)
            .output('outResultCode', connection_1.sql.Int)
            .execute('sp_GetBitacora');
        const recordsets = result.recordsets;
        const outResultCode = result.output.outResultCode;
        const data = recordsets[0];
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
    }
    catch (error) {
        console.error('Error en getBitacora:', error);
        res.status(500).json({
            success: false,
            outResultCode: 50008,
            message: 'Error interno del servidor',
        });
    }
}
