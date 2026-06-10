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

type Empleado = {
    Nombre: string;
    ValorDocumento: string;
    idPuesto: number;
    NombrePuesto: string;
};

type Puesto = {
    id: number;
    Nombre: string;
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
    private editarForm: HTMLFormElement;
    private documentoDespuesInput: HTMLInputElement;
    private nombreDespuesInput: HTMLInputElement;
    private idPuestoDespuesInput: HTMLSelectElement;
    private cancelarEdicionBtn: HTMLButtonElement;
    private deleteModal: HTMLElement;
    private deleteModalEstado: HTMLElement;
    private deleteDocumentoTexto: HTMLElement;
    private confirmDeleteBtn: HTMLButtonElement;
    private cancelDeleteBtn: HTMLButtonElement;
    private closeDeleteModalBtn: HTMLButtonElement;
    private btnInsertar: HTMLButtonElement;
    private insertModal: HTMLElement;
    private closeInsertModalBtn: HTMLButtonElement;
    private insertForm: HTMLFormElement;
    private insertDocumentoInput: HTMLInputElement;
    private insertNombreInput: HTMLInputElement;
    private insertPuestoSelect: HTMLSelectElement;
    private cancelInsertBtn: HTMLButtonElement;
    private logoutBtn: HTMLButtonElement;
    private detalleActual: EmpleadoDetalle | null = null;
    private documentoActual: string | null = null;
    private documentoPendienteBorrado: string | null = null;
    private puestos: Puesto[] = [];

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
        this.editarForm = document.getElementById('editarForm') as HTMLFormElement;
        this.documentoDespuesInput = document.getElementById('documentoDespues') as HTMLInputElement;
        this.nombreDespuesInput = document.getElementById('nombreDespues') as HTMLInputElement;
        this.idPuestoDespuesInput = document.getElementById('idPuestoDespues') as HTMLSelectElement;
        this.cancelarEdicionBtn = document.getElementById('cancelarEdicionBtn') as HTMLButtonElement;
        this.deleteModal = document.getElementById('deleteModal') as HTMLElement;
        this.deleteModalEstado = document.getElementById('deleteModalEstado') as HTMLElement;
        this.deleteDocumentoTexto = document.getElementById('deleteDocumentoTexto') as HTMLElement;
        this.confirmDeleteBtn = document.getElementById('confirmDeleteBtn') as HTMLButtonElement;
        this.cancelDeleteBtn = document.getElementById('cancelDeleteBtn') as HTMLButtonElement;
        this.closeDeleteModalBtn = document.getElementById('closeDeleteModalBtn') as HTMLButtonElement;
        this.btnInsertar = document.getElementById('btnInsertar') as HTMLButtonElement;
        this.insertModal = document.getElementById('insertModal') as HTMLElement;
        this.closeInsertModalBtn = document.getElementById('closeInsertModalBtn') as HTMLButtonElement;
        this.insertForm = document.getElementById('insertForm') as HTMLFormElement;
        this.insertDocumentoInput = document.getElementById('insertDocumento') as HTMLInputElement;
        this.insertNombreInput = document.getElementById('insertNombre') as HTMLInputElement;
        this.insertPuestoSelect = document.getElementById('insertPuesto') as HTMLSelectElement;
        this.cancelInsertBtn = document.getElementById('cancelInsertBtn') as HTMLButtonElement;
        this.logoutBtn = document.getElementById('logoutBtn') as HTMLButtonElement;

        this.bindEvents();
        void this.cargarPuestos();
        this.cargarEmpleados();
    }

    private bindEvents(): void {
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
            const target = event.target as HTMLElement | null;
            const button = target?.closest('button[data-accion]') as HTMLButtonElement | null;

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

            if (accion === 'impersonar') {
                void this.impersonarEmpleado(documento);
                return;
            }

            if (accion === 'borrar') {
                this.abrirModalBorrado(documento);
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

    private async cargarEmpleados(): Promise<void> {
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

    private async cargarPuestos(): Promise<void> {
        try {
            const response = await fetch('/api/puestos', { method: 'GET' });

            const payload = await response.json() as {
                success: boolean;
                outResultCode: number;
                message?: string;
                data?: Puesto[];
            };

            if (!response.ok || !payload.success) {
                this.renderPuestos([]);
                return;
            }

            this.puestos = payload.data ?? [];
            this.renderPuestos(this.puestos);
        } catch (error) {
            console.error('Error cargando puestos:', error);
            this.renderPuestos([]);
        }
    }

    private renderPuestos(puestos: Puesto[]): void {
        const options = puestos.length === 0
            ? '<option value="">No hay puestos disponibles</option>'
            : '<option value="">Selecciona un puesto</option>' + puestos.map((puesto) => (
                `<option value="${puesto.id}">${puesto.Nombre}</option>`
            )).join('');

        // Actualiza el select de edición
        this.idPuestoDespuesInput.innerHTML = options;
        this.idPuestoDespuesInput.disabled = puestos.length === 0;

        // Si existe el select de inserción, actualizarlo también
        if (this.insertPuestoSelect) {
            this.insertPuestoSelect.innerHTML = options;
            this.insertPuestoSelect.disabled = puestos.length === 0;
        }
    }

    private openInsertModal(): void {
        if (!this.insertModal) return;
        this.insertForm.reset();
        this.insertModal.classList.remove('hidden');
    }

    private closeInsertModal(): void {
        if (!this.insertModal) return;
        this.insertModal.classList.add('hidden');
    }

    private validarInsercion(): string | null {
        const documento = this.insertDocumentoInput.value.trim();
        const nombre = this.insertNombreInput.value.trim();
        const idPuesto = Number(this.insertPuestoSelect.value);

        if (!documento) return 'El documento es obligatorio.';
        if (!/^[0-9]{3,32}$/.test(documento)) return 'El documento debe tener solo números y al menos 3 dígitos.';
        if (!nombre) return 'El nombre es obligatorio.';
        if (nombre.length < 3 || nombre.length > 128) return 'El nombre debe tener entre 3 y 128 caracteres.';
        if (!/^[A-Za-zÁÉÍÓÚÜÑáéíóúüñ0-9.' -]+$/.test(nombre)) return 'El nombre contiene caracteres no permitidos.';
        if (Number.isNaN(idPuesto) || idPuesto <= 0) return 'Debes seleccionar un puesto válido.';
        return null;
    }

    private async guardarInsercion(): Promise<void> {
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

            const payload = await response.json() as { success: boolean; outResultCode: number; message?: string };

            if (!response.ok || !payload.success) {
                this.setEstado(payload.message || 'No se pudo crear el empleado.', 'error');
                return;
            }

            this.setEstado('Empleado creado correctamente.', 'success');
            this.closeInsertModal();
            await this.cargarEmpleados();
        } catch (error) {
            console.error('Error creando empleado:', error);
            this.setEstado('Error de conexión al crear empleado.', 'error');
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
                    <button type="button" class="action-button action-edit" data-accion="editar" data-documento="${empleado.ValorDocumento}">
                        Editar
                    </button>
                    <button type="button" class="action-button action-view" data-accion="impersonar" data-documento="${empleado.ValorDocumento}">
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
        const username = localStorage.getItem('username') || '';

        this.setEstado('Impersonando empleado...', 'info');

        try {
            const response = await fetch('/api/empleados/impersonar', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'x-username': username,
                },
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
                        // Mostrar fecha en formato local español (dd/mm/yyyy)
                        fechaContratacion = d.toLocaleDateString('es-ES');
                    } else {
                        fechaContratacion = String(rawFecha);
                    }
                } catch (e) {
                    fechaContratacion = String(rawFecha);
                }
            }
            this.detalleActual = detalle;
            this.documentoActual = detalle.ValorDocumento;
            localStorage.setItem('ultimoDocumentoEmpleado', detalle.ValorDocumento);
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

    private async abrirEdicion(valorDocumentoIdentidad: string): Promise<void> {
        await this.consultarEmpleado(valorDocumentoIdentidad);

        if (!this.detalleActual) {
            return;
        }

        this.documentoDespuesInput.value = this.detalleActual.ValorDocumento;
        this.nombreDespuesInput.value = this.detalleActual.Nombre;
        this.idPuestoDespuesInput.value = String(this.detalleActual.idPuesto);
        this.editarForm.classList.remove('hidden');
        this.detalleEstado.textContent = 'Edita los campos y guarda cambios.';
        this.detalleEstado.className = 'status info';
    }

    private validarEdicion(): string | null {
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

    private async guardarEdicion(): Promise<void> {
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

            const payload = await response.json() as {
                success: boolean;
                outResultCode: number;
                message?: string;
            };

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
        } catch (error) {
            console.error('Error actualizando empleado:', error);
            this.detalleEstado.textContent = 'Error de conexión al actualizar el empleado.';
            this.detalleEstado.className = 'status error';
        }
    }

    private abrirModalBorrado(valorDocumentoIdentidad: string): void {
        this.documentoPendienteBorrado = valorDocumentoIdentidad;
        this.deleteDocumentoTexto.textContent = `¿Deseas eliminar lógicamente al empleado ${valorDocumentoIdentidad}?`;
        this.deleteModalEstado.textContent = 'Esta acción desactiva al empleado, no lo elimina físicamente.';
        this.deleteModalEstado.className = 'status warning';
        this.deleteModal.classList.remove('hidden');
    }

    private cerrarModalBorrado(): void {
        this.deleteModal.classList.add('hidden');
        this.documentoPendienteBorrado = null;
    }

    private async confirmarBorradoPendiente(): Promise<void> {
        if (!this.documentoPendienteBorrado) {
            return;
        }

        await this.borrarEmpleado(this.documentoPendienteBorrado, true);
    }

    private async cancelarBorradoPendiente(): Promise<void> {
        if (!this.documentoPendienteBorrado) {
            this.cerrarModalBorrado();
            return;
        }

        await this.borrarEmpleado(this.documentoPendienteBorrado, false);
    }

    private async borrarEmpleado(valorDocumentoIdentidad: string, confirmado: boolean): Promise<void> {
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

            const payload = await response.json() as {
                success: boolean;
                outResultCode: number;
                message?: string;
            };

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
        } catch (error) {
            console.error('Error eliminando empleado:', error);
            this.deleteModalEstado.textContent = 'Error de conexión al eliminar empleado.';
            this.deleteModalEstado.className = 'status error';
        } finally {
            this.confirmDeleteBtn.disabled = false;
            this.cancelDeleteBtn.disabled = false;
            this.closeDeleteModalBtn.disabled = false;
        }
    }

    private setEstado(texto: string, tipo: 'info' | 'success' | 'warning' | 'error'): void {
        this.mensajeDiv.textContent = texto;
        this.mensajeDiv.className = `status ${tipo}`;
    }

    private setBotones(habilitado: boolean): void {
        this.buscarBtn.disabled = !habilitado;
        this.limpiarBtn.disabled = !habilitado;
    }
}

document.addEventListener('DOMContentLoaded', () => {
    new EmpleadosPage();
});