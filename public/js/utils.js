export function setEstado(elemento, texto, tipo) {
    elemento.textContent = texto;
    elemento.className = `status ${tipo}`;
}
export function formatearFecha(valor) {
    try {
        const d = new Date(valor);
        if (isNaN(d.getTime()))
            return valor;
        return d.toLocaleDateString('es-ES');
    }
    catch {
        return valor;
    }
}
export function formatearFechaHora(valor) {
    try {
        const d = new Date(valor);
        if (isNaN(d.getTime()))
            return valor;
        return d.toLocaleString('es-ES');
    }
    catch {
        return valor;
    }
}
export function logout() {
    localStorage.removeItem('authToken');
    localStorage.removeItem('username');
    localStorage.removeItem('userTipo');
    localStorage.removeItem('userId');
    localStorage.removeItem('empleadoImpersonadoId');
    localStorage.removeItem('empleadoImpersonadoDoc');
    localStorage.removeItem('ultimoDocumentoEmpleado');
    window.location.href = '/login.html';
}
