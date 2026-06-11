"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const empleadoController_1 = require("../controllers/empleadoController");
const authMiddleware_1 = require("../middleware/authMiddleware");
const validation_1 = require("../middleware/validation");
const router = (0, express_1.Router)();
// Todas las rutas de empleados requieren ser admin
router.use(authMiddleware_1.requireAdmin);
router.get('/', validation_1.validateGetEmpleados, empleadoController_1.getEmpleados);
router.post('/impersonar', validation_1.validateImpersonar, empleadoController_1.impersonarEmpleado);
router.post('/regresar-admin', empleadoController_1.regresarAdmin);
router.get('/by-id/:id', validation_1.validateGetEmpleadoByIdInt, empleadoController_1.getEmpleadoByIdInt);
router.get('/:valorDocumentoIdentidad', validation_1.validateGetEmpleadoByDoc, empleadoController_1.getEmpleadoById);
exports.default = router;
