import { body, query, param, validationResult } from 'express-validator';
import { Request, Response, NextFunction } from 'express';

function handleValidationErrors(req: Request, res: Response, next: NextFunction): void {
    const errors = validationResult(req);
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
export const validateLogin = [
    body('username')
        .trim()
        .notEmpty().withMessage('Username requerido')
        .isLength({ min: 1, max: 128 }).withMessage('Username debe tener entre 1 y 128 caracteres'),
    body('password')
        .notEmpty().withMessage('Password requerido'),
    handleValidationErrors,
];

// --- Empleados ---
export const validateGetEmpleados = [
    query('filtro')
        .optional()
        .trim()
        .isLength({ max: 128 }).withMessage('Filtro demasiado largo'),
    handleValidationErrors,
];

export const validateGetEmpleadoByDoc = [
    param('valorDocumentoIdentidad')
        .trim()
        .notEmpty().withMessage('Documento requerido'),
    handleValidationErrors,
];

export const validateImpersonar = [
    body('valorDocumento')
        .trim()
        .notEmpty().withMessage('valorDocumento requerido'),
    handleValidationErrors,
];

export const validateGetEmpleadoByIdInt = [
    param('id')
        .isInt({ min: 1 }).withMessage('id debe ser un numero entero positivo'),
    handleValidationErrors,
];

// --- Bitácora ---
export const validateGetBitacora = [
    query('idTipoEvento')
        .optional()
        .isInt({ min: 1 }).withMessage('idTipoEvento debe ser un entero positivo'),
    query('idUsuario')
        .optional()
        .isInt({ min: 1 }).withMessage('idUsuario debe ser un entero positivo'),
    query('fechaDesde')
        .optional()
        .isISO8601().withMessage('fechaDesde debe ser una fecha ISO valida'),
    query('fechaHasta')
        .optional()
        .isISO8601().withMessage('fechaHasta debe ser una fecha ISO valida'),
    query('page')
        .optional()
        .isInt({ min: 1 }).withMessage('page debe ser un entero positivo'),
    query('pageSize')
        .optional()
        .isInt({ min: 1, max: 500 }).withMessage('pageSize debe estar entre 1 y 500'),
    handleValidationErrors,
];
