import { Request, Response, NextFunction } from 'express';

export interface TokenPayload {
    id: number;
    username: string;
    tipo: string;
    iat: number;
    exp: number;
}

export interface AuthenticatedRequest extends Request {
    user?: TokenPayload;
}

/**
 * Decodifica un token base64 (JSON plano, sin HMAC — suficiente para alcance académico).
 * Retorna null si el token es inválido, está mal formado, o expiró.
 */
function decodeToken(token: string): TokenPayload | null {
    try {
        let parsed: Record<string, unknown>;
        try {
            const json = Buffer.from(token, 'base64').toString('utf8');
            parsed = JSON.parse(json);
        } catch {
            return null;
        }

        if (typeof parsed.id !== 'number' || parsed.id < 1) return null;
        if (typeof parsed.username !== 'string' || !parsed.username.trim()) return null;
        if (typeof parsed.tipo !== 'string') return null;
        if (parsed.tipo !== '1' && parsed.tipo !== '2') return null;
        if (typeof parsed.exp !== 'number' || Date.now() >= parsed.exp) return null;

        return {
            id: parsed.id,
            username: parsed.username.trim(),
            tipo: parsed.tipo,
            iat: typeof parsed.iat === 'number' ? parsed.iat : Date.now(),
            exp: parsed.exp,
        };
    } catch {
        return null;
    }
}

/**
 * Middleware de autenticación.
 * Extrae el token del header Authorization: Bearer <token>.
 * Si es válido, inyecta req.user y llama a next().
 * Si no, responde 401.
 */
export function authenticate(req: Request, res: Response, next: NextFunction): void {
    const auth = req.headers.authorization;
    if (!auth || !auth.startsWith('Bearer ')) {
        res.status(401).json({
            success: false,
            message: 'Token de autenticacion requerido. Use header: Authorization: Bearer <token>',
        });
        return;
    }

    const token = auth.slice(7).trim();
    if (!token) {
        res.status(401).json({ success: false, message: 'Token vacio' });
        return;
    }

    const user = decodeToken(token);
    if (!user) {
        res.status(401).json({
            success: false,
            message: 'Token invalido o expirado. Vuelva a iniciar sesion.',
        });
        return;
    }

    (req as AuthenticatedRequest).user = user;
    next();
}

/**
 * Middleware de autorización: solo administradores (tipo === '1').
 * Debe ejecutarse DESPUÉS de authenticate (req.user debe existir).
 */
export function requireAdmin(req: Request, res: Response, next: NextFunction): void {
    const user = (req as AuthenticatedRequest).user;

    if (!user) {
        res.status(401).json({
            success: false,
            message: 'Debe autenticarse antes de acceder a este recurso',
        });
        return;
    }

    if (user.tipo !== '1') {
        res.status(403).json({
            success: false,
            message: 'Acceso denegado. Solo administradores pueden acceder a este recurso.',
        });
        return;
    }

    next();
}
