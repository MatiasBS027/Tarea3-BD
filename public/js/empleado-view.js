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
        // Agrupar sub-datos por semana
        const deducsPorSemana = new Map();
        for (const d of deducciones) {
            if (!deducsPorSemana.has(d.idPlanillaSemanal)) deducsPorSemana.set(d.idPlanillaSemanal, []);
            deducsPorSemana.get(d.idPlanillaSemanal).push(d);
        }
        const asistPorSemana = new Map();
        for (const a of asistencias) {
            if (!asistPorSemana.has(a.idPlanillaSemanal)) asistPorSemana.set(a.idPlanillaSemanal, []);
            asistPorSemana.get(a.idPlanillaSemanal).push(a);
        }

        let html = '<div class="planilla-lista">';
        for (const p of planillas) {
            const id = p.idPlanillaSemanal;
            const deducs = deducsPorSemana.get(id) ?? [];
            const dias   = asistPorSemana.get(id) ?? [];

            // Tabla de deducciones
            let htmlDeducs = '';
            if (deducs.length > 0) {
                htmlDeducs = `
                <div class="planilla-subtabla">
                    <p class="planilla-subtitulo">Deducciones</p>
                    <table class="ptable">
                        <thead><tr><th>Concepto</th><th>Tipo</th><th class="num">Monto</th></tr></thead>
                        <tbody>
                            ${deducs.map(d => `<tr>
                                <td>${escapeHtml(d.NombreDeduccion)}</td>
                                <td class="badge-cell"><span class="badge">${d.EsPorcentual ? (d.PorcentajeAplicado ?? '') + '%' : 'Fijo'}</span></td>
                                <td class="num deduccion">${fmt(d.MontoDeduccion)}</td>
                            </tr>`).join('')}
                        </tbody>
                    </table>
                </div>`;
            }

            // Tabla de asistencia diaria
            let htmlDias = '';
            if (dias.length > 0) {
                htmlDias = `
                <div class="planilla-subtabla">
                    <p class="planilla-subtitulo">Asistencia diaria</p>
                    <table class="ptable">
                        <thead><tr><th>Fecha</th><th>Entrada</th><th>Salida</th><th class="num">Horas</th><th class="num">Monto</th></tr></thead>
                        <tbody>
                            ${dias.map(d => `<tr>
                                <td>${formatearFecha(d.Fecha)}</td>
                                <td>${d.HoraEntrada ?? '—'}</td>
                                <td>${d.HoraSalida ?? '—'}</td>
                                <td class="num">${d.QHoras}</td>
                                <td class="num">${fmt(d.Monto)}</td>
                            </tr>`).join('')}
                        </tbody>
                    </table>
                </div>`;
            }

            html += `
            <div class="planilla-card">
                <button class="planilla-card-header" onclick="this.closest('.planilla-card').classList.toggle('open')" type="button">
                    <div class="planilla-card-periodo">
                        <span class="planilla-card-icon">📅</span>
                        <span class="planilla-card-fechas">${formatearFecha(p.FechaInicio)} — ${formatearFecha(p.FechaFin)}</span>
                    </div>
                    <div class="planilla-card-kpis">
                        <div class="planilla-kpi">
                            <span class="planilla-kpi-label">Horas</span>
                            <span class="planilla-kpi-val">${p.QHorasOrdinarias}h + ${p.QHorasExtraNormales}h + ${p.QHorasExtraDobles}h</span>
                        </div>
                        <div class="planilla-kpi planilla-kpi-bruto">
                            <span class="planilla-kpi-label">Bruto</span>
                            <span class="planilla-kpi-val">${fmt(p.SalarioBruto)}</span>
                        </div>
                        <div class="planilla-kpi planilla-kpi-deduc">
                            <span class="planilla-kpi-label">Deducciones</span>
                            <span class="planilla-kpi-val">${fmt(p.TotalDeducciones)}</span>
                        </div>
                        <div class="planilla-kpi planilla-kpi-neto">
                            <span class="planilla-kpi-label">Neto</span>
                            <span class="planilla-kpi-val">${fmt(p.SalarioNeto)}</span>
                        </div>
                    </div>
                    <span class="planilla-card-chevron">▾</span>
                </button>
                <div class="planilla-card-body">
                    ${htmlDeducs}
                    ${htmlDias}
                </div>
            </div>`;
        }
        html += '</div>';
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
        // Agrupar sub-datos por mes
        const deducsPorMes = new Map();
        for (const d of deducciones) {
            if (!deducsPorMes.has(d.idPlanillaMensual)) deducsPorMes.set(d.idPlanillaMensual, []);
            deducsPorMes.get(d.idPlanillaMensual).push(d);
        }
        const semanasPorMes = new Map();
        for (const s of semanas) {
            if (!semanasPorMes.has(s.idPlanillaMensual)) semanasPorMes.set(s.idPlanillaMensual, []);
            semanasPorMes.get(s.idPlanillaMensual).push(s);
        }

        let html = '<div class="planilla-lista">';
        for (const p of planillas) {
            const id = p.idPlanillaMensual;
            const deducs   = deducsPorMes.get(id) ?? [];
            const semanasm = semanasPorMes.get(id) ?? [];

            // Tabla de deducciones acumuladas
            let htmlDeducs = '';
            if (deducs.length > 0) {
                htmlDeducs = `
                <div class="planilla-subtabla">
                    <p class="planilla-subtitulo">Deducciones acumuladas</p>
                    <table class="ptable">
                        <thead><tr><th>Concepto</th><th>Tipo</th><th class="num">Total</th></tr></thead>
                        <tbody>
                            ${deducs.map(d => `<tr>
                                <td>${escapeHtml(d.NombreDeduccion)}</td>
                                <td class="badge-cell"><span class="badge">${d.EsPorcentual ? (d.PorcentajeAplicado ?? '') + '%' : 'Fijo'}</span></td>
                                <td class="num deduccion">${fmt(d.MontoDeduccion)}</td>
                            </tr>`).join('')}
                        </tbody>
                    </table>
                </div>`;
            }

            // Tabla de desglose semanal
            let htmlSemanas = '';
            if (semanasm.length > 0) {
                htmlSemanas = `
                <div class="planilla-subtabla">
                    <p class="planilla-subtitulo">Desglose semanal</p>
                    <table class="ptable">
                        <thead><tr><th>Semana</th><th class="num">Bruto</th><th class="num">Deducciones</th><th class="num">Neto</th></tr></thead>
                        <tbody>
                            ${semanasm.map(s => `<tr>
                                <td>${formatearFecha(s.FechaInicio)} — ${formatearFecha(s.FechaFin)}</td>
                                <td class="num">${fmt(s.SalarioBruto)}</td>
                                <td class="num deduccion">${fmt(s.TotalDeducciones)}</td>
                                <td class="num neto">${fmt(s.SalarioNeto)}</td>
                            </tr>`).join('')}
                        </tbody>
                    </table>
                </div>`;
            }

            html += `
            <div class="planilla-card">
                <button class="planilla-card-header" onclick="this.closest('.planilla-card').classList.toggle('open')" type="button">
                    <div class="planilla-card-periodo">
                        <span class="planilla-card-icon">🗓️</span>
                        <span class="planilla-card-fechas">${formatearFecha(p.FechaInicio)} — ${formatearFecha(p.FechaFin)}</span>
                    </div>
                    <div class="planilla-card-kpis">
                        <div class="planilla-kpi">
                            <span class="planilla-kpi-label">Horas</span>
                            <span class="planilla-kpi-val">${p.QHorasOrdinarias}h + ${p.QHorasExtraNormales}h + ${p.QHorasExtraDobles}h</span>
                        </div>
                        <div class="planilla-kpi planilla-kpi-bruto">
                            <span class="planilla-kpi-label">Bruto</span>
                            <span class="planilla-kpi-val">${fmt(p.SalarioBruto)}</span>
                        </div>
                        <div class="planilla-kpi planilla-kpi-deduc">
                            <span class="planilla-kpi-label">Deducciones</span>
                            <span class="planilla-kpi-val">${fmt(p.TotalDeducciones)}</span>
                        </div>
                        <div class="planilla-kpi planilla-kpi-neto">
                            <span class="planilla-kpi-label">Neto</span>
                            <span class="planilla-kpi-val">${fmt(p.SalarioNeto)}</span>
                        </div>
                    </div>
                    <span class="planilla-card-chevron">▾</span>
                </button>
                <div class="planilla-card-body">
                    ${htmlDeducs}
                    ${htmlSemanas}
                </div>
            </div>`;
        }
        html += '</div>';
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
