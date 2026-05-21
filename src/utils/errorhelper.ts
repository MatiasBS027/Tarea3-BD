import { getPool, sql } from '../db/connection';

export async function getErrorMessage(codigo: number): Promise<string> {
    try {
        const pool = await getPool();

        const result = await pool
            .request()
            .input('inCodigo', sql.Int, codigo)
            .output('outResultCode', sql.Int)
            .execute('sp_GetError');

        return result.recordset?.[0]?.Descripcion ?? 'Error desconocido';
        
    } catch (error) {
        console.error('Error al obtener el mensaje de error:', error);
        return 'Error desconocido';
    }
}

export async function getLastDbErrorForUser(username: string): Promise<string | null> {
    try {
        const pool = await getPool();

        const result = await pool
            .request()
            .input('inUser', sql.NVarChar(128), username)
            .query(`SELECT TOP 1 [Message], DateTime FROM dbo.DBError WHERE UserName = @inUser ORDER BY DateTime DESC`);

        const msg = result.recordset?.[0]?.Message ?? null;
        if (msg) return msg;

        // Fallback: return the last DBError overall if none for this user
        const fallback = await pool
            .request()
            .query(`SELECT TOP 1 [Message], DateTime FROM dbo.DBError ORDER BY DateTime DESC`);

        return fallback.recordset?.[0]?.Message ?? null;
    } catch (error) {
        console.error('Error al obtener DBError para usuario:', error);
        return null;
    }
}