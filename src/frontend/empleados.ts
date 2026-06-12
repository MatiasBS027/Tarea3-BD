import { setEstado as setEstadoEl, logout } from './utils.js';

type Empleado = {
    Nombre: string;
    ValorDocumento: string;
    idPuesto: number;
    NombrePuesto: string;
};

type EmpleadoDetalle = {
    ValorDocumento: string;
    Nombre: string;
    idPuesto: number;
    NombrePuesto: string;
    FechaContratacion?: string;
    CuentaBancaria?: string;
    Activo: number;
};

class EmpleadosPage {
    private filtroInput: HTMLInputElement;
    private buscarBtn: HTMLButtonElement;
    private limpiarBtn: HTMLButtonElement;
    private mensajeDiv: HTMLElement;
    private contadorSpan: HTMLElement;
    private empleadosBody: HTMLTableSectionElement;
    private detallePanel: HTMLElement;
    private detalleContenido: HTMLElement;
    private detalleTitulo: HTMLElement;
    private detalleEstado: HTMLElement;
    private logoutBtn: HTMLButtonElement;

    constructor() {
        this.filtroInput = document.getElementById('filtro') as HTMLInputElement;
        this.buscarBtn = document.getElementById('buscarBtn') as HTMLButtonElement;
        this.limpiarBtn = document.getElementById('limpiarBtn') as HTMLButtonElement;
        this.mensajeDiv = document.getElementById('mensaje') as HTMLElement;
        this.contadorSpan = document.getElementById('contador') as HTMLElement;
        this.empleadosBody = document.getElementById('empleadosBody') as HTMLTableSectionElement;
        this.detallePanel = document.getElementById('detallePanel') as HTMLElement;
        this.detalleContenido = document.getElementById('detalleContenido') as HTMLElement;
        this.detalleTitulo = document.getElementById('detalleTitulo') as HTMLElement;
        this.detalleEstado = document.getElementById('detalleEstado') as HTMLElement;
        this.logoutBtn = document.getElementById('logoutBtn') as HTMLButtonElement;

        this.bindEvents();
        this.cargarEmpleados();
    }

    private bindEvents(): void {
        this.buscarBtn.addEventListener('click', () => {
            void this.cargarEmpleados();
        });

        this.limpiarBtn.addEventListener('click', () => {
            this.filtroInput.value = '';
            void this.cargarEmpleados();
        });

        this.filtroInput.addEventListener('keydown', (event) => {
            if (event.key === 'Enter') {
                event.preventDefault();
                void this.cargarEmpleados();
            }
        });

        this.empleadosBody.addEventListener('click', (event) => {
            const target = event.target as HTMLElement | null;
            const button = target?.closest('button[data-accion]') as HTMLButtonElement | null;

            if (!button) return;

            const documento = button.dataset.documento;
            if (!documento) return;

            const accion = button.dataset.accion;

            if (accion === 'consultar') {
                void this.consultarEmpleado(documento);
                return;
            }

            if (accion === 'impersonar') {
                void this.impersonarEmpleado(documento);
            }
        });

        if (this.logoutBtn) {
            this.logoutBtn.addEventListener('click', () => {
                logout();
            });
        }
    }

    private async cargarEmpleados(): Promise<void> {
        const filtro = this.filtroInput.value.trim();
        const token = localStorage.getItem('authToken') || '';
        const headers: Record<string, string> = {};
        if (token) headers['Authorization'] = 'Bearer ' + token;

        this.setEstado('Cargando empleados...', 'info');
        this.setBotones(false);

        try {
            const response = await fetch(`/api/empleados?filtro=${encodeURIComponent(filtro)}`, {
                method: 'GET',
                headers,
            });

            const payload = await response.json() as {
                success: boolean;
                outResultCode: number;
                message?: string;
                data?: Empleado[];
            };

            if (!response.ok || !payload.success) {
                this.limpiarTabla();
                this.setEstado(payload.message || 'No se pudieron obtener los empleados.', 'error');
                this.contadorSpan.textContent = '0 resultados';
                return;
            }

            const empleados = payload.data ?? [];
            this.renderTabla(empleados);
            this.contadorSpan.textContent = `${empleados.length} resultado${empleados.length === 1 ? '' : 's'}`;

            if (empleados.length === 0) {
                this.setEstado('No se encontraron empleados con ese filtro.', 'warning');
            } else {
                this.setEstado('Empleados cargados correctamente.', 'success');
            }
        } catch (error) {
            console.error('Error cargando empleados:', error);
            this.limpiarTabla();
            this.contadorSpan.textContent = '0 resultados';
            this.setEstado('Error de conexión con el servidor.', 'error');
        } finally {
            this.setBotones(true);
        }
    }

    private renderTabla(empleados: Empleado[]): void {
        this.empleadosBody.innerHTML = '';

        if (empleados.length === 0) {
            this.empleadosBody.innerHTML = `
                <tr>
                    <td colspan="4" class="empty-state">Todavía no hay datos cargados</td>
                </tr>
            `;
            return;
        }

        for (const empleado of empleados) {
            const fila = document.createElement('tr');

            fila.innerHTML = `
                <td>${empleado.Nombre}</td>
                <td>${empleado.ValorDocumento}</td>
                <td>${empleado.NombrePuesto}</td>
                <td>
                    <button type="button" class="action-button action-view" data-accion="consultar" data-documento="${empleado.ValorDocumento}">
                        Consultar
                    </button>
                    <button type="button" class="action-button action-impersonar" data-accion="impersonar" data-documento="${empleado.ValorDocumento}">
                        Impersonar
                    </button>
                </td>
            `;

            this.empleadosBody.appendChild(fila);
        }
    }

    private limpiarTabla(): void {
        this.empleadosBody.innerHTML = `
            <tr>
                <td colspan="4" class="empty-state">Todavía no hay datos cargados</td>
            </tr>
        `;
    }

    private async impersonarEmpleado(valorDocumentoIdentidad: string): Promise<void> {
        const token = localStorage.getItem('authToken') || '';
        const headers: Record<string, string> = { 'Content-Type': 'application/json' };
        if (token) headers['Authorization'] = 'Bearer ' + token;

        this.setEstado('Impersonando empleado...', 'info');

        try {
            const response = await fetch('/api/empleados/impersonar', {
                method: 'POST',
                headers,
                body: JSON.stringify({ valorDocumento: valorDocumentoIdentidad }),
            });

            const payload = await response.json() as {
                success: boolean;
                outResultCode: number;
                message?: string;
                data?: { idEmpleado: number | null };
            };

            if (!response.ok || !payload.success) {
                this.setEstado(payload.message || 'No se pudo impersonar al empleado.', 'error');
                return;
            }

            const idEmpleado = payload.data?.idEmpleado;
            if (!idEmpleado) {
                this.setEstado('El SP no devolvió el id del empleado.', 'error');
                return;
            }

            this.setEstado('Empleado impersonado. Redirigiendo...', 'success');
            localStorage.setItem('empleadoImpersonadoId', String(idEmpleado));
            localStorage.setItem('empleadoImpersonadoDoc', valorDocumentoIdentidad);

            setTimeout(() => {
                window.location.href = `/empleado-view.html?id=${idEmpleado}`;
            }, 500);
        } catch (error) {
            console.error('Error impersonando empleado:', error);
            this.setEstado('Error de conexión al impersonar.', 'error');
        }
    }

    private async consultarEmpleado(valorDocumentoIdentidad: string): Promise<void> {
        this.detallePanel.classList.remove('hidden');
        this.detalleTitulo.textContent = `Consulta de ${valorDocumentoIdentidad}`;
        this.detalleEstado.textContent = 'Cargando detalle del empleado...';
        this.detalleEstado.className = 'status info';
        this.detalleContenido.innerHTML = '';

        try {
            const token = localStorage.getItem('authToken') || '';
            const headers: Record<string, string> = {};
            if (token) headers['Authorization'] = 'Bearer ' + token;
            const response = await fetch(`/api/empleados/${encodeURIComponent(valorDocumentoIdentidad)}`, { headers });

            const payload = await response.json() as {
                success: boolean;
                outResultCode: number;
                message?: string;
                data?: EmpleadoDetalle | null;
            };

            if (!response.ok || !payload.success || !payload.data) {
                this.detalleEstado.textContent = payload.message || 'No se pudo cargar el detalle.';
                this.detalleEstado.className = 'status error';
                this.detalleContenido.innerHTML = '';
                return;
            }

            const detalle = payload.data;
            const rawFecha = detalle.FechaContratacion ?? '';
            let fechaContratacion = '';
            if (rawFecha) {
                try {
                    const d = new Date(rawFecha);
                    if (!isNaN(d.getTime())) {
                        fechaContratacion = d.toLocaleDateString('es-ES');
                    } else {
                        fechaContratacion = String(rawFecha);
                    }
                } catch {
                    fechaContratacion = String(rawFecha);
                }
            }

            this.detalleEstado.textContent = 'Detalle cargado correctamente.';
            this.detalleEstado.className = 'status success';
            this.detalleContenido.innerHTML = `
                <div class="detalle-grid">
                    <div class="detalle-item">
                        <span class="detalle-label">Documento</span>
                        <span class="detalle-valor">${detalle.ValorDocumento}</span>
                    </div>
                    <div class="detalle-item">
                        <span class="detalle-label">Nombre</span>
                        <span class="detalle-valor">${detalle.Nombre}</span>
                    </div>
                    <div class="detalle-item">
                        <span class="detalle-label">Puesto</span>
                        <span class="detalle-valor">${detalle.NombrePuesto}</span>
                    </div>
                    <div class="detalle-item">
                        <span class="detalle-label">Fecha contratación</span>
                        <span class="detalle-valor">${fechaContratacion}</span>
                    </div>
                    <div class="detalle-item">
                        <span class="detalle-label">Estado</span>
                        <span class="detalle-valor">${detalle.Activo ? 'Activo' : 'Inactivo'}</span>
                    </div>
                </div>
            `;
        } catch (error) {
            console.error('Error consultando empleado:', error);
            this.detalleEstado.textContent = 'Error de conexión con el servidor.';
            this.detalleEstado.className = 'status error';
            this.detalleContenido.innerHTML = '';
        }
    }

    private setEstado(texto: string, tipo: 'info' | 'success' | 'warning' | 'error'): void {
        setEstadoEl(this.mensajeDiv, texto, tipo);
    }

    private setBotones(habilitado: boolean): void {
        this.buscarBtn.disabled = !habilitado;
        this.limpiarBtn.disabled = !habilitado;
    }
}

document.addEventListener('DOMContentLoaded', () => {
    new EmpleadosPage();
});
