/**
* routes/impersonar.ts
* Rutas de impersonación (R03) y regreso a admin (R06).
*
* - POST /api/auth/impersonar      -> sp_ImpersonarEmpleado
* - POST /api/auth/regresar-admin  -> sp_RegresarAdmin
*
* Se montan bajo /api/auth porque la sesión activa (x-username) viaja
* en headers, igual que en /api/auth/login y /api/auth/logout.
*/

import { Router, Request, Response } from 'express';
import { impersonarEmpleado, regresarAdmin } from '../controllers/impersonarController';

const router = Router();

/**
* POST /api/auth/impersonar
* Body esperado:
* {
*   "valorDocumentoIdentidad": "110011001"
* }
* Header esperado:
*   x-username: <username del admin>
*
* Respuesta exitosa:
* {
*   "success": true,
*   "outResultCode": 0,
*   "idEmpleado": 7,
*   "message": "Impersonación iniciada correctamente"
* }
*/
router.post('/impersonar', (req: Request, res: Response) => {
    void impersonarEmpleado(req, res);
});

/**
* POST /api/auth/regresar-admin
* Header esperado:
*   x-username: <username del admin>
*
* Respuesta exitosa:
* {
*   "success": true,
*   "outResultCode": 0,
*   "message": "Regreso a interfaz de administrador"
* }
*/
router.post('/regresar-admin', (req: Request, res: Response) => {
    void regresarAdmin(req, res);
});

export default router;
