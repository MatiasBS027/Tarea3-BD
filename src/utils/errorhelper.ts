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
            .input('inUsername', sql.NVarChar(128), username)
            .execute('sp_GetLastDbError');

        return result.recordset?.[0]?.Message ?? null;
    } catch (error) {
        console.error('Error al obtener DBError para usuario:', error);
        return null;
    }
}
