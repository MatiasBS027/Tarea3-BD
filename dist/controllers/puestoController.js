"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getPuestos = getPuestos;
const connection_1 = require("../db/connection");
async function getPuestos(_req, res) {
    try {
        const pool = await (0, connection_1.getPool)();
        const result = await pool
            .request()
            .execute('sp_GetPuestos');
        res.status(200).json({
            success: true,
            outResultCode: 0,
            data: result.recordset
        });
    }
    catch (error) {
        console.error('Error en getPuestos:', error);
        res.status(500).json({
            success: false,
            outResultCode: 50008,
            message: 'Error interno del servidor'
        });
    }
}
