export function setEstado(
    elemento: HTMLElement,
    texto: string,
    tipo: 'info' | 'success' | 'warning' | 'error'
): void {
    elemento.textContent = texto;
    elemento.className = `status ${tipo}`;
}

export function formatearFecha(valor: string): string {
    try {
        const d = new Date(valor);
        if (isNaN(d.getTime())) return valor;
        return d.toLocaleDateString('es-ES');
    } catch {
        return valor;
    }
}

export function formatearFechaHora(valor: string): string {
    try {
        const d = new Date(valor);
        if (isNaN(d.getTime())) return valor;
        return d.toLocaleString('es-ES');
    } catch {
        return valor;
    }
}

export function logout(): void {
    localStorage.removeItem('authToken');
    localStorage.removeItem('username');
    localStorage.removeItem('empleadoImpersonadoId');
    localStorage.removeItem('empleadoImpersonadoDoc');
    localStorage.removeItem('ultimoDocumentoEmpleado');
    window.location.href = '/login.html';
}
