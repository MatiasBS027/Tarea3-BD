import sql from 'mssql';

const dbConfig: sql.config = {
    user: 'sa',
    password: 'Bd2Tarea2026!',
    server: '25.0.119.25',
    port: 1433,
    database: 'PlanillaDB',
    options: {
    encrypt: false,
    trustServerCertificate: true,
    },
};

let pool: sql.ConnectionPool | null = null;

export async function getPool(): Promise<sql.ConnectionPool> {
    if (pool && pool.connected) {
    return pool;
    }
    pool = await sql.connect(dbConfig);
    console.log('Conexión a SQL Server exitosa');
    return pool;
}

export { sql };

