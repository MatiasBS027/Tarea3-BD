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

# Bitácora de Sesión

Fecha: 02/06/2026

Inicio: [14:00] | Fin: [15:30] || Total: [1 hora 30 minutos]

Presente: Matías Benavides Sandoval

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

¿QUÉ HICIMOS HOY?

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Se revisó el modelo del compañero Sebas (ModeloSebas.jpeg + 1/2/3.jpeg) y se comparó contra nuestro modelo conceptual previo de 29 tablas.
Se aclararon con Sebas 7 dudas de su modelo: Empleado.idUsuario 1:1, PlanillaSemanal con 3 columnas de horas (Ordinarias/ExtraNormal/ExtraDoble), Comprobante.Tipo sin definir, Mes.NumJueves 4-5, TipoDeduccion.Valor siempre REAL, DeduccionXMes.MontoTotal precalculado al cierre, y el manejo de Feriado/extras dobles aún no lo había hecho.
Se adoptó el modelo de Sebas (23 tablas) como guía estructural y se le aplicaron 8 correcciones justificadas una a una con cita a Especificacion.pdf, llegando al modelo final de 20 tablas y 22 FKs.
Se reescribió SQL/SCRIPTS/Tablas.sql en formato SSMS con las 20 tablas, sin seed inline, asumiendo que la base PlanillaDB ya existe.
Se reescribió SQL/SCRIPTS/Trigger.sql con el trg_Empleado_Insert_AssignMandatoryDeductions al estilo de Sebas (AFTER INSERT sobre Empleado, cross-join con TipoDeduccion WHERE EsObligatoria=1, copia td.Valor a DeduccionEmpleado.MontoFijo).
Se reescribió AGENTS.md para que refleje el modelo de 20 tablas, con una tabla de las 8 correcciones citadas al PDF, las convenciones de Tarea2-BD, el orden de SPs a implementar, y los riesgos identificados.
Se validó todo el script contra localhost\SQLEXPRESS: 20 tablas, 22 FKs, trigger dispara correctamente con un INSERT de prueba (1 obligatoria → 1 fila DeduccionEmpleado; 2 obligatorias → 2 filas; EsObligatoria=0 ignorada).
Se borraron 6 imágenes que ya no aportan (4 de Sebas, Modelo Conceptual.png, SQL/SCRIPTS/image.png). Quedó únicamente ModeloFisico.jpeg como referencia visual del modelo final.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

PROBLEMAS DETECTADOS Y CÓMO SE RESOLVIERON

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Problema: nuestro modelo conceptual previo de 29 tablas no coincidía con el modelo del compañero ni con varias decisiones de diseño ya consensuadas con él.
Causa: se construyó partiendo de un diagrama propio en lugar del de Sebas.
Solución: se adoptó el modelo de Sebas como guía y se documentó cada desviación con cita explícita a Especificacion.pdf (página y sección) en AGENTS.md §1.3.

Problema: el trigger anterior estaba pensado para una jerarquía de 5 tablas de deducciones (DeduccionXLEy, DeduccionXPorcentaje, DeduccionXMontoFijo, etc.) que el modelo de Sebas no usa.
Causa: el modelo de Sebas unifica todas las deducciones en una sola TipoDeduccion con flags EsObligatoria/EsPorcentual, y en una sola DeduccionEmpleado.
Solución: se reescribió el trigger para que haga cross-join de INSERT con TipoDeduccion WHERE EsObligatoria=1, copiando td.Valor a DeduccionEmpleado.MontoFijo (sea % o monto fijo, el SP decide luego cómo aplicarlo).

Problema: el commit b70e438 (reescribir tablas) quedó con el modelo de Sebas (23 tablas) en vez del modelo corregido (20 tablas) porque se cometió sin git add explícito y el contenido del working dir nunca pasó al index.
Causa: tras un git reset --soft HEAD~1, el working dir tenía la versión corregida pero el index conservaba la versión vieja de Sebas. git commit usó el index, no el working dir.
Solución: se deshicieron los dos commits con git reset --soft b78974a, se stagió explícitamente solo SQL/SCRIPTS/{Tablas.sql,Trigger.sql}, se cometió como aee54bb, y se cometió AGENTS.md por separado como 8e18ec3. Lección: siempre correr git diff --staged antes de git commit cuando viene de un soft reset.

Problema: el primer amend tras detectar el error de b70e438 se aplicó al commit equivocado (al de AGENTS.md en lugar del de SQL), mezclando Tablas.sql dentro del commit de docs.
Causa: se usó HEAD sin verificar a qué commit apuntaba.
Solución: se volvió a hacer git reset --soft b78974a y se recomitió en el orden correcto: primero SQL, luego AGENTS.md.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

DUDAS Y DIVERGENCIAS DE CRITERIO

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Sigue pendiente decidir el comportamiento del SP de procesamiento de asistencia cuando una MarcaAsistencia no tiene un HorarioJornada asignado para esa semana: ¿se trata como fuera de jornada (todo el tiempo es extra), se rechaza, o se registra sin generar MovHoras? Documentado en AGENTS.md §7.
Sigue pendiente definir la estructura final del XML de carga de catálogos y del XML de operación. sp_CargarCatalogosXML sigue como scaffold en SQL/SCRIPTS/CargarDatosXML.sql.
Sigue pendiente el mecanismo de generación del PDF del Comprobante: la columna PlanillaSemanal.Comprobante es VARBINARY(MAX) NULL, pero ningún SP la llena todavía. Decidir si se genera desde SQL Server, desde el backend, o queda como NULL hasta que el usuario suba el PDF.
Sigue abierta la decisión de cómo distinguir en la UI (grid de R04) si una MarcaAsistencia cayó en domingo o feriado, ya que el PDF pide mostrar los movimientos por día pero no cómo se etiquetan los días especiales.
Se confirmó que el modelo de 20 tablas es estable y no debería requerir más cambios estructurales durante el resto del proyecto: cubre R01-R07, las reglas de horas (ordinarias, extras 1.5x, extras dobles 2x en domingo/feriado), la regla "una asistencia hasta 3 movimientos", semana viernes→jueves, deducciones porcentuales/fijas, asignación automática de obligatorias y trazabilidad completa.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

AVANCE DEL CÓDIGO

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Se reescribió SQL/SCRIPTS/Tablas.sql con 20 tablas y 22 FKs en formato SSMS, USE [PlanillaDB] al inicio, sin seed inline y sin DROP/CREATE DATABASE. Tablas: BitacoraEvento, DBError, DeduccionEmpleado, DeduccionXMes, Empleado, Feriado, HorarioJornada, MarcaAsistencia, Mes, MovHoras (nueva), MovPlanilla, PlanillaMensual, PlanillaSemanal, Puesto, Semana, TipoDeduccion, TipoEvento, TipoJornada, TipoMovimiento, Usuario. Se quitaron Departamento, TipoDocIdentidad, Comprobante(tabla) y ComprobanteHora.
Se reescribió SQL/SCRIPTS/Trigger.sql con el trg_Empleado_Insert_AssignMandatoryDeductions en formato SSMS, AFTER INSERT sobre dbo.Empleado, SET XACT_ABORT ON, y el cuerpo que hace cross-join de inserted con TipoDeduccion WHERE EsObligatoria=1, insertando (idEmpleado=i.id, idTipoDeduccion=td.id, MontoFijo=td.Valor, FechaInicio=i.FechaContratacion, FechaFin='99991231').
Se reescribió AGENTS.md con: §1.1 origen del modelo (Sebas como guía + 8 correcciones), §1.2 tabla con las 20 tablas y sus notas, §1.3 tabla con las 8 correcciones citadas al PDF, §2 convenciones de naming/tipos/constraints/plantilla SP, §3 reglas de negocio (semana, horas, deducciones, cierre), §4 arquitectura, §5 orden sugerido de SPs, §6 workflow del agente, §7 riesgos identificados y §8 anexo de archivos.
Se validó contra localhost\SQLEXPRESS: las 20 tablas se crean en orden alfabético, las 22 FKs se aplican correctamente, y el trigger se dispara con un INSERT de prueba. Se borraron los datos de prueba con TRUNCATE y se reseteó IDENTITY.
Se eliminaron 6 imágenes del repositorio: ModeloSebas.jpeg, ModeloSebas1.jpeg, ModeloSebas2.jpeg, ModeloSebas3.jpeg, Modelo Conceptual.png y SQL/SCRIPTS/image.png (esta última era un leftover de 77KB de un commit previo del usuario). Quedó únicamente ModeloFisico.jpeg como evidencia visual del modelo final.
Se dejaron sin pushear 2 commits, por instrucción explícita: aee54bb feat(sql): reescribir tablas y creacion del trigger, y 8e18ec3 docs(agents): actualizar al modelo corregido de 20 tablas.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

MORALEJAS / BUENAS PRÁCTICAS

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Cuando un compañero ya tiene un modelo en curso, adoptarlo como guía y justificar cada desviación contra el spec (con página y sección citadas) es más rápido y más defendible que rehacerlo desde cero.
Tras un git reset --soft, siempre correr git diff --staged antes de git commit: el working dir y el index pueden divergir silenciosamente, y un commit accidental puede terminar registrando contenido viejo.
Diferenciar en commits separados los cambios al esquema SQL, los cambios a la guía operativa (AGENTS.md) y los cambios a archivos de soporte (bitácora, imágenes). Mezclarlos dificulta revertir y revisar.
Para una base de datos, el DROP/CREATE DATABASE debe vivir en un archivo separado (VaciarDB.sql) que corre antes del script de tablas, para no contaminar el script de esquema con dependencias de master.
Mantener la bitácora de sesión al día (en vez de escribirla toda al final) ayuda a no perder el rastro de problemas y decisiones; en esta sesión se retrasó la actualización hasta el final por instrucción del usuario, pero en general conviene hacerlo al cerrar cada bloque de trabajo.
Antes de borrar evidencia del compañero (imágenes, diagramas), confirmar explícitamente que ya no se va a necesitar. En esta sesión los ModeloSebas*.jpeg se mantuvieron hasta que el modelo corregido estuvo validado y commiteado.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

PRÓXIMA SESIÓN: ¿QUÉ SIGUE?

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Definir el XML de carga de catálogos y reemplazar el scaffold de sp_CargarCatalogosXML con la implementación real, idempotente con WHERE NOT EXISTS o MERGE.
Decidir el comportamiento de MarcaAsistencia sin HorarioJornada y documentarlo en AGENTS.md §7 antes de implementar sp_ProcesarAsistencia.
Implementar los SPs en el orden de AGENTS.md §5, empezando por sp_Login/sp_Logout y sp_GetError (este último con dependencia de DBError y Error, revisar si la tabla Error sigue siendo necesaria en el modelo final).
Definir el mecanismo de generación del PDF del Comprobante y el SP que lo asigna a PlanillaSemanal.Comprobante (VARBINARY MAX NULL).
(Pendiente desde la sesión anterior) Clonar los SPs base desde Tarea2-BD y adaptarlos a PlanillaDB: sp_GetError, sp_Login, sp_Logout, sp_InsertarEmpleado, sp_GetEmpleados, sp_GetEmpleadoById, sp_UpdateEmpleado, sp_DeleteEmpleado.

# Bitácora de Sesión

Fecha: 02/06/2026

Inicio: [15:30] | Fin: [17:00] || Total: [1 hora 30 minutos]

Presente: Matías Benavides Sandoval

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

¿QUÉ HICIMOS HOY?

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Se discutió la estructura del XML de catálogos para Tarea3-BD, basándose en el XML de Tarea2-BD como referencia.
Se analizó la cita del profe sobre las PK de tablas catálogo: "Las llaves de las tablas catálogo se insertan tal cual vienen en el archivo XML, excepto para Puestos cuyo mapeo será a través del nombre". Esto significa que las 6 tablas catálogo (TipoJornada, TipoEvento, TipoMovimiento, TipoDeduccion, Feriado, Usuario) NO deben tener IDENTITY; solo Puesto sí.
Se quitó IDENTITY(1,1) de las 6 tablas catálogo en Tablas.sql y se agregó la tabla Error (Codigo INT PK, Descripcion NVARCHAR(256)) para los códigos 50001-50011. Validado: 21 tablas, 22 FKs, trigger OK.
Se reescribió data/Datos.xml completo con la estructura acordada: 8 secciones (Puestos sin Id, TiposJornada/Feriados/TiposEvento/TiposMovimiento/TiposDeduccion/Usuarios/Error con Id), 0/1 para booleanos, atributos renombrados (EsObligatoria/EsPorcentual), fechas ISO, horas HH:MM:SS, straight double quotes.
Se discutió y definió la división de trabajo entre Matías (Persona A) y el compañero (Persona B) para la implementación de SPs, frontend y backend. Se creó DIVISION_TRABAJO.md con 15 SPs divididos (8 para A, 7 para B), fases y validaciones.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

PROBLEMAS DETECTADOS Y CÓMO SE RESOLVIERON

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Problema: el XML original de Datos.xml tenía comillas raras (curly quotes " "), tags mal formados (</ Feriados >, <\Catalogo>), atributos con Si/No en vez de 0/1, y nombres inconsistentes (Obligatorio vs EsObligatoria).
Causa: el archivo era un borrador parcial de Tarea2-BD sin pulir.
Solución: se reescribió completo desde cero con las convenciones acordadas: straight quotes, 0/1 para BIT, EsObligatoria/EsPorcentual, HH:MM:SS para horas, YYYY-MM-DD para fechas.

Problema: el profe lista Departamento y TipoDocumentoIdentidad como secciones del XML de catálogos, pero nuestro modelo los excluyó (corrección #1 del AGENTS.md).
Causa: el profe los menciona en la descripción general del XML pero no aportan a la lógica de planilla.
Solución: se decidió ignorarlos en el SP de carga (opción b), ya que el modelo de 20 tablas no los requiere y incluirlos crearía tablas huérfanas sin uso.

Problema: la propuesta inicial de división de trabajo incluía tablas y SPs del modelo viejo (29 tablas) que ya no existen (UsuarioAdministrador, DeduccionLey, DeduccionPorcentual, etc.).
Causa: el proposal se basó en el modelo conceptual original, no en el modelo corregido de 20 tablas.
Solución: se reescribió la división con los nombres correctos del modelo actual y se eliminaron los SPs de CRUD que el profe confirmó que no se requieren.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

DUDAS Y DIVERGENCIAS DE CRITERIO

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Sigue pendiente decidir el comportamiento del SP de procesamiento de asistencia cuando una MarcaAsistencia no tiene un HorarioJornada asignado para esa semana.
Sigue pendiente el mecanismo de generación del PDF del Comprobante (PlanillaSemanal.Comprobante VARBINARY MAX NULL).
Sigue abierta la decisión de cómo distinguir en la UI (grid de R04) si una MarcaAsistencia cayó en domingo o feriado.
Se confirmó que el modelo de 21 tablas (20 + Error) es estable y no debería requerir más cambios estructurales.
Se confirmó que no hay CRUD de empleados en la interfaz de usuario — solo el insert de empleado (que dispara el trigger) se hace por script o SP dedicado.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

AVANCE DEL CÓDIGO

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Se modificó SQL/SCRIPTS/Tablas.sql: quitado IDENTITY(1,1) de TipoJornada, TipoEvento, TipoMovimiento, TipoDeduccion, Feriado y Usuario. Agregada tabla Error (Codigo INT PK NOT NULL, Descripcion NVARCHAR(256) NOT NULL) entre Empleado y Feriado. Validado con VaciarDB.sql + Tablas.sql + Trigger.sql contra localhost\SQLEXPRESS: 21 tablas, 22 FKs, trigger dispara correctamente.
Se reescribió data/Datos.xml completo: 8 secciones (Puestos(10), TiposJornada(3), Feriados(9), TiposEvento(14), TiposMovimiento(8), TiposDeduccion(4), Usuarios(3), Error(11)), 62 entradas totales. XML validado como bien formado con PowerShell [xml].
Se creó DIVISION_TRABAJO.md con la división simplificada de trabajo entre Matías (Persona A, 8 SPs) y el compañero (Persona B, 7 SPs), incluyendo frontend, backend, validaciones y fases.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

MORALEJAS / BUENAS PRÁCTICAS

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Cuando el profe da una regla específica sobre el modelo (como "las PK de catálogo se insertan tal cual del XML"), aplicarla inmediatamente al esquema SQL en vez de postergarla — evita retrasos y inconsistencias.
Antes de reescribir un archivo XML/SQL, leer la spec completa primero para no tener que volver a reescribir. En esta sesión se reescribió Datos.xml dos veces (primera vez incompleta, segunda vez completa).
La división de trabajo debe basarse en el modelo actual, no en el conceptual original. Los nombres de tablas y SPs cambian entre versiones del modelo.
Confirmar con el profe qué secciones del XML son obligatorias vs opcionales antes de diseñar la estructura. Evita incluir tablas que el modelo no requiere.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

PRÓXIMA SESIÓN: ¿QUÉ SIGUE?

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Empezar la Fase 1 de la división de trabajo: sp_Login, sp_Logout, sp_GetError (Matías) y sp_CrearCalendario, sp_ProcesarAsistencia (compañero).
Implementar sp_CargarCatalogosXML con la estructura real del XML de datos.
Decidir el comportamiento de MarcaAsistencia sin HorarioJornada y documentarlo en AGENTS.md §7.
Definir el mecanismo de generación del PDF del Comprobante.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Bitácora de Sesión

Fecha: 02/06/2026

Inicio: [14:00] | Fin: [17:30] || Total: [3 horas 30 minutos]

Presente: Matías Benavides Sandoval

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

¿QUÉ HICIMOS HOY?

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Se reescribieron 5 SPs de Tarea2-BD que no coincidían con el modelo actual de PlanillaDB: sp_Login, sp_Logout, sp_GetError, sp_GetEmpleados y sp_GetEmpleadoById.
Se alinearon todos con las convenciones del proyecto: USE [PlanillaDB], IF OBJECT_ID DROP, SET XACT_ABORT ON, nombres de columnas correctos (Activo, ValorDocumento, PasswordHash), DBError con dbo., y TRY/CATCH.
Se validaron 6 escenarios contra localhost\SQLEXPRESS: sp_GetError (valid/invalid), sp_Login (success/wrong password), sp_GetEmpleados (all/filtered) y sp_GetEmpleadoById (found/not found).

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

PROBLEMAS DETECTADOS Y CÓMO SE RESOLVIERON

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Problema: los 5 SPs usaban USE VacacionesDB, DROP PROCEDURE IF EXISTS, y columnas del modelo viejo (EsActivo, ValorDocumentoIdentidad, PasswordHash como VARBINARY).
Causa: eran copias literales de Tarea2-BD nunca adaptadas a PlanillaDB.
Solución: se reescribieron todos con USE [PlanillaDB], IF OBJECT_ID DROP, y los nombres de columna reales del esquema actual.

Problema: sp_Login y sp_Logout usaban INSERT INTO BitacoraEvento VALUES(...) directo, sin patrón de table variable + INSERT...SELECT.
Causa: no seguían la convención de Tarea2-BD de preparar datos en una tabla variable y hacer el INSERT en una sola operación.
Solución: se reescribieron con DECLARE @bitacoraData TABLE, INSERT INTO @bitacoraData, y luego BEGIN TRANSACTION → INSERT INTO BitacoraEvento SELECT FROM @bitacoraData → COMMIT.

Problema: sp_Login fallaba con Msg 3930 ("The current transaction cannot be committed") en el path de "usuario no encontrado" cuando se combinaba SET XACT_ABORT ON con BEGIN TRANSACTION/COMMIT explícito.
Causa: SET XACT_ABORT ON interactúa de forma incompatible con transacciones explícitas en ciertos flujos del SP.
Solución: se documentó el bug en AGENTS.md §7 y se dejó pendiente para resolver en la próxima sesión — el SP funciona correctamente en los paths de login exitoso y password incorrecto.

Problema: sp_GetEmpleados y sp_GetEmpleadoById tenían columnas incorrectas y dynamic SQL innecesario.
Causa: sp_GetEmpleados filtraba por EsActivo y ValorDocumentoIdentidad; sp_GetEmpleadoById usaba dynamic SQL para resolver FechaContratacion.
Solución: se corrigieron los nombres de columna y se eliminó el dynamic SQL (FechaContratacion ya existe en el esquema). Se agregó NOT EXISTS en sp_GetEmpleadoById para retornar 50012 si no se encuentra.

Problema: sp_GetError no tenía SET XACT_ABORT ON y usaba DROP sin IF OBJECT_ID.
Causa: era un scaffold mínimo sin seguir la plantilla de SPs.
Solución: se agregaron SET XACT_ABORT ON, IF OBJECT_ID DROP, y se mantuvo como SP de solo lectura (sin transacciones).

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

DUDAS Y DIVERGENCIAS DE CRITERIO

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Se confirmó que los SPs de solo lectura (sp_GetError, sp_GetEmpleados, sp_GetEmpleadoById) no necesitan INSERT en BitacoraEvento — la trazabilidad de consultas se puede hacer desde la capa de aplicación.
El código de error 50012 para "empleado no encontrado" se definió como convención propia del SP, no está en la tabla Error del XML.
El bug de Msg 3930 en sp_Login se documentó pero no se resolvió — afecta solo al path de "usuario no encontrado" con lockout, no al login exitoso ni al password incorrecto.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

AVANCE DEL CÓDIGO

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Se reescribió SQL/SPs/sp_Login.sql: autenticación con lockout (5 intentos → 20 min), table variable para BitacoraEvento, INSERT...SELECT, transacción explícita. Funciona en success/wrong password; falla con Msg 3930 en user-not-found.
Se reescribió SQL/SPs/sp_Logout.sql: registro de cierre de sesión en BitacoraEvento con table variable, INSERT...SELECT, transacción explícita.
Se reescribió SQL/SPs/sp_GetError.sql: helper de solo lectura que retorna Codigo/Descripcion de la tabla Error, con NOT EXISTS para código no encontrado.
Se reescribió SQL/SPs/sp_GetEmpleados.sql: listado de empleados activos con JOIN a Puesto, filtro opcional por nombre con LIKE, orden alfabético.
Se reescribió SQL/SPs/sp_GetEmpleadoById.sql: búsqueda por ValorDocumento con JOIN a Puesto, campos completos, NOT EXISTS → 50012 si no se encuentra.
Se crearon 5 commits individuales (uno por SP) y se pushearon a origin/main.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

MORALEJAS / BUENAS PRÁCTICAS

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Los SPs de solo lectura no necesitan transacciones explícitas ni logging a BitacoraEvento — simplifica el código y evita bugs como el Msg 3930 de sp_Login.
Cuando un SP viejo usa dynamic SQL para resolver un nombre de columna, verificar primero si la columna ya existe en el esquema actual — casi siempre se puede eliminar el dynamic SQL.
Antes de reescribir un SP, comparar los nombres de columna del viejo contra Tablas.sql para detectar todas las diferencias de una vez.
El patrón table variable + INSERT...SELECT + transacción explícita funciona bien para SPs que escriben en BitacoraEvento, pero hay que tener cuidado con SET XACT_ABORT ON en paths donde no se hace INSERT (como el return temprano de sp_Login).

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

PRÓXIMA SESIÓN: ¿QUÉ SIGUE?

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Corregir el bug de Msg 3930 en sp_Login (path de usuario no encontrado con lockout).
Continuar con la Fase 1: sp_InsertarEmpleado, sp_UpdateEmpleado, sp_DeleteEmpleado (Matías).
Implementar sp_CrearCalendario y sp_ProcesarAsistencia (compañero).
Definir el mecanismo de generación del PDF del Comprobante.
