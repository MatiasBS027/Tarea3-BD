import { Router } from 'express';
import { getTiposMovimiento } from '../controllers/empleadoController';

const router = Router();

// GET /api/tiposMovimiento para lista de los tipos de movimientos para el SELECT
router.get('/', getTiposMovimiento);

export default router;