import { Router } from 'express';
import { getMovimientos, insertMovimiento } from '../controllers/movimientoController';

const router = Router();

// GET /api/movimientos/:valorDocumentoIdentidad para lista movimientos de un empleado
router.get('/:valorDocumentoIdentidad', getMovimientos);

// Post /api/movimientos para agregar un nuevo movimiento
router.post('/', insertMovimiento);

export default router;