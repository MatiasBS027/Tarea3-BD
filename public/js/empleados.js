import { setEstado as setEstadoEl, logout, escapeHtml } from './utils.js';
class EmpleadosPage {
    constructor() {
        this.empleadoConsultado = null;
        this.deletePendienteId = null;
        // Cache
        this.puestos = [];
        this.filtroInput = document.getElementById('filtro');
        this.buscarBtn = document.getElementById('buscarBtn');
        this.limpiarBtn = document.getElementById('limpiarBtn');
        this.mensajeDiv = document.getElementById('mensaje');
        this.contadorSpan = document.getElementById('contador');
        this.empleadosBody = document.getElementById('empleadosBody');
        this.detallePanel = document.getElementById('detallePanel');
        this.detalleContenido = document.getElementById('detalleContenido');
        this.detalleTitulo = document.getElementById('detalleTitulo');
        this.detalleEstado = document.getElementById('detalleEstado');
        this.detalleCerrarBtn = document.getElementById('detalleCerrarBtn');
        this.logoutBtn = document.getElementById('logoutBtn');
        this.ingresarBtn = document.getElementById('ingresarBtn');
        this.empleadoModal = document.getElementById('empleadoModal');
        this.modalTitle = document.getElementById('modalTitle');
        this.modalCerrarBtn = document.getElementById('modalCerrarBtn');
        this.modalCancelarBtn = document.getElementById('modalCancelarBtn');
        this.empleadoForm = document.getElementById('empleadoForm');
        this.editEmpleadoId = document.getElementById('editEmpleadoId');
        this.modalValorDocumento = document.getElementById('modalValorDocumento');
        this.modalNombre = document.getElementById('modalNombre');
        this.modalIdPuesto = document.getElementById('modalIdPuesto');
        this.modalCuentaBancaria = document.getElementById('modalCuentaBancaria');
        this.modalCredentialFields = document.getElementById('modalCredentialFields');
        this.modalUsername = document.getElementById('modalUsername');
        this.modalPassword = document.getElementById('modalPassword');
        this.modalFechaContratacion = document.getElementById('modalFechaContratacion');
        this.deleteConfirmModal = document.getElementById('deleteConfirmModal');
        this.deleteEmpleadoNombre = document.getElementById('deleteEmpleadoNombre');
        this.deleteCancelarBtn = document.getElementById('deleteCancelarBtn');
        this.deleteConfirmarBtn = document.getElementById('deleteConfirmarBtn');
        this.bindEvents();
        void this.cargarPuestos();
        this.cargarEmpleados();
    }
    bindEvents() {
        this.buscarBtn.addEventListener('click', () => {
            void this.cargarEmpleados();
        });
        this.limpiarBtn.addEventListener('click', () => {
            this.filtroInput.value = '';
            void this.cargarEmpleados();
        });
        if (this.detalleCerrarBtn) {
            this.detalleCerrarBtn.addEventListener('click', () => {
                this.cerrarDetalle();
            });
        }
        this.filtroInput.addEventListener('keydown', (event) => {
            if (event.key === 'Enter') {
                event.preventDefault();
                void this.cargarEmpleados();
            }
        });
        this.empleadosBody.addEventListener('click', (event) => {
            const target = event.target;
            const button = target?.closest('button[data-accion]');
            if (!button)
                return;
            const accion = button.dataset.accion;
            if (accion === 'consultar') {
                const doc = button.dataset.documento;
                if (doc)
                    void this.consultarEmpleado(doc);
                return;
            }
            if (accion === 'impersonar') {
                const doc = button.dataset.documento;
                if (doc)
                    void this.impersonarEmpleado(doc);
                return;
            }
            if (accion === 'editar') {
                const id = Number(button.dataset.id);
                if (!isNaN(id))
                    void this.abrirModalEditar(id);
                return;
            }
            if (accion === 'borrar') {
                const id = Number(button.dataset.id);
                const nombre = button.dataset.nombre ?? '';
                if (!isNaN(id))
                    void this.iniciarBorrado(id, nombre);
            }
        });
        this.ingresarBtn.addEventListener('click', () => {
            this.abrirModalCrear();
        });
        this.modalCerrarBtn.addEventListener('click', () => {
            this.cerrarModal();
        });
        this.modalCancelarBtn.addEventListener('click', () => {
            this.cerrarModal();
        });
        this.empleadoForm.addEventListener('submit', (event) => {
            event.preventDefault();
            void this.guardarEmpleado();
        });
        this.deleteCancelarBtn.addEventListener('click', () => {
            this.cerrarDeleteConfirm();
        });
        this.deleteConfirmarBtn.addEventListener('click', () => {
            void this.ejecutarBorrado();
        });
        if (this.logoutBtn) {
            this.logoutBtn.addEventListener('click', () => {
                logout();
            });
        }
    }
    cerrarDetalle() {
        this.detallePanel.classList.add('hidden');
        this.empleadoConsultado = null;
    }
    // =================== Modal empleado ===================
    async cargarPuestos() {
        const token = localStorage.getItem('authToken') || '';
        const headers = {};
        if (token)
            headers['Authorization'] = 'Bearer ' + token;
        try {
            const res = await fetch('/api/puestos', { headers });
            const json = await res.json();
            if (json.success && json.data) {
                this.puestos = json.data;
                this.modalIdPuesto.innerHTML = '<option value="">Seleccione un puesto...</option>';
                for (const p of this.puestos) {
                    const opt = document.createElement('option');
                    opt.value = String(p.id);
                    opt.textContent = p.Nombre;
                    this.modalIdPuesto.appendChild(opt);
                }
            }
        }
        catch { /* ignore */ }
    }
    abrirModalCrear() {
        this.editEmpleadoId.value = '';
        this.empleadoForm.reset();
        this.modalTitle.textContent = 'Ingresar empleado';
        this.modalCredentialFields.style.display = '';
        this.modalUsername.required = true;
        this.modalPassword.required = true;
        this.empleadoModal.classList.remove('hidden');
    }
    async abrirModalEditar(id) {
        const token = localStorage.getItem('authToken') || '';
        const headers = {};
        if (token)
            headers['Authorization'] = 'Bearer ' + token;
        this.setEstado('Cargando datos del empleado...', 'info');
        try {
            const res = await fetch(`/api/empleados/by-id/${id}`, { headers });
            const json = await res.json();
            if (!json.success || !json.data) {
                this.setEstado('No se pudieron cargar los datos del empleado.', 'error');
                return;
            }
            const emp = json.data;
            this.editEmpleadoId.value = String(emp.id);
            this.modalValorDocumento.value = emp.ValorDocumento;
            this.modalNombre.value = emp.Nombre;
            this.modalIdPuesto.value = String(emp.idPuesto);
            this.modalCuentaBancaria.value = emp.CuentaBancaria ?? '';
            if (emp.FechaContratacion) {
                this.modalFechaContratacion.value = emp.FechaContratacion.substring(0, 10);
            }
            else {
                this.modalFechaContratacion.value = '';
            }
            this.modalTitle.textContent = 'Actualizar empleado';
            this.modalCredentialFields.style.display = 'none';
            this.modalUsername.required = false;
            this.modalPassword.required = false;
            this.empleadoModal.classList.remove('hidden');
        }
        catch {
            this.setEstado('Error de conexión al cargar empleado.', 'error');
        }
    }
    cerrarModal() {
        this.empleadoModal.classList.add('hidden');
        this.empleadoForm.reset();
        this.editEmpleadoId.value = '';
    }
    async guardarEmpleado() {
        const token = localStorage.getItem('authToken') || '';
        const headers = { 'Content-Type': 'application/json' };
        if (token)
            headers['Authorization'] = 'Bearer ' + token;
        const editId = this.editEmpleadoId.value;
        const body = {
            valorDocumento: this.modalValorDocumento.value.trim(),
            nombre: this.modalNombre.value.trim(),
            idPuesto: Number(this.modalIdPuesto.value),
            cuentaBancaria: this.modalCuentaBancaria.value.trim(),
        };
        if (this.modalFechaContratacion.value) {
            body.fechaContratacion = this.modalFechaContratacion.value;
        }
        this.setBotones(false);
        this.setEstado('Guardando...', 'info');
        try {
            let url = '/api/empleados';
            let method = 'POST';
            if (editId) {
                url = `/api/empleados/${editId}`;
                method = 'PATCH';
            }
            else {
                body.username = this.modalUsername.value.trim();
                body.password = this.modalPassword.value;
            }
            const res = await fetch(url, {
                method,
                headers,
                body: JSON.stringify(body),
            });
            const json = await res.json();
            if (!res.ok || !json.success) {
                this.setEstado(json.message || 'Error al guardar empleado.', 'error');
                return;
            }
            this.cerrarModal();
            this.setEstado(json.message || (editId ? 'Empleado actualizado.' : 'Empleado creado.'), 'success');
            await this.cargarEmpleados();
        }
        catch {
            this.setEstado('Error de conexión al guardar.', 'error');
        }
        finally {
            this.setBotones(true);
        }
    }
    // =================== Borrado ===================
    async iniciarBorrado(id, nombre) {
        const token = localStorage.getItem('authToken') || '';
        const headers = { 'Content-Type': 'application/json' };
        if (token)
            headers['Authorization'] = 'Bearer ' + token;
        this.setEstado('Registrando intento de borrado...', 'info');
        try {
            const res = await fetch(`/api/empleados/${id}`, {
                method: 'DELETE',
                headers,
                body: JSON.stringify({ confirmado: false }),
            });
            const json = await res.json();
            if (!res.ok || !json.success) {
                this.setEstado(json.message || 'Error al iniciar borrado.', 'error');
                return;
            }
            this.deletePendienteId = id;
            this.deleteEmpleadoNombre.textContent = nombre;
            this.deleteConfirmModal.classList.remove('hidden');
            this.setEstado('Intento de borrado registrado. Confirma la acción.', 'warning');
        }
        catch {
            this.setEstado('Error de conexión al iniciar borrado.', 'error');
        }
    }
    cerrarDeleteConfirm() {
        this.deleteConfirmModal.classList.add('hidden');
        this.deletePendienteId = null;
    }
    async ejecutarBorrado() {
        const id = this.deletePendienteId;
        if (id === null)
            return;
        const token = localStorage.getItem('authToken') || '';
        const headers = { 'Content-Type': 'application/json' };
        if (token)
            headers['Authorization'] = 'Bearer ' + token;
        this.deleteConfirmarBtn.disabled = true;
        this.setEstado('Borrando empleado...', 'info');
        try {
            const res = await fetch(`/api/empleados/${id}`, {
                method: 'DELETE',
                headers,
                body: JSON.stringify({ confirmado: true }),
            });
            const json = await res.json();
            if (!res.ok || !json.success) {
                this.setEstado(json.message || 'Error al borrar empleado.', 'error');
                return;
            }
            this.cerrarDeleteConfirm();
            this.setEstado('Empleado borrado exitosamente.', 'success');
            await this.cargarEmpleados();
        }
        catch {
            this.setEstado('Error de conexión al borrar.', 'error');
        }
        finally {
            this.deleteConfirmarBtn.disabled = false;
        }
    }
    async cargarEmpleados() {
        this.cerrarDetalle();
        const filtro = this.filtroInput.value.trim();
        const token = localStorage.getItem('authToken') || '';
        const headers = {};
        if (token)
            headers['Authorization'] = 'Bearer ' + token;
        this.setEstado('Cargando empleados...', 'info');
        this.setBotones(false);
        try {
            const response = await fetch(`/api/empleados?filtro=${encodeURIComponent(filtro)}`, {
                method: 'GET',
                headers,
            });
            const payload = await response.json();
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
            }
            else {
                this.setEstado('Empleados cargados correctamente.', 'success');
            }
        }
        catch (error) {
            console.error('Error cargando empleados:', error);
            this.limpiarTabla();
            this.contadorSpan.textContent = '0 resultados';
            this.setEstado('Error de conexión con el servidor.', 'error');
        }
        finally {
            this.setBotones(true);
        }
    }
    renderTabla(empleados) {
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
                <td>${escapeHtml(empleado.Nombre)}</td>
                <td>${escapeHtml(empleado.ValorDocumento)}</td>
                <td>${escapeHtml(empleado.NombrePuesto)}</td>
                <td>
                    <div class="action-group">
                    <button type="button" class="action-button action-view" data-accion="consultar" data-documento="${escapeHtml(empleado.ValorDocumento)}">
                        Consultar
                    </button>
                    <button type="button" class="action-button action-impersonar" data-accion="impersonar" data-documento="${escapeHtml(empleado.ValorDocumento)}">
                        Impersonar
                    </button>
                    <button type="button" class="action-button action-edit" data-accion="editar" data-id="${empleado.id}" data-nombre="${escapeHtml(empleado.Nombre)}">
                        Editar
                    </button>
                    <button type="button" class="action-button action-delete" data-accion="borrar" data-id="${empleado.id}" data-nombre="${escapeHtml(empleado.Nombre)}">
                        Borrar
                    </button>
                    </div>
                </td>
            `;
            this.empleadosBody.appendChild(fila);
        }
    }
    limpiarTabla() {
        this.empleadosBody.innerHTML = `
            <tr>
                <td colspan="4" class="empty-state">Todavía no hay datos cargados</td>
            </tr>
        `;
    }
    async impersonarEmpleado(valorDocumentoIdentidad) {
        const token = localStorage.getItem('authToken') || '';
        const headers = { 'Content-Type': 'application/json' };
        if (token)
            headers['Authorization'] = 'Bearer ' + token;
        this.setEstado('Impersonando empleado...', 'info');
        try {
            const response = await fetch('/api/empleados/impersonar', {
                method: 'POST',
                headers,
                body: JSON.stringify({ valorDocumento: valorDocumentoIdentidad }),
            });
            const payload = await response.json();
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
        }
        catch (error) {
            console.error('Error impersonando empleado:', error);
            this.setEstado('Error de conexión al impersonar.', 'error');
        }
    }
    async consultarEmpleado(valorDocumentoIdentidad) {
        // Toggle: si es el mismo empleado, cerrar
        if (this.empleadoConsultado === valorDocumentoIdentidad) {
            this.cerrarDetalle();
            return;
        }
        this.empleadoConsultado = valorDocumentoIdentidad;
        this.detallePanel.classList.remove('hidden');
        this.detalleTitulo.textContent = `Consulta de ${valorDocumentoIdentidad}`;
        this.detalleEstado.textContent = 'Cargando detalle del empleado...';
        this.detalleEstado.className = 'status info';
        this.detalleContenido.innerHTML = '';
        try {
            const token = localStorage.getItem('authToken') || '';
            const headers = {};
            if (token)
                headers['Authorization'] = 'Bearer ' + token;
            const response = await fetch(`/api/empleados/${encodeURIComponent(valorDocumentoIdentidad)}`, { headers });
            const payload = await response.json();
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
                    }
                    else {
                        fechaContratacion = String(rawFecha);
                    }
                }
                catch {
                    fechaContratacion = String(rawFecha);
                }
            }
            this.detalleEstado.textContent = 'Detalle cargado correctamente.';
            this.detalleEstado.className = 'status success';
            this.detalleContenido.innerHTML = `
                <div class="detalle-grid">
                    <div class="detalle-item">
                        <span class="detalle-label">Documento</span>
                        <span class="detalle-valor">${escapeHtml(detalle.ValorDocumento)}</span>
                    </div>
                    <div class="detalle-item">
                        <span class="detalle-label">Nombre</span>
                        <span class="detalle-valor">${escapeHtml(detalle.Nombre)}</span>
                    </div>
                    <div class="detalle-item">
                        <span class="detalle-label">Puesto</span>
                        <span class="detalle-valor">${escapeHtml(detalle.NombrePuesto)}</span>
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
        }
        catch (error) {
            console.error('Error consultando empleado:', error);
            this.detalleEstado.textContent = 'Error de conexión con el servidor.';
            this.detalleEstado.className = 'status error';
            this.detalleContenido.innerHTML = '';
        }
    }
    setEstado(texto, tipo) {
        setEstadoEl(this.mensajeDiv, texto, tipo);
    }
    setBotones(habilitado) {
        this.buscarBtn.disabled = !habilitado;
        this.limpiarBtn.disabled = !habilitado;
        this.ingresarBtn.disabled = !habilitado;
    }
}
document.addEventListener('DOMContentLoaded', () => {
    new EmpleadosPage();
});
