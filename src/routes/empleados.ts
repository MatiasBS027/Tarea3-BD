import { Router } from 'express';
import {
    getEmpleados, getEmpleadoById, getEmpleadoByIdInt,
    impersonarEmpleado, regresarAdmin,
    insertEmpleado, updateEmpleado, deleteEmpleado
} from '../controllers/empleadoController';
import { authenticate, requireAdmin } from '../middleware/authMiddleware';
import {
    validateGetEmpleados,
    validateGetEmpleadoByDoc,
    validateImpersonar,
    validateGetEmpleadoByIdInt,
    validateInsertEmpleado,
    validateUpdateEmpleado,
    validateDeleteEmpleado,
} from '../middleware/validation';

const router = Router();

// by-id/:id: cualquier usuario autenticado puede consultar su propio perfil
router.get('/by-id/:id', authenticate, validateGetEmpleadoByIdInt, getEmpleadoByIdInt);

// El resto de rutas requieren ser admin
router.use(requireAdmin);

router.get('/', validateGetEmpleados, getEmpleados);
router.post('/', validateInsertEmpleado, insertEmpleado);
router.patch('/:id', validateUpdateEmpleado, updateEmpleado);
router.delete('/:id', validateDeleteEmpleado, deleteEmpleado);
router.post('/impersonar', validateImpersonar, impersonarEmpleado);
router.post('/regresar-admin', regresarAdmin);
router.get('/:valorDocumentoIdentidad', validateGetEmpleadoByDoc, getEmpleadoById);

export default router;
