import { Request, Response } from 'express';
import { getPool, sql } from '../db/connection';
import { getErrorMessage, getHttpStatus } from '../utils/errorhelper';
import { AuthenticatedRequest } from '../middleware/authMiddleware';

interface LoginResponse {
    success: boolean;
    outResultCode: number;
    message: string;
    token?: string;
    usuario?: {
        id: number;
        username: string;
        tipo: string;
        idEmpleado?: number | null;
    };
}

export class AuthController {
    async login(req: Request, res: Response): Promise<void> {
        try {
            const { username, password } = req.body;

            if (!username || !password) {
                res.status(400).json({
                    success: false,
                    outResultCode: 50000,
                    message: 'Usuario y contrasena son requeridos',
                } as LoginResponse);
                return;
            }

            const pool = await getPool();

            const result = await pool
                .request()
                .input('inUsername', sql.VarChar(128), String(username))
                .input('inPassword', sql.VarChar(128), String(password))
                .input('inIpPostIn', sql.VarChar(64), req.ip ?? '')
                .input('inPostTime', sql.DateTime, new Date())
                .output('outResultCode', sql.Int)
                .output('outIdUsuario', sql.Int)
                .output('outTipo', sql.VarChar(2))
                .execute('sp_Login');

            const outResultCode = Number(result.output.outResultCode ?? 50008);

            if (outResultCode === 0) {
                const idUsuario = result.output.outIdUsuario;
                const tipo = String(result.output.outTipo ?? '2');
                const token = this.generateToken(String(username), Number(idUsuario), tipo);

                // Si es empleado (tipo 2), obtener su idEmpleado
                let idEmpleado: number | null = null;
                if (tipo === '2') {
                    const empResult = await pool
                        .request()
                        .input('inIdUsuario', sql.Int, Number(idUsuario))
                        .query('SELECT id FROM dbo.Empleado WHERE idUsuario = @inIdUsuario AND Activo = 1');
                    idEmpleado = empResult.recordset?.[0]?.id ?? null;
                }

                res.status(200).json({
                    success: true,
                    outResultCode: 0,
                    message: 'Autenticacion exitosa',
                    token,
                    usuario: {
                        id: Number(idUsuario),
                        username: String(username),
                        tipo,
                        idEmpleado,
                    },
                } as LoginResponse);
                return;
            }

            const message = await getErrorMessage(outResultCode);

            res.status(getHttpStatus(outResultCode)).json({
                success: false,
                outResultCode,
                message,
            } as LoginResponse);
        } catch (error) {
            console.error('Error en login:', error);
            res.status(500).json({
                success: false,
                outResultCode: 50008,
                message: 'Error interno del servidor',
            } as LoginResponse);
        }
    }

    async logout(req: Request, res: Response): Promise<void> {
        try {
            const user = (req as AuthenticatedRequest).user;
            if (!user) {
                res.status(401).json({
                    success: false,
                    message: 'No autenticado',
                });
                return;
            }

            const pool = await getPool();

            const result = await pool
                .request()
                .input('inIdUsuario', sql.Int, user.id)
                .input('inIpPostIn', sql.VarChar(64), req.ip ?? '')
                .input('inPostTime', sql.DateTime, new Date())
                .output('outResultCode', sql.Int)
                .execute('sp_Logout');

            const outResultCode = Number(result.output.outResultCode ?? 50008);

            if (outResultCode !== 0) {
                res.status(getHttpStatus(outResultCode)).json({
                    success: false,
                    outResultCode,
                    message: await getErrorMessage(outResultCode),
                });
                return;
            }

            res.status(200).json({
                success: true,
                message: 'Sesion cerrada correctamente',
            });
        } catch (error) {
            console.error('Error en logout:', error);
            res.status(500).json({
                success: false,
                message: 'Error al cerrar sesion',
            });
        }
    }

    private generateToken(username: string, id: number, tipo: string): string {
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