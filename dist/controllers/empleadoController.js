"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getEmpleados = getEmpleados;
exports.getEmpleadoById = getEmpleadoById;
exports.impersonarEmpleado = impersonarEmpleado;
exports.regresarAdmin = regresarAdmin;
exports.getEmpleadoByIdInt = getEmpleadoByIdInt;
const connection_1 = require("../db/connection");
const errorhelper_1 = require("../utils/errorhelper");
// GET /api/empleados
async function getEmpleados(req, res) {
    try {
        const filtro = String(req.query.filtro ?? '').trim();
        const pool = await (0, connection_1.getPool)();
        const result = await pool
            .request()
            .input('inNombre', connection_1.sql.VarChar(128), filtro)
            .output('outResultCode', connection_1.sql.Int)
            .execute('sp_GetEmpleados');
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
        console.error('Error en getEmpleados:', error);
        res.status(500).json({
            success: false,
            outResultCode: 50008,
            message: 'Error interno del servidor'
        });
    }
}
// GET /api/empleados/:valorDocumentoIdentidad
async function getEmpleadoById(req, res) {
    try {
        const valorDocumentoIdentidad = String(req.params.valorDocumentoIdentidad ?? '').trim();
        if (!valorDocumentoIdentidad) {
            res.status(400).json({
                success: false,
                message: 'valorDocumentoIdentidad es requerido'
            });
            return;
        }
        const pool = await (0, connection_1.getPool)();
        const result = await pool
            .request()
            .input('inValorDocumento', connection_1.sql.VarChar(32), valorDocumentoIdentidad)
            .output('outResultCode', connection_1.sql.Int)
            .execute('sp_GetEmpleadoById');
        const outResultCode = result.output.outResultCode;
        if (outResultCode !== 0) {
            res.status(404).json({
                success: false,
                outResultCode,
                message: await (0, errorhelper_1.getErrorMessage)(outResultCode)
            });
            return;
        }
        res.status(200).json({
            success: true,
            outResultCode,
            data: result.recordset?.[0] ?? null
        });
    }
    catch (error) {
        console.error('Error en getEmpleadoById:', error);
        res.status(500).json({
            success: false,
            outResultCode: 50008,
            message: 'Error interno del servidor'
        });
    }
}
// POST /api/empleados/impersonar
async function impersonarEmpleado(req, res) {
    try {
        const user = req.user;
        if (!user) {
            res.status(401).json({ success: false, message: 'No autenticado' });
            return;
        }
        const { valorDocumento } = req.body;
        if (!valorDocumento) {
            res.status(400).json({
                success: false,
                outResultCode: 50012,
                message: await (0, errorhelper_1.getErrorMessage)(50012)
            });
            return;
        }
        const pool = await (0, connection_1.getPool)();
        const result = await pool
            .request()
            .input('inValorDocumento', connection_1.sql.VarChar(32), String(valorDocumento))
            .input('inIdUsuarioAdmin', connection_1.sql.Int, user.id)
            .input('inIpPostIn', connection_1.sql.VarChar(64), req.ip ?? '')
            .input('inPostTime', connection_1.sql.DateTime, new Date())
            .output('outIdEmpleado', connection_1.sql.Int)
            .output('outResultCode', connection_1.sql.Int)
            .execute('sp_ImpersonarEmpleado');
        const outResultCode = result.output.outResultCode;
        const outIdEmpleado = result.output.outIdEmpleado ?? null;
        if (outResultCode !== 0) {
            res.status(outResultCode === 50012 ? 404 : 400).json({
                success: false,
                outResultCode,
                message: await (0, errorhelper_1.getErrorMessage)(outResultCode)
            });
            return;
        }
        res.status(200).json({
            success: true,
            outResultCode,
            data: { idEmpleado: outIdEmpleado }
        });
    }
    catch (error) {
        console.error('Error en impersonarEmpleado:', error);
        res.status(500).json({
            success: false,
            outResultCode: 50008,
            message: 'Error interno del servidor'
        });
    }
}
// POST /api/empleados/regresar-admin
async function regresarAdmin(req, res) {
    try {
        const user = req.user;
        if (!user) {
            res.status(401).json({ success: false, message: 'No autenticado' });
            return;
        }
        const pool = await (0, connection_1.getPool)();
        const result = await pool
            .request()
            .input('inIdUsuarioAdmin', connection_1.sql.Int, user.id)
            .input('inIpPostIn', connection_1.sql.VarChar(64), req.ip ?? '')
            .input('inPostTime', connection_1.sql.DateTime, new Date())
            .output('outResultCode', connection_1.sql.Int)
            .execute('sp_RegresarAdmin');
        const outResultCode = result.output.outResultCode;
        if (outResultCode !== 0) {
            res.status(outResultCode === 50013 ? 403 : 400).json({
                success: false,
                outResultCode,
                message: await (0, errorhelper_1.getErrorMessage)(outResultCode)
            });
            return;
        }
        res.status(200).json({
            success: true,
            outResultCode,
            message: 'Regreso a interfaz de administrador'
        });
    }
    catch (error) {
        console.error('Error en regresarAdmin:', error);
        res.status(500).json({
            success: false,
            outResultCode: 50008,
            message: 'Error interno del servidor'
        });
    }
}
// GET /api/empleados/by-id/:id
async function getEmpleadoByIdInt(req, res) {
    try {
        const id = Number(req.params.id);
        const pool = await (0, connection_1.getPool)();
        const result = await pool
            .request()
            .input('inId', connection_1.sql.Int, id)
            .output('outResultCode', connection_1.sql.Int)
            .execute('sp_GetEmpleadoByIdInt');
        const outResultCode = result.output.outResultCode;
        if (outResultCode !== 0) {
            const status = outResultCode === 50012 ? 404
                : outResultCode === 50008 ? 500
                    : 400;
            res.status(status).json({
                success: false,
                outResultCode,
                message: await (0, errorhelper_1.getErrorMessage)(outResultCode)
            });
            return;
        }
        const empleado = result.recordset?.[0] ?? null;
        if (!empleado) {
            res.status(404).json({
                success: false,
                outResultCode: 50012,
                message: await (0, errorhelper_1.getErrorMessage)(50012)
            });
            return;
        }
        res.status(200).json({
            success: true,
            outResultCode,
            data: empleado
        });
    }
    catch (error) {
        console.error('Error en getEmpleadoByIdInt:', error);
        res.status(500).json({
            success: false,
            outResultCode: 50008,
            message: 'Error interno del servidor'
        });
    }
}
