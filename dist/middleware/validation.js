"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.validateGetBitacora = exports.validateGetEmpleadoByIdInt = exports.validateImpersonar = exports.validateGetEmpleadoByDoc = exports.validateGetEmpleados = exports.validateLogin = void 0;
const express_validator_1 = require("express-validator");
function handleValidationErrors(req, res, next) {
    const errors = (0, express_validator_1.validationResult)(req);
    if (!errors.isEmpty()) {
        res.status(400).json({
            success: false,
            message: 'Error de validacion',
            errors: errors.array().map((e) => ({
                campo: e.type === 'field' ? e.path : e.type,
                mensaje: e.msg,
            })),
        });
        return;
    }
    next();
}
// --- Auth ---
exports.validateLogin = [
    (0, express_validator_1.body)('username')
        .trim()
        .notEmpty().withMessage('Username requerido')
        .isLength({ min: 1, max: 128 }).withMessage('Username debe tener entre 1 y 128 caracteres'),
    (0, express_validator_1.body)('password')
        .notEmpty().withMessage('Password requerido'),
    handleValidationErrors,
];
// --- Empleados ---
exports.validateGetEmpleados = [
    (0, express_validator_1.query)('filtro')
        .optional()
        .trim()
        .isLength({ max: 128 }).withMessage('Filtro demasiado largo'),
    handleValidationErrors,
];
exports.validateGetEmpleadoByDoc = [
    (0, express_validator_1.param)('valorDocumentoIdentidad')
        .trim()
        .notEmpty().withMessage('Documento requerido'),
    handleValidationErrors,
];
exports.validateImpersonar = [
    (0, express_validator_1.body)('valorDocumento')
        .trim()
        .notEmpty().withMessage('valorDocumento requerido'),
    handleValidationErrors,
];
exports.validateGetEmpleadoByIdInt = [
    (0, express_validator_1.param)('id')
        .isInt({ min: 1 }).withMessage('id debe ser un numero entero positivo'),
    handleValidationErrors,
];
// --- Bitácora ---
exports.validateGetBitacora = [
    (0, express_validator_1.query)('idTipoEvento')
        .optional()
        .isInt({ min: 1 }).withMessage('idTipoEvento debe ser un entero positivo'),
    (0, express_validator_1.query)('idUsuario')
        .optional()
        .isInt({ min: 1 }).withMessage('idUsuario debe ser un entero positivo'),
    (0, express_validator_1.query)('fechaDesde')
        .optional()
        .isISO8601().withMessage('fechaDesde debe ser una fecha ISO valida'),
    (0, express_validator_1.query)('fechaHasta')
        .optional()
        .isISO8601().withMessage('fechaHasta debe ser una fecha ISO valida'),
    (0, express_validator_1.query)('page')
        .optional()
        .isInt({ min: 1 }).withMessage('page debe ser un entero positivo'),
    (0, express_validator_1.query)('pageSize')
        .optional()
        .isInt({ min: 1, max: 500 }).withMessage('pageSize debe estar entre 1 y 500'),
    handleValidationErrors,
];
