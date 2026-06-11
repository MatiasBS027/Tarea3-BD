"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getErrorMessage = getErrorMessage;
exports.getLastDbErrorForUser = getLastDbErrorForUser;
const connection_1 = require("../db/connection");
async function getErrorMessage(codigo) {
    try {
        const pool = await (0, connection_1.getPool)();
        const result = await pool
            .request()
            .input('inCodigo', connection_1.sql.Int, codigo)
            .output('outResultCode', connection_1.sql.Int)
            .execute('sp_GetError');
        return result.recordset?.[0]?.Descripcion ?? 'Error desconocido';
    }
    catch (error) {
        console.error('Error al obtener el mensaje de error:', error);
        return 'Error desconocido';
    }
}
async function getLastDbErrorForUser(username) {
    try {
        const pool = await (0, connection_1.getPool)();
        const result = await pool
            .request()
            .input('inUsername', connection_1.sql.NVarChar(128), username)
            .execute('sp_GetLastDbError');
        return result.recordset?.[0]?.Message ?? null;
    }
    catch (error) {
        console.error('Error al obtener DBError para usuario:', error);
        return null;
    }
}
