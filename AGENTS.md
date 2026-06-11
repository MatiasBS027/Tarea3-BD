# AGENTS.md — Guía operativa (Planilla / Control de Asistencia)

> **Fuente única de verdad**: `Especificacion.pdf` (PDF del profe fquiros, Mayo 2026).
> Este archivo **no** redefine requisitos; documenta **decisiones de implementación**, **convenciones** y **workflow** del agente.

---

## 1. Modelo de datos (resumen)

### 1.1 Origen del modelo

- Se parte del modelo de Sebas (su diagrama ER, `ModeloSebas.jpeg` + `ModeloSebas1/2/3.jpeg`) usado como **guía estructural**.
- Se aplican 8 correcciones justificadas contra `Especificacion.pdf` (ver `SQL/SCRIPTS/Tablas.sql` por tabla y la sección §1.3 aquí para el resumen).
- Convenciones de Tarea2-BD: `id` en minúscula (PK IDENTITY), tablas `DBError` y `Error` para trazabilidad, `inXxx`/`@outResultCode INT OUTPUT` en SPs, `SET XACT_ABORT ON; SET NOCOUNT ON;` por SP.
- Convenciones de SSMS en `SQL/SCRIPTS/Tablas.sql`: sin `IF OBJECT_ID` ni `DROP` (esquema único, se asume base preexistente creada con `VaciarDB.sql`).
- Los SPs individuales (`SQL/SPs/*.sql`) SÍ usan `IF OBJECT_ID DROP` porque se deployan incrementalmente.
- Convenciones Tarea2-BD para `BitacoraEvento`: `IpPostIn` (no `ip`), `PostTime` (no `FechaHora`).
- El backend de Tarea2-BD (`src/controllers/*.ts`) NO es de este proyecto — no basarse en él.

### 1.2 Modelo final (21 tablas, 23 FKs, 1 trigger)

| Tabla | Columnas | Notas |
|---|---|---|
| `BitacoraEvento` | id, idTipoEvento, idUsuario, **PostTime**, **IpPostIn**, Descripcion | R07: User.Id, IP, estampa de tiempo. NVARCHAR(512) en Descripcion. |
| `DBError` | id, UserName, Number, State, Severity, Line, [Procedure], Message, DateTime | Bitácora de errores no controlados. NVARCHAR en UserName/Procedure/Message. |
| `DeduccionEmpleado` | id, idEmpleado, idTipoDeduccion, **MontoFijo**, FechaInicio, **FechaFin** | Una fila por (empleado, tipo de deducción). MontoFijo carga el `Valor` del TipoDeduccion (sea % o monto); el SP decide cómo aplicarlo. FechaFin='9999-12-31' = vigente. |
| `DeduccionXMes` | id, idPlanillaMensual, **idEmpleado**, idTipoDeduccion, MontoTotal | Resumen mensual de deducciones por empleado (PDF §6: "DeduccionesXEmpleadoxMes"). idEmpleado agregado para evitar join transitivo a PlanillaMensual. |
| `Empleado` | id, idPuesto, idUsuario, ValorDocumento, Nombre, CuentaBancaria, FechaContratacion, **Activo** | Sin `Departamento`/`TipoDocIdentidad` (no aportan a planilla, ver §1.3). |
| `Feriado` | id, Nombre, Fecha | Tabla obligatoria: el SP de cierre verifica `Fecha` contra `MarcaAsistencia.Fecha` para extras dobles (PDF p.1, p.8 §4.4.5). |
| `HorarioJornada` | id, idEmpleado, idSemana, idTipoJornada | Asignación de jornada por semana. |
| `MarcaAsistencia` | id, idEmpleado, Fecha, HoraEntrada, HoraSalida | **Sin** FK a HorarioJornada ni Semana (ver §1.3.6). Jornada nocturna puede cruzar medianoche. |
| `Mes` | id, FechaInicio, FechaFin, NumJueves TINYINT | Encabezado del ciclo mensual. NumJueves precalculado por el SP. |
| `MovHoras` | id, QHoras INT, **Monto DECIMAL(10,2)**, idAsistencia, idTipoMov | **Tabla nueva**. PDF §4.4.5: cada asistencia → hasta 3 movimientos (1 ord, 1 ext-normal, 1 ext-doble). QHoras siempre entero (PDF: "Solo se pagan horas completas, si el empleado trabajo 7.5 horas se pagan 7 horas"). Monto = QHoras × SalarioXHora × factor (1.0/1.5/2.0). |
| `MovPlanilla` | id, idPlanillaSemanal, idTipoMovimiento, Monto, NuevoSaldo | Líneas monetarias de la planilla. `NuevoSaldo` = saldo acumulado después de aplicar el movimiento. |
| `PlanillaMensual` | id, idEmpleado, idMes, SalarioBruto, TotalDeducciones, SalarioNeto | Suma de las semanales del mes (puede no ser mes natural). |
| `PlanillaSemanal` | id, idEmpleado, idSemana, SalarioBruto, TotalDeducciones, SalarioNeto, **Comprobante** VARBINARY(MAX) NULL | **Sin** columnas HorasOrd/ExtraNormal/ExtraDoble (denormalización, ver §1.3.5). Comprobante = PDF/image del recibo. |
| `Puesto` | id, Nombre, SalarioXHora | Catálogo. Mapeo por `Nombre` desde el XML (PDF p.6). |
| `Semana` | id, idMes, FechaInicio, FechaFin | Ciclo semanal viernes → jueves. |
| `TipoDeduccion` | id, Nombre, **EsObligatoria** BIT, **EsPorcentual** BIT, **Valor** DECIMAL(8,4), idTipoMovimiento | Modelo unificado: si `EsPorcentual=1` el SP aplica `Valor * SalarioBruto`; si `EsPorcentual=0` el SP divide `Valor / NumJueves` y aplica por semana. |
| `TipoEvento` | id, Nombre | Catálogo para BitacoraEvento. |
| `TipoJornada` | id, Nombre, HoraInicio TIME(0), HoraFin TIME(0) | Diurno, Vespertino, Nocturno. |
| `TipoMovimiento` | id, Nombre, Accion CHAR(1) | Crédito ('C') o Débito ('D'). Catálogo para MovHoras y MovPlanilla. |
| `Usuario` | id, Username, PasswordHash, **Tipo** VARCHAR(2) | `Tipo='1'` admin, `Tipo='2'` empleado (PDF p.6, comentario XML). |
| **Trigger** | `trg_Empleado_Insert_AssignMandatoryDeductions` | `AFTER INSERT ON Empleado`, cross-join con `TipoDeduccion WHERE EsObligatoria=1`, inserta `DeduccionEmpleado` con `MontoFijo=td.Valor`, `FechaInicio=i.FechaContratacion`, `FechaFin='9999-12-31'`. |

**Total: 21 tablas, 23 FKs, 1 trigger.**

### 1.3 Las 8 correcciones al modelo de Sebas (con cita al PDF)

| # | Cambio | Justificación (PDF) |
|---|---|---|
| 1 | Quitar `Departamento`, `TipoDocIdentidad` | Mencionados solo en el XML de catálogos (p.7 §4); no aparecen en R01-R07 ni en §2 (cálculo de planilla). "Control de asistencia y Planilla Obrera" no las necesita. |
| 2 | Agregar `MovHoras` | p.8 §4.4.5: *"en un caso extremo la asistencia del empleado a una fecha puede generar 3 movimientos"*. p.8: *"debe generarse movimientos en la planilla semanal"*. R04 (p.3): *"se visualizan, en un grid, para cada día de la semana … los movimientos que generó esa asistencia"*. Sebas solo guarda sumas — rompe R04. |
| 3 | `Comprobante` de tabla a columna `VARBINARY(MAX) NULL` en `PlanillaSemanal` | El PDF no menciona `Comprobante` como entidad. R04 (p.3) enumera las columnas del grid y `Comprobante` no está. |
| 4 | Quitar `ComprobanteHora` | Consecuencia de 3. |
| 5 | Quitar `PlanillaSemanal.HorasOrdinarias/ExtraNormal/ExtraDoble` | Denormalización. p.8: *"debe generarse movimientos"*. p.10 §6: *"insertar movimientos por horas"*. Con `MovHoras` se obtiene por SQL agregado. |
| 6 | `MarcaAsistencia` solo `idEmpleado` (sin `idSemana`/`idHorarioJornada`) | p.8: *"NO puede ser que inicien al siguiente día (a menos que se inserten jueves), pues aún no tendrán asignado una jornada de trabajo."* Si la FK fuera obligatoria, no podrían existir marcas sin horario. |
| 7 | `BitacoraEvento`: `ip`→`IpPostIn`, `FechaHora`→`PostTime` | Cosmético, convención Tarea2-BD. |
| 8 | `Feriado.Fecha` consultable al cierre | p.1: *"el valor de la hora extra es 1.5 … siempre que la hora trabajada no sea en domingo ni feriado, en cuyo caso es 2.0"*. p.8 §4.4.5: *"si la fecha es domingo o feriado, son horas extras dobles"*. El SP hace `MarcaAsistencia.Fecha IN (SELECT Fecha FROM Feriado)`. |

---

## 2. Convenciones

### 2.1 Naming
- Tablas: `PascalCase` singular.
- Columnas: `PascalCase`. PK = `id` (minúscula, IDENTITY). FK = `idEntidad` (minúscula, ej. `idPuesto`, `idEmpleado`).
- SPs: `sp_ActionEntity` (`sp_InsertarEmpleado`, `sp_ProcessWeeklyPayroll`).
- Triggers: `trg_Tabla_Evento` (`trg_Empleado_Insert_AssignMandatoryDeductions`).
- Cursores explícitos: prohibido. Usar `OUTPUT INTO` para capturar IDs nuevos.

### 2.2 Tipos de datos
- Montos: `decimal(10,2)` (equivalente a `money` para nuestros rangos).
- Porcentajes: `decimal(8,4)` (rango 0–1).
- Fechas: `date`. Fechas+hora: `datetime`. Horas de jornada: `time(0)`.
- IDs: `int IDENTITY(1,1)` para todas las tablas (catálogos incluidos). Tarea2-BD lo hace así para uniformidad; el SP de carga de XML usa `WHERE NOT EXISTS` para idempotencia.
- PDFs/images de comprobante: `varbinary(max)`.

### 2.3 Constraints
- Toda FK: `FK_Origen_Destino`.
- UNIQUE: `UQ_Tabla_Cols`.
- CHECK: `CK_Tabla_Restriccion`.
- Identificadores que se buscan por nombre (no por PK): `Puesto.Nombre`, `Usuario.Username`, `TipoEvento.Nombre`, `TipoMovimiento.Nombre`, `TipoJornada.Nombre`.

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
        -- BEGIN TRANSACTION
        -- logica de negocio
        -- INSERT en BitacoraEvento
        -- COMMIT
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;

        INSERT INTO [dbo].[DBError] ([UserName], [Number], [State], [Severity], [Line], [Procedure], [Message], [DateTime])
        VALUES (SYSTEM_USER, ERROR_NUMBER(), ERROR_STATE(), ERROR_SEVERITY(),
                ERROR_LINE(), ISNULL(ERROR_PROCEDURE(), 'sp_AccionEntidad'),
                ERROR_MESSAGE(), GETDATE());

        SET @outResultCode = 50008;
    END CATCH
END;
GO
```

---

## 3. Reglas de negocio (resumen para SPs)

### 3.1 Semana y mes planilla
- **Semana**: viernes → jueves. Cierre: jueves 00:00 (medianoche).
- **Mes planilla**: último viernes del mes anterior → último jueves del mes en curso. 4 o 5 semanas según cuántos jueves caigan.
- Deducciones porcentuales: `SalarioBruto × Valor` (semanal) — el SP ve `EsPorcentual=1`.
- Deducciones fijas: `Valor / NumJueves` — el SP ve `EsPorcentual=0`.

### 3.2 Horas extra (PDF p.8 §4.4.5)
- **Ordinarias**: horas trabajadas dentro de la jornada × `SalarioXHora` → fila en `MovHoras` (con `Monto`) + fila en `MovPlanilla` (crédito).
- **Extras normales**: horas trabajadas **después** del fin de jornada, no domingo/feriado × `SalarioXHora × 1.5` → fila en `MovHoras` (con `Monto`) + fila en `MovPlanilla`.
- **Extras dobles**: horas extras en domingo/feriado × `SalarioXHora × 2.0` → fila en `MovHoras` (con `Monto`) + fila en `MovPlanilla`.
- Solo horas **completas** (7.5 → 7). QHoras = INT en `MovHoras`.
- **Una asistencia puede generar hasta 3 movimientos** distintos (ej: salida 3am del día siguiente siendo feriado).

### 3.3 Salario neto
- `SalarioNeto = SalarioBruto - TotalDeducciones`.
- Planilla semanal y mensual: ambas con `SalarioBruto`, `TotalDeducciones`, `SalarioNeto`.

### 3.4 Cierre mensual
Cuando el jueves es el **último jueves** del mes calendario:
1. Cerrar planillas semanales del mes (asignar `idPlanillaMensual` en su tabla mensual).
2. Acumular a `PlanillaMensual` por empleado.
3. Crear encabezado del **siguiente mes** planilla (4 o 5 semanas).

### 3.5 Trigger
`trg_Empleado_Insert_AssignMandatoryDeductions` (en `SQL/SCRIPTS/Trigger.sql`):
- Al insertar un empleado, crea una fila en `DeduccionEmpleado` por cada `TipoDeduccion` con `EsObligatoria=1`.
- Copia `TipoDeduccion.Valor` a `DeduccionEmpleado.MontoFijo` (sea % o monto fijo).
- `FechaInicio = Empleado.FechaContratacion`, `FechaFin = '9999-12-31'` (sentinela de vigente).

---

## 4. Arquitectura

- **DB**: SQL Server ≥ 2014, base `PlanillaDB` (se crea con `VaciarDB.sql`, esquema con `Tablas.sql`, trigger con `Trigger.sql`).
- **Capa lógica**: `src/` (Node.js + Express + `mssql`). Se adaptó del código de Tarea2-BD pero se reescribió significativamente para este proyecto (SP execution patterns, middleware, validación, etc.).
- **Auth**: `Usuario.Tipo='1'` admin, `Tipo='2'` empleado (PDF p.6). Middleware en `src/middleware/authMiddleware.ts`.
- **Validación**: `express-validator` en `src/middleware/validation.ts`. Cada ruta usa `validateXxx` arrays que sanitizan y validan antes de llegar al controller.
- **Trazabilidad**: cada SP inserta en `BitacoraEvento` dentro de la misma transacción; en `BEGIN CATCH` inserta en `DBError`.
- **Scripts disponibles**:
  - `pnpm dev` — hot-reload con `tsx watch`
  - `pnpm start` — producción (Node + dist/)
  - `pnpm build` — compila backend
  - `pnpm build:frontend` — compila frontend (TS → public/js/)
  - `pnpm build:all` — ambos
  - `postinstall` — compila automáticamente tras `pnpm install`
- **Health check**: `GET /health` sin autenticación, devuelve `{ status: "ok", timestamp }`.

### 4.1 Conexión
La conexión real está en `src/db/connection.ts` (asume base ya creada y SPs ya desplegados). Credenciales dev-only — rotar antes de producción.

---

## 5. SPs a implementar (orden sugerido)

1. `sp_Login` / `sp_Logout` (con escritura a `BitacoraEvento`).
2. `sp_GetEmpleados` / `sp_GetEmpleadoById` / `sp_GetEmpleadoByIdInt` (R01/R02).
3. `sp_InsertarEmpleado` (cuenta el trigger).
4. `sp_UpdateEmpleado` / `sp_DeleteEmpleado`.
5. `sp_GetTiposMovimiento` (catálogo).
6. `sp_GetMovimientos` / `sp_InsertMovimiento` (empleado consulta planilla).
7. `sp_GetError` (helper).
8. `sp_GetBitacora` / `sp_GetTiposEvento` (bitácora de eventos).
9. `sp_CrearCalendario` (genera `Mes` y `Semana` con regla viernes→jueves, cierre último jueves).
10. `sp_ProcesarAsistencia` (genera hasta 3 `MovHoras` por asistencia + sus `MovPlanilla`).
11. `sp_ProcesarPlanillaSemanal` (cierre jueves: deducciones, SalarioNeto).
12. `sp_ProcesarPlanillaMensual` (último jueves: cierre de mes, siguiente ciclo).
13. `sp_GetPlanillaSemanal` / `sp_GetPlanillaMensual` (R04/R05).
14. `sp_ImpersonarEmpleado` / `sp_RegresarAdmin` (R03/R06).

Todos con `SET NOCOUNT ON;` (NO usar `SET XACT_ABORT ON` — combinado con transacciones explícitas produce Msg 3930), `BEGIN TRY / BEGIN CATCH` con `IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION` en el CATCH antes de insertar en DBError, y `INSERT INTO BitacoraEvento ...` para SPs que escriben. SPs de solo lectura (catálogos, GETs) no abren transacción ni escriben bitácora.

---

## 6. Workflow del agente

1. **Antes de cambiar esquema**: leer `SQL/SCRIPTS/Tablas.sql` y `SQL/SCRIPTS/Trigger.sql`, y verificar contra el PDF (`Especificacion.pdf`).
2. **Antes de cambiar SPs**: leer este `AGENTS.md` y verificar el invariante con `DBError`/`Error`/`BitacoraEvento` en `Tablas.sql`.
3. **No añadir tablas que no estén en este AGENTS.md o el PDF**, a menos que el usuario lo apruebe.
4. **No usar SQL embebido en TS**: siempre `pool.request().execute('sp_...')`.
5. **Validación de entrada**: usar arrays de `validateXxx` en `src/middleware/validation.ts` por ruta. No repetir validación manual en controllers.
6. **Cada cambio al esquema** requiere probar con el dataset de ejemplo (seed en `sp_CargarCatalogosXML` + INSERTs de prueba en scripts separados).
7. **Mapeo XML → BD**: el SP de carga (`sp_CargarCatalogosXML`) es el único punto que lee el XML. Idempotente: `WHERE NOT EXISTS` o `MERGE`.

---

## 7. Riesgos identificados

- **Asistencia sin horario**: si el `SP` de procesamiento de asistencia no encuentra `HorarioJornada` para esa semana, debe tratarlo como fuera de jornada (probablemente todo el tiempo es "extra" o se rechaza). Documentar el comportamiento esperado antes de implementar.
- **Jornadas nocturnas**: una asistencia puede cruzar medianoche. Calcular siempre con `datetime`, no con `date` ni `time`.
- **Mes planilla ≠ mes natural**: la apertura del siguiente mes ocurre cuando el jueves es el **último jueves del mes calendario**, no el último día.
- **Carga inicial idempotente**: el SP `sp_CargarCatalogosXML` debe usar `WHERE NOT EXISTS` o `MERGE` cuando se implemente, para no duplicar si se corre 2 veces.
- **Subtipo único de `TipoDeduccion`**: el modelo simplificado (Sebas) funde obligatoria/porcentual/fija en una sola tabla con flags. El SP que aplica la deducción es el responsable de interpretar `EsPorcentual` y `EsObligatoria` correctamente.
- **`PlanillaSemanal.Comprobante`**: es `VARBINARY(MAX) NULL`. El SP que lo llena debe generar el PDF (o NULL si no se ha emitido). No hay tabla `Comprobante` que liste múltiples comprobantes por planilla.
- **Cierre semanal sin movimientos**: si una semana no tuvo marcas para un empleado, el SP debe crear la `PlanillaSemanal` con saldos en 0 y aplicar deducciones igual (las deducciones porcentuales sobre 0 son 0; las fijas se dividen igual entre 4 ó 5).

---

## 8. Anexo: archivos del proyecto SQL

- `SQL/SCRIPTS/VaciarDB.sql` — drop + create de la base vacía (en `master`).
- `SQL/SCRIPTS/Tablas.sql` — 21 tablas + 23 FKs, en formato SSMS, `USE [PlanillaDB]`. Asume base preexistente.
- `SQL/SCRIPTS/Trigger.sql` — `trg_Empleado_Insert_AssignMandatoryDeductions`.
- `SQL/SCRIPTS/CargarDatosXML.sql` — scaffold de `sp_CargarCatalogosXML` (pendiente del XML final).
- `ModeloSebas*.jpeg` — diagrama ER del compañero, referencia visual. No se commitea (evidencia del compañero).
