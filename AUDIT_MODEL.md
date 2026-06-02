**Informe técnico: Auditoría del Modelo Físico de Base de Datos**

Resumen ejecutivo
- Fecha: 2026-06-01
- Proyecto: Planilla / Control de Asistencia
- Resultado general: ⚠️ Funciona pero requiere ajustes (varios problemas críticos y medios detectados).

Hallazgos clave (resumen)
- Inconsistencias en claves foráneas (FK) — varias ALTER TABLE referencian columnas incorrectas (ej.: BitacoraEvento usa `[id]` en lugar de `[idTipoEvento]` / `[idUsuario]`). (Critical)
- Falta de `IDENTITY` / auto-increment en PKs donde la especificación lo exige (Puesto debe ser IDENTITY; tablas no-catalogo deben usar identity) — actualmente ningún PK tiene IDENTITY. (High)
- Clave circular entre `DeduccionMensual` y `PlanillaMensual` (ambas referencian la otra) — impide inserciones sin workarounds. (Critical)
- Nombres de columnas y tipos inconsistentes con el código (ej.: tabla `Usuario` define columna `User` pero el código TS consulta `Username`; `PostTIme` vs `PostTime` typo). (High)
- Tablas con PKs mal elegidas para relaciones 1:N vs 1:1 (ej.: `MovimientoHoras` usa `idMovimientoPlanilla` como PK, impidiendo múltiples filas por movimiento). (High)
- Tipos de datos subóptimos o mal usados: `TipoJornada.HoraInicio/HoraFin` como `datetime` en lugar de `time`; `money` es aceptable pero recomiendo `decimal(12,2)` para control. (Medium)
- Nombres de tablas con caracteres inválidos (`Feriados'` con apóstrofe). (Medium)
- Falta de columnas para trazabilidad completa en `BitacoraEvento` (JSON antes/después, parametros). (Medium)
- Conexión en `src/db/connection.ts` apunta a `VacacionesDB` mientras el script crea `PlanillaDB`. (High)

Detalles y pruebas realizadas
- Leí y contrasté: `SPEC.md`, `SQL/SCRIPTS/Tablas.sql`, controladores en `src/controllers/*`, y `src/db/connection.ts`.
- Revisé todas las CREATE TABLE y ALTER TABLE del script; observé múltiples mismatches entre columnas usadas en los ALTER (FK) y las columnas realmente definidas.

Problemas detectados (detallado)

1) FK referencian columnas equivocadas — BitacoraEvento
- Problema: Las ALTER TABLE para `BitacoraEvento` usan `FOREIGN KEY([id]) REFERENCES TipoEvento([id])` y `FOREIGN KEY([id]) REFERENCES Usuario([id])`. La tabla `BitacoraEvento` tiene columnas `[idTipoEvento]` y `[idUsuario]` que deberían ser las FK.
- Impacto: Inserciones en `BitacoraEvento` fallarán o la integridad referencial será inválida; operación de auditoría no segura.
- Gravedad: Critical
- Recomendación / SQL propuesto:

```sql
ALTER TABLE dbo.BitacoraEvento DROP CONSTRAINT IF EXISTS FK_BitacoraEvento_TipoEvento;
ALTER TABLE dbo.BitacoraEvento DROP CONSTRAINT IF EXISTS FK_BitacoraEvento_Usuario;

ALTER TABLE dbo.BitacoraEvento WITH CHECK ADD CONSTRAINT FK_BitacoraEvento_TipoEvento
  FOREIGN KEY ([idTipoEvento]) REFERENCES dbo.TipoEvento([id]);

ALTER TABLE dbo.BitacoraEvento WITH CHECK ADD CONSTRAINT FK_BitacoraEvento_Usuario
  FOREIGN KEY ([idUsuario]) REFERENCES dbo.Usuario([id]);
```

Prioridad: Critical

2) PKs no usan IDENTITY cuando la especificación lo exige
- Problema: Ninguna tabla del script define `IDENTITY`. La especificación dice: "Catálogos → IDs vienen del XML. Excepto `Puesto` que debe ser identity/autoincremental. Tablas no catálogo → identity/autoincrementales." Actualmente no hay `IDENTITY` ni `SEQUENCE`.
- Impacto: Inserciones desde la aplicación necesitan generar/gestionar manualmente IDs; riesgo de colisiones; contradicción con la regla de catálogos que algunos IDs vengan de XML.
- Gravedad: High
- Recomendación: Aplicar una estrategia mixta:
  - `Puesto`: recrear la tabla o agregar columna nueva `id INT IDENTITY(1,1)` y migrar datos. Preferible: crear tabla nueva `Puesto_new` con IDENTITY, migrar y renombrar.
  - Para tablas no-catalogo (Asistencia, PlanillaSemanal, PlanillaMensual, MovimientoPlanilla, MovimientoHoras, EmpleadoXTipoDeduccion, etc.) usar `IDENTITY` en su PK.
  - Para catálogos que reciben IDs desde XML (ej. `TipoJornada`, `TipoMovimiento`, `TipoDeduccion`, `TipoEvento`), mantener `id` como valor provisto (sin IDENTITY). Para seguridad, crear un UNIQUE INDEX sobre `id` y PK sobre `id`.

Ejemplo de solución (recrear `Puesto`):

```sql
CREATE TABLE dbo.Puesto_new (
  id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  Nombre VARCHAR(32) NOT NULL,
  SalarioXHora DECIMAL(12,2) NOT NULL
);

INSERT INTO dbo.Puesto_new (Nombre, SalarioXHora)
SELECT Nombre, SalarioXHora FROM dbo.Puesto;

-- luego renombrar tablas mediante sp_rename en mantenimiento
```

Prioridad: High

3) Circular FK: `DeduccionMensual` <-> `PlanillaMensual`
- Problema: `DeduccionMensual` contiene `idPlanillaMensual` y `PlanillaMensual` contiene `idDeduccionMensual` y ambas son FK una de otra, creando dependencia circular.
- Impacto: No es posible insertar una planilla mensual sin antes tener la deducción mensual y viceversa; complica cargas y SPs transaccionales.
- Gravedad: Critical
- Recomendación: Normalizar a un modelo unidireccional:
  - Dejar `DeduccionMensual.idPlanillaMensual` como FK hacia `PlanillaMensual.id` (cada deducción mensual pertenece a una planilla mensual).
  - Eliminar `PlanillaMensual.idDeduccionMensual` o usarlo únicamente como un valor calculado (no como FK); si se requiere mantener un resumen, use una vista o columna calculada actualizada por trigger tras inserciones en `DeduccionMensual`.

SQL sugerido (remover FK y columna):

```sql
-- Si la columna se usa sólo para referencia, migrar y eliminar la FK
ALTER TABLE dbo.PlanillaMensual DROP CONSTRAINT IF EXISTS FK_PlanillaMensual_DeduccionMensual;
ALTER TABLE dbo.PlanillaMensual DROP COLUMN IF EXISTS idDeduccionMensual;

-- Asegurar DeduccionMensual tiene FK a PlanillaMensual
ALTER TABLE dbo.DeduccionMensual WITH CHECK ADD CONSTRAINT FK_DeduccionMensual_PlanillaMensual
  FOREIGN KEY (idPlanillaMensual) REFERENCES dbo.PlanillaMensual(id);
```

Prioridad: Critical

4) `MovimientoHoras` PK inadecuado (1:1 vs 1:N)
- Problema: `MovimientoHoras` define su PK como `idMovimientoPlanilla`. Eso lo hace 1:1 con `MovimientoPlanilla`, pero semánticamente un movimiento de planilla puede detallar varias filas de horas.
- Impacto: Imposible guardar más de una fila de horas asociada a un `MovimientoPlanilla` (p. ej. por distinta asistencia). (High)
- Recomendación: Añadir PK `id` INT IDENTITY en `MovimientoHoras`; conservar `idMovimientoPlanilla` como FK (no PK).

SQL sugerido:

```sql
ALTER TABLE dbo.MovimientoHoras ADD id INT IDENTITY(1,1) NOT NULL;
ALTER TABLE dbo.MovimientoHoras DROP CONSTRAINT PK_MovimientoHoras;
ALTER TABLE dbo.MovimientoHoras ADD CONSTRAINT PK_MovimientoHoras PRIMARY KEY (id);

-- Asegurar FK
ALTER TABLE dbo.MovimientoHoras WITH CHECK ADD CONSTRAINT FK_MovimientoHoras_MovimientoPlanilla
  FOREIGN KEY (idMovimientoPlanilla) REFERENCES dbo.MovimientoPlanilla(id);
```

Prioridad: High

5) Tipos y nombres inconsistentes (code vs schema)
- Observaciones:
  - `Usuario` tabla define columna `[User]` y `[Password]` pero el código consulta `Username`. (High)
  - `src/db/connection.ts` apunta a `VacacionesDB` en lugar de `PlanillaDB`. (High)
  - `BitacoraEvento` tiene `PostTIme` typo. (Medium)
  - Tabla `Feriados'` contiene apóstrofe en nombre. (Medium)
  - `HorarioJornada.isEmpleado` nombre confuso: usar `idEmpleado` para claridad. (Medium)

Recomendaciones:
  - Renombrar columna `User` a `Username` o cambiar el código para usar `User` consistentemente. SQL sugerido:

```sql
EXEC sp_rename 'dbo.Usuario.[User]', 'Username', 'COLUMN';
```

  - Actualizar `src/db/connection.ts` para usar `PlanillaDB` o documentar el db name correcto.
  - Renombrar tabla `Feriados'` a `Feriados` con `sp_rename`.
  - Cambiar `HorarioJornada.isEmpleado` -> `idEmpleado` (crear nueva columna, migrar datos, dropear antigua).

Prioridad: High / Medium según item

6) Uso de tipos `datetime` para horas de jornada
- Problema: `TipoJornada.HoraInicio` y `HoraFin` están como `datetime`. Esto obliga a usar una fecha fija o mezclar fechas al comparar. El tipo `time` es más apropiado.
- Recomendación: Cambiar columnas a `time(0)` o `time(3)`. Se puede agregar nuevas columnas `HoraInicio_time` y migrar.

Prioridad: Medium

7) Bitácora / trazabilidad insuficiente
- Recomendación: Añadir columnas en `BitacoraEvento` para `ParamsJson NVARCHAR(MAX)`, `BeforeState NVARCHAR(MAX)`, `AfterState NVARCHAR(MAX)` y un `id` identity (si no existe). Garantizar índices por `idUsuario` y `PostTime`.

Prioridad: Medium

8) Índices y performance
- Recomendación mínima: crear índices en columnas FK y en columnas de fecha (`Asistencia.Fecha`, `Semana.FechaInicio`, etc.).

Prioridad: Low

9) Reglas temporales / semanas y meses
- Observación: El modelo tiene tablas `Semana` y `Mes` con `FechaInicio` / `FechaFin`, y `PlanillaSemanal` referencia `Semana` y `PlanillaMensual` referencia `Mes`. Hay que asegurar que la construcción de semanas respete la regla de negocio: "semana inicia viernes y termina jueves" — esto depende de la carga de datos y de los SP que generen las semanas.
- Recomendación: Implementar SP `sp_CreateCalendarEntries` que cree las filas `Semana` y `Mes` con la regla de cierre (último jueves del mes). Documentar claramente en AGENTS.md.

Prioridad: High

10) SPs y triggers: soporte incompleto pero viable
- Observación: El proyecto usa SPs (controladores llaman a `sp_*`). El modelo debe permitir SPs para:
  - `sp_ImportXML` (ingesta masiva)
  - `sp_ProcessWeeklyPayroll` y `sp_ProcessMonthlyPayroll`
  - `sp_InsertarEmpleado` con trigger que asigne deducciones obligatorias
  - `sp_Login`, `sp_Logout`, `sp_InsertMovimiento`, etc.
- Recomendación: Implementar SPs con transacciones por `idEmpleado`. Evitar triggers que hagan trabajo pesado; usar triggers sólo para inserciones de trazas o asignaciones simples (ej.: asignar deducciones obligatorias al insertar empleado).

Prioridad: Medium

Viabilidad general
- Clasificación: ⚠️ Funciona pero requiere ajustes.
- Por qué: La base del modelo cubre la mayoría de entidades del dominio (empleado, puesto, asistencias, movimientos, deducciones, planillas, semanas y meses). Sin embargo, los problemas críticos (FK equivocadas y circularidades, identidades faltantes, inconsistencias de nombres) impiden implementar SPs y procesos de simulación sin cambios. La corrección es factible y no requiere re-diseño entero, pero sí una actividad de refactorización de esquema y migración de datos.

Plan de acción recomendado (alto nivel)
1. Congelar cambios de código que escriben en BD (evitar escrituras en entorno real). (Immediate)
2. Corregir FK rotas y nombres de columnas (BitacoraEvento, Usuario.Username, HorarioJornada, Feriados). (Critical)
3. Resolver la circularidad DeduccionMensual ↔ PlanillaMensual. (Critical)
4. Añadir IDENTITY a `Puesto` y a tablas no-catalogo; definir estrategia para catálogos cuyos IDs vienen del XML. (High)
5. Cambiar tipos `datetime` → `time` para horas; revisar comparaciones de horas en SPs. (Medium)
6. Añadir columnas de trazabilidad en `BitacoraEvento`. (Medium)
7. Ajustar `MovimientoHoras` PK para permitir N rows por movimiento. (High)
8. Crear scripts de migración y pruebas unitarias/integración con dataset de ejemplo (archivo XML de prueba). (High)

Anexos — SQL de corrección (ejemplos rápidos)
- Fix FK BitacoraEvento (ver arriba en sección 1)
- Fix Usuario column rename:

```sql
EXEC sp_rename 'dbo.Usuario.[User]', 'Username', 'COLUMN';
-- si existen datos duplicados o colisión, validar antes
```

- Fix MovimientoHoras PK (ver sección 4)

- Recomendación para remover circularidad (ver sección 3)

Notas finales
- Puedo generar scripts completos de migración (ordenados, con fases: crear columnas nuevas, migrar datos, drop columnas viejas, recrear constraints) si apruebas que empiece la reparación.
- También puedo generar un conjunto de SPs plantilla (import XML, calculo semanal, calculo mensual, asignación de deducciones) alineados con el modelo corregido.

-- Fin del informe --
