"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.authenticate = authenticate;
exports.requireAdmin = requireAdmin;
function decodeToken(token) {
    try {
        const payload = JSON.parse(Buffer.from(token, 'base64').toString('utf8'));
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
        return payload;
    }
    catch {
        return null;
    }
}
function authenticate(req, res, next) {
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
    req.user = user;
    next();
}
function requireAdmin(req, res, next) {
    const user = req.user;
    if (!user || user.tipo !== '1') {
        res.status(403).json({ success: false, message: 'Acceso solo para administradores' });
        return;
    }
    next();
}
