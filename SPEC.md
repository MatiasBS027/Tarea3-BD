# Especificación del Proyecto

> **Fuente única de verdad**: `Especificacion.pdf` (ITCR – Escuela de Ing. en Computación – Base de Datos 1 – Prof. fquiros – Mayo 2026).
> Este documento es una transcripción limpia del PDF. Todo lo que no esté aquí NO es requisito del proyecto.

---

## Uno. Objetivos

Implementar una base de datos física, así como escribir el código en capa lógica y física, para la implementación de 2 sitios web (para administradores y empleados), para el mantenimiento de entidades (CRUD) y la realización de consultas. Escribir en SQL un script que realice una simulación la operación del sistema por varios meses.

---

## Dos. Descripción

### Control de asistencia y Planilla Obrera

Los obreros en una fábrica tienen horarios rotativos que cambian semana a semana, según el tipo de jornada (matutina, vespertina o nocturna). La fábrica nunca se detiene, así que los horarios incluyen fines de semana y días feriados. Los obreros trabajan 6 días, descansan un día.

### Salario

El salario por hora depende del puesto y la jornada. Hay **3 tipos de jornadas** (todas de 8 horas):

| Jornada  | Inicio | Fin    |
|----------|--------|--------|
| Diurna   | 06:00  | 14:00  |
| Vespertina | 14:00 | 22:00 |
| Nocturna | 22:00  | 06:00 (del día siguiente) |

- **Hora extra normal**: 1.5 × salario/hora, cuando la marca de salida supera la hora de fin de jornada y **no** es domingo ni feriado.
- **Hora extra doble**: 2.0 × salario/hora, cuando es domingo o feriado.
- Una hora se considera **extraordinaria** si la marca de salida del empleado es superior a la hora de salida de su tipo de jornada en la semana actual.
- **Solo se pagan horas completas** (si trabajó 7.5 se pagan 7).

### Cierre semanal y mensual

- El pago es **semanal**, el reporte a la caja del seguro es **mensual**.
- El **cierre semanal** se realiza todos los jueves a las 12 medianoche.
- El **cierre mensual** se realiza el **último jueves** de cada mes.
- El mes planilla va desde la semana que inicia el **último viernes del mes anterior** hasta el **último jueves del presente mes**.
- El mes usualmente tiene **4 semanas**, pero algunos tienen **5** (depende de cuántos jueves caigan en el ciclo).
- La deducción por aporte a la Caja, aguinaldo y liquidaciones se calculan sobre el **salario mensual**, aunque se paguen semanalmente.

### Deducciones

**Porcentuales** (se aplican semanalmente sobre el salario bruto):
- Caja del seguro (10.5%)
- Cuota Asociación Solidarista (5%)

**Fijas** (monto mensual, se prorratea entre 4 o 5 según los jueves del mes):
- Embargo por pensión alimenticia
- Ahorro vacacional
- Embargo por deuda
- Pago de préstamo con la asociación solidarista

> Las deducciones porcentuales simplemente se aplican como porcentaje. Las fijas se dividen entre 4 o 5 dependiendo de los jueves del mes planilla.

### Planilla

- **Mensual** = suma de semanales del ciclo. Es el salario reportado a la Caja, base para aguinaldo y liquidaciones.
- La suma de las deducciones se transfiere mensualmente a las cuentas de: caja, asociación solidarista, embargos.
- El **pago** al obrero es por transferencia del salario neto (bruto − deducciones).
- El **aguinaldo** (segundo lunes de diciembre) = suma del salario bruto mensual de dic-nov ÷ 12.
- Cada jueves ingresa un XML con los turnos de la siguiente semana (que inicia viernes).

### Devengados (créditos)
- Salario por hora trabajada
- Salario por hora extraordinaria
- Salario por hora extra doble
- Venta de vacaciones y otros

---

## Tres. Requerimientos funcionales

Sitio web para 2 tipos de usuario (administrador / empleado). Login con Usuario + Password.

### Tres.1. Administrador

- **R01**. Listar empleados: nombre + puesto, en orden alfabético. Default al ingresar. Seleccionable para editar.
- **R02**. Listar empleados con filtro: mismo grid que R01, filtrado por patrón en el nombre.
- **R03**. Impersonar un empleado: la siguiente interfaz es idéntica a la del empleado.

### Tres.2. Empleado

- **R04**. Consultar planilla semanal: grid con salario bruto (clickeable), total deducciones (clickeable), salario neto, horas ordinarias, horas extra normales, horas extras dobles. Al click en deducciones: nombre + porcentaje + monto. Al click en salario bruto: por día, hora entrada/salida + movimientos (horas ordinarias, extras normales, extras dobles con su monto).
- **R05**. Consultar planilla mensual: últimos X meses con salario bruto, total deducciones, salario neto. Al click en deducciones: nombre + porcentaje + monto de cada una (suma de las semanales del mes).
- **R06**. Regresar a interfaz de administrador (solo visible si se entró como admin aunque impersonando).

### R07. Trazabilidad (no funcional)

Bitácora de eventos para **toda** acción: consultas, CRUD, asignación/desasignación de deducciones, login, logout.

Para cada evento se almacena:
- `IdUsuario`
- `IP` desde donde se ejecuta
- `PostTime` (estampa de tiempo)
- `IdTipoEvento`
- **Parámetros** de la operación (formato JSON permitido)
- Para CRUD: registro **antes** y registro **después** (JSON)

| Tipo de Evento | Información guardada |
|---|---|
| Login | UserName, resultado: exitoso/no exitoso |
| Logout | Nada |
| Listar empleados | Nada |
| Listar empleados con filtro | Descripción del filtro |
| Insertar empleado | Todos los atributos del nuevo empleado |
| Eliminar empleado | Todos los atributos del empleado a borrar |
| Asociar deducción | Empleado.Id, TipoDeduccion.Id, valor porcentual, valor monto fijo |
| Desasociar deducción | Empleado.Id, TipoDeduccion.Id |
| Consultar planilla semanal | Empleado.Id, Fecha Inicio, Fecha fin |
| Consultar planilla mensual | Empleado.Id, Fecha Inicio, Fecha fin |
| Editar empleado | Atributos antes y después |
| Impersonar empleado | Empleado.Id que se está impersonando |
| Regresar a interfaz de administrador | Nada |
| Ingreso de marcas de asistencia | Empleado.Id, marca de inicio, marca de fin |
| Ingreso nuevas jornadas | Empleado.Id, TipoJornada.Id |

> **No hay interfaz de usuario** para asignar o desasignar deducciones, excepto la que se asigna por default al insertar un empleado.

---

## Cuatro. Datos de prueba

Carga inicial y simulación (≥ 4 meses) desde archivos XML. **Dos XML**: uno de catálogos, uno de operación (cada nodo raíz = una fecha consecutiva).

### 4.1 Nodos del XML de catálogos

```xml
<Catalogo>
  <TiposDeJornada>
    <TipoDeJornada id="1" Nombre="Diurno" HoraInicio="6:00" HoraFin="14:00"/>
    <TipoDeJornada id="2" Nombre="Vespertino" HoraInicio="14:00" HoraFin="22:00"/>
    <TipoDeJornada id="3" Nombre="Nocturno" HoraInicio="22:00" HoraFin="06:00"/>
  </TiposDeJornada>

  <Puestos>
    <Puesto Nombre="Electricista" SalarioXHora="1200"/>
    <Puesto Nombre="Auxiliar de Laboratorio" SalarioXHora="1250"/>
    <Puesto Nombre="Operador de Maquina" SalarioXHora="1025"/>
  </Puestos>

  <Feriados>
    <Feriado Id="1" Nombre="Dia de Juan Santamaria" Fecha="20220411"/>
    <Feriado Id="2" Nombre="Jueves Santo" Fecha="20220414"/>
    <Feriado Id="3" Nombre="Viernes Santo" Fecha="20220415"/>
    <Feriado Id="4" Nombre="Dia del trabajo" Fecha="20220501"/>
  </Feriados>

  <TiposDeMovimiento>
    <TipoDeMovimiento Id="1" Nombre="Credito Horas ordinarias"/>
    <TipoDeMovimiento Id="2" Nombre="Credito Horas Extra Normales"/>
    <TipoDeMovimiento Id="3" Nombre="Credito Horas Extra Dobles"/>
    <TipoDeMovimiento Id="4" Nombre="Caja"/>
    <TipoDeMovimiento Id="5" Nombre="Deduccion Ahorro Obligatorio"/>
  </TiposDeMovimiento>

  <TiposDeDeduccion>
    <TipoDeDeduccion Id="1" Nombre="Obligatorio de Ley" Obligatorio="Si" Porcentual="Si" Valor="0.095"/>
    <TipoDeDeduccion Id="2" Nombre="Ahorro Asociacion Solidarista" Obligatorio="No" Porcentual="Si" Valor="0.05"/>
    <TipoDeDeduccion Id="3" Nombre="Ahorro Vacacional" Obligatorio="No" Porcentual="No" Valor="0"/>
    <TipoDeDeduccion Id="4" Nombre="Pension Alimenticia" Obligatorio="No" Porcentual="No" Valor="0"/>
  </TiposDeDeduccion>

  <UsuariosAdministrador>
    <!-- Usuario tipo 1 es administrador, tipo 2 es empleado -->
    <Usuario pwd="1234" username="Goku"/>
    <Usuario pwd="1234" username="Willy"/>
  </UsuariosAdministrador>

  <TiposdeEvento>
    <TipoEvento Id="1" Nombre="login"/>
    <TipoEvento Id="2" Nombre="logout"/>
    <TipoEvento Id="3" Nombre="Listar empleados"/>
    <TipoEvento Id="4" Nombre="Listar empleados con filtro"/>
    <TipoEvento Id="5" Nombre="Insertar empleado"/>
  </TiposdeEvento>
</Catalogo>
```

### 4.2 Reglas de mapeo

- **Las llaves de las tablas catálogo se insertan tal cual vienen del XML**, excepto `Puesto` cuyo mapeo se hace **por nombre** (porque su `Id` es IDENTITY y cada proyecto puede tener un Id distinto para "Electricista").
- **Las tablas no-catálogo usan `IDENTITY`** (cada proyecto genera sus propias llaves).

### 4.3 Nodos del XML de operación

```xml
<Operacion>
  <FechaOperacion Fecha="2023-06-10">
    <NuevosEmpleados>
      <NuevoEmpleado Nombre=""
                     IdTipoDocumento="" ValorTipoDocumento=""
                     IdDepartamento="" IdPuesto=""
                     Usuario="" Password=""/>
    </NuevosEmpleados>

    <EliminarEmpleados>
      <EliminarEmpleado ValorTipoDocumento=""/>
    </EliminarEmpleados>

    <AsociacionEmpleadoDeducciones>
      <AsociacionEmpleadoConDeduccion IdTipoDeduccion=""
                                       ValorTipoDocumento="" Monto=""/>
    </AsociacionEmpleadoDeducciones>

    <DesasociacionEmpleadoDeducciones>
      <DesasociacionEmpleadoConDeduccion IdTipoDeduccion=""
                                          ValorTipoDocumento=""/>
    </DesasociacionEmpleadoDeducciones>

    <MarcasAsistencia>
      <MarcaDeAsistencia ValorTipoDocumento="" HoraEntrada="--" HoraSalida="-- :"/>
    </MarcasAsistencia>

    <JornadasProximaSemana>
      <TipoJornadaProximaSemana ValorTipoDocumento="" IdTipoJornada=""/>
    </JornadasProximaSemana>
  </FechaOperacion>
  <FechaOperacion Fecha="2023-06-11">
    ...
  </FechaOperacion>
</Operacion>
```

### 4.4 Reglas del XML de operación

- Los empleados se identifican por `ValorTipoDocumento` (típicamente cédula).
- Al insertar un empleado, este debe asociarse automáticamente con las deducciones obligatorias, **a través de un trigger**.
- "Una deducción de tipo obligatoria (caja) no se asocian" → solo se asignan automáticamente, no desde el XML.
- Las marcas de asistencia pueden iniciar un día y terminar al día siguiente (jornadas nocturnas).

### 4.5 Pasos de la simulación por cada fecha (en orden)

1. **Insertar empleados** que inician en próximo inicio de semana. No pueden iniciar al día siguiente (a menos que sea jueves).
2. **Eliminar empleados** que dejan de trabajar en esa fecha.
3. **Asociar** empleado con deducción, aplicable desde próximo inicio de semana.
4. **Desasociar** empleado con deducción, aplicable desde próximo inicio de semana.
5. **Procesar asistencias** por cada empleado:
   - **Horas ordinarias** = horas trabajadas (enteras) × salario/hora del puesto → un movimiento.
   - **Horas extras normales** = exceso sobre la hora de salida de la jornada (enteras) × salario/hora × 1.5 → un movimiento (si la fecha no es domingo/feriado).
   - **Horas extras dobles** = horas extras cuando la fecha es domingo/feriado × salario/hora × 2.0 → un movimiento.
   - Una asistencia puede generar hasta 3 movimientos (ej: salida 3am del día siguiente siendo feriado).
   - Los movimientos se insertan en la planilla semanal e incrementan `SalarioBruto`.

6. **Si es jueves, cierre de semana** (en orden):
   - El salario bruto ya está calculado.
   - Aplicar **deducciones porcentuales** al salario bruto, agregar movimiento de débito y acumular a `TotalDeducciones`.
   - Aplicar **deducciones fijas no vencidas**, agregar movimiento de débito y acumular a `TotalDeducciones`.
   - Acumular las deducciones en el resumen mensual por empleado y por tipo.
   - `SalarioNeto = SalarioBruto - TotalDeducciones`.
   - (Depósito bancario NO se implementa.)

7. **Si es jueves y mañana es primer viernes del mes, apertura del mes**:
   - Crear encabezado del mes para todos los empleados.
   - Crear encabezado de la siguiente semana para todos los empleados.
   - Procesar nodos `JornadasProximaSemana` → insertar en `HorarioJornada`.

---

## Cinco. Qué se pide

1. La **BD física** para implementar la solución.
2. El código del **trigger** que asocia un nuevo empleado con las deducciones obligatorias.
3. El **script para el llenado de catálogos**.
4. El **script que hace la simulación** y su corrida.
5. El código en **capa lógica** para el sitio web (admin y empleado).
6. El código de los **SP** para las simulaciones y todas las consultas.
7. Un **portal web** donde el empleado hace login.
8. La **documentación**.

---

## Seis. Reglas

Por cada empleado, al final de su procesamiento (día normal o cierre), debe existir **una sola transacción** que haga todo para ese empleado:

- Insertar movimientos por horas.
- Insertar movimientos por deducciones solo en día de cierre.
- Acumular Salario Bruto Semanal y Total Deducciones semanal (`PlanillaSemXEmpleado`).
- Acumular Salario Bruto Mensual y Total Deducciones mensuales (`PlanillaMexXEmpleado`).
- Acumular en `DeduccionesXEmpleadoxMes` por cada tipo de deducción asociado.
- Si es el primer empleado que se procesa:
  - Si es la última semana del mes, aperturar `MesPlanilla` para el siguiente ciclo.
  - Crear instancia del siguiente ciclo semanal `SemanaPlanilla`.
- Crear instancia de `PlanillaSemXEmpleado` del nuevo ciclo semanal, con acumuladores en cero.
- Si se procesa la última semana del mes, crear instancia de `PlanillaMexXEmpleado` y de `DeduccionesXEmpleadoxMes`.

> **Todo el código referido a base de datos debe ser un SP. No puede haber SQL incrustado en capa lógica.**

**Grupos**: 2 personas. **Motor**: MS SQL Server ≥ 2014. **Lenguaje de capa lógica**: libre.
**Entregas**: 13 junio 2026 (primera), 1 julio 2026 (segunda).
