import { getPool, sql } from '../db/connection';

export async function resolveUsuarioId(
    pool: Awaited<ReturnType<typeof getPool>>,
    username: string
): Promise<number | null> {
    const result = await pool
        .request()
        .input('inUsername', sql.VarChar(128), username)
        .execute('sp_GetUsuarioId');

    return result.recordset?.[0]?.id ?? null;
}
