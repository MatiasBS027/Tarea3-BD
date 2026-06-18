import express from 'express';
import path from 'path';
import { getPool } from './db/connection';
import { authenticate } from './middleware/authMiddleware';
import empleadosRouter from './routes/empleados';
import authRouter from './routes/auth';
import puestosRouter from './routes/puestos';
import tiposMovimientoRouter from './routes/tiposMovimiento';
import bitacoraRouter from './routes/bitacora';
import planillaRouter from './routes/planilla';

const app = express();
const PORT = 3000;

app.set('trust proxy', 1);
app.use(express.json());

app.use(express.static(path.join(__dirname, '../public')));

// Health check (no requiere auth)
app.get('/health', (_req, res) => {
    res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Auth routes (login no requiere token)
app.use('/api/auth', authRouter);

// Rutas protegidas — requieren token valido
app.use('/api/empleados', authenticate, empleadosRouter);
app.use('/api/puestos', authenticate, puestosRouter);
app.use('/api/tiposMovimiento', authenticate, tiposMovimientoRouter);
app.use('/api/bitacora', authenticate, bitacoraRouter);
app.use('/api/planilla', authenticate, planillaRouter);

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