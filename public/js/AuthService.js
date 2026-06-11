export class AuthService {
    constructor() {
        this.baseUrl = '/api/auth';
    }
    buildFallbackResponse(status) {
        if (status === 401) {
            return {
                success: false,
                outResultCode: 50001,
                message: 'Usuario o contrasena invalidos.',
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
                message: 'Error interno del servidor. Intenta mas tarde.',
            };
        }
        return {
            success: false,
            outResultCode: 50008,
            message: 'No se pudo completar la autenticacion.',
        };
    }
    async login(username, password) {
        try {
            const loginData = { username, password };
            const response = await fetch(`${this.baseUrl}/login`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(loginData),
            });
            let data = null;
            try {
                data = (await response.json());
            }
            catch {
                data = null;
            }
            if (!response.ok) {
                if (data && typeof data.outResultCode === 'number') {
                    return data;
                }
                return this.buildFallbackResponse(response.status);
            }
            if (!data) {
                return {
                    success: false,
                    outResultCode: 50008,
                    message: 'Respuesta invalida del servidor.',
                };
            }
            return data;
        }
        catch (error) {
            console.error('Error en login:', error);
            return {
                success: false,
                outResultCode: 50008,
                message: 'Error de conexion con el servidor. Intenta de nuevo.',
            };
        }
    }
}
