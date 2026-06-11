import { Router } from 'express';
import { getTiposMovimiento } from '../controllers/tiposMovimientoController';

const router = Router();

router.get('/', getTiposMovimiento);

export default router;
