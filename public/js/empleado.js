/**
* empleado.js
* Vista de empleado (resultado de R03 impersonación).
*
* Responsabilidad actual (Matías / Persona A):
* - Mostrar el nombre y documento del empleado impersonado
* - Ofrecer el botón "Regresar a admin" (R06) que invoca
*   sp_RegresarAdmin a través del backend
* - Mantener la sesión del admin (x-username) y limpiar los
*   rastros de la impersonación al regresar
*
* Pendiente (Sebastián / Persona B):
* - Reemplazar el placeholder de #contenidoEmpleado con las
*   pantallas de planilla semanal (R04) y mensual (R05)
*/

class EmpleadoPage {
    constructor() {
        this.btnRegresarAdmin = document.getElementById('btnRegresarAdmin');
        this.logoutBtn = document.getElementById('logoutBtn');
        this.estado = document.getElementById('estado');
        this.nombreSpan = document.getElementById('empleadoNombre');
        this.documentoP = document.getElementById('empleadoDocumento');
        this.bindEvents();
        this.pintarContexto();
    }
    bindEvents() {
        if (this.btnRegresarAdmin) {
            this.btnRegresarAdmin.addEventListener('click', () => {
                void this.regresarAdmin();
            });
        }
        if (this.logoutBtn) {
            this.logoutBtn.addEventListener('click', () => {
                localStorage.removeItem('authToken');
                localStorage.removeItem('username');
                localStorage.removeItem('impersonatedIdEmpleado');
                localStorage.removeItem('impersonatedDocumento');
                localStorage.removeItem('impersonatedNombre');
                window.location.href = '/login.html';
            });
        }
    }
    pintarContexto() {
        const documento = localStorage.getItem('impersonatedDocumento') || this.queryParam('documento') || '';
        const nombre = localStorage.getItem('impersonatedNombre') || '';
        if (this.documentoP) {
            this.documentoP.textContent = documento ? `Documento: ${documento}` : '';
        }
        if (this.nombreSpan) {
            this.nombreSpan.textContent = nombre || documento || 'Empleado';
        }
    }
    queryParam(nombre) {
        const url = new URL(window.location.href);
        return url.searchParams.get(nombre) || '';
    }
    setEstado(texto, tipo) {
        if (!this.estado) {
            return;
        }
        this.estado.textContent = texto;
        this.estado.className = `status ${tipo || 'info'}`;
    }
    async regresarAdmin() {
        const username = localStorage.getItem('username');
        if (!username) {
            window.location.href = '/login.html';
            return;
        }
        if (this.btnRegresarAdmin) {
            this.btnRegresarAdmin.disabled = true;
        }
        this.setEstado('Regresando a interfaz de administrador...', 'info');
        try {
            const response = await fetch('/api/auth/regresar-admin', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'x-username': username,
                },
            });
            const payload = await response.json().catch(() => null);
            if (!response.ok || !payload || !payload.success) {
                this.setEstado((payload && payload.message) || 'No se pudo regresar a la interfaz de administrador.', 'error');
                if (this.btnRegresarAdmin) {
                    this.btnRegresarAdmin.disabled = false;
                }
                return;
            }
            localStorage.removeItem('impersonatedIdEmpleado');
            localStorage.removeItem('impersonatedDocumento');
            localStorage.removeItem('impersonatedNombre');
            window.location.href = '/empleados.html';
        }
        catch (error) {
            console.error('Error regresando a admin:', error);
            this.setEstado('Error de conexión con el servidor.', 'error');
            if (this.btnRegresarAdmin) {
                this.btnRegresarAdmin.disabled = false;
            }
        }
    }
}

document.addEventListener('DOMContentLoaded', () => {
    new EmpleadoPage();
});
