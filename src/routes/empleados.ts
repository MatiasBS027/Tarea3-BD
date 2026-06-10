import { Router } from 'express';
import { deleteEmpleado, getEmpleadoById, getEmpleadoByIdInt, getEmpleados, impersonarEmpleado, insertEmpleado, regresarAdmin, updateEmpleado } from '../controllers/empleadoController';

const router = Router();

// GET  /api/empleados -> llama a getEmpleados
router.get('/', getEmpleados);

// POST /api/empleados/impersonar -> impersonar un empleado (R03)
router.post('/impersonar', impersonarEmpleado);

// POST /api/empleados/regresar-admin -> volver a admin (R06)
router.post('/regresar-admin', regresarAdmin);

// GET /api/empleados/by-id/:id -> buscar empleado por id INT (vista impersonación)
router.get('/by-id/:id', getEmpleadoByIdInt);

// GET  /api/empleados/:valorDocumentoIdentidad -> consulta un empleado
router.get('/:valorDocumentoIdentidad', getEmpleadoById);

// PATCH /api/empleados/:valorDocumentoIdentidad -> actualiza un empleado
router.patch('/:valorDocumentoIdentidad', updateEmpleado);

// DELETE /api/empleados/:valorDocumentoIdentidad -> borrado lógico o intento de borrado
router.delete('/:valorDocumentoIdentidad', deleteEmpleado);

// POST /api/empleados -> llama a insertEmpleado
router.post('/', insertEmpleado);

export default router;