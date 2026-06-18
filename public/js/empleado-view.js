import { formatearFecha, logout, escapeHtml } from './utils.js';
const fmt = (n) => '₡' + Number(n ?? 0).toLocaleString('es-CR', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
class EmpleadoViewPage {
    constructor() {
        const params = new URLSearchParams(window.location.search);
        this.empleadoId = Number(params.get('id')) || 0;
        this.pageTitle = document.getElementById('pageTitle');
        this.pageSubtitle = document.getElementById('pageSubtitle');
        this.sidebarNombre = document.getElementById('sidebarNombre');
        this.sidebarPuesto = document.getElementById('sidebarPuesto');
        this.estadoDiv = document.getElementById('estado');
        this.detalleEmpleado = document.getElementById('detalleEmpleado');
        this.semanalEstado = document.getElementById('semanalEstado');
        this.semanalContenido = document.getElementById('semanalContenido');
        this.mensualEstado = document.getElementById('mensualEstado');
        this.mensualContenido = document.getElementById('mensualContenido');
        this.btnRegresarAdmin = document.getElementById('btnRegresarAdmin');
        this.logoutBtn = document.getElementById('logoutBtn');
        const esImpersonacion = !!localStorage.getItem('empleadoImpersonadoId');
        if (this.btnRegresarAdmin) {
            this.btnRegresarAdmin.style.display = esImpersonacion ? '' : 'none';
        }
        this.bindEvents();
        void this.cargarEmpleado();
    }
    bindEvents() {
        this.btnRegresarAdmin.addEventListener('click', () => { void this.regresarAdmin(); });
        this.logoutBtn.addEventListener('click', () => { logout(); });
    }
    // ----------------------------------------------------------------
    // Empleado
    // ----------------------------------------------------------------
    async cargarEmpleado() {
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
            const headers = {};
            if (token)
                headers['Authorization'] = 'Bearer ' + token;
            const response = await fetch(`/api/empleados/by-id/${this.empleadoId}`, { headers });
            const payload = await response.json();
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
                        <span class="detalle-valor">${emp.FechaContratacion ? formatearFecha(emp.FechaContratacion) : '—'}</span>
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
            // Cargar planillas en paralelo
            await Promise.all([
                this.cargarPlanillaSemanal(),
                this.cargarPlanillaMensual(),
            ]);
        }
        catch (error) {
            console.error('Error cargando empleado:', error);
            this.estadoDiv.textContent = 'Error de conexión con el servidor.';
            this.estadoDiv.className = 'status error';
        }
    }
    // ----------------------------------------------------------------
    // Planilla Semanal (R04)
    // ----------------------------------------------------------------
    async cargarPlanillaSemanal() {
        this.semanalEstado.textContent = 'Cargando planilla semanal...';
        this.semanalEstado.className = 'status info';
        try {
            const token = localStorage.getItem('authToken') || '';
            const headers = {};
            if (token)
                headers['Authorization'] = 'Bearer ' + token;
            const response = await fetch(`/api/planilla/semanal/${this.empleadoId}?cantidadSemanas=10`, { headers });
            const payload = await response.json();
            if (!response.ok || !payload.success || !payload.data) {
                this.semanalEstado.textContent = payload.message || 'No se pudo cargar la planilla semanal.';
                this.semanalEstado.className = 'status error';
                return;
            }
            const { planillas, deducciones, asistencias } = payload.data;
            if (planillas.length === 0) {
                this.semanalEstado.textContent = 'No hay planillas semanales registradas.';
                this.semanalEstado.className = 'status info';
                return;
            }
            this.semanalEstado.textContent = `${planillas.length} semana(s) cargadas.`;
            this.semanalEstado.className = 'status success';
            this.semanalContenido.innerHTML = this.renderPlanillaSemanal(planillas, deducciones, asistencias);
        }
        catch (error) {
            console.error('Error cargando planilla semanal:', error);
            this.semanalEstado.textContent = 'Error de conexión al cargar planilla semanal.';
            this.semanalEstado.className = 'status error';
        }
    }
    renderPlanillaSemanal(planillas, deducciones, asistencias) {
        // Grid principal
        let html = `
            <table class="data-table">
                <thead>
                    <tr>
                        <th>Semana</th>
                        <th>H. Ordinarias</th>
                        <th>H. Extra 1.5×</th>
                        <th>H. Extra 2×</th>
                        <th>Salario Bruto</th>
                        <th>Deducciones</th>
                        <th>Salario Neto</th>
                    </tr>
                </thead>
                <tbody>
        `;
        for (const p of planillas) {
            html += `
                <tr>
                    <td>${formatearFecha(p.FechaInicio)} — ${formatearFecha(p.FechaFin)}</td>
                    <td>${p.QHorasOrdinarias}</td>
                    <td>${p.QHorasExtraNormales}</td>
                    <td>${p.QHorasExtraDobles}</td>
                    <td>${fmt(p.SalarioBruto)}</td>
                    <td>${fmt(p.TotalDeducciones)}</td>
                    <td>${fmt(p.SalarioNeto)}</td>
                </tr>
            `;
        }
        html += `</tbody></table>`;
        // Detalle de deducciones agrupado por semana
        if (deducciones.length > 0) {
            const porSemana = new Map();
            for (const d of deducciones) {
                if (!porSemana.has(d.idPlanillaSemanal))
                    porSemana.set(d.idPlanillaSemanal, []);
                porSemana.get(d.idPlanillaSemanal).push(d);
            }
            html += `<h3 class="subtitulo-seccion">Detalle de deducciones por semana</h3>`;
            for (const [idPS, deducs] of porSemana) {
                const semana = planillas.find(p => p.idPlanillaSemanal === idPS);
                const titulo = semana
                    ? `${formatearFecha(semana.FechaInicio)} — ${formatearFecha(semana.FechaFin)}`
                    : `Semana #${idPS}`;
                html += `<p class="detalle-label">${titulo}</p>`;
                html += `<table class="data-table data-table-sm"><thead><tr>
                    <th>Deducción</th><th>Tipo</th><th>Monto</th>
                </tr></thead><tbody>`;
                for (const d of deducs) {
                    const tipo = d.EsPorcentual
                        ? `${d.PorcentajeAplicado ?? ''}%`
                        : 'Fijo';
                    html += `<tr>
                        <td>${escapeHtml(d.NombreDeduccion)}</td>
                        <td>${tipo}</td>
                        <td>${fmt(d.MontoDeduccion)}</td>
                    </tr>`;
                }
                html += `</tbody></table>`;
            }
        }
        // Detalle de asistencia diaria por semana
        if (asistencias.length > 0) {
            const porSemana = new Map();
            for (const a of asistencias) {
                if (!porSemana.has(a.idPlanillaSemanal))
                    porSemana.set(a.idPlanillaSemanal, []);
                porSemana.get(a.idPlanillaSemanal).push(a);
            }
            html += `<h3 class="subtitulo-seccion">Asistencia diaria por semana</h3>`;
            for (const [idPS, dias] of porSemana) {
                const semana = planillas.find(p => p.idPlanillaSemanal === idPS);
                const titulo = semana
                    ? `${formatearFecha(semana.FechaInicio)} — ${formatearFecha(semana.FechaFin)}`
                    : `Semana #${idPS}`;
                html += `<p class="detalle-label">${titulo}</p>`;
                html += `<table class="data-table data-table-sm"><thead><tr>
                    <th>Fecha</th><th>Entrada</th><th>Salida</th><th>Horas</th><th>Monto</th>
                </tr></thead><tbody>`;
                for (const d of dias) {
                    html += `<tr>
                        <td>${formatearFecha(d.Fecha)}</td>
                        <td>${d.HoraEntrada ?? '—'}</td>
                        <td>${d.HoraSalida ?? '—'}</td>
                        <td>${d.QHoras}</td>
                        <td>${fmt(d.Monto)}</td>
                    </tr>`;
                }
                html += `</tbody></table>`;
            }
        }
        return html;
    }
    // ----------------------------------------------------------------
    // Planilla Mensual (R05)
    // ----------------------------------------------------------------
    async cargarPlanillaMensual() {
        this.mensualEstado.textContent = 'Cargando planilla mensual...';
        this.mensualEstado.className = 'status info';
        try {
            const token = localStorage.getItem('authToken') || '';
            const headers = {};
            if (token)
                headers['Authorization'] = 'Bearer ' + token;
            const response = await fetch(`/api/planilla/mensual/${this.empleadoId}?cantidadMeses=6`, { headers });
            const payload = await response.json();
            if (!response.ok || !payload.success || !payload.data) {
                this.mensualEstado.textContent = payload.message || 'No se pudo cargar la planilla mensual.';
                this.mensualEstado.className = 'status error';
                return;
            }
            const { planillas, deducciones, semanas } = payload.data;
            if (planillas.length === 0) {
                this.mensualEstado.textContent = 'No hay planillas mensuales registradas.';
                this.mensualEstado.className = 'status info';
                return;
            }
            this.mensualEstado.textContent = `${planillas.length} mes(es) cargado(s).`;
            this.mensualEstado.className = 'status success';
            this.mensualContenido.innerHTML = this.renderPlanillaMensual(planillas, deducciones, semanas);
        }
        catch (error) {
            console.error('Error cargando planilla mensual:', error);
            this.mensualEstado.textContent = 'Error de conexión al cargar planilla mensual.';
            this.mensualEstado.className = 'status error';
        }
    }
    renderPlanillaMensual(planillas, deducciones, semanas) {
        // Grid principal
        let html = `
            <table class="data-table">
                <thead>
                    <tr>
                        <th>Mes</th>
                        <th>H. Ordinarias</th>
                        <th>H. Extra 1.5×</th>
                        <th>H. Extra 2×</th>
                        <th>Salario Bruto</th>
                        <th>Deducciones</th>
                        <th>Salario Neto</th>
                    </tr>
                </thead>
                <tbody>
        `;
        for (const p of planillas) {
            html += `
                <tr>
                    <td>${formatearFecha(p.FechaInicio)} — ${formatearFecha(p.FechaFin)}</td>
                    <td>${p.QHorasOrdinarias}</td>
                    <td>${p.QHorasExtraNormales}</td>
                    <td>${p.QHorasExtraDobles}</td>
                    <td>${fmt(p.SalarioBruto)}</td>
                    <td>${fmt(p.TotalDeducciones)}</td>
                    <td>${fmt(p.SalarioNeto)}</td>
                </tr>
            `;
        }
        html += `</tbody></table>`;
        // Deducciones acumuladas por mes
        if (deducciones.length > 0) {
            const porMes = new Map();
            for (const d of deducciones) {
                if (!porMes.has(d.idPlanillaMensual))
                    porMes.set(d.idPlanillaMensual, []);
                porMes.get(d.idPlanillaMensual).push(d);
            }
            html += `<h3 class="subtitulo-seccion">Deducciones acumuladas por mes</h3>`;
            for (const [idPM, deducs] of porMes) {
                const mes = planillas.find(p => p.idPlanillaMensual === idPM);
                const titulo = mes
                    ? `${formatearFecha(mes.FechaInicio)} — ${formatearFecha(mes.FechaFin)}`
                    : `Mes #${idPM}`;
                html += `<p class="detalle-label">${titulo}</p>`;
                html += `<table class="data-table data-table-sm"><thead><tr>
                    <th>Deducción</th><th>Tipo</th><th>Total</th>
                </tr></thead><tbody>`;
                for (const d of deducs) {
                    const tipo = d.EsPorcentual
                        ? `${d.PorcentajeAplicado ?? ''}%`
                        : 'Fijo';
                    html += `<tr>
                        <td>${escapeHtml(d.NombreDeduccion)}</td>
                        <td>${tipo}</td>
                        <td>${fmt(d.MontoDeduccion)}</td>
                    </tr>`;
                }
                html += `</tbody></table>`;
            }
        }
        // Resumen semanal dentro de cada mes
        if (semanas.length > 0) {
            const porMes = new Map();
            for (const s of semanas) {
                if (!porMes.has(s.idPlanillaMensual))
                    porMes.set(s.idPlanillaMensual, []);
                porMes.get(s.idPlanillaMensual).push(s);
            }
            html += `<h3 class="subtitulo-seccion">Desglose semanal por mes</h3>`;
            for (const [idPM, semanasDelMes] of porMes) {
                const mes = planillas.find(p => p.idPlanillaMensual === idPM);
                const titulo = mes
                    ? `${formatearFecha(mes.FechaInicio)} — ${formatearFecha(mes.FechaFin)}`
                    : `Mes #${idPM}`;
                html += `<p class="detalle-label">${titulo}</p>`;
                html += `<table class="data-table data-table-sm"><thead><tr>
                    <th>Semana</th><th>Bruto</th><th>Deducciones</th><th>Neto</th>
                </tr></thead><tbody>`;
                for (const s of semanasDelMes) {
                    html += `<tr>
                        <td>${formatearFecha(s.FechaInicio)} — ${formatearFecha(s.FechaFin)}</td>
                        <td>${fmt(s.SalarioBruto)}</td>
                        <td>${fmt(s.TotalDeducciones)}</td>
                        <td>${fmt(s.SalarioNeto)}</td>
                    </tr>`;
                }
                html += `</tbody></table>`;
            }
        }
        return html;
    }
    // ----------------------------------------------------------------
    // Regresar a admin
    // ----------------------------------------------------------------
    async regresarAdmin() {
        const token = localStorage.getItem('authToken') || '';
        const headers = { 'Content-Type': 'application/json' };
        if (token)
            headers['Authorization'] = 'Bearer ' + token;
        this.btnRegresarAdmin.disabled = true;
        this.btnRegresarAdmin.textContent = 'Regresando...';
        try {
            const response = await fetch('/api/empleados/regresar-admin', {
                method: 'POST',
                headers,
            });
            const payload = await response.json();
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
        }
        catch (error) {
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
