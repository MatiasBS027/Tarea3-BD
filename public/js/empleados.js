"use strict";
/**
* empleados.ts
* Lógica de la pantalla de empleados.
*
* Este archivo solo se encarga de la interfaz del navegador:
* - leer el filtro
* - llamar al backend
* - pintar la tabla
* - mostrar mensajes de estado
*/
class EmpleadosPage {
    constructor() {
        this.detalleActual = null;
        this.documentoActual = null;
        this.documentoPendienteBorrado = null;
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
        this.editarForm = document.getElementById('editarForm');
        this.documentoDespuesInput = document.getElementById('documentoDespues');
        this.nombreDespuesInput = document.getElementById('nombreDespues');
        this.idPuestoDespuesInput = document.getElementById('idPuestoDespues');
        this.cancelarEdicionBtn = document.getElementById('cancelarEdicionBtn');
        this.deleteModal = document.getElementById('deleteModal');
        this.deleteModalEstado = document.getElementById('deleteModalEstado');
        this.deleteDocumentoTexto = document.getElementById('deleteDocumentoTexto');
        this.confirmDeleteBtn = document.getElementById('confirmDeleteBtn');
        this.cancelDeleteBtn = document.getElementById('cancelDeleteBtn');
        this.closeDeleteModalBtn = document.getElementById('closeDeleteModalBtn');
        this.btnInsertar = document.getElementById('btnInsertar');
        this.insertModal = document.getElementById('insertModal');
        this.closeInsertModalBtn = document.getElementById('closeInsertModalBtn');
        this.insertForm = document.getElementById('insertForm');
        this.insertDocumentoInput = document.getElementById('insertDocumento');
        this.insertNombreInput = document.getElementById('insertNombre');
        this.insertPuestoSelect = document.getElementById('insertPuesto');
        this.cancelInsertBtn = document.getElementById('cancelInsertBtn');
        this.btnSidebarMovimientos = document.getElementById('btnSidebarMovimientos');
        this.logoutBtn = document.getElementById('logoutBtn');
        this.bindEvents();
        void this.cargarPuestos();
        this.cargarEmpleados();
    }
    bindEvents() {
        // Botón principal: ejecutar la búsqueda
        this.buscarBtn.addEventListener('click', () => {
            void this.cargarEmpleados();
        });
        // Botón secundario: limpiar el filtro y volver a cargar todo
        this.limpiarBtn.addEventListener('click', () => {
            this.filtroInput.value = '';
            void this.cargarEmpleados();
        });
        // Permitir Enter dentro de la caja de texto
        this.filtroInput.addEventListener('keydown', (event) => {
            if (event.key === 'Enter') {
                event.preventDefault();
                void this.cargarEmpleados();
            }
        });
        // Delegación de eventos: una sola escucha para todos los botones de la tabla
        this.empleadosBody.addEventListener('click', (event) => {
            const target = event.target;
            const button = target?.closest('button[data-accion]');
            if (!button) {
                return;
            }
            const documento = button.dataset.documento;
            if (!documento) {
                return;
            }
            const accion = button.dataset.accion;
            if (accion === 'consultar') {
                void this.consultarEmpleado(documento);
                return;
            }
            if (accion === 'editar') {
                void this.abrirEdicion(documento);
                return;
            }
            if (accion === 'movimientos') {
                this.abrirMovimientos(documento);
                return;
            }
            if (accion === 'borrar') {
                this.abrirModalBorrado(documento);
            }
            if (accion === 'impersonar') {
                void this.impersonarEmpleado(documento);
            }
        });
        // Insertar empleado: abrir modal
        if (this.btnInsertar) {
            this.btnInsertar.addEventListener('click', () => {
                this.openInsertModal();
            });
        }
        // Insert modal controls
        if (this.insertForm) {
            this.insertForm.addEventListener('submit', (event) => {
                event.preventDefault();
                void this.guardarInsercion();
            });
        }
        if (this.cancelInsertBtn) {
            this.cancelInsertBtn.addEventListener('click', () => {
                this.closeInsertModal();
            });
        }
        if (this.btnSidebarMovimientos) {
            this.btnSidebarMovimientos.addEventListener('click', () => {
                this.irAMovimientosSeleccionado();
            });
        }
        if (this.logoutBtn) {
            this.logoutBtn.addEventListener('click', () => {
                localStorage.removeItem('authToken');
                localStorage.removeItem('username');
                localStorage.removeItem('ultimoDocumentoEmpleado');
                window.location.href = '/login.html';
            });
        }
        if (this.closeInsertModalBtn) {
            this.closeInsertModalBtn.addEventListener('click', () => {
                this.closeInsertModal();
            });
        }
        this.editarForm.addEventListener('submit', (event) => {
            event.preventDefault();
            void this.guardarEdicion();
        });
        this.cancelarEdicionBtn.addEventListener('click', () => {
            this.editarForm.classList.add('hidden');
        });
        this.confirmDeleteBtn.addEventListener('click', () => {
            void this.confirmarBorradoPendiente();
        });
        this.cancelDeleteBtn.addEventListener('click', () => {
            void this.cancelarBorradoPendiente();
        });
        this.closeDeleteModalBtn.addEventListener('click', () => {
            void this.cancelarBorradoPendiente();
        });
        this.deleteModal.addEventListener('click', (event) => {
            if (event.target === this.deleteModal) {
                void this.cancelarBorradoPendiente();
            }
        });
    }
    async cargarEmpleados() {
        const filtro = this.filtroInput.value.trim();
        const username = localStorage.getItem('username') || 'UsuarioScripts';
        this.setEstado('Cargando empleados...', 'info');
        this.setBotones(false);
        try {
            const response = await fetch(`/api/empleados?filtro=${encodeURIComponent(filtro)}`, {
                method: 'GET',
                headers: {
                    'x-username': username,
                },
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
    async cargarPuestos() {
        try {
            const response = await fetch('/api/puestos', { method: 'GET' });
            const payload = await response.json();
            if (!response.ok || !payload.success) {
                this.renderPuestos([]);
                return;
            }
            this.puestos = payload.data ?? [];
            this.renderPuestos(this.puestos);
        }
        catch (error) {
            console.error('Error cargando puestos:', error);
            this.renderPuestos([]);
        }
    }
    renderPuestos(puestos) {
        const options = puestos.length === 0
            ? '<option value="">No hay puestos disponibles</option>'
            : '<option value="">Selecciona un puesto</option>' + puestos.map((puesto) => (`<option value="${puesto.id}">${puesto.Nombre}</option>`)).join('');
        // Actualiza el select de edición
        this.idPuestoDespuesInput.innerHTML = options;
        this.idPuestoDespuesInput.disabled = puestos.length === 0;
        // Si existe el select de inserción, actualizarlo también
        if (this.insertPuestoSelect) {
            this.insertPuestoSelect.innerHTML = options;
            this.insertPuestoSelect.disabled = puestos.length === 0;
        }
    }
    openInsertModal() {
        if (!this.insertModal)
            return;
        this.insertForm.reset();
        this.insertModal.classList.remove('hidden');
    }
    closeInsertModal() {
        if (!this.insertModal)
            return;
        this.insertModal.classList.add('hidden');
    }
    validarInsercion() {
        const documento = this.insertDocumentoInput.value.trim();
        const nombre = this.insertNombreInput.value.trim();
        const idPuesto = Number(this.insertPuestoSelect.value);
        if (!documento)
            return 'El documento es obligatorio.';
        if (!/^[0-9]{3,32}$/.test(documento))
            return 'El documento debe tener solo números y al menos 3 dígitos.';
        if (!nombre)
            return 'El nombre es obligatorio.';
        if (nombre.length < 3 || nombre.length > 128)
            return 'El nombre debe tener entre 3 y 128 caracteres.';
        if (!/^[A-Za-zÁÉÍÓÚÜÑáéíóúüñ0-9.' -]+$/.test(nombre))
            return 'El nombre contiene caracteres no permitidos.';
        if (Number.isNaN(idPuesto) || idPuesto <= 0)
            return 'Debes seleccionar un puesto válido.';
        return null;
    }
    async guardarInsercion() {
        const username = localStorage.getItem('username') || 'UsuarioScripts';
        const documento = this.insertDocumentoInput.value.trim();
        const nombre = this.insertNombreInput.value.trim();
        const idPuesto = Number(this.insertPuestoSelect.value);
        const errorValidacion = this.validarInsercion();
        if (errorValidacion) {
            this.setEstado(errorValidacion, 'warning');
            return;
        }
        this.setEstado('Creando empleado...', 'info');
        try {
            const response = await fetch('/api/empleados', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'x-username': username,
                },
                body: JSON.stringify({
                    valorDocumentoIdentidad: documento,
                    nombre,
                    idPuesto,
                }),
            });
            const payload = await response.json();
            if (!response.ok || !payload.success) {
                this.setEstado(payload.message || 'No se pudo crear el empleado.', 'error');
                return;
            }
            this.setEstado('Empleado creado correctamente.', 'success');
            this.closeInsertModal();
            await this.cargarEmpleados();
        }
        catch (error) {
            console.error('Error creando empleado:', error);
            this.setEstado('Error de conexión al crear empleado.', 'error');
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
                <td>${empleado.Nombre}</td>
                <td>${empleado.ValorDocumentoIdentidad}</td>
                <td>${empleado.NombrePuesto}</td>
                <td>
                    <button type="button" class="action-button action-view" data-accion="consultar" data-documento="${empleado.ValorDocumentoIdentidad}">
                        Consultar
                    </button>
                    <button type="button" class="action-button action-edit" data-accion="editar" data-documento="${empleado.ValorDocumentoIdentidad}">
                        Editar
                    </button>
                    <button type="button" class="action-button action-view" data-accion="movimientos" data-documento="${empleado.ValorDocumentoIdentidad}">
                        Movimientos
                    </button>
                    <button type="button" class="action-button action-impersonar" data-accion="impersonar" data-documento="${empleado.ValorDocumentoIdentidad}">
                        Impersonar
                    </button>
                    <button type="button" class="action-button action-delete" data-accion="borrar" data-documento="${empleado.ValorDocumentoIdentidad}">
                        Borrar
                    </button>
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
    abrirMovimientos(valorDocumentoIdentidad) {
        localStorage.setItem('ultimoDocumentoEmpleado', valorDocumentoIdentidad);
        window.location.href = `/movimientos.html?documento=${encodeURIComponent(valorDocumentoIdentidad)}`;
    }
    async impersonarEmpleado(valorDocumentoIdentidad) {
        const username = localStorage.getItem('username') || 'UsuarioScripts';
        this.setEstado(`Impersonando a ${valorDocumentoIdentidad}...`, 'info');
        try {
            const response = await fetch('/api/auth/impersonar', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'x-username': username,
                },
                body: JSON.stringify({ valorDocumentoIdentidad }),
            });
            const payload = await response.json();
            if (!response.ok || !payload.success) {
                this.setEstado(payload.message || 'No se pudo iniciar la impersonación.', 'error');
                return;
            }
            const idEmpleado = Number(payload.idEmpleado ?? 0);
            if (!idEmpleado) {
                this.setEstado('La respuesta del servidor no incluyó el id del empleado.', 'error');
                return;
            }
            localStorage.setItem('impersonatedIdEmpleado', String(idEmpleado));
            localStorage.setItem('impersonatedDocumento', valorDocumentoIdentidad);
            localStorage.setItem('impersonatedNombre', this.nombreDeEmpleadoActual(valorDocumentoIdentidad));
            window.location.href = `/empleado.html?idEmpleado=${idEmpleado}&documento=${encodeURIComponent(valorDocumentoIdentidad)}`;
        }
        catch (error) {
            console.error('Error impersonando empleado:', error);
            this.setEstado('Error de conexión con el servidor.', 'error');
        }
    }
    nombreDeEmpleadoActual(documento) {
        if (this.detalleActual && this.detalleActual.ValorDocumentoIdentidad === documento) {
            return this.detalleActual.Nombre || '';
        }
        const filas = this.empleadosBody.querySelectorAll('tr');
        for (const fila of filas) {
            const docCell = fila.children?.[1]?.textContent?.trim();
            if (docCell === documento) {
                return fila.children?.[0]?.textContent?.trim() || '';
            }
        }
        return '';
    }
    irAMovimientosSeleccionado() {
        const documento = this.documentoActual || localStorage.getItem('ultimoDocumentoEmpleado') || '';
        if (!documento) {
            this.setEstado('Primero consulta o selecciona un empleado y luego abre sus movimientos.', 'warning');
            return;
        }
        window.location.href = `/movimientos.html?documento=${encodeURIComponent(documento)}`;
    }
    async consultarEmpleado(valorDocumentoIdentidad) {
        const username = localStorage.getItem('username') || 'UsuarioScripts';
        this.detallePanel.classList.remove('hidden');
        this.editarForm.classList.add('hidden');
        this.detalleTitulo.textContent = `Consulta de ${valorDocumentoIdentidad}`;
        this.detalleEstado.textContent = 'Cargando detalle del empleado...';
        this.detalleEstado.className = 'status info';
        this.detalleContenido.innerHTML = '';
        try {
            const response = await fetch(`/api/empleados/${encodeURIComponent(valorDocumentoIdentidad)}`, {
                method: 'GET',
                headers: {
                    'x-username': username,
                },
            });
            const payload = await response.json();
            if (!response.ok || !payload.success || !payload.data) {
                this.detalleEstado.textContent = payload.message || 'No se pudo cargar el detalle.';
                this.detalleEstado.className = 'status error';
                this.detalleContenido.innerHTML = '';
                return;
            }
            const detalle = payload.data;
            const rawFecha = detalle.FechaContratación ?? detalle.FechaContratacion ?? '';
            let fechaContratacion = '';
            if (rawFecha) {
                try {
                    const d = new Date(rawFecha);
                    if (!isNaN(d.getTime())) {
                        // Mostrar fecha en formato local español (dd/mm/yyyy)
                        fechaContratacion = d.toLocaleDateString('es-ES');
                    }
                    else {
                        fechaContratacion = String(rawFecha);
                    }
                }
                catch (e) {
                    fechaContratacion = String(rawFecha);
                }
            }
            this.detalleActual = detalle;
            this.documentoActual = detalle.ValorDocumentoIdentidad;
            localStorage.setItem('ultimoDocumentoEmpleado', detalle.ValorDocumentoIdentidad);
            this.detalleEstado.textContent = 'Detalle cargado correctamente.';
            this.detalleEstado.className = 'status success';
            this.detalleContenido.innerHTML = `
                <div class="detalle-grid">
                    <div class="detalle-item">
                        <span class="detalle-label">Documento</span>
                        <span class="detalle-valor">${detalle.ValorDocumentoIdentidad}</span>
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
                        <span class="detalle-label">Saldo vacaciones</span>
                        <span class="detalle-valor">${detalle.SaldoVacaciones}</span>
                    </div>
                    <div class="detalle-item">
                        <span class="detalle-label">Estado</span>
                        <span class="detalle-valor">${detalle.EsActivo ? 'Activo' : 'Inactivo'}</span>
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
    async abrirEdicion(valorDocumentoIdentidad) {
        await this.consultarEmpleado(valorDocumentoIdentidad);
        if (!this.detalleActual) {
            return;
        }
        this.documentoDespuesInput.value = this.detalleActual.ValorDocumentoIdentidad;
        this.nombreDespuesInput.value = this.detalleActual.Nombre;
        this.idPuestoDespuesInput.value = String(this.detalleActual.idPuesto);
        this.editarForm.classList.remove('hidden');
        this.detalleEstado.textContent = 'Edita los campos y guarda cambios.';
        this.detalleEstado.className = 'status info';
    }
    validarEdicion() {
        const documento = this.documentoDespuesInput.value.trim();
        const nombre = this.nombreDespuesInput.value.trim();
        const idPuesto = Number(this.idPuestoDespuesInput.value);
        if (!documento) {
            return 'El documento después es obligatorio.';
        }
        if (!/^\d{3,32}$/.test(documento)) {
            return 'El documento debe tener solo números y al menos 3 dígitos.';
        }
        if (!nombre) {
            return 'El nombre después es obligatorio.';
        }
        if (nombre.length < 3 || nombre.length > 128) {
            return 'El nombre debe tener entre 3 y 128 caracteres.';
        }
        if (!/^[A-Za-zÁÉÍÓÚÜÑáéíóúüñ0-9.' -]+$/.test(nombre)) {
            return 'El nombre contiene caracteres no permitidos.';
        }
        if (Number.isNaN(idPuesto) || idPuesto <= 0) {
            return 'Debes seleccionar un puesto válido.';
        }
        return null;
    }
    async guardarEdicion() {
        if (!this.detalleActual || !this.documentoActual) {
            this.detalleEstado.textContent = 'Primero consulta un empleado antes de editar.';
            this.detalleEstado.className = 'status warning';
            return;
        }
        const username = localStorage.getItem('username') || 'UsuarioScripts';
        const valorDocumentoIdentidadDespues = this.documentoDespuesInput.value.trim();
        const nombreDespues = this.nombreDespuesInput.value.trim();
        const idPuestoDespues = Number(this.idPuestoDespuesInput.value);
        const errorValidacion = this.validarEdicion();
        if (errorValidacion) {
            this.detalleEstado.textContent = errorValidacion;
            this.detalleEstado.className = 'status warning';
            return;
        }
        this.detalleEstado.textContent = 'Guardando cambios...';
        this.detalleEstado.className = 'status info';
        try {
            const response = await fetch(`/api/empleados/${encodeURIComponent(this.documentoActual)}`, {
                method: 'PATCH',
                headers: {
                    'Content-Type': 'application/json',
                    'x-username': username,
                },
                body: JSON.stringify({
                    valorDocumentoIdentidadDespues,
                    nombreAntes: this.detalleActual.Nombre,
                    nombreDespues,
                    idPuestoAntes: this.detalleActual.idPuesto,
                    idPuestoDespues,
                }),
            });
            const payload = await response.json();
            if (!response.ok || !payload.success) {
                this.detalleEstado.textContent = payload.message || 'No se pudo actualizar el empleado.';
                this.detalleEstado.className = 'status error';
                return;
            }
            this.detalleEstado.textContent = 'Empleado actualizado correctamente.';
            this.detalleEstado.className = 'status success';
            this.editarForm.classList.add('hidden');
            await this.cargarEmpleados();
            await this.consultarEmpleado(valorDocumentoIdentidadDespues);
        }
        catch (error) {
            console.error('Error actualizando empleado:', error);
            this.detalleEstado.textContent = 'Error de conexión al actualizar el empleado.';
            this.detalleEstado.className = 'status error';
        }
    }
    abrirModalBorrado(valorDocumentoIdentidad) {
        this.documentoPendienteBorrado = valorDocumentoIdentidad;
        this.deleteDocumentoTexto.textContent = `¿Deseas eliminar lógicamente al empleado ${valorDocumentoIdentidad}?`;
        this.deleteModalEstado.textContent = 'Esta acción desactiva al empleado, no lo elimina físicamente.';
        this.deleteModalEstado.className = 'status warning';
        this.deleteModal.classList.remove('hidden');
    }
    cerrarModalBorrado() {
        this.deleteModal.classList.add('hidden');
        this.documentoPendienteBorrado = null;
    }
    async confirmarBorradoPendiente() {
        if (!this.documentoPendienteBorrado) {
            return;
        }
        await this.borrarEmpleado(this.documentoPendienteBorrado, true);
    }
    async cancelarBorradoPendiente() {
        if (!this.documentoPendienteBorrado) {
            this.cerrarModalBorrado();
            return;
        }
        await this.borrarEmpleado(this.documentoPendienteBorrado, false);
    }
    async borrarEmpleado(valorDocumentoIdentidad, confirmado) {
        const username = localStorage.getItem('username') || 'UsuarioScripts';
        this.confirmDeleteBtn.disabled = true;
        this.cancelDeleteBtn.disabled = true;
        this.closeDeleteModalBtn.disabled = true;
        try {
            const response = await fetch(`/api/empleados/${encodeURIComponent(valorDocumentoIdentidad)}`, {
                method: 'DELETE',
                headers: {
                    'Content-Type': 'application/json',
                    'x-username': username,
                },
                body: JSON.stringify({ confirmado }),
            });
            const payload = await response.json();
            if (!response.ok || !payload.success) {
                this.deleteModalEstado.textContent = payload.message || 'No se pudo eliminar el empleado.';
                this.deleteModalEstado.className = 'status error';
                return;
            }
            this.cerrarModalBorrado();
            if (!confirmado) {
                this.setEstado('Intento de borrado registrado (no confirmado).', 'warning');
                return;
            }
            this.setEstado('Empleado eliminado lógicamente.', 'success');
            this.detallePanel.classList.add('hidden');
            this.detalleActual = null;
            this.documentoActual = null;
            await this.cargarEmpleados();
        }
        catch (error) {
            console.error('Error eliminando empleado:', error);
            this.deleteModalEstado.textContent = 'Error de conexión al eliminar empleado.';
            this.deleteModalEstado.className = 'status error';
        }
        finally {
            this.confirmDeleteBtn.disabled = false;
            this.cancelDeleteBtn.disabled = false;
            this.closeDeleteModalBtn.disabled = false;
        }
    }
    setEstado(texto, tipo) {
        this.mensajeDiv.textContent = texto;
        this.mensajeDiv.className = `status ${tipo}`;
    }
    setBotones(habilitado) {
        this.buscarBtn.disabled = !habilitado;
        this.limpiarBtn.disabled = !habilitado;
    }
}
document.addEventListener('DOMContentLoaded', () => {
    new EmpleadosPage();
});
