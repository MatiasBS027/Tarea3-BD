"use strict";
class InsertarMovimientoPage {
    constructor() {
        this.saldoActual = 0;
        this.empleadoCargado = false;
        const params = new URLSearchParams(window.location.search);
        this.documentoIdentidad = params.get('documento')?.trim() ?? '';
        this.tituloEmpleado = document.getElementById('tituloEmpleado');
        this.resumenEmpleado = document.getElementById('resumenEmpleado');
        this.estadoDiv = document.getElementById('estado');
        this.estadoFormDiv = document.getElementById('estadoForm');
        this.tipoMovimientoSelect = document.getElementById('tipoMovimiento');
        this.montoInput = document.getElementById('monto');
        this.insertarBtn = document.getElementById('insertarBtn');
        this.volverBtn = document.getElementById('volverBtn');
        this.cancelarBtn = document.getElementById('cancelarBtn');
        // Apuntar los enlaces de volver y cancelar al empleado correcto
        const urlMovimientos = `/movimientos.html?documento=${encodeURIComponent(this.documentoIdentidad)}`;
        this.volverBtn.href = urlMovimientos;
        this.cancelarBtn.href = urlMovimientos;
        this.bindEvents();
        void this.cargarVista();
    }
    bindEvents() {
        this.insertarBtn.addEventListener('click', () => {
            void this.insertar();
        });
        // Validar el monto en tiempo real
        this.montoInput.addEventListener('input', () => {
            this.validarMontoEnTiempoReal();
        });
    }
    async cargarVista() {
        if (!this.documentoIdentidad) {
            this.tituloEmpleado.textContent = 'Sin empleado seleccionado';
            this.setEstado('Regresa a la lista de empleados y selecciona uno.', 'warning');
            return;
        }
        this.setEstado('Cargando datos del empleado...', 'info');
        await this.cargarEmpleado();
        if (this.empleadoCargado) {
            await this.cargarTiposMovimiento();
        }
    }
    async cargarEmpleado() {
        try {
            const response = await fetch(`/api/empleados/${encodeURIComponent(this.documentoIdentidad)}`, {
                method: 'GET',
            });
            const payload = await response.json();
            if (!response.ok || !payload.success || !payload.data) {
                this.tituloEmpleado.textContent = 'Error al cargar empleado';
                this.setEstado(payload.message ?? 'No se pudo cargar el empleado.', 'error');
                return;
            }
            const empleado = payload.data;
            this.saldoActual = empleado.SaldoVacaciones;
            this.empleadoCargado = true;
            this.tituloEmpleado.textContent = `Insertar movimientos - ${empleado.Nombre}`;
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
                        <span class="detalle-label">Saldo vacaciones</span>
                        <span class="detalle-valor">${empleado.SaldoVacaciones}</span>
                    </div>
                </div>
            `;
            this.setEstado('Empleado cargado. Selecciona el tipo de movimiento y el monto.', 'success');
        }
        catch (error) {
            console.error('Error cargando empleado:', error);
            this.tituloEmpleado.textContent = 'Error al cargar empleado';
            this.setEstado('Error de conexión al cargar el empleado.', 'error');
        }
    }
    async cargarTiposMovimiento() {
        try {
            const response = await fetch('/api/tiposMovimiento', { method: 'GET' });
            const payload = await response.json();
            if (!response.ok || !payload.success || !payload.data?.length) {
                this.tipoMovimientoSelect.innerHTML =
                    '<option value="">No hay tipos disponibles</option>';
                return;
            }
            this.tipoMovimientoSelect.innerHTML =
                '<option value="">Selecciona un tipo</option>' +
                    payload.data.map((t) => `<option value="${t.Nombre}" data-accion="${t.TipoAccion}">${t.Nombre}</option>`).join('');
            // Habilitar boton solo cuando hay tipos disponibles
            this.insertarBtn.disabled = false;
        }
        catch (error) {
            console.error('Error cargando tipos de movimiento:', error);
            this.tipoMovimientoSelect.innerHTML = '<option value"">Error al cargar tipos</option>';
        }
    }
    validarMontoEnTiempoReal() {
        const monto = parseFloat(this.montoInput.value);
        const selectedOption = this.tipoMovimientoSelect.selectedOptions[0];
        const tipoAccion = selectedOption?.dataset['accion'] ?? '';
        if (isNaN(monto) || monto <= 0) {
            this.setEstadoForm('El monto debe ser mayor a 0.', 'warning');
            return;
        }
        // Verificar que no haya saldo negativo si el tipo es R (retiro/debito)
        if (tipoAccion === 'R' && monto > this.saldoActual) {
            this.setEstadoForm(`El monto supera el saldo actual (${this.saldoActual}). El saldo no puede ser negativo.`, 'error');
            return;
        }
        this.setEstadoForm('', 'info');
    }
    validar() {
        const tipoMovimiento = this.tipoMovimientoSelect.value.trim();
        const monto = parseFloat(this.montoInput.value);
        const selectedOption = this.tipoMovimientoSelect.selectedOptions[0];
        const tipoAccion = selectedOption?.dataset['accion'] ?? '';
        if (!tipoMovimiento) {
            return 'Debes seleccionar un tipo de movimiento.';
        }
        if (isNaN(monto) || monto <= 0) {
            return 'El monto debe ser mayor a 0.';
        }
        if (tipoAccion === 'R' && monto > this.saldoActual) {
            return `El monto supera el saldo actual (${this.saldoActual}). El saldo no puede ser negativo.`;
        }
        return null;
    }
    async insertar() {
        const error = this.validar();
        if (error) {
            this.setEstadoForm(error, 'error');
            return;
        }
        const tipoMovimiento = this.tipoMovimientoSelect.value.trim();
        const monto = parseFloat(this.montoInput.value);
        const username = localStorage.getItem('username') ?? 'UsuarioScripts';
        const fecha = new Date().toISOString().split('T')[0];
        this.insertarBtn.disabled = true;
        this.setEstadoForm('Insertando movimiento...', 'info');
        try {
            const response = await fetch('/api/movimientos', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'x-username': username,
                },
                body: JSON.stringify({
                    valorDocumentoIdentidad: this.documentoIdentidad,
                    nombreTipoMovimiento: tipoMovimiento,
                    monto,
                    fecha,
                }),
            });
            const payload = await response.json();
            if (!response.ok || !payload.success) {
                this.setEstadoForm(payload.message ?? 'No se pudo insertar el movimiento.', 'error');
                this.insertarBtn.disabled = false;
                return;
            }
            this.setEstadoForm('Movimiento insertado correctamente. Redirigiendo...', 'success');
            // Redirigir a movimientos despues de exito
            setTimeout(() => {
                window.location.href = `/movimientos.html?documento=${encodeURIComponent(this.documentoIdentidad)}`;
            }, 1500);
        }
        catch (error) {
            console.error('Error insertanto movimiento:', error);
            this.setEstadoForm('Error de conexion al registrar el movimiento.', 'error');
            this.insertarBtn.disabled = false;
        }
    }
    setEstado(mensaje, tipo) {
        this.estadoDiv.textContent = mensaje;
        this.estadoDiv.className = `status ${tipo}`;
    }
    setEstadoForm(mensaje, tipo) {
        if (!mensaje) {
            this.estadoFormDiv.classList.add('hidden');
            return;
        }
        this.estadoFormDiv.textContent = mensaje;
        this.estadoFormDiv.className = `status ${tipo}`;
        this.estadoFormDiv.classList.remove('hidden');
    }
}
new InsertarMovimientoPage();
