# Bitácora de cambios

## Sesión: Implementación #5, #6, #10, #12, #13 — 11 Jun 2026

### #5 — Validación de entrada con express-validator
- **Nuevo archivo**: `src/middleware/validation.ts`
  - Middleware `handleValidationErrors` unificado (retorna 400 con errores descriptivos)
  - Arrays de validación: `validateLogin`, `validateGetEmpleados`, `validateGetEmpleadoByDoc`, `validateImpersonar`, `validateGetEmpleadoByIdInt`, `validateGetBitacora`
  - Sanitización: `.trim()` en strings, `.isInt()` en IDs, `.isISO8601()` en fechas
- **Actualizados**: `src/routes/auth.ts`, `src/routes/empleados.ts`, `src/routes/bitacora.ts`
  - Cada ruta ahora usa su array de validación antes del controller
- **Dependencia añadida**: `express-validator` (v7.2.1)

### #6 — Gitignore: outputs compilados consistentes
- Eliminada la entrada `dist` de `.gitignore` para que ambos outputs (`dist/` y `public/js/`) se commiteen
- `dist/` agregado al staging (`git add dist/`)
- Añadido script `"build:all"` en `package.json` (compila backend + frontend de una vez)
- Añadido `"postinstall"` en `package.json` para compilar automáticamente tras `pnpm install`

### #10 — Error mapping en getEmpleadoByIdInt
- `src/controllers/empleadoController.ts`:
  - Cambiado `res.status(500)` genérico → mapping por código:
    - 50012 → 404 (no encontrado)
    - 50008 → 500 (error interno)
    - otros → 400
  - Respuesta 404 ahora incluye `outResultCode` y `message` desde `getErrorMessage()`
  - Eliminada validación manual duplicada (ya la cubre `validation.ts`)
  - Respuesta 200 ahora incluye `outResultCode` para consistencia

### #12 — Health check
- `src/index.ts`: Añadida ruta `GET /health` sin autenticación:
  ```json
  { "status": "ok", "timestamp": "2026-06-11T..." }
  ```

### #13 — Dev script con hot-reload
- `package.json`: `"dev"` cambiado de `ts-node src/index.ts` a `tsx watch src/index.ts`
- **Dependencia añadida**: `tsx` (v4.19.3)

### AGENTS.md actualizado
- Sección 4: documentados middleware de auth, validación, scripts disponibles, health check
- Sección 5: añadidos `sp_GetEmpleadoByIdInt`, `sp_GetBitacora`, `sp_GetTiposEvento`
- Sección 6: añadida regla de validación de entrada con express-validator

---

## Sesión: Login/Logout/Bitácora + adaptación backend — Jun 2026

### SPs implementados
- `sp_Login` — autenticación con escritura a BitacoraEvento
- `sp_Logout` — cierre de sesión explícito
- `sp_GetEmpleados` — listado con filtro opcional
- `sp_GetEmpleadoById` — búsqueda por documento
- `sp_GetEmpleadoByIdInt` — búsqueda por ID (impersonación)
- `sp_ImpersonarEmpleado` — admin ve como empleado
- `sp_RegresarAdmin` — vuelta a interfaz admin
- `sp_GetTiposEvento` — catálogo
- `sp_GetBitacora` — paginada con filtros
- `sp_GetTiposMovimiento` — catálogo
- `sp_GetPuestos` — catálogo
- `sp_GetError` — helper de mensajes

### Backend adaptado (src/)
- Controladores: auth, empleado, bitácora, puesto, tipoMovimiento
- Middleware: JWT (authMiddleware.ts)
- Rutas protegidas vs públicas
- Error helper con códigos descriptivos
- Conexión a BD con connection pool (`mssql`)

### Frontend adaptado (public/)
- login.html/js — formulario de login con JWT
- empleados.html/js — CRUD de empleados con impersonación
- empleado-view.html/js — vista de empleado individual
- bitacora.html/js — consulta de eventos paginada
- utils.js — funciones compartidas
- style.css — diseño responsivo

### Modelo de datos
- Creadas 21 tablas con 23 FKs y 1 trigger
- Scripts: VaciarDB.sql, Tablas.sql, Trigger.sql, CargarDatosXML.sql
