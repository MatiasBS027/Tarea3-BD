import { Router } from 'express';
import { getPuestos } from '../controllers/empleadoController';

const router = Router();

// GET /api/puestos -> lista los puestos disponibles para el select de edición.
router.get('/', getPuestos);

export default router;