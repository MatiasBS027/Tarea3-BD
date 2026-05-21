/**
* AuthService.ts
* Servicio para comunicarse con el backend de autenticación
* 
* Este archivo contiene la lógica de AJAX/fetch que envía datos
* al servidor y recibe respuestas.
*/

interface LoginRequest {
    username: string;
    password: string;
}

interface LoginResponse {
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
* Clase AuthService
* Maneja todas las comunicaciones con el backend de autenticación
*/
export class AuthService {
  private baseUrl = '/api/auth'; // Ruta base de la API

private buildFallbackResponse(status: number): LoginResponse {
  if (status === 401) {
  return {
    success: false,
    outResultCode: 50001,
    message: 'Usuario o contraseña inválidos.',
  };
  }

  if (status === 403) {
  return {
    success: false,
    outResultCode: 50003,
    message: 'Cuenta bloqueada temporalmente.',
  };
  }

  if (status >= 500) {
  return {
    success: false,
    outResultCode: 50008,
    message: 'Error interno del servidor. Intenta más tarde.',
  };
  }

  return {
  success: false,
  outResultCode: 50008,
  message: 'No se pudo completar la autenticación.',
  };
}

/**
* Envía credenciales al servidor para autenticación
* 
* @param username - Nombre de usuario
* @param password - Contraseña
* @returns Promesa con la respuesta del servidor
*/
async login(username: string, password: string): Promise<LoginResponse> {
    try {
      // Preparar el objeto con los datos del login
    const loginData: LoginRequest = { username, password };

      // Hacer petición POST al endpoint /api/auth/login
    const response = await fetch(`${this.baseUrl}/login`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json', // Indicar que enviamos JSON
        },
        body: JSON.stringify(loginData), // Convertir objeto a JSON
    });

      // Parsear respuesta JSON (si existe)
    let data: LoginResponse | null = null;
    try {
        data = (await response.json()) as LoginResponse;
    } catch {
        data = null;
    }

    // Si backend respondió error HTTP, devolver error específico
    if (!response.ok) {
        if (data && typeof data.outResultCode === 'number') {
        return data;
        }
        return this.buildFallbackResponse(response.status);
    }

    // Éxito HTTP pero payload vacío o inválido
    if (!data) {
    return {
        success: false,
        outResultCode: 50008,
        message: 'Respuesta inválida del servidor.',
    };
    }

    return data;
    } catch (error) {
      // Si hay error de red (fetch falla), devolver error de conectividad
    console.error('Error en login:', error);
    return {
        success: false,
        outResultCode: 50008, // Código de error genérico
        message: 'Error de conexión con el servidor. Intenta de nuevo.',
    };
    }
}

/**
 * Cerrar sesión
 * 
 * @param token - Token de sesión
 */
async logout(token: string): Promise<boolean> {
    try {
    const response = await fetch(`${this.baseUrl}/logout`, {
        method: 'POST',
        headers: {
        'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`, // Enviar token en header
        },
    });

    return response.ok;
    } catch (error) {
        console.error('Error en logout:', error);
    return false;
    }
}
}
