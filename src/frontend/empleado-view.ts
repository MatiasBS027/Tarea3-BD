import { formatearFecha, logout, escapeHtml } from './utils.js';

type EmpleadoPlanilla = {
    id: number;
    Nombre: string;
    ValorDocumento: string;
    idPuesto: number;
    NombrePuesto: string;
    FechaContratacion: string;
    CuentaBancaria: string;
    Activo: number;
};

class EmpleadoViewPage {
    private readonly empleadoId: number;
    private readonly pageTitle: HTMLElement;
    private readonly pageSubtitle: HTMLElement;
    private readonly sidebarNombre: HTMLElement;
    private readonly sidebarPuesto: HTMLElement;
    private readonly estadoDiv: HTMLElement;
    private readonly detalleEmpleado: HTMLElement;
    private readonly semanalEstado: HTMLElement;
    private readonly mensualEstado: HTMLElement;
    private readonly btnRegresarAdmin: HTMLButtonElement;
    private readonly logoutBtn: HTMLButtonElement;

    constructor() {
        const params = new URLSearchParams(window.location.search);
        this.empleadoId = Number(params.get('id')) || 0;

        this.pageTitle = document.getElementById('pageTitle') as HTMLElement;
        this.pageSubtitle = document.getElementById('pageSubtitle') as HTMLElement;
        this.sidebarNombre = document.getElementById('sidebarNombre') as HTMLElement;
        this.sidebarPuesto = document.getElementById('sidebarPuesto') as HTMLElement;
        this.estadoDiv = document.getElementById('estado') as HTMLElement;
        this.detalleEmpleado = document.getElementById('detalleEmpleado') as HTMLElement;
        this.semanalEstado = document.getElementById('semanalEstado') as HTMLElement;
        this.mensualEstado = document.getElementById('mensualEstado') as HTMLElement;
        this.btnRegresarAdmin = document.getElementById('btnRegresarAdmin') as HTMLButtonElement;
        this.logoutBtn = document.getElementById('logoutBtn') as HTMLButtonElement;

        // R06: el boton de regresar solo se muestra cuando el admin esta impersonando
        const esImpersonacion = !!localStorage.getItem('empleadoImpersonadoId');
        if (this.btnRegresarAdmin) {
            this.btnRegresarAdmin.style.display = esImpersonacion ? '' : 'none';
        }

        this.bindEvents();
        void this.cargarEmpleado();
    }

    private bindEvents(): void {
        this.btnRegresarAdmin.addEventListener('click', () => {
            void this.regresarAdmin();
        });

        this.logoutBtn.addEventListener('click', () => {
            logout();
        });
    }

    private async cargarEmpleado(): Promise<void> {
        if (!this.empleadoId) {
            this.pageTitle.textContent = 'ID de empleado no válido';
            this.estadoDiv.textContent = 'No se proporcionó un id de empleado válido.';
            this.estadoDiv.className = 'status error';
            return;
        }

        this.estadoDiv.textContent = 'Cargando datos del empleado...';
        this.estadoDiv.className = 'status info';

        try {
            const token = localStorage.getItem('authToken') || '';
            const headers: Record<string, string> = {};
            if (token) headers['Authorization'] = 'Bearer ' + token;
            const response = await fetch(`/api/empleados/by-id/${this.empleadoId}`, { headers });

            const payload = await response.json() as {
                success: boolean;
                message?: string;
                data?: EmpleadoPlanilla | null;
            };

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
                        <span class="detalle-valor">${escapeHtml(emp.ValorDocumento)}</span>
                    </div>
                    <div class="detalle-item">
                        <span class="detalle-label">Nombre</span>
                        <span class="detalle-valor">${escapeHtml(emp.Nombre)}</span>
                    </div>
                    <div class="detalle-item">
                        <span class="detalle-label">Puesto</span>
                        <span class="detalle-valor">${escapeHtml(emp.NombrePuesto)}</span>
                    </div>
                    <div class="detalle-item">
                        <span class="detalle-label">Fecha contratación</span>
                        <span class="detalle-valor">${fechaContratacion}</span>
                    </div>
                    <div class="detalle-item">
                        <span class="detalle-label">Cuenta bancaria</span>
                        <span class="detalle-valor">${escapeHtml(emp.CuentaBancaria)}</span>
                    </div>
                    <div class="detalle-item">
                        <span class="detalle-label">Estado</span>
                        <span class="detalle-valor">${emp.Activo ? 'Activo' : 'Inactivo'}</span>
                    </div>
                </div>
            `;

            this.estadoDiv.textContent = 'Datos cargados correctamente.';
            this.estadoDiv.className = 'status success';
        } catch (error) {
            console.error('Error cargando empleado:', error);
            this.estadoDiv.textContent = 'Error de conexión con el servidor.';
            this.estadoDiv.className = 'status error';
        }
    }

    private async regresarAdmin(): Promise<void> {
        const token = localStorage.getItem('authToken') || '';
        const headers: Record<string, string> = { 'Content-Type': 'application/json' };
        if (token) headers['Authorization'] = 'Bearer ' + token;

        this.btnRegresarAdmin.disabled = true;
        this.btnRegresarAdmin.textContent = 'Regresando...';

        try {
            const response = await fetch('/api/empleados/regresar-admin', {
                method: 'POST',
                headers,
            });

            const payload = await response.json() as {
                success: boolean;
                outResultCode: number;
                message?: string;
            };

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
        } catch (error) {
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
