import { Router } from 'express';
import {
    getEmpleados, getEmpleadoById, getEmpleadoByIdInt,
    impersonarEmpleado, regresarAdmin
} from '../controllers/empleadoController';
import { authenticate, requireAdmin } from '../middleware/authMiddleware';
import {
    validateGetEmpleados,
    validateGetEmpleadoByDoc,
    validateImpersonar,
    validateGetEmpleadoByIdInt,
} from '../middleware/validation';

const router = Router();

// by-id/:id: cualquier usuario autenticado puede consultar su propio perfil
router.get('/by-id/:id', authenticate, validateGetEmpleadoByIdInt, getEmpleadoByIdInt);

// El resto de rutas requieren ser admin
router.use(requireAdmin);

router.get('/', validateGetEmpleados, getEmpleados);
router.post('/impersonar', validateImpersonar, impersonarEmpleado);
router.post('/regresar-admin', regresarAdmin);
router.get('/:valorDocumentoIdentidad', validateGetEmpleadoByDoc, getEmpleadoById);

export default router;
