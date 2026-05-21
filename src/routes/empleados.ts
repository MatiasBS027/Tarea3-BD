import { Router } from 'express';
import { deleteEmpleado, getEmpleadoById, getEmpleados, insertEmpleado, updateEmpleado } from '../controllers/empleadoController';

const router = Router();

// GET  /api/empleados -> llama a getEmpleados
router.get('/', getEmpleados);

// GET  /api/empleados/:valorDocumentoIdentidad -> consulta un empleado
router.get('/:valorDocumentoIdentidad', getEmpleadoById);

// PATCH /api/empleados/:valorDocumentoIdentidad -> actualiza un empleado
router.patch('/:valorDocumentoIdentidad', updateEmpleado);

// DELETE /api/empleados/:valorDocumentoIdentidad -> borrado lógico o intento de borrado
router.delete('/:valorDocumentoIdentidad', deleteEmpleado);

// POST /api/empleados -> llama a insertEmpleado
router.post('/', insertEmpleado);

export default router;