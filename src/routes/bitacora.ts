import { Router } from 'express';
import { getTiposEvento, getBitacora } from '../controllers/bitacoraController';

const router = Router();

router.get('/tipos-evento', getTiposEvento);
router.get('/', getBitacora);

export default router;
