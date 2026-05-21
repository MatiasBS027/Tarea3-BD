/**
* controllers/authController.ts
* Controlador de autenticación
* 
* Aquí va la lógica de negocio del login:
* - Validar inputs
* - Llamar al SP de login
* - Generar token de sesión
* - Devolver respuesta
*/

import { Request, Response } from 'express';
import { getPool, sql } from '../db/connection';
import { getErrorMessage } from '../utils/errorhelper';

/**
* Interfaz para la respuesta de login
*/
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
/**
* Manejar petición POST /api/auth/login
* 
* Lógica:
* 1. Extraer username y password del body
* 2. Validar que no estén vacíos
* 3. Llamar al SP sp_Login con reintentos
* 4. Si es exitoso, generar token JWT
* 5. Devolver respuesta
* 
* El SP sp_Login va a:
* - Validar credenciales
* - Contar reintentos fallidos
* - Si hay 5+ reintentos en 20 min, bloquear por 10 min
* - Devolver outResultCode = 0 si es exitoso
*/
async login(req: Request, res: Response): Promise<void> {
    try {
        const { username, password } = req.body;

        if (!username || !password) {
            const response: LoginResponse = {
                success: false,
                outResultCode: 50000,
                message: 'Usuario y contraseña son requeridos',
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
            const usuarioResult = await pool
                .request()
                .input('inUsername', sql.VarChar(128), String(username))
                .query('SELECT TOP 1 id, Username FROM dbo.Usuario WHERE Username = @inUsername');

            const usuario = usuarioResult.recordset?.[0];
            const token = this.generateToken(String(username));

            const response: LoginResponse = {
                success: true,
                outResultCode: 0,
                message: 'Autenticación exitosa',
                token,
                usuario: {
                    id: Number(usuario?.id ?? 0),
                    username: String(usuario?.Username ?? username),
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

/**
* Manejar petición POST /api/auth/logout
* 
* Simplemente invalida la sesión del usuario
* En un caso real, podríamos agregar el token a una "blacklist"
*/
async logout(req: Request, res: Response): Promise<void> {
    try {
        const authorization = String(req.headers.authorization ?? '');
        const token = authorization.startsWith('Bearer ') ? authorization.slice(7).trim() : '';

        if (!token) {
            res.status(400).json({
                success: false,
                message: 'Token de sesión requerido',
            });
            return;
        }

        const username = this.decodeUsernameFromToken(token);

        if (!username) {
            res.status(400).json({
                success: false,
                message: 'Token de sesión inválido',
            });
            return;
        }

        const pool = await getPool();
        const usuarioResult = await pool
            .request()
            .input('inUsername', sql.VarChar(128), username)
            .query('SELECT TOP 1 id FROM dbo.Usuario WHERE Username = @inUsername');

        const idUsuario = usuarioResult.recordset?.[0]?.id;

        if (!idUsuario) {
            res.status(400).json({
                success: false,
                message: 'Usuario de sesión no encontrado',
            });
            return;
        }

        const result = await pool
            .request()
            .input('inIdUsuario', sql.Int, Number(idUsuario))
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
            message: 'Sesión cerrada correctamente',
        });
    } catch (error) {
        console.error('Error en logout:', error);
        res.status(500).json({
            success: false,
            message: 'Error al cerrar sesión',
        });
    }
}

/**
* Generar un token JWT simple
* 
* NOTA: En producción, usarías la librería 'jsonwebtoken'
* Por ahora, es un placeholder
* 
* @param username Nombre del usuario autenticado
* @returns Token como string
*/
private generateToken(username: string): string {
    // PLACEHOLDER: Implementar JWT cuando lo requieras
    // Por ahora, simplemente retorna un string base64
    const payload = {
        username,
        iat: Date.now(),
      exp: Date.now() + 24 * 60 * 60 * 1000, // 24 horas
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
