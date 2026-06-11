# Bitácora de cambios

## Sesión 2026-06-11 — Items #1 al #15 (Parte 2)

### Commits realizados (push a main)

```
975149d chore: remove unused agent skill files from repo
ab567e8 feat: input validation, health endpoint, auth improvements, and dev tooling
110a908 chore: relocate Datos.xml to SQL/DATA, rebuild dist, update docs
```

Resumen: +1,497 líneas, −9,630 líneas, 54 archivos eliminados, 18 archivos creados.

---

### Items completados en esta sesión

| # | Estado | Item | Cambios |
|---|--------|------|---------|
| 1 | ✅ Hecho | Eliminar CRUD muerto del frontend | `public/empleados.html`: −50 líneas (formulario CRUD inline). `public/js/empleados.js`: −384 líneas (funciones CRUD, modales, handlers). `public/css/style.css`: −238 líneas (estilos CRUD no usados). `src/frontend/empleados.ts`: −479 líneas (código fuente TS del CRUD) |
| 2 | ✅ Hecho | Auth real: sp_Login retorna id + tipo | `SQL/SPs/sp_Login.sql`: +@outIdUsuario OUTPUT, +@outTipo VARCHAR(2) OUTPUT. `src/controllers/authController.ts`: desacoplado, maneja payload JWT con id + tipo. `src/middleware/authMiddleware.ts`: creado (authenticate + requireAdmin). `src/controllers/usuarioHelper.ts`: eliminado |
| 3 | 🔲 Pendiente | Middleware de auth centralizado | `src/middleware/authMiddleware.ts` creado (authenticate + requireAdmin). Falta integration testing end-to-end |
| 5 | ✅ Hecho | Validación de entrada | `src/middleware/validation.ts`: creado con express-validator. 6 arrays de validación (login, empleados, bitácora, etc.) con sanitización y mensajes en español. Rutas actualizadas para usar validación |
| 6 | ✅ Hecho | Gitignore consistente | Eliminado `dist` del `.gitignore`. Ambos outputs (`dist/` + `public/js/`) ahora se commitean. Añadido script `build:all` y `postinstall` |
| 7 | ✅ Hecho | Ignorar .opencode/ .agents/ | Añadido `.opencode/` y `.agents/` al `.gitignore`. 52 archivos removidos del tracking (`git rm --cached`) |
| 8 | ✅ Hecho | Limpiar carpetas vacías | `src/models/` y `src/scripts/` eliminadas (tracking vacío, ya no aparecen en working tree) |
| 10 | ✅ Hecho | Error mapping 500→404 | `getEmpleadoByIdInt` ahora retorna 404 para 50012, 500 para 50008, 400 para otros códigos. Consistente con demás endpoints |
| 11 | ✅ Hecho | Fix package.json | `main` corregido a `dist/index.js`. `test` actualizado. Scripts reorganizados |
| 12 | ✅ Hecho | Health check | `GET /health` en `src/index.ts` sin autenticación. Retorna `{ status: "ok", timestamp }` |
| 13 | ✅ Hecho | Dev hot-reload | `"dev"` cambiado a `tsx watch src/index.ts`. Dependencia `tsx` añadida |
| 14 | ✅ Hecho | Mover Datos.xml | `data/Datos.xml` → `SQL/DATA/Datos.xml` (detectado por git como rename) |
| 15 | ✅ Hecho | Consistencia AGENTS.md | Actualizada sección 4 (arquitectura), 5 (SPs), 6 (workflow). Documentados scripts, health check, validación |

### Detalle por archivo

#### Backend — TypeScript (src/)
| Archivo | Cambio |
|---------|--------|
| `src/middleware/validation.ts` | **Nuevo**. 6 arrays de validación con express-validator |
| `src/middleware/authMiddleware.ts` | **Nuevo**. authenticate (JWT verify) + requireAdmin (tipo='1') |
| `src/controllers/authController.ts` | Refactor: desacoplado, usa pool.request().execute, payload JWT con id+tipo |
| `src/controllers/empleadoController.ts` | Error mapping 500→404, validación duplicada removida |
| `src/controllers/usuarioHelper.ts` | **Eliminado**. Reemplazado por authMiddleware |
| `src/routes/auth.ts` | Usa validateLogin, llama a authController |
| `src/routes/empleados.ts` | Usa validateGetEmpleados, validateGetEmpleadoByDoc, validateImpersonar, validateGetEmpleadoByIdInt |
| `src/routes/bitacora.ts` | Usa validateGetBitacora |
| `src/index.ts` | +GET /health, estructura limpia |
| `src/frontend/*.ts` | Limpieza de CRUD muerto, mejoras de UX |

#### Backend — Compilado (dist/)
| Archivo | Cambio |
|---------|--------|
| `dist/*.js` (14 archivos) | **Nuevos**. Compilación del backend completa |

#### SQL
| Archivo | Cambio |
|---------|--------|
| `SQL/SPs/sp_Login.sql` | +@outIdUsuario, +@outTipo OUTPUTs |
| `data/Datos.xml` → `SQL/DATA/Datos.xml` | Relocalizado |

#### Frontend
| Archivo | Cambio |
|---------|--------|
| `public/js/empleados.js` | −384 líneas (CRUD eliminado) |
| `public/empleados.html` | −50 líneas (formulario CRUD) |
| `public/css/style.css` | −238 líneas (estilos muertos) |
| `public/js/*.js` (resto) | Recompilados con cambios TS |
| `public/js/utils.js` | +helper compartido |

#### Configuración
| Archivo | Cambio |
|---------|--------|
| `.gitignore` | −dist, +.opencode/, +.agents/ |
| `package.json` | main, dev, test, +build:all, +postinstall, +express-validator, +tsx |
| `pnpm-lock.yaml` | Actualizado con nuevas dependencias |
| `pnpm-workspace.yaml` | **Nuevo**. Config pnpm para esbuild |

#### Documentación
| Archivo | Cambio |
|---------|--------|
| `AGENTS.md` | Secciones 4, 5, 6 actualizadas |
| `bitacora.md` | Este archivo, reescrito completo |

### Items pendientes
- **#3**: Probar middleware de auth end-to-end (faltan tests de integración)

---

## Sesiones anteriores (Jun 2026)

### Login/Logout/Bitácora + adaptación backend

#### SPs implementados
- `sp_Login` / `sp_Logout` — autenticación
- `sp_GetEmpleados` / `sp_GetEmpleadoById` / `sp_GetEmpleadoByIdInt` — consulta empleados
- `sp_ImpersonarEmpleado` / `sp_RegresarAdmin` — R03/R06
- `sp_GetTiposEvento` / `sp_GetBitacora` — bitácora (R07)
- `sp_GetTiposMovimiento` / `sp_GetPuestos` — catálogos
- `sp_GetError` — helper de mensajes

#### Backend adaptado
- Controladores, middleware JWT, rutas, error helper, connection pool
- Frontend (login, empleados, empleado-view, bitácora)

#### Modelo de datos
- 21 tablas, 23 FKs, 1 trigger
- Scripts: VaciarDB.sql, Tablas.sql, Trigger.sql, CargarDatosXML.sql
