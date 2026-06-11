import { Router } from 'express';
import { getTiposEvento, getBitacora } from '../controllers/bitacoraController';
import { requireAdmin } from '../middleware/authMiddleware';
import { validateGetBitacora } from '../middleware/validation';

const router = Router();

router.use(requireAdmin);
router.get('/tipos-evento', getTiposEvento);
router.get('/', validateGetBitacora, getBitacora);

export default router;
