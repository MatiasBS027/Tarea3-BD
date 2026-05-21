type EmpleadoResumen = {
    ValorDocumentoIdentidad: string;
    Nombre: string;
    NombrePuesto: string;
    SaldoVacaciones: number;
};

type Movimiento = {
    id: number;
    NombreEmpleado: string;
    ValorDocumentoIdentidad: string;
    NombreTipoMovimiento: string;
    TipoAccion: string;
    Monto: number;
    NuevoSaldo: number;
    Fecha: string;
    PostTime: string;
    IpPostIn: string;
    UsuarioRegistro: string;
};

class MovimientosPage {
    private readonly documentoIdentidad: string;
    private readonly tituloEmpleado: HTMLElement;
    private readonly resumenEmpleado: HTMLElement;
    private readonly estadoDiv: HTMLElement;
    private readonly contadorSpan: HTMLElement;
    private readonly movimientosBody: HTMLTableSectionElement;
    private readonly recargarBtn: HTMLButtonElement;
    private readonly logoutBtn: HTMLButtonElement;
    private readonly volverEmpleadosBtn: HTMLAnchorElement;

    constructor() {
        const params = new URLSearchParams(window.location.search);
        this.documentoIdentidad = params.get('documento')?.trim() ?? localStorage.getItem('ultimoDocumentoEmpleado')?.trim() ?? '';

        const insertarBtn = document.getElementById('insertarMovimientoBtn') as HTMLAnchorElement;
        if (insertarBtn){
            insertarBtn.href = `/insertarMovimiento.html?documento=${encodeURIComponent(this.documentoIdentidad)}`;
        }

        this.tituloEmpleado = document.getElementById('tituloEmpleado') as HTMLElement;
        this.resumenEmpleado = document.getElementById('resumenEmpleado') as HTMLElement;
        this.estadoDiv = document.getElementById('estado') as HTMLElement;
        this.contadorSpan = document.getElementById('contador') as HTMLElement;
        this.movimientosBody = document.getElementById('movimientosBody') as HTMLTableSectionElement;
        this.recargarBtn = document.getElementById('recargarBtn') as HTMLButtonElement;
        this.logoutBtn = document.getElementById('logoutBtn') as HTMLButtonElement;
        this.volverEmpleadosBtn = document.getElementById('volverEmpleadosBtn') as HTMLAnchorElement;

        this.bindEvents();
        void this.cargarVista();
    }

    private bindEvents(): void {
        this.recargarBtn.addEventListener('click', () => {
            void this.cargarVista();
        });

        this.logoutBtn.addEventListener('click', () => {
            localStorage.removeItem('authToken');
            localStorage.removeItem('username');
            localStorage.removeItem('ultimoDocumentoEmpleado');
            window.location.href = '/login.html';
        });

        this.volverEmpleadosBtn.addEventListener('click', () => {
            window.location.href = '/empleados.html';
        });
    }

    private async cargarVista(): Promise<void> {
        if (!this.documentoIdentidad) {
            this.tituloEmpleado.textContent = 'Movimiento sin empleado seleccionado';
            this.resumenEmpleado.innerHTML = '';
            this.renderMovimientos([]);
            this.setEstado('Regresa a la lista de empleados y usa la acción "Movimientos" sobre una fila.', 'warning');
            this.contadorSpan.textContent = '0 movimientos';
            return;
        }

        this.setEstado('Cargando contexto del empleado y sus movimientos...', 'info');

        await this.cargarEmpleado();
        await this.cargarMovimientos();
    }

    private async cargarEmpleado(): Promise<void> {
        try {
            const response = await fetch(`/api/empleados/${encodeURIComponent(this.documentoIdentidad)}`, {
                method: 'GET',
            });

            const payload = await response.json() as {
                success: boolean;
                message?: string;
                data?: EmpleadoResumen | null;
            };

            if (!response.ok || !payload.success || !payload.data) {
                this.tituloEmpleado.textContent = `Movimientos de ${this.documentoIdentidad}`;
                this.resumenEmpleado.innerHTML = '';
                this.setEstado(payload.message || 'No se pudo cargar el empleado seleccionado.', 'error');
                return;
            }

            const empleado = payload.data;
            this.tituloEmpleado.textContent = `Movimientos de ${empleado.Nombre}`;
            this.resumenEmpleado.innerHTML = `
                <div class="detalle-grid">
                    <div class="detalle-item">
                        <span class="detalle-label">Documento</span>
                        <span class="detalle-valor">${empleado.ValorDocumentoIdentidad}</span>
                    </div>
                    <div class="detalle-item">
                        <span class="detalle-label">Nombre</span>
                        <span class="detalle-valor">${empleado.Nombre}</span>
                    </div>
                    <div class="detalle-item">
                        <span class="detalle-label">Puesto</span>
                        <span class="detalle-valor">${empleado.NombrePuesto}</span>
                    </div>
                    <div class="detalle-item">
                        <span class="detalle-label">Saldo actual</span>
                        <span class="detalle-valor">${empleado.SaldoVacaciones}</span>
                    </div>
                </div>
            `;
        } catch (error) {
            console.error('Error cargando empleado:', error);
            this.tituloEmpleado.textContent = `Movimientos de ${this.documentoIdentidad}`;
            this.resumenEmpleado.innerHTML = '';
            this.setEstado('Error de conexión al cargar el empleado.', 'error');
        }
    }

    private async cargarMovimientos(): Promise<void> {
        try {
            const response = await fetch(`/api/movimientos/${encodeURIComponent(this.documentoIdentidad)}`, {
                method: 'GET',
            });

            const payload = await response.json() as {
                success: boolean;
                message?: string;
                data?: Movimiento[];
            };

            if (!response.ok || !payload.success) {
                this.renderMovimientos([]);
                this.contadorSpan.textContent = '0 movimientos';
                this.setEstado(payload.message || 'No se pudieron obtener los movimientos.', 'error');
                return;
            }

            const movimientos = payload.data ?? [];
            this.renderMovimientos(movimientos);
            this.contadorSpan.textContent = `${movimientos.length} movimiento${movimientos.length === 1 ? '' : 's'}`;

            if (movimientos.length === 0) {
                this.setEstado('El empleado no tiene movimientos registrados.', 'warning');
            } else {
                this.setEstado('Movimientos cargados correctamente.', 'success');
            }
        } catch (error) {
            console.error('Error cargando movimientos:', error);
            this.renderMovimientos([]);
            this.contadorSpan.textContent = '0 movimientos';
            this.setEstado('Error de conexión al cargar los movimientos.', 'error');
        }
    }

    private renderMovimientos(movimientos: Movimiento[]): void {
        this.movimientosBody.innerHTML = '';

        if (movimientos.length === 0) {
            this.movimientosBody.innerHTML = `
                <tr>
                    <td colspan="7" class="empty-state">No hay movimientos para mostrar</td>
                </tr>
            `;
            return;
        }

        for (const movimiento of movimientos) {
            const fila = document.createElement('tr');
            const fecha = this.formatearFecha(movimiento.Fecha);
            const estampa = this.formatearFechaHora(movimiento.PostTime);

            fila.innerHTML = `
                <td>${fecha}</td>
                <td>${movimiento.NombreTipoMovimiento}</td>
                <td>${movimiento.Monto}</td>
                <td>${movimiento.NuevoSaldo}</td>
                <td>${movimiento.UsuarioRegistro}</td>
                <td>${movimiento.IpPostIn}</td>
                <td>${estampa}</td>
            `;

            this.movimientosBody.appendChild(fila);
        }
    }

    private setEstado(mensaje: string, tipo: 'info' | 'success' | 'warning' | 'error'): void {
        this.estadoDiv.textContent = mensaje;
        this.estadoDiv.className = `status ${tipo}`;
    }

    private formatearFecha(valor: string): string {
        const fecha = new Date(valor);
        if (Number.isNaN(fecha.getTime())) {
            return valor;
        }

        return fecha.toLocaleDateString('es-ES');
    }

    private formatearFechaHora(valor: string): string {
        const fecha = new Date(valor);
        if (Number.isNaN(fecha.getTime())) {
            return valor;
        }

        return fecha.toLocaleString('es-ES');
    }
}

new MovimientosPage();