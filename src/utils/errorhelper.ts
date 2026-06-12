import { getPool, sql } from '../db/connection';

/**
 * Mapa de códigos de error (XML) a códigos HTTP.
 * Los códigos provienen del elemento <Error> en Datos.xml.
 * Cualquier código no listado se mapea a 400 (Bad Request).
 */
const ERROR_HTTP_MAP: Record<number, number> = {
    50001: 401, // Username no existe
    50002: 401, // Password no existe
    50003: 403, // Login deshabilitado
    50004: 409, // Empleado con ValorDocumentoIdentidad ya existe (inserción)
    50005: 409, // Empleado con mismo nombre ya existe (inserción)
    50006: 409, // Empleado con ValorDocumentoIdentidad ya existe (actualización)
    50007: 409, // Empleado con mismo nombre ya existe (actualización)
    50008: 500, // Error de base de datos
    50009: 400, // Nombre de empleado no alfabético
    50010: 400, // Valor de documento de identidad no alfabético
    50011: 400, // Monto del movimiento rechazado (saldo negativo)
    50012: 404, // Empleado no existe o está inactivo
    50013: 403, // Usuario no es administrador
};

/**
 * Retorna el código HTTP correspondiente a un código de error del negocio.
 */
export function getHttpStatus(outResultCode: number): number {
    return ERROR_HTTP_MAP[outResultCode] ?? 400;
}

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
