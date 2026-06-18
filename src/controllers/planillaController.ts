import { Response } from 'express';
import { getPool, sql } from '../db/connection';
import { getErrorMessage, getHttpStatus } from '../utils/errorhelper';
import { AuthenticatedRequest } from '../middleware/authMiddleware';

// GET /api/planilla/semanal/:idEmpleado
export async function getPlanillaSemanal(req: AuthenticatedRequest, res: Response): Promise<void> {
    try {
        const idEmpleado = Number(req.params.idEmpleado);
        const cantidadSemanas = Number(req.query.cantidadSemanas ?? 10);

        const pool = await getPool();

        const result = await pool
            .request()
            .input('inIdEmpleado',      sql.Int, idEmpleado)
            .input('inCantidadSemanas', sql.Int, cantidadSemanas)
            .input('inIdUsuario',       sql.Int,         req.user?.id ?? null)
            .input('inIpPostIn',        sql.VarChar(64), req.ip ?? '')
            .input('inPostTime',        sql.DateTime,    new Date())
            .output('outResultCode',    sql.Int)
            .execute('sp_GetPlanillaSemanal');

        const outResultCode = Number(result.output.outResultCode ?? 50008);

        if (outResultCode !== 0) {
            res.status(getHttpStatus(outResultCode)).json({
                success: false,
                outResultCode,
                message: await getErrorMessage(outResultCode)
            });
            return;
        }

        res.status(200).json({
            success: true,
            outResultCode,
            data: {
                planillas:    result.recordsets[0] ?? [],   // RS1: grid principal
                deducciones:  result.recordsets[1] ?? [],   // RS2: detalle deducciones
                asistencias:  result.recordsets[2] ?? [],   // RS3: detalle por día
            }
        });
    } catch (error) {
        console.error('Error en getPlanillaSemanal:', error);
        res.status(500).json({
            success: false,
            outResultCode: 50008,
            message: 'Error interno del servidor'
        });
    }
}

// GET /api/planilla/mensual/:idEmpleado
export async function getPlanillaMensual(req: AuthenticatedRequest, res: Response): Promise<void> {
    try {
        const idEmpleado    = Number(req.params.idEmpleado);
        const cantidadMeses = Number(req.query.cantidadMeses ?? 6);

        const pool = await getPool();

        const result = await pool
            .request()
            .input('inIdEmpleado',      sql.Int, idEmpleado)
            .input('inCantidadMeses',   sql.Int, cantidadMeses)
            .input('inIdUsuario',       sql.Int,         req.user?.id ?? null)
            .input('inIpPostIn',        sql.VarChar(64), req.ip ?? '')
            .input('inPostTime',        sql.DateTime,    new Date())
            .output('outResultCode',    sql.Int)
            .execute('sp_GetPlanillaMensual');

        const outResultCode = Number(result.output.outResultCode ?? 50008);

        if (outResultCode !== 0) {
            res.status(getHttpStatus(outResultCode)).json({
                success: false,
                outResultCode,
                message: await getErrorMessage(outResultCode)
            });
            return;
        }

        res.status(200).json({
            success: true,
            outResultCode,
            data: {
                planillas:   result.recordsets[0] ?? [],   // RS1: grid principal
                deducciones: result.recordsets[1] ?? [],   // RS2: deducciones acumuladas
                semanas:     result.recordsets[2] ?? [],   // RS3: resumen por semana
            }
        });
    } catch (error) {
        console.error('Error en getPlanillaMensual:', error);
        res.status(500).json({
            success: false,
            outResultCode: 50008,
            message: 'Error interno del servidor'
        });
    }
}