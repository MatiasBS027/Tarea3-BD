import express from 'express';
import path from 'path';
import { getPool } from './db/connection';
import empleadosRouter from './routes/empleados';
import authRouter from './routes/auth';
import puestosRouter from './routes/puestos';
import tiposMovimientoRouter from './routes/tiposMovimiento';
import bitacoraRouter from './routes/bitacora';

const app = express();
const PORT = 3000;

// Middlewares
app.use(express.json());

// Servir archivos estaticos del frontend
app.use(express.static(path.join(__dirname, '../public')));

// Rutas API
app.use('/api/auth', authRouter);
app.use('/api/empleados', empleadosRouter);
app.use('/api/puestos', puestosRouter);
app.use('/api/tiposMovimiento', tiposMovimientoRouter);
app.use('/api/bitacora', bitacoraRouter);

// Iniciar servidor
async function startServer(): Promise<void> {
    try {
        await getPool();
        app.listen(PORT, () => {
            console.log(`Servidor corriendo en http://localhost:${PORT}`);
        });
    } catch (error) {
        console.error('Error al conectar a la BD:', error);
        process.exit(1);
    }
}

startServer();
