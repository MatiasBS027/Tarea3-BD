import { Router } from 'express';
import { getPlanillaSemanal, getPlanillaMensual } from '../controllers/planillaController';
import { param, query, validationResult } from 'express-validator';
import { Request, Response, NextFunction } from 'express';

const router = Router();

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

const validateIdEmpleado = [
    param('idEmpleado')
        .isInt({ min: 1 }).withMessage('idEmpleado debe ser un entero positivo'),
    handleValidationErrors,
];

const validateCantidadSemanas = [
    query('cantidadSemanas')
        .optional()
        .isInt({ min: 1, max: 52 }).withMessage('cantidadSemanas debe ser entre 1 y 52'),
    handleValidationErrors,
];

const validateCantidadMeses = [
    query('cantidadMeses')
        .optional()
        .isInt({ min: 1, max: 24 }).withMessage('cantidadMeses debe ser entre 1 y 24'),
    handleValidationErrors,
];

// GET /api/planilla/semanal/:idEmpleado?cantidadSemanas=10
router.get('/semanal/:idEmpleado', [...validateIdEmpleado, ...validateCantidadSemanas], getPlanillaSemanal);

// GET /api/planilla/mensual/:idEmpleado?cantidadMeses=6
router.get('/mensual/:idEmpleado', [...validateIdEmpleado, ...validateCantidadMeses], getPlanillaMensual);

export default router;