import { Router } from 'express';
import { getPuestos } from '../controllers/puestoController';

const router = Router();

router.get('/', getPuestos);

export default router;
