"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getTiposMovimiento = getTiposMovimiento;
const connection_1 = require("../db/connection");
const errorhelper_1 = require("../utils/errorhelper");
async function getTiposMovimiento(_req, res) {
    try {
        const pool = await (0, connection_1.getPool)();
        const result = await pool
            .request()
            .output('outResultCode', connection_1.sql.Int)
            .execute('sp_GetTiposMovimiento');
        const outResultCode = result.output.outResultCode;
        if (outResultCode !== 0) {
            res.status(400).json({
                success: false,
                outResultCode,
                message: await (0, errorhelper_1.getErrorMessage)(outResultCode)
            });
            return;
        }
        res.status(200).json({
            success: true,
            outResultCode,
            data: result.recordset
        });
    }
    catch (error) {
        console.error('Error en getTiposMovimiento:', error);
        res.status(500).json({
            success: false,
            outResultCode: 50008,
            message: 'Error interno del servidor'
        });
    }
}
