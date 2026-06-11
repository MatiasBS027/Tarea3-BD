"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.AuthController = void 0;
const connection_1 = require("../db/connection");
const errorhelper_1 = require("../utils/errorhelper");
class AuthController {
    async login(req, res) {
        try {
            const { username, password } = req.body;
            if (!username || !password) {
                res.status(400).json({
                    success: false,
                    outResultCode: 50000,
                    message: 'Usuario y contrasena son requeridos',
                });
                return;
            }
            const pool = await (0, connection_1.getPool)();
            const result = await pool
                .request()
                .input('inUsername', connection_1.sql.VarChar(128), String(username))
                .input('inPassword', connection_1.sql.VarChar(128), String(password))
                .input('inIpPostIn', connection_1.sql.VarChar(64), req.ip ?? '')
                .input('inPostTime', connection_1.sql.DateTime, new Date())
                .output('outResultCode', connection_1.sql.Int)
                .output('outIdUsuario', connection_1.sql.Int)
                .output('outTipo', connection_1.sql.VarChar(2))
                .execute('sp_Login');
            const outResultCode = Number(result.output.outResultCode ?? 50008);
            if (outResultCode === 0) {
                const idUsuario = result.output.outIdUsuario;
                const tipo = String(result.output.outTipo ?? '2');
                const token = this.generateToken(String(username), Number(idUsuario), tipo);
                res.status(200).json({
                    success: true,
                    outResultCode: 0,
                    message: 'Autenticacion exitosa',
                    token,
                    usuario: {
                        id: Number(idUsuario),
                        username: String(username),
                        tipo,
                    },
                });
                return;
            }
            const message = await (0, errorhelper_1.getErrorMessage)(outResultCode);
            if (outResultCode === 50003) {
                res.status(403).json({
                    success: false,
                    outResultCode,
                    message,
                });
                return;
            }
            res.status(outResultCode === 50008 ? 500 : 401).json({
                success: false,
                outResultCode,
                message,
            });
        }
        catch (error) {
            console.error('Error en login:', error);
            res.status(500).json({
                success: false,
                outResultCode: 50008,
                message: 'Error interno del servidor',
            });
        }
    }
    async logout(req, res) {
        try {
            const user = req.user;
            if (!user) {
                res.status(401).json({
                    success: false,
                    message: 'No autenticado',
                });
                return;
            }
            const pool = await (0, connection_1.getPool)();
            const result = await pool
                .request()
                .input('inIdUsuario', connection_1.sql.Int, user.id)
                .input('inIpPostIn', connection_1.sql.VarChar(64), req.ip ?? '')
                .input('inPostTime', connection_1.sql.DateTime, new Date())
                .output('outResultCode', connection_1.sql.Int)
                .execute('sp_Logout');
            const outResultCode = Number(result.output.outResultCode ?? 50008);
            if (outResultCode !== 0) {
                res.status(500).json({
                    success: false,
                    outResultCode,
                    message: await (0, errorhelper_1.getErrorMessage)(outResultCode),
                });
                return;
            }
            res.status(200).json({
                success: true,
                message: 'Sesion cerrada correctamente',
            });
        }
        catch (error) {
            console.error('Error en logout:', error);
            res.status(500).json({
                success: false,
                message: 'Error al cerrar sesion',
            });
        }
    }
    generateToken(username, id, tipo) {
        const payload = {
            id,
            username,
            tipo,
            iat: Date.now(),
            exp: Date.now() + 24 * 60 * 60 * 1000,
        };
        return Buffer.from(JSON.stringify(payload)).toString('base64');
    }
}
exports.AuthController = AuthController;
