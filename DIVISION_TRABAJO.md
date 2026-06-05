# División de Trabajo — Tarea 3: Planilla

Proyecto en parejas. Ambos hacen front, back, SQL y SPs. Revisión cruzada al final.

---

## Requisitos del proyecto (R01–R07)

| Req. | Descripción | Interfaz |
|------|-------------|----------|
| R01 | Listar empleados (admin) | Admin |
| R02 | Consultar empleado (deducciones, planilla) | Admin |
| R03 | Admin impersona empleado | Admin |
| R04 | Planilla semanal (grid con movimientos por día) | Empleado |
| R05 | Planilla mensual (resumen) | Empleado |
| R06 | Regresar a interfaz de admin | Admin |
| R07 | Trazabilidad (BitacoraEvento) | Admin |

**No hay CRUD de empleados** — el profe confirmó que no se requiere interfaz para insertar/actualizar/borrar. Solo el insert de empleado (que dispara el trigger de deducciones obligatorias) se hace por script o SP dedicado.

---

## SPs por implementar

### Persona A — Matías (8 SPs)

| SP | Complejidad | Requisito |
|----|-------------|-----------|
| `sp_Login` | Baja | R07 + auth |
| `sp_Logout` | Baja | R07 + auth |
| `sp_GetError` | Baja | Helper (errorhelper.ts) |
| `sp_GetEmpleados` | Baja | R01 |
| `sp_GetEmpleadoById` | Baja | R02 |
| `sp_ImpersonarEmpleado` | Baja | R03 |
| `sp_RegresarAdmin` | Baja | R06 |
| `sp_GetTiposMovimiento` | Baja | Catálogo para R04 |

### Persona B — Seastian (7 SPs)

| SP | Complejidad | Requisito |
|----|-------------|-----------|
| `sp_CrearCalendario` | Alta | Genera Mes + Semana (viernes→jueves) |
| `sp_ProcesarAsistencia` | Alta | Genera MovHoras (hasta 3 por asistencia) |
| `sp_ProcesarPlanillaSemanal` | Alta | Deducciones + SalarioNeto |
| `sp_ProcesarPlanillaMensual` | Alta | Cierre de mes |
| `sp_GetPlanillaSemanal` | Media | R04 grid |
| `sp_GetPlanillaMensual` | Media | R05 resumen |
| `sp_CargarCatalogosXML` | Media | Carga inicial desde XML |

---

## Frontend

| Persona A (Matías) | Persona B (Sebastian) |
|---------------------|------------------------|
| Login | Pantallas empleado |
| Pantallas admin (R01, R02, R03, R06) | Planilla semanal (R04) |
| | Planilla mensual (R05) |

---

## Backend

| Persona A (Matías) | Persona B (Sebastian) |
|---------------------|------------------------|
| Auth middleware | Rutas planilla |
| Rutas admin (empleados, puestos) | Cálculos de planilla |
| Bitácora de operaciones | Consultas de movimientos |

---

## Validaciones

| Persona A (Matías) | Persona B (Sebastian) |
|---------------------|------------------------|
| Nombre alfabético | Horas extra (ordinarias, 1.5x, 2x) |
| ValorDocumentoID duplicado | Feriados vs domingos |
| Username existente/no existente | Deducciones porcentuales vs fijas |
| Password incorrecto | Cierre semanal/mensual |
| Login deshabilitado | NumJueves para deducciones fijas |
| Impersonación válida | Asistencia sin HorarioJornada |

---

## Fases

| Fase | Persona A | Persona B |
|------|-----------|-----------|
| **Común** | Revisar SPEC.md, modelo final, convenciones, XML de catálogos | Igual |
| **1** | sp_Login, sp_Logout, sp_GetError, sp_GetEmpleados | sp_CrearCalendario, sp_ProcesarAsistencia |
| **2** | sp_GetEmpleadoById, sp_ImpersonarEmpleado, sp_RegresarAdmin | sp_ProcesarPlanillaSemanal, sp_ProcesarPlanillaMensual |
| **3** | sp_GetTiposMovimiento, frontend admin, backend auth | sp_GetPlanillaSemanal, sp_GetPlanillaMensual, sp_CargarCatalogosXML, frontend empleado |
| **4** | Integración, pruebas, XML de operación | Integración, pruebas, XML de operación |
| **5** | Revisión cruzada | Revisión cruzada |

---

## Notas

- Tablas SQL ya están en `SQL/SCRIPTS/Tablas.sql` (21 tablas, 22 FKs, 1 trigger). No hay que modificar salvo correcciones.
- XML de catálogos ya está en `data/Datos.xml` (8 secciones, 62 entradas).
- XML de operación (fechas consecutivas) se define en la Fase 4.
- Cada uno commitea en su rama o en main con prefijo `[A]` o `[B]` para distinguir.
- Al final, revisión cruzada: A revisa B, B revisa A.
