import { setEstado as setEstadoEl, logout, escapeHtml } from './utils.js';
class BitacoraPage {
    constructor() {
        this.paginaActual = 1;
        this.totalRegistros = 0;
        this.pageSize = 50;
        this.filtroTipoInput = document.getElementById('filtroTipo');
        this.filtroFechaDesdeInput = document.getElementById('filtroFechaDesde');
        this.filtroFechaHastaInput = document.getElementById('filtroFechaHasta');
        this.filtroIpInput = document.getElementById('filtroIp');
        this.buscarBtn = document.getElementById('buscarBtn');
        this.limpiarBtn = document.getElementById('limpiarBtn');
        this.mensajeDiv = document.getElementById('mensaje');
        this.contadorSpan = document.getElementById('contador');
        this.tablaBody = document.getElementById('bitacoraBody');
        this.paginacionDiv = document.getElementById('paginacion');
        this.logoutBtn = document.getElementById('logoutBtn');
        this.bindEvents();
        void this.cargarTiposEvento();
        void this.cargarBitacora();
    }
    bindEvents() {
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
    async cargarTiposEvento() {
        try {
            const token = localStorage.getItem('authToken') || '';
            const headers = {};
            if (token)
                headers['Authorization'] = 'Bearer ' + token;
            const response = await fetch('/api/bitacora/tipos-evento', { headers });
            const payload = await response.json();
            const tipos = payload.data ?? [];
            const opts = '<option value="">Todos los tipos</option>'
                + tipos.map(t => `<option value="${t.id}">${t.Nombre}</option>`).join('');
            this.filtroTipoInput.innerHTML = opts;
        }
        catch {
            this.filtroTipoInput.innerHTML = '<option value="">Todos los tipos</option>';
        }
    }
    async cargarBitacora() {
        const params = new URLSearchParams();
        params.set('page', String(this.paginaActual));
        params.set('pageSize', String(this.pageSize));
        const tipo = this.filtroTipoInput.value;
        if (tipo)
            params.set('idTipoEvento', tipo);
        const fechaDesde = this.filtroFechaDesdeInput.value;
        if (fechaDesde)
            params.set('fechaDesde', fechaDesde);
        const fechaHasta = this.filtroFechaHastaInput.value;
        if (fechaHasta)
            params.set('fechaHasta', fechaHasta);
        const ip = this.filtroIpInput.value.trim();
        if (ip)
            params.set('ip', ip);
        this.setEstado('Cargando bitácora...', 'info');
        this.buscarBtn.disabled = true;
        try {
            const token = localStorage.getItem('authToken') || '';
            const headers = {};
            if (token)
                headers['Authorization'] = 'Bearer ' + token;
            const response = await fetch(`/api/bitacora?${params.toString()}`, {
                method: 'GET',
                headers,
            });
            const payload = await response.json();
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
            }
            else {
                this.setEstado('Bitácora cargada correctamente.', 'success');
            }
        }
        catch (error) {
            console.error('Error cargando bitácora:', error);
            this.renderTabla([]);
            this.contadorSpan.textContent = '0 registros';
            this.setEstado('Error de conexión con el servidor.', 'error');
        }
        finally {
            this.buscarBtn.disabled = false;
        }
    }
    renderTabla(data) {
        this.tablaBody.innerHTML = '';
        if (data.length === 0) {
            this.tablaBody.innerHTML = `
                <tr>
                    <td colspan="5" class="empty-state">No hay registros en la bitácora.</td>
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
            `;
            this.tablaBody.appendChild(tr);
        }
    }
    renderPaginacion() {
        const totalPages = Math.ceil(this.totalRegistros / this.pageSize);
        this.paginacionDiv.innerHTML = '';
        if (totalPages <= 1)
            return;
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
    setEstado(texto, tipo) {
        setEstadoEl(this.mensajeDiv, texto, tipo);
    }
}
document.addEventListener('DOMContentLoaded', () => {
    new BitacoraPage();
});
