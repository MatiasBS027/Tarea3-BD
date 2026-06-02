 # Bitácora de Sesión

Fecha: 01/06/2026

Inicio: [19:00] | Fin: [22:00] || Total: [3 horas]

Presente: Matías Benavides Sandoval

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

¿QUÉ HICIMOS HOY?

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Se realizó una revisión profunda del modelo físico de la base de datos y se documentaron las inconsistencias más importantes.
Se corrigieron problemas estructurales del esquema SQL base para acercarlo a la especificación del proyecto.
Se alineó el backend con el esquema corregido, especialmente la conexión a la base de datos y los nombres de columnas usados por los controladores.
Se recreó la base de datos desde cero a partir del script actualizado y se validó que el despliegue quedara consistente.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

PROBLEMAS DETECTADOS Y CÓMO SE RESOLVIERON

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Problema: llaves primarias sin IDENTITY en tablas operativas.
Causa: varias tablas que representan entidades transaccionales dependían de capturas manuales de ID.
Solución: se ajustó el script Tablas.sql para que las tablas no catálogicas usen IDENTITY donde corresponde.
Problema: tipos de datos incorrectos para horarios.
Causa: TipoJornada.HoraInicio y HoraFin no estaban modeladas como hora pura.
Solución: se cambiaron a tipo time para evitar ambigüedades de fecha.
Problema: nombres de columnas y referencias inconsistentes.
Causa: el backend esperaba nombres distintos a los declarados en el esquema, especialmente en Usuario y en tablas de bitácora.
Solución: se ajustaron las referencias del backend para coincidir con el modelo real y se corrigieron nombres mal definidos en SQL.
Problema: dependencia circular entre tablas relacionadas con deducciones y planillas.
Causa: la relación entre DeduccionMensual y PlanillaMensual estaba planteada de forma que complicaba la creación limpia del esquema.
Solución: se reordenó la referencia para romper la circularidad y permitir recrear la base desde cero sin conflicto.
Problema: falla inicial al compilar el proyecto TypeScript.
Causa: el entorno local tenía dependencias enlazadas de forma incompleta.
Solución: se reinstalaron dependencias con el gestor apropiado y luego la compilación terminó correctamente.
Problema: ejecución de sqlcmd con error de certificado.
Causa: el servidor local requería confiar explícitamente en el certificado para la conexión de prueba.
Solución: se ejecutaron los comandos con la opción adecuada para confiar en el certificado y continuar con la recreación de la base.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

DUDAS Y DIVERGENCIAS DE CRITERIO

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Quedó pendiente decidir si la bitácora de eventos debe guardar trazabilidad completa en texto plano o en un formato más estructurado.
Se identificó la necesidad de definir qué campos adicionales debe registrar BitacoraEvento para cubrir mejor auditoría de operaciones críticas.
Sigue abierta la discusión sobre qué índices y restricciones únicas conviene agregar antes de implementar los procedimientos almacenados principales.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

AVANCE DEL CÓDIGO

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Se actualizó SQL/SCRIPTS/Tablas.sql con correcciones al modelo físico.
Se ajustó src/db/connection.ts para apuntar a la base correcta.
Se alinearon controladores del backend con los nombres reales del esquema.
Se creó y dejó registrado el archivo AGENTS.md como guía operativa del proyecto.
Se generó el documento de auditoría del modelo para dejar constancia de los hallazgos y prioridades.
Se validó que la base PlanillaDB pudiera recrearse desde cero a partir del script corregido.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

MORALEJAS / BUENAS PRÁCTICAS

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Revisar siempre el modelo físico contra la especificación antes de crear o volver a crear la base.
Alinear nombres de columnas, tablas y parámetros entre SQL y backend desde el inicio evita errores costosos.
Validar el script completo de creación después de cada cambio grande, no solo fragmentos aislados.
Mantener una guía operativa clara ayuda a que el trabajo sea repetible y más fácil de continuar.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

PRÓXIMA SESIÓN: ¿QUÉ SIGUE?

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Implementar los procedimientos almacenados base que consumirá el backend.
Definir la estructura final de la tabla de bitácora para auditoría.
Agregar índices y restricciones faltantes antes de entrar a pruebas funcionales.
Empezar la conexión real entre el listado de empleados y el endpoint del backend.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Bitácora de Sesión

Fecha: 01/06/2026

Inicio: [22:00] | Fin: [01:00] || Total: [3 horas]

Presente: Matías Benavides Sandoval

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

¿QUÉ HICIMOS HOY?

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Se reescribió desde cero el archivo SQL/SCRIPTS/Tablas.sql alineándolo con el modelo conceptual corregido y con las convenciones del proyecto de referencia Tarea2-BD.
Se validó el script recreando la base PlanillaDB desde cero contra el servidor local SQL Server Express y se probó el trigger de deducciones obligatorias con un INSERT de prueba.
Se reemplazó el archivo SQL/SCRIPTS/CargarDatosXML.sql por un scaffold explícito que deja lista la firma del SP de carga hasta que se defina el XML final de catálogos.
Se reescribió el archivo AGENTS.md para que refleje el modelo de 29 tablas, las convenciones de Tarea2-BD y el orden sugerido de implementación de los SPs.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

PROBLEMAS DETECTADOS Y CÓMO SE RESOLVIERON

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Problema: orden de creación de tablas con dependencias cruzadas al ejecutar Tablas.sql.
Causa: las FK FK_UsuarioEmpleado_Empleado y FK_PlanillaSemanal_PlanillaMensual se creaban antes de que existieran las tablas referenciadas.
Solución: se reordenó el script para que Empleado se cree antes que UsuarioEmpleado y PlanillaMensual antes que PlanillaSemanal, respetando el orden topológico.
Problema: tablas Departamento y TipoDocumentoIdentidad presentes en el esquema original.
Causa: el XML de operación del PDF las incluye, pero el modelo conceptual corregido por el profesor las omite por no aportar a la lógica de planilla.
Solución: se eliminaron del esquema físico y se documentó la decisión en AGENTS.md §7 para que no se reintroduzcan.
Problema: divergencia de convenciones entre el modelo conceptual, Tarea2-BD y el backend ya escrito.
Causa: el modelo usa nombres como Feriados, documentoIdentidad e ids en mayúscula, mientras que Tarea2-BD y los controladores esperan Feriado, ValorDocumentoIdentidad e ids en minúscula.
Solución: se adoptó Tarea2-BD como convención estructural (ids en minúscula, tablas DBError y Error) y se conservaron los nombres del modelo cuando eran explícitos; las desviaciones se anotaron en AGENTS.md §7.
Problema: el script de carga de XML original dependía de las tablas Departamento y TipoDocumentoIdentidad que se acaban de eliminar.
Causa: era un primer pass que se construyó cuando aún no se había recibido la corrección del modelo conceptual.
Solución: se reemplazó el archivo por un scaffold que emite un RAISERROR explícito y deja la firma del SP lista para cuando se defina el XML final.
Problema: la primera ejecución del script falló por orden de dependencias y dejó la base en estado intermedio.
Causa: la ejecución no tenía la opción de continuar hasta el final cuando fallaba una tabla intermedia.
Solución: se ejecutó con sqlcmd en modo por lotes hasta dejar el script 100% verde y se verificó el conteo de tablas (29) y de FKs (29) contra los INFORMATION_SCHEMA.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

DUDAS Y DIVERGENCIAS DE CRITERIO

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Quedó pendiente la decisión final sobre si las extensiones EXTDPorcentual y EXTDMontoFijo deben materializarse siempre al asignar una deducción a un empleado, o solo cuando el valor difiera del catálogo.
Sigue abierta la pregunta de si el porcentaje y el monto de las deducciones opcionales deben vivir en una sola columna (convención actual del modelo) o si conviene separarlos desde el inicio.
No se ha definido todavía la forma del XML de carga de catálogos ni del XML de operación, por lo que el SP sp_CargarCatalogosXML queda como scaffold y la simulación mensual del SPEC queda pendiente.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

AVANCE DEL CÓDIGO

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Se reescribió SQL/SCRIPTS/Tablas.sql con 29 tablas en el orden correcto: 12 catálogos, 10 de dominio, 4 de deducciones y planillas, y 3 de trazabilidad.
Se definió el trigger trg_Empleado_Insert_AssignMandatoryDeductions y se validó su comportamiento insertando un empleado de prueba: la deducción obligatoria se asignó correctamente con el Porcentaje copiado de DeduccionXLEy.
Se reemplazó SQL/SCRIPTS/CargarDatosXML.sql por un scaffold del SP sp_CargarCatalogosXML con la firma @XmlCatalogos / @outResultCode y cuerpo de placeholder que falla explícitamente.
Se reescribió AGENTS.md para reflejar el modelo final, las convenciones estructurales de Tarea2-BD, el orden sugerido de SPs a implementar y los riesgos identificados.
Se dejaron sembrados inline en Tablas.sql los 11 códigos de error 50001-50011 que el backend ya espera resolver mediante sp_GetError, y los 14 TipoEvento base que la bitácora referencia por nombre.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

MORALEJAS / BUENAS PRÁCTICAS

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Validar el script completo de creación de la base después de cada cambio estructural, no solo fragmentos aislados.
Probar los triggers con INSERTs reales contra la base recién creada, no quedarse solo en el análisis estático del SQL.
Cuando hay varias fuentes de verdad, conviene documentar las divergencias (modelo conceptual vs Tarea2-BD vs backend) en AGENTS.md en lugar de elegir a ciegas.
Para dejar un scaffold seguro, mejor un RAISERROR explícito que un cuerpo vacío que devuelva código 0 y haga creer que la carga funcionó.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

PRÓXIMA SESIÓN: ¿QUÉ SIGUE?

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Clonar los SPs base desde Tarea2-BD y adaptarlos a PlanillaDB: sp_GetError, sp_Login, sp_Logout.
Implementar los SPs de empleados que ya consumen los controladores: sp_InsertarEmpleado, sp_GetEmpleados, sp_GetEmpleadoById, sp_UpdateEmpleado, sp_DeleteEmpleado.
Empezar la lógica de planilla: sp_CrearCalendario, sp_ProcesarAsistencia, sp_ProcesarPlanillaSemanal.
Definir el XML final de carga de catálogos para reemplazar el scaffold de sp_CargarCatalogosXML.
