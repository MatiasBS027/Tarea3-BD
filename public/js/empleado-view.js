import { formatearFecha, logout } from './utils.js';
class EmpleadoViewPage {
    constructor() {
        const params = new URLSearchParams(window.location.search);
        this.empleadoId = Number(params.get('id')) || 0;
        this.pageTitle = document.getElementById('pageTitle');
        this.pageSubtitle = document.getElementById('pageSubtitle');
        this.sidebarNombre = document.getElementById('sidebarNombre');
        this.sidebarPuesto = document.getElementById('sidebarPuesto');
        this.estadoDiv = document.getElementById('estado');
        this.detalleEmpleado = document.getElementById('detalleEmpleado');
        this.semanalEstado = document.getElementById('semanalEstado');
        this.mensualEstado = document.getElementById('mensualEstado');
        this.btnRegresarAdmin = document.getElementById('btnRegresarAdmin');
        this.logoutBtn = document.getElementById('logoutBtn');
        // R06: el boton de regresar solo se muestra cuando el admin esta impersonando
        const esImpersonacion = !!localStorage.getItem('empleadoImpersonadoId');
        if (this.btnRegresarAdmin) {
            this.btnRegresarAdmin.style.display = esImpersonacion ? '' : 'none';
        }
        this.bindEvents();
        void this.cargarEmpleado();
    }
    bindEvents() {
        this.btnRegresarAdmin.addEventListener('click', () => {
            void this.regresarAdmin();
        });
        this.logoutBtn.addEventListener('click', () => {
            logout();
        });
    }
    async cargarEmpleado() {
        if (!this.empleadoId) {
            this.pageTitle.textContent = 'ID de empleado no válido';
            this.estadoDiv.textContent = 'No se proporcionó un id de empleado válido.';
            this.estadoDiv.className = 'status error';
            return;
        }
        this.estadoDiv.textContent = 'Cargando datos del empleado...';
        this.estadoDiv.className = 'status info';
        try {
            const response = await fetch(`/api/empleados/by-id/${this.empleadoId}`);
            const payload = await response.json();
            if (!response.ok || !payload.success || !payload.data) {
                this.estadoDiv.textContent = payload.message || 'No se pudo cargar el empleado.';
                this.estadoDiv.className = 'status error';
                return;
            }
            const emp = payload.data;
            this.pageTitle.textContent = `Planilla de ${emp.Nombre}`;
            this.pageSubtitle.textContent = `${emp.ValorDocumento} — ${emp.NombrePuesto}`;
            this.sidebarNombre.textContent = emp.Nombre;
            this.sidebarPuesto.textContent = emp.NombrePuesto;
            let fechaContratacion = '';
            if (emp.FechaContratacion) {
                fechaContratacion = formatearFecha(emp.FechaContratacion);
            }
            this.detalleEmpleado.innerHTML = `
                <div class="detalle-grid">
                    <div class="detalle-item">
                        <span class="detalle-label">Documento</span>
                        <span class="detalle-valor">${emp.ValorDocumento}</span>
                    </div>
                    <div class="detalle-item">
                        <span class="detalle-label">Nombre</span>
                        <span class="detalle-valor">${emp.Nombre}</span>
                    </div>
                    <div class="detalle-item">
                        <span class="detalle-label">Puesto</span>
                        <span class="detalle-valor">${emp.NombrePuesto}</span>
                    </div>
                    <div class="detalle-item">
                        <span class="detalle-label">Fecha contratación</span>
                        <span class="detalle-valor">${fechaContratacion}</span>
                    </div>
                    <div class="detalle-item">
                        <span class="detalle-label">Cuenta bancaria</span>
                        <span class="detalle-valor">${emp.CuentaBancaria}</span>
                    </div>
                    <div class="detalle-item">
                        <span class="detalle-label">Estado</span>
                        <span class="detalle-valor">${emp.Activo ? 'Activo' : 'Inactivo'}</span>
                    </div>
                </div>
            `;
            this.estadoDiv.textContent = 'Datos cargados correctamente.';
            this.estadoDiv.className = 'status success';
        }
        catch (error) {
            console.error('Error cargando empleado:', error);
            this.estadoDiv.textContent = 'Error de conexión con el servidor.';
            this.estadoDiv.className = 'status error';
        }
    }
    async regresarAdmin() {
        const token = localStorage.getItem('authToken') || '';
        const headers = { 'Content-Type': 'application/json' };
        if (token)
            headers['Authorization'] = 'Bearer ' + token;
        this.btnRegresarAdmin.disabled = true;
        this.btnRegresarAdmin.textContent = 'Regresando...';
        try {
            const response = await fetch('/api/empleados/regresar-admin', {
                method: 'POST',
                headers,
            });
            const payload = await response.json();
            if (!response.ok || !payload.success) {
                this.btnRegresarAdmin.disabled = false;
                this.btnRegresarAdmin.textContent = 'Regresar a interfaz de administrador';
                this.estadoDiv.textContent = payload.message || 'No se pudo regresar a admin.';
                this.estadoDiv.className = 'status error';
                return;
            }
            localStorage.removeItem('empleadoImpersonadoId');
            localStorage.removeItem('empleadoImpersonadoDoc');
            window.location.href = '/empleados.html';
        }
        catch (error) {
            console.error('Error regresando a admin:', error);
            this.btnRegresarAdmin.disabled = false;
            this.btnRegresarAdmin.textContent = 'Regresar a interfaz de administrador';
            this.estadoDiv.textContent = 'Error de conexión al regresar.';
            this.estadoDiv.className = 'status error';
        }
    }
}
document.addEventListener('DOMContentLoaded', () => {
    new EmpleadoViewPage();
});
