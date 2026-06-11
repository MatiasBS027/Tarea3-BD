"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const path_1 = __importDefault(require("path"));
const connection_1 = require("./db/connection");
const authMiddleware_1 = require("./middleware/authMiddleware");
const empleados_1 = __importDefault(require("./routes/empleados"));
const auth_1 = __importDefault(require("./routes/auth"));
const puestos_1 = __importDefault(require("./routes/puestos"));
const tiposMovimiento_1 = __importDefault(require("./routes/tiposMovimiento"));
const bitacora_1 = __importDefault(require("./routes/bitacora"));
const app = (0, express_1.default)();
const PORT = 3000;
app.use(express_1.default.json());
app.use(express_1.default.static(path_1.default.join(__dirname, '../public')));
// Health check (no requiere auth)
app.get('/health', (_req, res) => {
    res.json({ status: 'ok', timestamp: new Date().toISOString() });
});
// Auth routes (login no requiere token)
app.use('/api/auth', auth_1.default);
// Rutas protegidas — requieren token valido
app.use('/api/empleados', authMiddleware_1.authenticate, empleados_1.default);
app.use('/api/puestos', authMiddleware_1.authenticate, puestos_1.default);
app.use('/api/tiposMovimiento', authMiddleware_1.authenticate, tiposMovimiento_1.default);
app.use('/api/bitacora', authMiddleware_1.authenticate, bitacora_1.default);
async function startServer() {
    try {
        await (0, connection_1.getPool)();
        app.listen(PORT, () => {
            console.log(`Servidor corriendo en http://localhost:${PORT}`);
        });
    }
    catch (error) {
        console.error('Error al conectar a la BD:', error);
        process.exit(1);
    }
}
startServer();
