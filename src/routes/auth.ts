/**
* routes/auth.ts
* Rutas de autenticación
* 
* Estas son las rutas HTTP que el frontend llama para login/logout
* Ejemplos de URLs:
* - POST /api/auth/login
* - POST /api/auth/logout
*/

import { Router, Request, Response } from 'express';
import { AuthController } from '../controllers/authController';

// Crear el enrutador
const router = Router();

// Instanciar el controlador
const authController = new AuthController();

/**
* POST /api/auth/login
* Endpoint para autenticarse
* 
* Body esperado:
* {
*   "username": "usuario",
*   "password": "contraseña"
* }
* 
* Respuesta:
{
*   "success": true/false,
*   "outResultCode": 0,
*   "message": "Mensaje de resultado",
*   "token": "jwt_token_aqui",
*   "usuario": { "id": 1, "username": "usuario" }
* }
*/
router.post('/login', (req: Request, res: Response) => {
    authController.login(req, res);
});

/**
* POST /api/auth/logout
* Endpoint para cerrar sesión
* 
* Header esperado:
* Authorization: Bearer <token>
* 
* Respuesta:
* {
*   "success": true,
*   "message": "Sesión cerrada"
* }
*/
router.post('/logout', (req: Request, res: Response) => {
    authController.logout(req, res);
});

export default router;
