/**
* login.ts
* Lógica principal del formulario de login
*
* Este archivo se ejecuta cuando el usuario accede a login.html
* Maneja:
* - Captura del formulario
* - Validación de inputs
* - Llamadas al servicio
* - Mostrar mensajes y bloqueo
*/
import { AuthService } from './AuthService.js';
/**
* Clase LoginManager
* Gestiona toda la interfaz de usuario y lógica del login
*/
class LoginManager {
    constructor() {
        this.blockedCountdown = null;
        // Inicializar el servicio de autenticación
        this.authService = new AuthService();
        // Obtener referencias a los elementos HTML
        // El "!" al final indica a TypeScript que garantizamos que existen
        this.loginForm = document.getElementById('loginForm');
        this.usernameInput = document.getElementById('username');
        this.passwordInput = document.getElementById('password');
        this.messageDiv = document.getElementById('message');
        this.loginBtn = document.getElementById('loginBtn');
        this.loadingSpinner = document.getElementById('loadingSpinner');
        this.blockedMessage = document.getElementById('blockedMessage');
        this.blockedTime = document.getElementById('blockedTime');
        // Configurar listeners (escuchadores de eventos)
        this.setupEventListeners();
        // Limpiar contador de bloqueo al salir de la pagina
        window.addEventListener('beforeunload', () => {
            if (this.blockedCountdown)
                clearTimeout(this.blockedCountdown);
        });
    }
    /**
    * Configurar todos los listeners de eventos
    * Esto se ejecuta cuando se instancia la clase
    */
    setupEventListeners() {
        // Cuando se envía el formulario
        this.loginForm.addEventListener('submit', (e) => this.handleSubmit(e));
    }
    /**
    * Manejador del evento "submit" del formulario
    * Se ejecuta cuando el usuario presiona "Iniciar Sesión"
    */
    async handleSubmit(e) {
        // Prevenir que la página se recargue (comportamiento por defecto)
        e.preventDefault();
        // Obtener los valores del formulario
        const username = this.usernameInput.value.trim();
        const password = this.passwordInput.value;
        // Validar que los campos no estén vacíos
        if (!username || !password) {
            this.showMessage('Por favor completa todos los campos', 'error');
            return;
        }
        // Deshabilitar botón y mostrar spinner
        this.setLoading(true);
        try {
            // Llamar al servicio de login
            const response = await this.authService.login(username, password);
            // Verificar la respuesta
            if (response.success && response.outResultCode === 0) {
                //  LOGIN EXITOSO
                this.showMessage('¡Bienvenido! Redirigiendo...', 'success');
                // Guardar el token y datos de sesion en localStorage
                if (response.token) {
                    localStorage.setItem('authToken', response.token);
                    localStorage.setItem('username', username);
                    localStorage.setItem('userTipo', response.usuario?.tipo ?? '2');
                    localStorage.setItem('userId', String(response.usuario?.id ?? ''));
                }
                // Redirigir según tipo de usuario
                setTimeout(() => {
                    const tipo = response.usuario?.tipo ?? '2';
                    if (tipo === '1') {
                        window.location.href = '/empleados.html';
                    }
                    else {
                        const idEmpleado = response.usuario?.idEmpleado;
                        if (idEmpleado) {
                            window.location.href = `/empleado-view.html?id=${idEmpleado}`;
                        }
                        else {
                            window.location.href = '/empleado-view.html';
                        }
                    }
                }, 1000);
            }
            else if (response.outResultCode === 50003) {
                //  CUENTA BLOQUEADA
                this.showBlockedMessage(response.message);
            }
            else {
                // ERROR DE AUTENTICACIÓN
                this.showMessage(response.message, 'error');
            }
        }
        catch (error) {
            // Manejo de errores inesperados
            console.error('Error inesperado:', error);
            this.showMessage('Ocurrió un error inesperado. Intenta de nuevo.', 'error');
        }
        finally {
            // Siempre reabilitar el botón y ocultar spinner
            this.setLoading(false);
        }
    }
    /**
    * Mostrar un mensaje en la interfaz
    *
    * @param text - Texto del mensaje
    * @param type - Tipo de mensaje: 'error', 'success', 'warning'
    */
    showMessage(text, type) {
        // Limpiar clases previas
        this.messageDiv.className = 'message';
        // Agregar la clase correspondiente al tipo
        this.messageDiv.classList.add(type);
        // Mostrar el mensaje
        this.messageDiv.textContent = text;
        // Si es error, scroll al mensaje para que vea el usuario
        if (type === 'error') {
            this.messageDiv.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
        }
    }
    /**
    * Mostrar mensaje de bloqueo por reintentos fallidos
    * Incluye un contador regresivo
    *
    * @param message - Mensaje del servidor
    */
    showBlockedMessage(message) {
        // Mostrar el contenedor de bloqueo
        this.blockedMessage.classList.remove('hidden');
        // Mostrar el mensaje en la consola (para debugging)
        console.warn('Cuenta bloqueada:', message);
        // Iniciar contador regresivo (10 minutos = 600 segundos)
        let remainingSeconds = 600;
        const updateCounter = () => {
            const minutes = Math.floor(remainingSeconds / 60);
            const seconds = remainingSeconds % 60;
            this.blockedTime.textContent = `${minutes}:${seconds.toString().padStart(2, '0')}`;
            if (remainingSeconds > 0) {
                remainingSeconds--;
                // Actualizar cada segundo
                this.blockedCountdown = setTimeout(updateCounter, 1000);
            }
            else {
                // Cuando llega a 0, ocultar el bloqueo
                this.blockedMessage.classList.add('hidden');
                this.showMessage('Tu cuenta ha sido desbloqueada. Intenta de nuevo.', 'success');
            }
        };
        // Iniciar el contador
        updateCounter();
    }
    /**
    * Controlar el estado de carga
    * Muestra/oculta el spinner y deshabilita el botón
    *
    * @param isLoading - true si está cargando, false si terminó
    */
    setLoading(isLoading) {
        if (isLoading) {
            // Mostrar spinner y deshabilitar inputs
            this.loadingSpinner.classList.remove('hidden');
            this.loginBtn.disabled = true;
            this.usernameInput.disabled = true;
            this.passwordInput.disabled = true;
        }
        else {
            // Ocultar spinner y habilitar inputs
            this.loadingSpinner.classList.add('hidden');
            this.loginBtn.disabled = false;
            this.usernameInput.disabled = false;
            this.passwordInput.disabled = false;
        }
    }
}
/**
* PUNTO DE ENTRADA
* Se ejecuta cuando el DOM está completamente cargado
*/
document.addEventListener('DOMContentLoaded', () => {
    // Crear una instancia de LoginManager, que automáticamente
    // configura todos los listeners y prepara la interfaz
    new LoginManager();
});
