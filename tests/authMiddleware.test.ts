/**
 * Tests unitarios para authMiddleware (decodeToken + requireAdmin).
 * No requiere BD — prueba lógica pura del token.
 * Ejecutar: node --test tests/authMiddleware.test.ts
 */

import assert from 'node:assert';
import { describe, it } from 'node:test';

// ─── Lógica bajo test (copia aislada de authMiddleware.ts) ───

interface TokenPayload {
    id: number;
    username: string;
    tipo: string;
    iat: number;
    exp: number;
}

function encodeToken(payload: Partial<TokenPayload>): string {
    return Buffer.from(JSON.stringify(payload)).toString('base64');
}

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

function requireAdminLogic(user: { tipo: string } | null): { status: number; message: string } | null {
    if (!user) {
        return { status: 401, message: 'Debe autenticarse antes de acceder a este recurso' };
    }
    if (user.tipo !== '1') {
        return { status: 403, message: 'Acceso denegado. Solo administradores pueden acceder a este recurso.' };
    }
    return null;
}

// ─── Tests ─────────────────────────────────────────────

describe('decodeToken', () => {

    it('decodifica token valido de admin', () => {
        const token = encodeToken({
            id: 1,
            username: 'admin',
            tipo: '1',
            iat: Date.now() - 1000,
            exp: Date.now() + 3600000,
        });
        const result = decodeToken(token);
        assert.notStrictEqual(result, null);
        assert.strictEqual(result!.id, 1);
        assert.strictEqual(result!.username, 'admin');
        assert.strictEqual(result!.tipo, '1');
    });

    it('decodifica token valido de empleado', () => {
        const token = encodeToken({
            id: 5,
            username: 'juan',
            tipo: '2',
            iat: Date.now() - 1000,
            exp: Date.now() + 3600000,
        });
        const result = decodeToken(token);
        assert.notStrictEqual(result, null);
        assert.strictEqual(result!.tipo, '2');
    });

    it('rechaza token expirado', () => {
        const token = encodeToken({
            id: 1,
            username: 'admin',
            tipo: '1',
            iat: Date.now() - 7200000,
            exp: Date.now() - 3600000,
        });
        assert.strictEqual(decodeToken(token), null);
    });

    it('rechaza base64 invalido', () => {
        assert.strictEqual(decodeToken('no-es-base64!!!'), null);
    });

    it('rechaza JSON mal formado dentro del base64', () => {
        const token = Buffer.from('{ broken json }').toString('base64');
        assert.strictEqual(decodeToken(token), null);
    });

    it('rechaza token sin id', () => {
        const token = encodeToken({ username: 'admin', tipo: '1' } as unknown as Partial<TokenPayload>);
        assert.strictEqual(decodeToken(token), null);
    });

    it('rechaza token con id 0', () => {
        const token = encodeToken({ id: 0, username: 'admin', tipo: '1', exp: Date.now() + 3600000 } as TokenPayload);
        assert.strictEqual(decodeToken(token), null);
    });

    it('rechaza token sin username', () => {
        const token = encodeToken({ id: 1, tipo: '1' } as unknown as Partial<TokenPayload>);
        assert.strictEqual(decodeToken(token), null);
    });

    it('rechaza token con username vacio', () => {
        const token = encodeToken({ id: 1, username: '   ', tipo: '1', exp: Date.now() + 3600000 } as TokenPayload);
        assert.strictEqual(decodeToken(token), null);
    });

    it('rechaza token con tipo invalido (ni 1 ni 2)', () => {
        const token = encodeToken({
            id: 1, username: 'admin', tipo: '3',
            exp: Date.now() + 3600000,
        } as TokenPayload);
        assert.strictEqual(decodeToken(token), null);
    });

    it('rechaza string vacio', () => {
        assert.strictEqual(decodeToken(''), null);
    });

    it('recupera iat por defecto si no esta presente', () => {
        const token = encodeToken({
            id: 1, username: 'admin', tipo: '1',
            exp: Date.now() + 3600000,
        } as TokenPayload);
        const result = decodeToken(token);
        assert.notStrictEqual(result, null);
        assert.ok(typeof result!.iat === 'number');
    });

    it('normaliza username con trim', () => {
        const token = encodeToken({
            id: 1, username: '  admin  ', tipo: '1',
            iat: Date.now(), exp: Date.now() + 3600000,
        });
        const result = decodeToken(token);
        assert.notStrictEqual(result, null);
        assert.strictEqual(result!.username, 'admin');
    });
});

describe('requireAdmin', () => {

    it('permite admin', () => {
        assert.strictEqual(requireAdminLogic({ tipo: '1' }), null);
    });

    it('deniega empleado (tipo 2)', () => {
        const err = requireAdminLogic({ tipo: '2' });
        assert.notStrictEqual(err, null);
        assert.strictEqual(err!.status, 403);
    });

    it('deniega usuario no autenticado (null)', () => {
        const err = requireAdminLogic(null);
        assert.notStrictEqual(err, null);
        assert.strictEqual(err!.status, 401);
    });
});
