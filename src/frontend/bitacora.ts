import { setEstado as setEstadoEl, logout, escapeHtml } from './utils.js';

type BitacoraRow = {
    id: number;
    idTipoEvento: number;
    TipoEvento: string;
    idUsuario: number | null;
    Username: string | null;
    Descripcion: string;
    PostTime: string;
    IpPostIn: string;
};

type BitacoraResponse = {
    success: boolean;
    outResultCode: number;
    message?: string;
    data?: BitacoraRow[];
    total?: number;
};

class BitacoraPage {
    private readonly filtroTipoInput: HTMLSelectElement;
    private readonly filtroFechaDesdeInput: HTMLInputElement;
    private readonly filtroFechaHastaInput: HTMLInputElement;
    private readonly filtroIpInput: HTMLInputElement;
    private readonly buscarBtn: HTMLButtonElement;
    private readonly limpiarBtn: HTMLButtonElement;
    private readonly mensajeDiv: HTMLElement;
    private readonly contadorSpan: HTMLElement;
    private readonly tablaBody: HTMLTableSectionElement;
    private readonly paginacionDiv: HTMLElement;
    private readonly logoutBtn: HTMLButtonElement;

    private paginaActual = 1;
    private totalRegistros = 0;
    private readonly pageSize = 50;

    constructor() {
        this.filtroTipoInput = document.getElementById('filtroTipo') as HTMLSelectElement;
        this.filtroFechaDesdeInput = document.getElementById('filtroFechaDesde') as HTMLInputElement;
        this.filtroFechaHastaInput = document.getElementById('filtroFechaHasta') as HTMLInputElement;
        this.filtroIpInput = document.getElementById('filtroIp') as HTMLInputElement;
        this.buscarBtn = document.getElementById('buscarBtn') as HTMLButtonElement;
        this.limpiarBtn = document.getElementById('limpiarBtn') as HTMLButtonElement;
        this.mensajeDiv = document.getElementById('mensaje') as HTMLElement;
        this.contadorSpan = document.getElementById('contador') as HTMLElement;
        this.tablaBody = document.getElementById('bitacoraBody') as HTMLTableSectionElement;
        this.paginacionDiv = document.getElementById('paginacion') as HTMLElement;
        this.logoutBtn = document.getElementById('logoutBtn') as HTMLButtonElement;

        this.bindEvents();
        void this.cargarTiposEvento();
        void this.cargarBitacora();
    }

    private bindEvents(): void {
        this.buscarBtn.addEventListener('click', () => {
            this.paginaActual = 1;
            void this.cargarBitacora();
        });

        this.limpiarBtn.addEventListener('click', () => {
            this.filtroTipoInput.value = '';
            this.filtroFechaDesdeInput.value = '';
            this.filtroFechaHastaInput.value = '';
            this.filtroIpInput.value = '';
            this.paginaActual = 1;
            void this.cargarBitacora();
        });

        if (this.logoutBtn) {
            this.logoutBtn.addEventListener('click', () => {
                logout();
            });
        }
    }

    private async cargarTiposEvento(): Promise<void> {
        try {
            const token = localStorage.getItem('authToken') || '';
            const headers: Record<string, string> = {};
            if (token) headers['Authorization'] = 'Bearer ' + token;
            const response = await fetch('/api/bitacora/tipos-evento', { headers });
            const payload = await response.json() as { data?: { id: number; Nombre: string }[] };
            const tipos = payload.data ?? [];
            const opts = '<option value="">Todos los tipos</option>'
                + tipos.map(t => `<option value="${t.id}">${t.Nombre}</option>`).join('');
            this.filtroTipoInput.innerHTML = opts;
        } catch {
            this.filtroTipoInput.innerHTML = '<option value="">Todos los tipos</option>';
        }
    }

    private async cargarBitacora(): Promise<void> {
        const params = new URLSearchParams();
        params.set('page', String(this.paginaActual));
        params.set('pageSize', String(this.pageSize));

        const tipo = this.filtroTipoInput.value;
        if (tipo) params.set('idTipoEvento', tipo);

        const fechaDesde = this.filtroFechaDesdeInput.value;
        if (fechaDesde) params.set('fechaDesde', fechaDesde);

        const fechaHasta = this.filtroFechaHastaInput.value;
        if (fechaHasta) params.set('fechaHasta', fechaHasta);

        const ip = this.filtroIpInput.value.trim();
        if (ip) params.set('ip', ip);

        this.setEstado('Cargando bitácora...', 'info');
        this.buscarBtn.disabled = true;

        try {
            const token = localStorage.getItem('authToken') || '';
            const headers: Record<string, string> = {};
            if (token) headers['Authorization'] = 'Bearer ' + token;

            const response = await fetch(`/api/bitacora?${params.toString()}`, {
                method: 'GET',
                headers,
            });

            const payload = await response.json() as BitacoraResponse;

            if (!response.ok || !payload.success) {
                this.renderTabla([]);
                this.contadorSpan.textContent = '0 registros';
                this.setEstado(payload.message || 'Error al cargar bitácora.', 'error');
                return;
            }

            const data = payload.data ?? [];
            this.totalRegistros = payload.total ?? 0;
            this.renderTabla(data);
            this.contadorSpan.textContent = `${this.totalRegistros} registro${this.totalRegistros === 1 ? '' : 's'}`;
            this.renderPaginacion();

            if (data.length === 0) {
                this.setEstado('No se encontraron registros.', 'warning');
            } else {
                this.setEstado('Bitácora cargada correctamente.', 'success');
            }
        } catch (error) {
            console.error('Error cargando bitácora:', error);
            this.renderTabla([]);
            this.contadorSpan.textContent = '0 registros';
            this.setEstado('Error de conexión con el servidor.', 'error');
        } finally {
            this.buscarBtn.disabled = false;
        }
    }

    private renderTabla(data: BitacoraRow[]): void {
        this.tablaBody.innerHTML = '';

        if (data.length === 0) {
            this.tablaBody.innerHTML = `
                <tr>
                    <td colspan="6" class="empty-state">No hay registros en la bitácora.</td>
                </tr>
            `;
            return;
        }

        for (const row of data) {
            const tr = document.createElement('tr');
            const fecha = row.PostTime
                ? new Date(row.PostTime).toLocaleString('es-ES')
                : '';

            tr.innerHTML = `
                <td>${fecha}</td>
                <td><span class="badge badge-event">${escapeHtml(row.TipoEvento)}</span></td>
                <td>${escapeHtml(row.Username ?? '-')}</td>
                <td>${escapeHtml(row.Descripcion || '-')}</td>
                <td>${escapeHtml(row.IpPostIn)}</td>
                <td>${row.id}</td>
            `;
            this.tablaBody.appendChild(tr);
        }
    }

    private renderPaginacion(): void {
        const totalPages = Math.ceil(this.totalRegistros / this.pageSize);
        this.paginacionDiv.innerHTML = '';

        if (totalPages <= 1) return;

        const nav = document.createElement('div');
        nav.className = 'pagination-nav';

        const prevBtn = document.createElement('button');
        prevBtn.type = 'button';
        prevBtn.className = 'ghost-btn';
        prevBtn.textContent = 'Anterior';
        prevBtn.disabled = this.paginaActual <= 1;
        prevBtn.addEventListener('click', () => {
            if (this.paginaActual > 1) {
                this.paginaActual--;
                void this.cargarBitacora();
            }
        });
        nav.appendChild(prevBtn);

        const pageSpan = document.createElement('span');
        pageSpan.className = 'pagination-info';
        pageSpan.textContent = `Página ${this.paginaActual} de ${totalPages}`;
        nav.appendChild(pageSpan);

        const nextBtn = document.createElement('button');
        nextBtn.type = 'button';
        nextBtn.className = 'ghost-btn';
        nextBtn.textContent = 'Siguiente';
        nextBtn.disabled = this.paginaActual >= totalPages;
        nextBtn.addEventListener('click', () => {
            if (this.paginaActual < totalPages) {
                this.paginaActual++;
                void this.cargarBitacora();
            }
        });
        nav.appendChild(nextBtn);

        this.paginacionDiv.appendChild(nav);
    }

    private setEstado(texto: string, tipo: 'info' | 'success' | 'warning' | 'error'): void {
        setEstadoEl(this.mensajeDiv, texto, tipo);
    }
}

document.addEventListener('DOMContentLoaded', () => {
    new BitacoraPage();
});
