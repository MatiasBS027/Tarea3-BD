import { Router } from 'express';
import { getEmpleados, getEmpleadoById, getEmpleadoByIdInt, impersonarEmpleado, regresarAdmin } from '../controllers/empleadoController';

const router = Router();

// GET  /api/empleados -> llama a getEmpleados
router.get('/', getEmpleados);

// POST /api/empleados/impersonar -> impersonar un empleado (R03)
router.post('/impersonar', impersonarEmpleado);

// POST /api/empleados/regresar-admin -> volver a admin (R06)
router.post('/regresar-admin', regresarAdmin);

// GET /api/empleados/by-id/:id -> buscar empleado por id INT (vista impersonacion)
router.get('/by-id/:id', getEmpleadoByIdInt);

// GET  /api/empleados/:valorDocumentoIdentidad -> consulta un empleado
router.get('/:valorDocumentoIdentidad', getEmpleadoById);

export default router;
