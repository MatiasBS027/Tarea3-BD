# AGENTS.md — Guía operativa (Planilla / Control de Asistencia)

> **Fuente única de verdad**: `Especificacion.pdf` (transcripción limpia en `SPEC.md`).
> Este archivo **no** redefine requisitos; documenta **decisiones de implementación**, **convenciones** y **workflow** del agente.

---

## 1. Modelo de datos (resumen)

### 1.1 Origen del modelo

- Modelo conceptual provisto por el profesor (`Modelo Conceptual.png`), con la corrección explícita de **NO** incluir `Departamento` ni `TipoDocumentoIdentidad` en la BD. Esos dos catálogos aparecen en el XML de operación del PDF, pero no aportan a la lógica de planilla y por tanto se omiten del esquema físico.
- Convenciones estructurales copiadas de `Tarea2-BD`: ids en minúscula (`id`, `idPuesto`, etc.), tablas `DBError` y `[Error]` para trazabilidad de SPs, uso de `@outResultCode INT OUTPUT` en cada SP, `SET XACT_ABORT ON; SET NOCOUNT ON;` como cabecera.
- El backend ya existente (`src/controllers/*.ts`) asume los nombres `ValorDocumentoIdentidad`, `sp_Login`, `sp_InsertarEmpleado`, `sp_GetEmpleados`, `sp_GetTiposMovimiento`, `sp_GetMovimientos`, `sp_InsertMovimiento`, `sp_UpdateEmpleado`, `sp_DeleteEmpleado`, `sp_GetEmpleadoById`, `sp_Logout`, `sp_GetError`. El esquema y los SPs deben respetar esos nombres.

### 1.2 Catálogos (12 tablas, `id INT IDENTITY(1,1)`)

| Tabla | Notas |
|---|---|
| `TipoEvento` | `id, Nombre` (UNIQUE). Sembrado inline en `Tablas.sql` con 14 valores base. |
| `TipoMov` | `id, Nombre, Accion char(1) CHECK IN ('C','D')`. Catálogo de movimientos. **No** se llama `TipoMovimiento` (es el nombre del modelo conceptual; ya está alineado con el SP `sp_GetTiposMovimiento`). |
| `TipoJornada` | `id, Nombre, HoraInicio time(0), HoraFin time(0)`. `HoraFin <> HoraInicio` (jornadas nocturnas cruzan medianoche — el control se hace en `datetime`, no en `time`). |
| `Puesto` | `id, Nombre, SalarioXHora decimal(10,2)`. `Nombre` UNIQUE. **Es el único catálogo con `IDENTITY`** (consistente con Tarea2-BD). |
| `TipoDeduccion` | `id, FlagObligatorio bit`. Raíz de la jerarquía de deducciones. |
| `DeduccionXLEy` | Subtipo 1:1 de `TipoDeduccion` cuando es **obligatoria de ley** (`FlagObligatorio=1`). Tiene `Porcentaje decimal(8,4)`. |
| `DeduccionNoObligatoria` | Subtipo 1:1 de `TipoDeduccion` cuando es **opcional** (`FlagObligatorio=0`). Tiene `FlagFijo bit`. |
| `DeduccionMontoFijo` | Subtipo 1:1 de `DeduccionNoObligatoria` cuando `FlagFijo=1`. Tiene `Monto money`. |
| `DeduccionPorcentual` | Subtipo 1:1 de `DeduccionNoObligatoria` cuando `FlagFijo=0`. Tiene `Porcentaje decimal(8,4)`. |
| `Feriados` | `id, Nombre, Fecha date` (UNIQUE — no se duplican feriados). Plural tal como aparece en el modelo conceptual. |
| `Mes` | `id, FechaInicio date, FechaFin date`. Encabezado del ciclo mensual de planilla. |
| `Semana` | `id, FechaInicio date, FechaFin date`. Encabezado del ciclo semanal de planilla (viernes → jueves). |

### 1.3 Dominio (10 tablas, `id INT IDENTITY(1,1)`)

- `Usuario` — `id, Username (UNIQUE), Password, Tipo tinyint CHECK IN (1,2)`. `Tipo=1` admin, `Tipo=2` empleado.
- `UsuarioAdministrador` — `idUsuario` PK+FK → `Usuario`. 1:1 cuando `Tipo=1`.
- `UsuarioEmpleado` — `idUsuario` PK+FK → `Usuario`, `idEmpleado` FK → `Empleado` (UNIQUE). 1:1 cuando `Tipo=2`.
- `Empleado` — `id, idPuesto, ValorDocumentoIdentidad (UNIQUE, NVARCHAR(32)), Nombre, CuentaBancaria`. (Se usa `ValorDocumentoIdentidad` y no `documentoIdentidad` para alinear con los SPs ya escritos en `src/`.)
- `Asistencia` — `id, Fecha, MarcaInicio datetime, MarcaFin datetime, idEmpleado`. `MarcaFin > MarcaInicio`.
- `MovHoras` — `id, QHoras int, idAsistencia, idTipoMov`. Una asistencia puede tener hasta 3 filas (ordinarias, extras normales, extras dobles).
- `HorarioJornada` — `id, idEmpleado, idSemana, idTipoJornada`. UNIQUE(`idEmpleado`, `idSemana`).
- `PlanillaSemanal` — `id, SalarioBruto money, SalarioNeto money, idEmpleado, idSemana, idPlanillaMensual NULLABLE`. UNIQUE(`idEmpleado`, `idSemana`). `idPlanillaMensual` se llena en el cierre mensual.
- `MovPlanilla` — `id, Fecha date, Monto money, NuevoSaldo money, idPlanillaSemanal, idTipoMov`. Hijos de la planilla semanal.
- `PlanillaMensual` — `id, SalarioBruto money, idEmpleado, idMes`. UNIQUE(`idEmpleado`, `idMes`).

### 1.4 Deducciones y planes mensuales (4 tablas)

- `DeduccionMensual` — `id, Monto money, idPlanillaMensual, idTipoDeduccion`. UNIQUE(`idPlanillaMensual`, `idTipoDeduccion`). Exigida por la sección 6 del PDF (acumulado mensual por tipo).
- `EmpXTipoDed` — `id, FechaInicio date, FechaFin date NULLABLE, idEmpleado, idTipoDeduccion`. Asignación vigente (`FechaFin IS NULL`).
- `EXTDPorcentual` — `idEmpXTipoDed` PK+FK → `EmpXTipoDed`, `Porcentaje decimal(8,4)`. 1:1 unidireccional.
- `EXTDMontoFijo` — `idEmpXTipoDed` PK+FK → `EmpXTipoDed`, `Monto money`. 1:1 unidireccional.

> **Regla de oro**: una fila de `EmpXTipoDed` puede tener fila **en `EXTDPorcentual` o en `EXTDMontoFijo`, nunca en ambas**. Lo garantiza el SP de asociación, no la BD (no se puede poner CHECK entre dos tablas distintas).

### 1.5 Trazabilidad (3 tablas)

- `BitacoraEvento` — `id, idTipoEvento, Descripcion varchar(512), idUsuario NULLABLE, IpPostIn, PostTime`. R07 del PDF. Todos los SPs insertan aquí dentro de la misma transacción.
- `Error` — `id, Codigo (UNIQUE), Descripcion varchar(512)`. Catálogo de códigos semánticos `5xxxx` (50001–50011 ya sembrados).
- `DBError` — `id, UserName, Number, State, Severity, Line, [Procedure], Message, DateTime`. Bitácora de excepciones no controladas de SQL Server. Los SPs la llenan en su bloque `CATCH`.

> **Total: 29 tablas.**

---

## 2. Convenciones

### 2.1 Naming
- Tablas: `PascalCase` singular (`Empleado`, `PlanillaSemanal`). Excepciones: `Feriados` (plural, fiel al modelo conceptual).
- Columnas: `PascalCase`. PK = `id` (minúscula, IDENTITY). FK = `idEntidad` (minúscula, ej. `idPuesto`, `idEmpleado`).
- SPs: `sp_ActionEntity` (`sp_InsertarEmpleado`, `sp_ProcessWeeklyPayroll`).
- Triggers: `trg_Tabla_Evento` (`trg_Empleado_Insert_AssignMandatoryDeductions`).
- Cursores explícitos: prohibido. Usar `OUTPUT INTO` para capturar IDs nuevos.

### 2.2 Tipos de datos
- Montos: `money`.
- Porcentajes: `decimal(8,4)` (rango 0–1).
- Fechas: `date`. Fechas+hora: `datetime`. Horas de jornada: `time(0)`.
- IDs: `int IDENTITY(1,1)` para **todas** las tablas (catálogos incluidos). Tarea2-BD lo hace así para uniformidad; el SP de carga de XML usa `WHERE NOT EXISTS` para idempotencia.

### 2.3 Constraints
- Toda FK: `FK_Origen_Destino`.
- UNIQUE: `UQ_Tabla_Cols`.
- CHECK: `CK_Tabla_Restriccion`.
- Identificadores que se buscan por nombre (no por PK): `Puesto.Nombre`, `Usuario.Username`, `TipoEvento.Nombre`, `TipoMov.Nombre`, `TipoJornada.Nombre`.

### 2.4 Plantilla de SP
```sql
USE [PlanillaDB];
GO

IF OBJECT_ID(N'dbo.sp_AccionEntidad', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_AccionEntidad];
GO

CREATE PROCEDURE [dbo].[sp_AccionEntidad]
    @inParam1 VARCHAR(128),
    @inIpPostIn VARCHAR(64),
    @inPostTime DATETIME,
    @outResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SET @outResultCode = 0;

    BEGIN TRY
        -- logica de negocio
        -- BEGIN TRANSACTION
        -- INSERT / UPDATE en BitacoraEvento
        -- COMMIT
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;

        INSERT INTO [dbo].[DBError] ([UserName], [Number], [State], [Severity], [Line], [Procedure], [Message], [DateTime])
        VALUES (SYSTEM_USER, ERROR_NUMBER(), CAST(ERROR_STATE() AS VARCHAR(32)),
                CAST(ERROR_SEVERITY() AS VARCHAR(32)), ERROR_LINE(),
                ISNULL(ERROR_PROCEDURE(), 'sp_AccionEntidad'), ERROR_MESSAGE(), GETDATE());

        SET @outResultCode = 50008;
    END CATCH
END;
GO
```

---

## 3. Reglas de negocio (resumen para SPs)

### 3.1 Semana y mes planilla
- **Semana**: viernes → jueves. Cierre: jueves 00:00.
- **Mes planilla**: último viernes del mes anterior → último jueves del mes en curso. 4 o 5 semanas según cuántos jueves caigan.
- Deducciones porcentuales: `SalarioBruto × porcentaje` (semanal).
- Deducciones fijas: `MontoMensual / N` donde `N` = # de jueves en el mes planilla (4 ó 5).

### 3.2 Horas extra
- **Ordinarias**: horas trabajadas dentro de la jornada × `SalarioXHora`.
- **Extras normales**: horas trabajadas **después** del fin de jornada, no domingo/feriado × `SalarioXHora × 1.5`.
- **Extras dobles**: horas extras en domingo/feriado × `SalarioXHora × 2.0`.
- Solo horas **completas** (7.5 → 7).
- Una asistencia puede generar hasta **3 movimientos** distintos.

### 3.3 Salario neto
- `SalarioNeto = SalarioBruto - TotalDeducciones`.
- Planilla semanal y mensual: ambas con `SalarioBruto`, `TotalDeducciones` (calculado en SP), `SalarioNeto`.

### 3.4 Cierre mensual
Cuando el jueves es el **último jueves** del mes calendario:
1. Cerrar planillas semanales del mes (asignar `idPlanillaMensual`).
2. Acumular a `PlanillaMensual` por empleado.
3. Crear encabezado del **siguiente mes** planilla (4 o 5 semanas).

### 3.5 Trigger
`trg_Empleado_Insert_AssignMandatoryDeductions` (en `Tablas.sql`):
- Al insertar un empleado, crea una fila en `EmpXTipoDed` por cada `TipoDeduccion` con `FlagObligatorio=1` (es decir, con fila en `DeduccionXLEy`).
- Crea también la fila en `EXTDPorcentual` correspondiente, copiando el `Porcentaje` de `DeduccionXLEy`.

---

## 4. Arquitectura

- **DB**: SQL Server ≥ 2014, base `PlanillaDB`.
- **Capa lógica**: Node.js + Express + `mssql`. Cero SQL embebido — todo vía SPs.
- **Front**: HTML/CSS/JS servidos desde `public/`.
- **Web layer**: 2 portales (admin y empleado) según SPEC.
- **Auth**: `sp_Login` / `sp_Logout`. `Usuario.Tipo` = 1 admin, 2 empleado.
- **Trazabilidad**: cada SP inserta en `BitacoraEvento` dentro de la misma transacción; en `BEGIN CATCH` inserta en `DBError`.

### 4.1 Conexión
`src/db/connection.ts` ya apunta a `PlanillaDB`. Credenciales hardcoded (sa / `Bd2Tarea2026!`) — son **dev only**, rotar antes de producción.

### 4.2 Carga de errores
El backend referencia `dbo.DBError` y `sp_GetError` (ver `src/utils/errorhelper.ts`). **Estas YA están en el esquema** (ver §1.5). El SP `sp_GetError` ya está disponible como referencia en `Tarea2-BD\SQL\SPs\sp_GetError.sql`.

---

## 5. SPs a implementar (orden sugerido)

1. `sp_Login` / `sp_Logout` (con escritura a `BitacoraEvento`).
2. `sp_GetEmpleados` / `sp_GetEmpleadoById` (R01/R02).
3. `sp_InsertarEmpleado` (cuenta el trigger).
4. `sp_UpdateEmpleado` / `sp_DeleteEmpleado`.
5. `sp_GetTiposMovimiento` (catálogo).
6. `sp_GetMovimientos` / `sp_InsertMovimiento` (empleado consulta planilla).
7. `sp_GetError` (helper — clonar de Tarea2-BD, ajustar `USE PlanillaDB`).
8. `sp_CrearCalendario` (genera `Mes` y `Semana` con regla viernes→jueves, cierre último jueves).
9. `sp_ProcesarAsistencia` (genera hasta 3 `MovHoras` por asistencia).
10. `sp_ProcesarPlanillaSemanal` (cierre jueves: deducciones, SalarioNeto).
11. `sp_ProcesarPlanillaMensual` (último jueves: cierre de mes, siguiente ciclo).
12. `sp_GetPlanillaSemanal` / `sp_GetPlanillaMensual` (R04/R05).
13. `sp_ImpersonarEmpleado` / `sp_RegresarAdmin` (R03/R06).

Todos con `SET XACT_ABORT ON; SET NOCOUNT ON;`, `BEGIN TRY / BEGIN CATCH`, y al final `INSERT INTO BitacoraEvento ...`.

---

## 6. Workflow del agente

1. **Antes de cambiar esquema**: leer `Tablas.sql` y `SPEC.md` (PDF).
2. **Antes de cambiar SPs**: leer este `AGENTS.md` y verificar el invariante con el backend en `src/controllers/`.
3. **No añadir tablas que no estén en el modelo conceptual o el SPEC**, a menos que el usuario lo apruebe.
4. **No usar SQL embebido en TS**: siempre `pool.request().execute('sp_...')`.
5. **Cada cambio al esquema** requiere probar con el dataset de ejemplo (catal seed en `Tablas.sql` + INSERTs de prueba en scripts separados).
6. **Mapeo XML → BD**: el SP de carga queda como scaffold en `CargarDatosXML.sql`. Hasta que se defina el XML final, la BD arranca con la semilla inline de `Tablas.sql` (Error + TipoEvento).

---

## 7. Riesgos identificados

- **FKs bidireccionales entre `EmpXTipoDed` y `EXTDX*`**: solo van en una dirección (`EXTDX*` apunta a `EmpXTipoDed`).
- **Subtipos de `TipoDeduccion`**: nunca debe existir un `TipoDeduccion` con filas en **dos** subtipos a la vez (XLEy **y** NoObligatoria, o NoObligatoria **y** ambas DeduccionPorcentual/DeduccionMontoFijo). Lo garantiza el SP de carga, no la BD.
- **Jornadas nocturnas**: una asistencia puede cruzar medianoche. Calcular siempre con `datetime`, no con `date` ni `time`.
- **Mes planilla ≠ mes natural**: la apertura del siguiente mes ocurre cuando el jueves es el **último jueves del mes calendario**, no el último día.
- **Carga inicial idempotente**: el SP `sp_CargarCatalogosXML` (scaffold) debe usar `WHERE NOT EXISTS` o `MERGE` cuando se implemente, para no duplicar si se corre 2 veces.
- **Backend usa nombres específicos**: `ValorDocumentoIdentidad` (no `documentoIdentidad`), `sp_InsertarEmpleado` (con `r`). Si se renombran, hay que actualizar `src/` también.

---

## 8. Anexo: cambios al modelo (vs esquema anterior)

- **Agregadas** (fieles al modelo conceptual): `DeduccionXLEy`, `DeduccionNoObligatoria`, `DeduccionMontoFijo`, `DeduccionPorcentual`, `EXTDPorcentual`, `EXTDMontoFijo`, `DeduccionMensual`. Total +7 tablas de deducciones.
- **Eliminadas** (corrección del profe): `Departamento`, `TipoDocumentoIdentidad`. Existían en el XML de operación pero no aportan a la lógica de planilla.
- **Renombradas / normalizadas**:
  - `TipoMovimiento` → `TipoMov` (modelo conceptual).
  - `Feriado` → `Feriados` (plural del modelo).
  - `EmpleadoXTipoDeduccion` → `EmpXTipoDed` (modelo).
  - `EXTDXDeduccionPorcentual` → `EXTDPorcentual`, `EXTDXMontoFijo` → `EXTDMontoFijo` (modelo).
- **Cambios estructurales**:
  - Todos los `id` en minúscula (antes `Id`), siguiendo Tarea2-BD.
  - `Puesto.id` ahora `IDENTITY(1,1)` (antes manual desde XML).
  - Tablas `Error` y `DBError` añadidas (no estaban en el SPEC pero el backend `src/utils/errorhelper.ts` las referencia, y Tarea2-BD las aprueba).
  - `BitacoraEvento.idUsuario` ahora NULLABLE (para login fallido sin usuario).
