# Planilla Obrera — Control de Asistencia y Planilla

[![Node](https://img.shields.io/badge/Node.js-18%2B-339933?logo=node.js)](https://nodejs.org)
[![Express](https://img.shields.io/badge/Express-5.x-000000?logo=express)](https://expressjs.com)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.x-3178c6?logo=typescript)](https://www.typescriptlang.org)
[![SQL Server](https://img.shields.io/badge/SQL%20Server-2014%2B-cc2927?logo=microsoft-sql-server)](https://www.microsoft.com/sql-server)
[![pnpm](https://img.shields.io/badge/pnpm-9.x-F69220?logo=pnpm)](https://pnpm.io)
[![Tests](https://img.shields.io/badge/tests-16%20passing-2ea44f)](#testing)

---

**Curso:** Base de Datos 1 | ITCR — Escuela de Ingeniería en Computación  
**Profesor:** fquiros  
**Semestre:** I Semestre 2026  

Sistema completo de control de asistencia y planilla obrera. Administra empleados, jornadas, marcas de asistencia, cálculo de horas ordinarias y extras, deducciones obligatorias y optativas, y genera planillas semanales y mensuales con su respectiva bitácora de eventos.

---

## Tabla de Contenidos

- [Funcionalidades](#funcionalidades)
- [Stack Tecnológico](#stack-tecnológico)
- [Setup del Proyecto](#setup-del-proyecto)
- [Estructura del Proyecto](#estructura-del-proyecto)
- [Base de Datos](#base-de-datos)
- [API REST](#api-rest)
- [Frontend](#frontend)
- [Stored Procedures](#stored-procedures)
- [Testing](#testing)
- [Códigos de Error](#códigos-de-error)
- [Licencia](#licencia)

---

## Funcionalidades

- **Autenticación** de usuarios con roles administrador (`Tipo=1`) y empleado (`Tipo=2`) mediante tokens base64.
- **CRUD conceptual** de empleados con búsqueda por nombre y valor de documento.
- **Ciclo de planilla semanal** (viernes → jueves) con cierre automático cada jueves.
- **Ciclo de planilla mensual** (último viernes → último jueves) que agrega 4 o 5 semanas.
- **Cálculo de horas extras**: ordinarias (1.0×), extras normales (1.5×), extras dobles en domingos y feriados (2.0×). Solo se pagan horas completas.
- **Deducciones automáticas**: las deducciones obligatorias se asignan vía trigger al crear un empleado. Soporte para deducciones porcentuales y montos fijos.
- **Impersonación de empleados**: un administrador puede consultar la planilla de cualquier empleado sin cambiar de sesión (R03/R06).
- **Bitácora de eventos** con filtros por tipo, usuario, fecha e IP, paginada.
- **Trazabilidad de errores** no controlados en tabla `DBError` con stack trace.

---

## Stack Tecnológico

| Capa | Tecnología |
|------|-----------|
| Backend | Node.js + Express 5.x (CommonJS) |
| Lenguaje backend | TypeScript 5.x |
| Base de datos | SQL Server 2014+ (PlanillaDB) |
| Driver BD | `mssql` v12.x |
| Validación | `express-validator` v7.x |
| Frontend | HTML5 + CSS3 + JavaScript (ES2020 modules) |
| Lenguaje frontend | TypeScript (compilado por separado) |
| Dev server | `tsx` (hot-reload) |
| Package manager | pnpm |
| Testing | `node:test` + `node:assert` |

---

## Setup del Proyecto

### Prerrequisitos

- [Node.js](https://nodejs.org) 18+
- [pnpm](https://pnpm.io) 9+
- [SQL Server](https://www.microsoft.com/sql-server) 2014+ (con `sqlcmd` o SSMS)

### 1. Base de Datos

Ejecutar los siguientes scripts en orden sobre una instancia de SQL Server:

```
SQL/SCRIPTS/VaciarDB.sql         → Crea la base PlanillaDB (vacía)
SQL/SCRIPTS/Tablas.sql           → 21 tablas + 23 foreign keys
SQL/SCRIPTS/Trigger.sql          → Trigger de deducciones obligatorias
SQL/SCRIPTS/CargarDatosXML.sql   → Catálogos iniciales (puestos, jornadas, feriados, usuarios, errores)
SQL/SCRIPTS/CargarOperacionesXML.sql → Datos operativos de ejemplo (empleados, asistencias)
```

> Los SPs en `SQL/SPs/*.sql` se depliegan incrementalmente (usan `IF OBJECT_ID DROP`) y deben ejecutarse **después** de las tablas.

### 2. Backend

```bash
# Instalar dependencias (compila automáticamente backend + frontend vía postinstall)
pnpm install

# Development (hot-reload en http://localhost:3000)
pnpm dev

# Producción
pnpm build
pnpm start
```

### 3. Scripts Disponibles

| Comando | Descripción |
|---------|------------|
| `pnpm dev` | Servidor de desarrollo con hot-reload (`tsx watch`) |
| `pnpm start` | Servidor de producción (Node + `dist/`) |
| `pnpm build` | Compila backend (`src/` → `dist/`) |
| `pnpm build:frontend` | Compila frontend (`src/frontend/` → `public/js/`) |
| `pnpm build:all` | Compila backend + frontend |
| `pnpm test` | Ejecuta todos los tests |
| `pnpm test:auth` | Solo tests de autenticación |

---

## Estructura del Proyecto

```
├── src/                          # Backend TypeScript
│   ├── index.ts                  # Entry point Express
│   ├── db/connection.ts          # Pool de conexión SQL Server
│   ├── middleware/
│   │   ├── authMiddleware.ts     # JWT decode + admin authorization
│   │   └── validation.ts        # express-validator rules
│   ├── controllers/
│   │   ├── authController.ts     # Login / Logout
│   │   ├── empleadoController.ts # CRUD empleados + impersonación
│   │   ├── puestoController.ts   # Catálogo de puestos
│   │   ├── tiposMovimientoController.ts
│   │   ├── bitacoraController.ts # Bitácora de eventos
│   │   └── planillaController.ts # Planilla semanal/mensual
│   ├── routes/                   # Enrutadores Express
│   ├── utils/errorhelper.ts      # Mapeo códigos de error HTTP
│   └── frontend/                 # Frontend TypeScript
│       ├── AuthService.ts
│       ├── login.ts
│       ├── empleados.ts
│       ├── empleado-view.ts
│       ├── bitacora.ts
│       └── utils.ts
├── public/                       # Archivos estáticos
│   ├── login.html
│   ├── empleados.html
│   ├── empleado-view.html
│   ├── bitacora.html
│   └── css/style.css
├── SQL/
│   ├── SCRIPTS/                  # DDL, triggers, seed data
│   ├── SPs/                      # 21 stored procedures
│   └── DATA/                     # Archivos XML de ejemplo
├── tests/
│   └── authMiddleware.test.ts    # 16 tests
├── dist/                         # Backend compilado
├── package.json
├── tsconfig.json                 # Backend TS (CommonJS)
└── tsconfigFronted.json          # Frontend TS (ES modules + DOM)
```

---

## Base de Datos

Modelo relacional de 21 tablas con 23 foreign keys y 1 trigger.

### Tablas

| Tabla | Tipo | Propósito |
|-------|------|-----------|
| `BitacoraEvento` | Auditoría | Trazabilidad de eventos con IP y timestamp |
| `DBError` | Error | Errores no controlados de BD |
| `DeduccionEmpleado` | Asignación | Deducciones asignadas a empleados (con rango de fechas) |
| `DeduccionXMes` | Resumen | Resumen mensual de deducciones por empleado |
| `Empleado` | Core | Datos maestros de empleados |
| `Error` | Catálogo | Códigos de error con descripción |
| `Feriado` | Catálogo | Feriados (disparan horas extra dobles) |
| `HorarioJornada` | Asignación | Jornada asignada por empleado y semana |
| `MarcaAsistencia` | Core | Marcas diarias de entrada y salida |
| `Mes` | Calendario | Ciclo mensual de planilla |
| `MovHoras` | Movimiento | Movimientos por hora (hasta 3 por asistencia) |
| `MovPlanilla` | Movimiento | Líneas monetarias de la planilla semanal |
| `PlanillaMensual` | Planilla | Resumen mensual por empleado |
| `PlanillaSemanal` | Planilla | Resumen semanal por empleado (con comprobante opcional) |
| `Puesto` | Catálogo | Puestos con salario por hora |
| `Semana` | Calendario | Ciclo semanal (viernes → jueves) |
| `TipoDeduccion` | Catálogo | Tipos de deducción (% o monto fijo, obligatoria o no) |
| `TipoEvento` | Catálogo | Tipos de evento para bitácora |
| `TipoJornada` | Catálogo | Diurno, Vespertino, Nocturno |
| `TipoMovimiento` | Catálogo | Tipos de movimiento (C = crédito, D = débito) |
| `Usuario` | Auth | Usuarios del sistema |

### Trigger

- **`trg_Empleado_Insert_AssignMandatoryDeductions`** — `AFTER INSERT ON Empleado`. Asigna automáticamente todas las deducciones obligatorias (`TipoDeduccion.EsObligatoria = 1`) al nuevo empleado con `FechaFin = '9999-12-31'`.

---

## API REST

Todas las rutas bajo `/api`. Solo `/health` y `POST /api/auth/login` no requieren autenticación. El token se envía como `Authorization: Bearer <token>`.

| Método | Ruta | Auth | Admin | Descripción |
|--------|------|:----:|:-----:|-------------|
| `GET` | `/health` | ✗ | ✗ | Health check |
| `POST` | `/api/auth/login` | ✗ | ✗ | Inicio de sesión |
| `POST` | `/api/auth/logout` | ✓ | ✗ | Cierre de sesión |
| `GET` | `/api/empleados` | ✓ | ✓ | Lista de empleados activos |
| `GET` | `/api/empleados/:doc` | ✓ | ✓ | Empleado por documento |
| `GET` | `/api/empleados/by-id/:id` | ✓ | ✗ | Empleado por ID interno |
| `POST` | `/api/empleados/impersonar` | ✓ | ✓ | Impersonar empleado |
| `POST` | `/api/empleados/regresar-admin` | ✓ | ✓ | Regresar de impersonación |
| `GET` | `/api/puestos` | ✓ | ✗ | Catálogo de puestos |
| `GET` | `/api/tiposMovimiento` | ✓ | ✗ | Tipos de movimiento |
| `GET` | `/api/bitacora` | ✓ | ✓ | Bitácora (filtros + paginación) |
| `GET` | `/api/bitacora/tipos-evento` | ✓ | ✓ | Tipos de evento |
| `GET` | `/api/planilla/semanal/:idEmpleado` | ✓ | ✗ | Planilla semanal (3 recordsets) |
| `GET` | `/api/planilla/mensual/:idEmpleado` | ✓ | ✗ | Planilla mensual (3 recordsets) |

### Formato de respuesta

```json
{
  "success": true,
  "outResultCode": 0,
  "message": null,
  "data": { ... }
}
```

---

## Frontend

| Página | Archivo | Descripción |
|--------|---------|-------------|
| Login | `login.html` | Formulario de inicio de sesión con contador de bloqueo |
| Empleados | `empleados.html` | Lista de empleados con filtro por nombre/documento e impersonación |
| Employee-View | `empleado-view.html` | Planilla semanal y mensual con desglose diario |
| Bitácora | `bitacora.html` | Visor de eventos con filtros y paginación |
| Index | `index.html` | Redirecciona a login o empleados según sesión |

Tema oscuro con sidebar responsivo de 280px y soporte para `prefers-reduced-motion`.

---

## Stored Procedures

21 procedimientos almacenados en `SQL/SPs/`:

**Autenticación**
- `sp_Login` / `sp_Logout` / `sp_GetUsuarioId`

**Empleados**
- `sp_GetEmpleados` / `sp_GetEmpleadoById` / `sp_GetEmpleadoByIdInt`
- `sp_GetEmpleadoIdByUsuario`
- `sp_ImpersonarEmpleado` / `sp_RegresarAdmin`

**Catálogos**
- `sp_GetPuestos` / `sp_GetTiposMovimiento` / `sp_GetTiposEvento`
- `sp_GetBitacora` / `sp_GetError` / `sp_GetLastDbError`

**Procesamiento (lógica de negocio)**
- `sp_CrearCalendario` — genera ciclos de mes y semana
- `sp_ProcesarAsistencia` — procesa una marca → hasta 3 movimientos de horas
- `sp_ProcesarPlanillaSemanal` — cierre semanal con deducciones
- `sp_ProcesarPlanillaMensual` — cierre mensual + apertura del siguiente ciclo

**Consultas de planilla**
- `sp_GetPlanillaSemanal` — grid + deducciones + asistencias diarias
- `sp_GetPlanillaMensual` — grid + deducciones + desglose semanal

---

## Testing

```bash
pnpm test
pnpm test:auth   # solo auth middleware
```

El test suite contiene 16 pruebas unitarias sobre el middleware de autenticación (decodificación de token, validación de expiración, autorización admin). No requiere conexión a base de datos.

---

## Códigos de Error

| Código | HTTP | Significado |
|--------|:----:|-------------|
| 50001 | 401 | Username no existe |
| 50002 | 401 | Contraseña incorrecta |
| 50003 | 403 | Login bloqueado (5 intentos fallidos en 20 min) |
| 50004 | 409 | Documento duplicado en inserción |
| 50005 | 409 | Nombre duplicado en inserción |
| 50006 | 409 | Documento duplicado en actualización |
| 50007 | 409 | Nombre duplicado en actualización |
| 50008 | 500 | Error de base de datos |
| 50009 | 400 | Nombre no alfabético |
| 50010 | 400 | Documento no alfabético |
| 50011 | 400 | Movimiento genera saldo negativo |
| 50012 | 404 | Empleado no encontrado o inactivo |
| 50013 | 403 | El usuario no es administrador |

---

## Licencia

Proyecto académico — ITCR, Base de Datos 1, I Semestre 2026.
