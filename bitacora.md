# Bitácora de Sesión

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Sesión 1 — Adaptación inicial del backend

Fecha: 10/06/2026

Inicio: [09:00] | Fin: [13:30] || Total: [4 horas y 30 min]

Presente: Matías Benavides Sandoval

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### ¿QUÉ HICIMOS HOY?

Se adaptó el backend de Tarea2-BD (copia literal) a la arquitectura de Tarea3-BD. Se implementaron los items #1, #2, #7, #8, #11, #14, #15 del checklist:

- **#1 — Eliminar CRUD muerto del frontend**: El `empleados.ts` traía ~500 líneas de ABM (alta, baja, modificación) que eran de Tarea2-BD. En Tarea3-BD los empleados se importan por XML, no se crean desde frontend. Se eliminó todo: formularios HTML, funciones TS, modales, estilos CSS.

- **#2 — Auth real con payload JWT**: El SP `sp_Login` original solo validaba credenciales (sí/no). Se modificó para que retorne `@outIdUsuario` y `@outTipo`. El `authController` construye el token con `{id, username, tipo, iat, exp}` (base64). Se eliminó `usuarioHelper.ts` que ya no era necesario. El frontend ahora recibe `{token, usuario: {id, username, tipo}}`.

- **#7 — Ignorar .opencode/ .agents/**: Estas carpetas contienen tooling local de opencode (skills de IA). No deben estar en el repo. Se añadieron al `.gitignore` y se removieron del tracking con `git rm --cached` (52 archivos).

- **#8 — Limpiar carpetas vacías**: `src/models/` y `src/scripts/` estaban vacías (herencia). Eliminadas del tracking.

- **#11 — Fix package.json**: `main` apuntaba a `index.js` (no existía). Corregido a `dist/index.js`. Script `test` cambiado de `exit 1` a mensaje informativo.

- **#14 — Mover Datos.xml**: El XML de datos de prueba estaba en `data/Datos.xml` (raíz). Movido a `SQL/DATA/Datos.xml` siguiendo la estructura del proyecto.

- **#15 — Consistencia AGENTS.md**: Actualizadas secciones 4 (arquitectura), 5 (SPs), 6 (workflow) para reflejar el proyecto actual y no Tarea2-BD.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### PROBLEMAS DETECTADOS Y CÓMO SE RESOLVIERON

| Problema | Solución |
|----------|----------|
| `sp_Login` no retornaba datos del usuario (solo éxito/fracaso) | Se añadieron OUTPUTs `@outIdUsuario INT` y `@outTipo VARCHAR(2)` |
| El frontend tenía 500+ líneas de CRUD que no se usaban | Eliminación completa: `empleados.ts` (−479), `empleados.js` (−384), `empleados.html` (−50), `style.css` (−238) |
| `package.json` tenía `main: "index.js"` que no existe | Corregido a `dist/index.js` |
| `data/Datos.xml` estaba en la raíz, fuera de la estructura SQL | Movido a `SQL/DATA/Datos.xml` (git lo detectó como rename automático) |
| La dependencia `ts-node` se usaba para desarrollo pero no recargaba automáticamente | Se dejó `ts-node` instalada pero se planea migrar a `tsx watch` en la siguiente sesión |
| `pnpm install` fallaba porque esbuild necesita aprobación | Se documentó en AGENTS.md: ejecutar `pnpm approve-builds esbuild` después del primer install |

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### AVANCE DEL CÓDIGO

```
SQL/
├── SPs/
│   └── sp_Login.sql          ← +@outIdUsuario, +@outTipo OUTPUT
├── DATA/
│   └── Datos.xml              ← MOVIDO desde data/
src/
├── controllers/
│   ├── authController.ts      ← REFACTOR: token con id+tipo
│   └── usuarioHelper.ts       ← ELIMINADO
├── frontend/
│   ├── empleados.ts           ← −479 líneas (CRUD eliminado)
│   └── ... (resto sin cambios)
public/
├── empleados.html             ← −50 líneas
├── js/empleados.js            ← −384 líneas
└── css/style.css              ← −238 líneas
.htaccess                        ← ELIMINADO
.gitignore                       ← +.opencode/, +.agents/
package.json                     ← main, test corregidos
AGENTS.md                        ← Secciones 4, 5, 6 actualizadas
```

Commits de esta sesión:
```
975149d chore: remove unused agent skill files from repo
110a908 chore: relocate Datos.xml to SQL/DATA, rebuild dist, update docs
```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### MORALEJAS / BUENAS PRÁCTICAS

1. **No commitees tooling local**: `.opencode/` y `.agents/` son específicos del editor/herramienta. Siempre agregarlos al `.gitignore` desde el inicio.
2. **Los SPs deben retornar datos útiles**: Un SP de login que solo dice "sí/no" obliga al backend a hacer queries adicionales. Mejor retornar todo lo que el frontend necesita de una vez.
3. **Mantener estructura de carpetas consistente**: Si todo lo SQL está en `SQL/`, el XML de datos de prueba también debe estar ahí.
4. **CRUD muerto = deuda técnica**: Si una feature no se usa en el proyecto actual, hay que eliminarla. No dejarla "por si acaso".

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### PRÓXIMA SESIÓN: ¿QUÉ SIGUE?

- #5 — Implementar validación de entrada con express-validator
- #6 — Hacer consistentes los outputs compilados (dist/ vs public/js/)
- #10 — Fix error mapping 500→404 en getEmpleadoByIdInt
- #12 — Agregar health check (GET /health)
- #13 — Migrar a tsx watch para hot-reload
- #3 — Centralizar middleware de auth (authenticate + requireAdmin)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Sesión 2 — Validación, health check, dev tooling, auth middleware y tests

Fecha: 11/06/2026

Inicio: [14:00] | Fin: [17:30] || Total: [3 horas y 30 min]

Presente: Matías Benavides Sandoval

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### ¿QUÉ HICIMOS HOY?

Se completaron los items pendientes #5, #6, #10, #12, #13 y #3 del checklist.

**#5 — Validación de entrada con express-validator (🟡 Alto)**

Se creó `src/middleware/validation.ts` con 6 arrays de validación:
- `validateLogin`: username (1-128 chars) + password requeridos
- `validateGetEmpleados`: filtro opcional (max 128 chars)
- `validateGetEmpleadoByDoc`: documento requerido
- `validateImpersonar`: valorDocumento requerido
- `validateGetEmpleadoByIdInt`: id entero positivo
- `validateGetBitacora`: filtros opcionales con tipo correcto (enteros, ISO8601)

Cada ruta usa su array ANTES del controller. Si la validación falla, responde 400 automáticamente sin llegar al SP.

**#6 — Gitignore consistente (🟡 Alto)**

Antes: `public/js/*.js` estaba commiteado pero `dist/` estaba en `.gitignore` → inconsistencia.
Ahora: Se eliminó `dist` del `.gitignore`. Ambos outputs se commitean juntos. Se añadió `"build:all"` y `"postinstall"` para compilar automáticamente.

**#10 — Error mapping en getEmpleadoByIdInt (🟡 Medio)**

Antes: cualquier error → 500.
Ahora: 50012 → 404 (no encontrado), 50008 → 500 (error interno), otros → 400. Consistente con los demás endpoints.

**#12 — Health check (🟢 Bajo)**

Se añadió `GET /health` sin autenticación:
```json
{ "status": "ok", "timestamp": "2026-06-11T..." }
```

**#13 — Dev hot-reload (🟢 Bajo)**

Se cambió `"dev": "ts-node src/index.ts"` → `"dev": "tsx watch src/index.ts"`. Ahora recarga automáticamente al detectar cambios. Se añadió dependencia `tsx` y se configuró `postinstall` para compilar ambos outputs.

**#3 — Middleware de auth centralizado**

Se refactorizó `src/middleware/authMiddleware.ts`:
- `decodeToken`: ahora valida que tipo sea solo '1' o '2', normaliza username con trim, rechaza tokens con campos faltantes
- `authenticate`: mensajes descriptivos (distingue "token requerido" vs "token vacío" vs "token inválido/expirado")
- `requireAdmin`: distingue 401 (no autenticado) vs 403 (autenticado pero no admin)

Se crearon 16 tests unitarios en `tests/authMiddleware.test.ts` (13 para decodeToken, 3 para requireAdmin). No requieren BD — prueban lógica pura del token. Se ejecutan con `pnpm test:auth`.

Cableado de rutas verificado:
- `/api/auth` → público ✅
- `/api/empleados` → authenticate + requireAdmin ✅
- `/api/puestos` → authenticate ✅
- `/api/tiposMovimiento` → authenticate ✅
- `/api/bitacora` → authenticate + requireAdmin ✅
- `GET /health` → público ✅

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### PROBLEMAS DETECTADOS Y CÓMO SE RESOLVIERON

| Problema | Solución |
|----------|----------|
| Los controllers parseaban entrada a mano: `String(req.query.fechaDesde)`, si pasaban `NaN` se iba `null` al SP | express-validator: sanitiza y valida antes de llegar al controller. Campos numéricos → `.isInt()`, fechas → `.isISO8601()` |
| `dist/` ignorado pero `public/js/` commiteado → inconsistencia | Eliminado `dist` del `.gitignore`. Ambos outputs se commitean. Script `build:all` compila ambos |
| `getEmpleadoByIdInt` retornaba 500 incluso para "empleado no existe" | Mapping por código: 50012→404, 50008→500, otros→400 |
| No había forma de monitorear si el server está vivo | `GET /health` sin auth, retorna status + timestamp |
| `ts-node` no recarga automáticamente | Migrado a `tsx watch`. Recarga al guardar archivos .ts |
| `requireAdmin` no distinguía entre "no autenticado" y "no admin" | 401 (no auth) vs 403 (no admin) con mensajes distintos. Tests unitarios para ambos casos |
| El token base64 no tenía validación de tipo de usuario | `decodeToken` ahora valida que `tipo` sea exactamente '1' o '2'. Rechaza cualquier otro valor |
| `postinstall` fallaba por esbuild bloqueado | Se añadió paso al AGENTS.md: `pnpm approve-builds esbuild` |

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### AVANCE DEL CÓDIGO

```
src/
├── middleware/
│   ├── authMiddleware.ts      ← REFACTOR: validaciones + mensajes descriptivos
│   └── validation.ts          ← NUEVO: 6 arrays de validación con express-validator
├── controllers/
│   ├── authController.ts      ← usa OUTPUTs del SP para construir token
│   └── empleadoController.ts  ← error mapping 50012→404
├── routes/
│   ├── auth.ts                ← +validateLogin
│   ├── empleados.ts           ← +validateGetEmpleados, etc.
│   └── bitacora.ts            ← +validateGetBitacora
├── index.ts                   ← +GET /health
tests/
└── authMiddleware.test.ts     ← NUEVO: 16 tests unitarios
.gitignore                     ← −dist (ahora se commitea)
package.json                   ← scripts: dev, test, test:auth, build:all, postinstall
                               ← deps: express-validator, tsx
pnpm-workspace.yaml            ← esbuild: true aprobado
AGENTS.md                      ← +tests, +approve-builds, +validación
```

Commits de esta sesión:
```
ab567e8 feat: input validation, health endpoint, auth improvements, and dev tooling
f5bd0e7 feat(auth): #3 middleware centralizado con tests unitarios
0b76057 docs(bitacora): agregar subsesion #3 auth middleware tests
```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### MORALEJAS / BUENAS PRÁCTICAS

1. **Validar entrada antes de llegar al SP**: express-validator corta requests maliciosas antes de tocar la BD. Mensajes de error en español para el usuario.
2. **Consistencia en outputs compilados**: O todos se ignoran o todos se commitean. La mezcla causa confusión en el equipo.
3. **Códigos de error HTTP semánticos**: 404 ≠ 500. Un "no encontrado" no es un error interno. Cada código debe reflejar la naturaleza del problema.
4. **Siempre tener un health check**: Los load balancers y sistemas de monitoreo lo necesitan. Son 3 líneas de código pero salvan horas de debugging.
5. **Hot-reload ahorra minutos por hora**: `tsx watch` recarga en ~200ms vs ~3s de `ts-node` + reinicio manual. La productividad mejora notablemente.
6. **Probar la lógica de auth sin BD**: Los tests de `decodeToken` y `requireAdmin` son pura lógica JS. No necesitan BD, corren en <150ms, y cubren 16 casos. Esto debería ser estándar.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### PRÓXIMA SESIÓN: ¿QUÉ SIGUE?

- Probar end-to-end: iniciar servidor + BD, probar login, consultas, impersonación
- Implementar SPs de planilla: `sp_CrearCalendario`, `sp_ProcesarAsistencia`, `sp_ProcesarPlanillaSemanal`, `sp_ProcesarPlanillaMensual`
- Implementar vistas de planilla (R04/R05): `sp_GetPlanillaSemanal`, `sp_GetPlanillaMensual`
- Carga de datos por XML (`sp_CargarCatalogosXML`)
- Frontend de planilla (vista semanal/mensual con movimientos y comprobantes)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
