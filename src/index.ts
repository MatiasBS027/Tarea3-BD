import express from 'express';
import path from 'path';
import { getPool } from './db/connection';
import empleadosRouter from './routes/empleados';
import authRouter from './routes/auth';
import movimientosRouter from './routes/movimientos';
import puestosRouter from './routes/puestos';
import tiposMovimientoRouter from './routes/tiposMovimiento';

const app = express();
const PORT = 3000;

// Middlewares
app.use(express.json());

// Servir archivos estáticos del frontend
app.use(express.static(path.join(__dirname, '../public')));

// Rutas API
app.use('/api/auth', authRouter);
app.use('/api/empleados', empleadosRouter);
app.use('/api/movimientos', movimientosRouter);
app.use('/api/puestos', puestosRouter);
app.use('/api/tiposMovimiento', tiposMovimientoRouter);

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