"use strict";
class MovimientosPage {
    constructor() {
        const params = new URLSearchParams(window.location.search);
        this.documentoIdentidad = params.get('documento')?.trim() ?? localStorage.getItem('ultimoDocumentoEmpleado')?.trim() ?? '';
        const insertarBtn = document.getElementById('insertarMovimientoBtn');
        if (insertarBtn) {
            insertarBtn.href = `/insertarMovimiento.html?documento=${encodeURIComponent(this.documentoIdentidad)}`;
        }
        this.tituloEmpleado = document.getElementById('tituloEmpleado');
        this.resumenEmpleado = document.getElementById('resumenEmpleado');
        this.estadoDiv = document.getElementById('estado');
        this.contadorSpan = document.getElementById('contador');
        this.movimientosBody = document.getElementById('movimientosBody');
        this.recargarBtn = document.getElementById('recargarBtn');
        this.logoutBtn = document.getElementById('logoutBtn');
        this.volverEmpleadosBtn = document.getElementById('volverEmpleadosBtn');
        this.bindEvents();
        void this.cargarVista();
    }
    bindEvents() {
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
    async cargarVista() {
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
    async cargarEmpleado() {
        try {
            const response = await fetch(`/api/empleados/${encodeURIComponent(this.documentoIdentidad)}`, {
                method: 'GET',
            });
            const payload = await response.json();
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
                        <span class="detalle-valor">${empleado.ValorDocumento}</span>
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
        }
        catch (error) {
            console.error('Error cargando empleado:', error);
            this.tituloEmpleado.textContent = `Movimientos de ${this.documentoIdentidad}`;
            this.resumenEmpleado.innerHTML = '';
            this.setEstado('Error de conexión al cargar el empleado.', 'error');
        }
    }
    async cargarMovimientos() {
        try {
            const response = await fetch(`/api/movimientos/${encodeURIComponent(this.documentoIdentidad)}`, {
                method: 'GET',
            });
            const payload = await response.json();
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
            }
            else {
                this.setEstado('Movimientos cargados correctamente.', 'success');
            }
        }
        catch (error) {
            console.error('Error cargando movimientos:', error);
            this.renderMovimientos([]);
            this.contadorSpan.textContent = '0 movimientos';
            this.setEstado('Error de conexión al cargar los movimientos.', 'error');
        }
    }
    renderMovimientos(movimientos) {
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
    setEstado(mensaje, tipo) {
        this.estadoDiv.textContent = mensaje;
        this.estadoDiv.className = `status ${tipo}`;
    }
    formatearFecha(valor) {
        const fecha = new Date(valor);
        if (Number.isNaN(fecha.getTime())) {
            return valor;
        }
        return fecha.toLocaleDateString('es-ES');
    }
    formatearFechaHora(valor) {
        const fecha = new Date(valor);
        if (Number.isNaN(fecha.getTime())) {
            return valor;
        }
        return fecha.toLocaleString('es-ES');
    }
}
new MovimientosPage();
