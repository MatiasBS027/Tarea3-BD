import { Router } from 'express';
import {
    getEmpleados, getEmpleadoById, getEmpleadoByIdInt,
    impersonarEmpleado, regresarAdmin
} from '../controllers/empleadoController';
import { requireAdmin } from '../middleware/authMiddleware';
import {
    validateGetEmpleados,
    validateGetEmpleadoByDoc,
    validateImpersonar,
    validateGetEmpleadoByIdInt,
} from '../middleware/validation';

const router = Router();

// Todas las rutas de empleados requieren ser admin
router.use(requireAdmin);

router.get('/', validateGetEmpleados, getEmpleados);
router.post('/impersonar', validateImpersonar, impersonarEmpleado);
router.post('/regresar-admin', regresarAdmin);
router.get('/by-id/:id', validateGetEmpleadoByIdInt, getEmpleadoByIdInt);
router.get('/:valorDocumentoIdentidad', validateGetEmpleadoByDoc, getEmpleadoById);

export default router;
