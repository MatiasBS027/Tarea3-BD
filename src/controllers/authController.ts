import { Request, Response } from 'express';
import { getPool, sql } from '../db/connection';
import { getErrorMessage } from '../utils/errorhelper';
import { resolveUsuarioId } from './usuarioHelper';

interface LoginResponse {
    success: boolean;
    outResultCode: number;
    message: string;
    token?: string;
    usuario?: {
        id: number;
        username: string;
    };
}

export class AuthController {
    async login(req: Request, res: Response): Promise<void> {
        try {
            const { username, password } = req.body;

            if (!username || !password) {
                const response: LoginResponse = {
                    success: false,
                    outResultCode: 50000,
                    message: 'Usuario y contrasena son requeridos',
                };

                res.status(400).json(response);
                return;
            }

            const pool = await getPool();
            const ipPostIn = req.ip ?? '';
            const postTime = new Date();

            const result = await pool
                .request()
                .input('inUsername', sql.VarChar(128), String(username))
                .input('inPassword', sql.VarChar(128), String(password))
                .input('inIpPostIn', sql.VarChar(64), ipPostIn)
                .input('inPostTime', sql.DateTime, postTime)
                .output('outResultCode', sql.Int)
                .execute('sp_Login');

            const outResultCode = Number(result.output.outResultCode ?? 50008);

            if (outResultCode === 0) {
                const idUsuario = await resolveUsuarioId(pool, String(username));
                const token = this.generateToken(String(username));

                const response: LoginResponse = {
                    success: true,
                    outResultCode: 0,
                    message: 'Autenticacion exitosa',
                    token,
                    usuario: {
                        id: idUsuario ?? 0,
                        username: String(username),
                    },
                };

                res.status(200).json(response);
                return;
            }

            const message = await getErrorMessage(outResultCode);

            if (outResultCode === 50003) {
                const response: LoginResponse = {
                    success: false,
                    outResultCode,
                    message,
                };

                res.status(403).json(response);
                return;
            }

            const response: LoginResponse = {
                success: false,
                outResultCode,
                message,
            };

            res.status(outResultCode === 50008 ? 500 : 401).json(response);
        } catch (error) {
            console.error('Error en login:', error);
            const response: LoginResponse = {
                success: false,
                outResultCode: 50008,
                message: 'Error interno del servidor',
            };

            res.status(500).json(response);
        }
    }

    async logout(req: Request, res: Response): Promise<void> {
        try {
            const authorization = String(req.headers.authorization ?? '');
            const token = authorization.startsWith('Bearer ') ? authorization.slice(7).trim() : '';

            if (!token) {
                res.status(400).json({
                    success: false,
                    message: 'Token de sesion requerido',
                });
                return;
            }

            const username = this.decodeUsernameFromToken(token);

            if (!username) {
                res.status(400).json({
                    success: false,
                    message: 'Token de sesion invalido',
                });
                return;
            }

            const pool = await getPool();
            const idUsuario = await resolveUsuarioId(pool, username);

            if (!idUsuario) {
                res.status(400).json({
                    success: false,
                    message: 'Usuario de sesion no encontrado',
                });
                return;
            }

            const result = await pool
                .request()
                .input('inIdUsuario', sql.Int, idUsuario)
                .input('inIpPostIn', sql.VarChar(64), req.ip ?? '')
                .input('inPostTime', sql.DateTime, new Date())
                .output('outResultCode', sql.Int)
                .execute('sp_Logout');

            const outResultCode = Number(result.output.outResultCode ?? 50008);

            if (outResultCode !== 0) {
                res.status(500).json({
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

    private generateToken(username: string): string {
        const payload = {
            username,
            iat: Date.now(),
            exp: Date.now() + 24 * 60 * 60 * 1000,
        };
        return Buffer.from(JSON.stringify(payload)).toString('base64');
    }

    private decodeUsernameFromToken(token: string): string | null {
        try {
            const payloadText = Buffer.from(token, 'base64').toString('utf8');
            const payload = JSON.parse(payloadText) as { username?: unknown };

            if (typeof payload.username !== 'string' || !payload.username.trim()) {
                return null;
            }

            return payload.username.trim();
        } catch {
            return null;
        }
    }
}
