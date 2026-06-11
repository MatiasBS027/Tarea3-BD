"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.sql = void 0;
exports.getPool = getPool;
const mssql_1 = __importDefault(require("mssql"));
exports.sql = mssql_1.default;
const dbConfig = {
    user: 'sa',
    password: 'Bd2Tarea2026!',
    server: 'localhost',
    port: 1433,
    database: 'PlanillaDB',
    options: {
        encrypt: false,
        trustServerCertificate: true,
    },
};
let pool = null;
async function getPool() {
    if (pool && pool.connected) {
        return pool;
    }
    pool = await mssql_1.default.connect(dbConfig);
    console.log('Conexión a SQL Server exitosa');
    return pool;
}
