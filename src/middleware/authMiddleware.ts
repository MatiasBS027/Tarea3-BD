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

function decodeToken(token: string): TokenPayload | null {
    try {
        const payload = JSON.parse(
            Buffer.from(token, 'base64').toString('utf8')
        ) as Partial<TokenPayload>;

        if (typeof payload.username !== 'string' || !payload.username.trim()) {
            return null;
        }
        if (typeof payload.id !== 'number' || payload.id < 1) {
            return null;
        }
        if (typeof payload.tipo !== 'string' || !payload.tipo.trim()) {
            return null;
        }
        if (typeof payload.exp === 'number' && Date.now() > payload.exp) {
            return null;
        }

        return payload as TokenPayload;
    } catch {
        return null;
    }
}

export function authenticate(req: Request, res: Response, next: NextFunction): void {
    const auth = req.headers.authorization;
    if (!auth || !auth.startsWith('Bearer ')) {
        res.status(401).json({ success: false, message: 'Token de autenticacion requerido' });
        return;
    }

    const token = auth.slice(7).trim();
    const user = decodeToken(token);
    if (!user) {
        res.status(401).json({ success: false, message: 'Token invalido o expirado' });
        return;
    }

    (req as AuthenticatedRequest).user = user;
    next();
}

export function requireAdmin(req: Request, res: Response, next: NextFunction): void {
    const user = (req as AuthenticatedRequest).user;
    if (!user || user.tipo !== '1') {
        res.status(403).json({ success: false, message: 'Acceso solo para administradores' });
        return;
    }
    next();
}
