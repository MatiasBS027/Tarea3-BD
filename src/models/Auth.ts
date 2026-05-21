/**
 * Modelo de datos para autenticación
 * Este archivo se usa tanto en backend como en frontend
 */

/**
 * LoginRequest: Lo que el frontend ENVÍA al servidor
 * username: El nombre de usuario
 * password: La contraseña
 */
export interface LoginRequest {
  username: string;
  password: string;
}

/**
 * LoginResponse: Lo que el servidor DEVUELVE al frontend
 * success: ¿Se autenticó correctamente?
 * outResultCode: Código de error (0 = éxito)
 * message: Mensaje amigable para mostrar al usuario
 * token?: Si es exitoso, un token para sesión
 * usuario?: Datos del usuario autenticado
 */
export interface LoginResponse {
  success: boolean;
  outResultCode: number;
  message: string;
  token?: string;
  usuario?: {
    id: number;
    username: string;
  };
}

/**
 * LogoutRequest: Lo que enviamos para logout (podría estar vacío, pero es buena práctica)
 */
export interface LogoutRequest {
  token: string;
}

/**
 * LogoutResponse: Confirmación de logout
 */
export interface LogoutResponse {
  success: boolean;
  message: string;
}
