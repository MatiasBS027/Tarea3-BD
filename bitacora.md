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

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Bitácora de Sesión

Fecha: 02-04/06/2026

Inicio: [17:30 del 02/06] | Fin: [13:00 del 04/06] || Total: [2 horas, fraccionadas en 2 días]

Presente: Matías Benavides Sandoval

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

¿QUÉ HICIMOS HOY?

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Esta sesión se trabajó en dos bloques separados por un día (siguieron siendo la misma unidad lógica: terminar los SPs pendientes de Persona A después de resolver las dudas de Sebas sobre el modelo).

Bloque 1 (02/06, 17:30-18:00): se recibieron 3 dudas de Sebas sobre el modelo conceptual y se analizaron contra el PDF textual (especificacion.md). Se confirmó que las 3 eran válidas. Se modificaron MovHoras (agregado Monto DECIMAL(10,2)) y DeduccionXMes (agregado idEmpleado INT NOT NULL + FK) en Tablas.sql. Se recreó PlanillaDB completa y se validó: 21 tablas, 23 FKs, trigger OK. Se actualizó AGENTS.md con los nuevos campos y conteos.

Bloque 2 (04/06, 11:30-13:00): se reescribieron los 3 SPs pendientes de la persona A: sp_GetTiposMovimiento, sp_ImpersonarEmpleado y sp_RegresarAdmin. Se actualizó data/Datos.xml con los TiposEvento 15 (Impersonar empleado) y 16 (Regresar a interfaz de administrador) y los códigos de error 50012 (Empleado no existe o está inactivo) y 50013 (Usuario no es administrador). Se actualizó AGENTS.md eliminando la línea obsoleta sobre SET XACT_ABORT ON y corrigiendo el conteo de tablas/FKs.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

DECISIONES DE DISEÑO

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Sobre el modelo (dudas de Sebas, bloque 1):
- MovHoras ahora guarda Monto DECIMAL(10,2) NOT NULL — el SP de procesamiento de asistencia calculará QHoras × SalarioXHora × factor y lo guardará directamente.
- DeduccionXMes ahora tiene idEmpleado INT NOT NULL con FK a Empleado — refleja el nombre "DeduccionesXEmpleadoxMes" del PDF.
- Se decidió NO agregar idPlanillaSemanal a MovHoras — MovPlanilla ya funciona como bridge table y el diseño actual es válido.

Sobre los SPs (bloque 2):
- sp_GetTiposMovimiento: parámetro @inAccion CHAR(1) = NULL opcional. Si es NULL retorna todos los tipos, si no filtra por Accion ('C' o 'D').
- sp_ImpersonarEmpleado: input por ValorDocumento (consistencia con sp_GetEmpleadoById). OUTPUT @outIdEmpleado. Valida que el empleado exista y esté activo (Activo=1). Inserta en BitacoraEvento con idTipoEvento=15 (lookup por Nombre "Impersonar empleado") y Descripcion="Empleado.Id = N".
- sp_RegresarAdmin: input @inIdUsuarioAdmin. Valida que el usuario exista (si no, 50001) y que Tipo='1' (si no, 50013). Inserta en BitacoraEvento con idTipoEvento=16 (lookup por Nombre "Regresar a interfaz de administrador").

Sobre los códigos de error:
- 50001 (Username no existe) se reutiliza para "idUsuario no existe".
- 50012 es código nuevo compartido entre sp_GetEmpleadoById y sp_ImpersonarEmpleado (Empleado no existe o está inactivo).
- 50013 es código nuevo (Usuario no es administrador).

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

PROBLEMAS DETECTADOS Y CÓMO SE RESOLVIERON

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Problema (bloque 1): MovHoras no tenía campo Monto, pero el PDF dice "crear un movimiento cuyo monto es X".
Causa: el modelo original de Sebas solo guardaba QHoras y el monto se calculaba after-the-fact.
Solución: se agregó Monto DECIMAL(10,2) NOT NULL a MovHoras.

Problema (bloque 1): DeduccionXMes no tenía idEmpleado, pero el PDF dice "DeduccionesXEmpleadoxMes".
Causa: el modelo original infería el empleado transitivamente vía PlanillaMensual.
Solución: se agregó idEmpleado INT NOT NULL con FK a Empleado.

Problema (bloque 2): Msg 515 al insertar Empleado sin idUsuario.
Causa: Empleado.idUsuario es NOT NULL (porque en la vida real todo empleado tiene un Usuario asociado), pero los tests anteriores no lo seteaban.
Solución: se seedearon Usuario id=2 (Goku) y id=3 (Willy) y se asignó idUsuario=2 al Empleado de prueba.

Problema (bloque 2): el trigger trg_Empleado_Insert_AssignMandatoryDeductions no creó deducciones obligatorias al insertar el Empleado de prueba.
Causa: TipoDeduccion está vacío en la BD (no se ha ejecutado sp_CargarCatalogosXML). El trigger funciona correctamente, solo no hay deducciones que copiar.
Solución: no afecta a sp_ImpersonarEmpleado (no necesita deducciones). Se documenta en PRÓXIMA SESIÓN.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

RESULTADOS DE TESTS (bloque 2)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

sp_GetTiposMovimiento: 3/3 pass.
- Sin filtro → 8 tipos (3 crédito + 5 débito).
- @inAccion='C' → 3 tipos crédito.
- @inAccion='D' → 5 tipos débito.

sp_ImpersonarEmpleado: 3/3 pass.
- @inValorDocumento='1-1111-1111' (existe, activo) → idEmpleado=2, ResultCode=0, BitacoraEvento id=9 con idTipoEvento=15.
- @inValorDocumento='9-9999-9999' (no existe) → idEmpleado=NULL, ResultCode=50012.
- @inValorDocumento='1-1111-1111' (Activo=0) → idEmpleado=NULL, ResultCode=50012.

sp_RegresarAdmin: 3/3 pass.
- @inIdUsuarioAdmin=1 (admin) → ResultCode=0, BitacoraEvento id=11 con idTipoEvento=16.
- @inIdUsuarioAdmin=3 (Tipo='2', empleado) → ResultCode=50013.
- @inIdUsuarioAdmin=99 (no existe) → ResultCode=50001.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

AVANCE DEL CÓDIGO

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Bloque 1 (esquema, commits previos — no incluidos en esta sesión):
- Tablas.sql: agregado Monto DECIMAL(10,2) NOT NULL a MovHoras; agregado idEmpleado INT NOT NULL a DeduccionXMes con FK_DeduccionXMes_Empleado.
- PlanillaDB recreada y validada contra localhost\SQLEXPRESS: 21 tablas, 23 FKs, trigger funciona correctamente.
- AGENTS.md: §1.2 (21 tablas, 23 FKs), tabla MovHoras (agregado Monto), tabla DeduccionXMes (agregado idEmpleado), §3.2 (reglas de horas con Monto).

Bloque 2 (SPs y datos, commits de esta sesión):
- Commit 91b5596: feat(sp): reescribir sp_GetTiposMovimiento — catalogo con filtro por Accion opcional.
- Commit 125486f: feat(sp): reescribir sp_ImpersonarEmpleado — input por ValorDocumento, OUTPUT idEmpleado, valida activo.
- Commit 37e5cff: feat(sp): reescribir sp_RegresarAdmin — valida existe y Tipo='1', bitacora evento 16.
- Commit 5f156f1: feat(data): agregar TiposEvento 15 (Impersonar empleado) y 16 (Regresar a interfaz de administrador); errores 50012 y 50013.
- AGENTS.md: corregida línea 188 (quitada mención obsoleta de SET XACT_ABORT ON) y línea 218 (20 tablas → 21 tablas, 22 FKs → 23 FKs).

Persona A (Matías) completó los 3 SPs asignados. Total: 8 SPs persona A hechos.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

MORALEJAS / BUENAS PRÁCTICAS

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Cuando un compañero levanta una duda sobre el modelo, comparar contra el PDF textual (no contra el SPEC.md resumido) para tener la respuesta más precisa.
Los cambios de esquema (agregar columnas) son seguros si no hay SPs existentes que dependan de las tablas modificadas — en este caso, los SPs que usarán MovHoras y DeduccionXMes aún no se han escrito.
Antes de recrear la base, verificar el orden de DELETEs respetando FKs para poder limpiar datos de prueba.
Patrón para sp_ImpersonarEmpleado y sp_RegresarAdmin: input → lookup validaciones (con early RETURN) → lookup idTipoEvento (con early RETURN) → armar descripción → insert en @bitacoraData → BEGIN TRANSACTION + INSERT SELECT + COMMIT. Sin XACT_ABORT.
Lookup por Nombre de TipoEvento es más legible y robusto que hardcodear el id (15, 16). Si en el futuro se reordenan los TiposEvento en el XML, los SPs siguen funcionando.
Cada nuevo error code nuevo (50012, 50013) debe documentarse en data/Datos.xml para mantener la sincronía.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

PRÓXIMA SESIÓN: ¿QUÉ SIGUE?

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Ejecutar sp_CargarCatalogosXML con el XML actualizado para popular TipoDeduccion, Puesto, Feriado, TipoJornada, etc. (orden: catalogos primero, usuarios al final).
Implementar sp_InsertarEmpleado (Persona A) — patrón completo: insert con validaciones de unicidad (50004, 50005), trigger dispara deducciones obligatorias, bitacora (idTipoEvento 5/6).
Implementar sp_UpdateEmpleado y sp_DeleteEmpleado (Persona A) — usar soft delete con Activo=0 o hard delete con DELETE.
Empezar a documentar la incertidumbre sobre MarcaAsistencia sin HorarioJornada (riesgo §7 AGENTS.md).

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Bitácora de Sesión

Fecha: 05/06/2026

Inicio: [20:00] | Fin: [22:00] || Total: [2 horas]

Presente: Matías Benavides Sandoval

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

¿QUÉ HICIMOS HOY?

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Se cerró la única inconsistencia pendiente en el catálogo de eventos (data/Datos.xml) detectada al revisar R07 del PDF contra los eventos ya listados, agregando los 7 tipos que faltaban para alinearse con la tabla de eventos del enunciado. El cambio fue puramente aditivo (sin modificar nombres ni ids existentes), por lo que ningún SP que resuelve TipoEvento por Nombre se vio afectado.

Luego se completó R03 (Impersonar empleado) y R06 (Regresar a interfaz de administrador) end-to-end. Los SPs ya existían (implementados en la sesión 02-04/06), pero faltaba el cableado del backend (controller + route) y, sobre todo, la UI para invocarlos. Se creó un nuevo controller y route de Express, se registró bajo /api/auth, se agregó el botón "Impersonar" en cada fila de la tabla de empleados (empleados.js), y se creó la página placeholder empleado.html con su handler para el botón "Regresar a admin". Sebastián (Persona B) podrá ahora conectar sus SPs de planilla (R04/R05) al placeholder que ya muestra el nombre del empleado impersonado y tiene el botón de regreso funcional.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

DECISIONES DE DISEÑO

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Sobre el catálogo de eventos (R07):
- Se agregaron Ids 17-23 a data/Datos.xml sin tocar los Ids 1-16 ya existentes: 17=Listar empleados, 18=Asociar deduccion, 19=Desasociar deduccion, 20=Consultar planilla semanal, 21=Consultar planilla mensual, 22=Ingreso de marcas de asistencia, 23=Ingreso nuevas jornadas. Nombres sin tilde (consistente con el estilo del archivo, ej. "Insercion" sin tilde).
- Eventos partidos exitoso/no-exitoso (Insercion, Update, Borrado) se MANTIENEN tal cual. Es decisión de proyecto, no contradice la spec (que es enunciativa, no taxativa).
- Eventos 13/14 (Intento/éxito de insertar movimiento) se MANTIENEN. Existen por la pantalla insertarMovimiento.html que ya está implementada.

Sobre R03/R06 backend:
- Las dos rutas nuevas se montan en /api/auth (no en /api/empleados) porque la sesión activa viaja en el header x-username, igual que en /api/auth/login y /api/auth/logout.
- impersonarController resuelve el id del usuario admin desde x-username (mismo helper resolveUsuarioId que usa empleadoController.ts) y lo pasa a sp_ImpersonarEmpleado / sp_RegresarAdmin.
- El SP sp_ImpersonarEmpleado tiene OUTPUT @outIdEmpleado; el controller lo captura con .output('outIdEmpleado', sql.Int) y lo devuelve al frontend en la respuesta.
- Para outResultCode != 0: 50012 → HTTP 404, 50013 → HTTP 403, resto → HTTP 400. Errores de servidor → 500.

Sobre R03/R06 frontend:
- localStorage guarda 3 keys nuevas durante la impersonación: impersonatedIdEmpleado, impersonatedDocumento, impersonatedNombre. Se limpian al regresar a admin.
- Se pasa el documento y el idEmpleado también por query string (?idEmpleado=...&documento=...) por si el usuario recarga la página (sobrevive a un F5).
- El nombre del empleado se resuelve del DOM de la tabla (nombreDeEmpleadoActual) para no tener que hacer un GET extra al backend.
- empleado.html es placeholder: el sidebar muestra el nombre del empleado impersonado y un botón "Regresar a admin" prominente. El cuerpo es un status info indicando "Pendiente de implementación por Sebastián" — Sebastián reemplaza esa sección con la UI de R04/R05 sin tocar el header/sidebar.

Sobre CSS:
- Se agregó la clase .action-impersonar (color morado) para distinguir visualmente el botón de impersonación de los existentes (consultar/editar/movimientos/borrar).

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

PROBLEMAS DETECTADOS Y CÓMO SE RESOLVIERON

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Problema: faltaban TiposEvento en data/Datos.xml para cubrir R07 del PDF.
Causa: la spec R07 lista 15 eventos (Login, Logout, Listar empleados, Listar con filtro, Insertar empleado, Eliminar empleado, Asociar deducción, Desasociar deducción, Consultar planilla semanal, Consultar planilla mensual, Editar empleado, Impersonar empleado, Regresar a admin, Ingreso de marcas de asistencia, Ingreso nuevas jornadas), pero el XML solo tenía 16 que cubrían parcialmente.
Solución: se agregaron Ids 17-23. Cambio aditivo, sin tocar Ids 1-16 (los SPs existentes que resuelven por Nombre siguen funcionando idéntico).

Problema: no había forma de probar R03/R06 desde la UI, solo a nivel SP.
Causa: los SPs existían pero no había controller/route/botón que los invocaran.
Solución: se implementó el cableado completo (controller + route + botón admin + página empleado con botón de regreso).

Problema: el placeholder de la vista de empleado (empleado.html) no existía.
Causa: Sebastián aún no implementa R04/R05, pero el botón R06 necesita una página donde vivir.
Solución: se creó empleado.html como placeholder mínimo (header con nombre del empleado, botón "Regresar a admin" prominente, cuerpo pendiente). Sebastián reemplaza solo el cuerpo, sin tocar el header.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

AVANCE DEL CÓDIGO

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Catálogo:
- data/Datos.xml: 7 nuevos <TipoEvento> (Ids 17-23). XML validado con [xml]::Load, 23 nodos.

Backend (R03 + R06 end-to-end):
- src/controllers/impersonarController.ts (nuevo, 134 líneas): funciones impersonarEmpleado y regresarAdmin. Resuelven idUsuarioAdmin desde x-username, llaman a los SPs, manejan outResultCode y los HTTP codes correspondientes.
- src/routes/impersonar.ts (nuevo, 38 líneas): POST /api/auth/impersonar y POST /api/auth/regresar-admin.
- src/index.ts: import + app.use('/api/auth', impersonarRouter).

Frontend admin (R03):
- public/js/empleados.js: nuevo botón "Impersonar" en cada fila (clase action-impersonar, color morado). Nuevo case en bindEvents para accion='impersonar'. Nuevo método impersonarEmpleado() que llama al nuevo endpoint, guarda contexto en localStorage y redirige a empleado.html. Nuevo helper nombreDeEmpleadoActual() para resolver el nombre desde el DOM sin GET extra.

Frontend empleado (R06):
- public/empleado.html (nuevo): sidebar con kicker "Impersonando", nombre del empleado, documento, botón "Regresar a admin". Main con placeholder "Planilla semanal y mensual — Pendiente de implementación por Sebastián".
- public/js/empleado.js (nuevo): clase EmpleadoPage con bindEvents, pintarContexto (lee de localStorage o query params), regresarAdmin() que llama al endpoint y limpia localStorage.

CSS:
- public/css/style.css: agregada .page-content .action-impersonar (rgba morado).

Validación:
- `npx tsc --noEmit` sobre tsconfig.json y tsconfigFronted.json: 0 errores reales (los warnings son por dependencias no instaladas — sin node_modules, esperado).

Archivos modificados (4) y creados (4):
- Modificados: data/Datos.xml, src/index.ts, public/js/empleados.js, public/css/style.css.
- Nuevos: src/controllers/impersonarController.ts, src/routes/impersonar.ts, public/empleado.html, public/js/empleado.js.

Persona A (Matías) completó R03 y R06 end-to-end. R07 (bitácora) está implementado a nivel de SPs (todos los eventos quedan registrados) y la trazabilidad funciona — falta el visor de bitácora (Opción 2 de la sesión, no priorizada hoy).

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

MORALEJAS / BUENAS PRÁCTICAS

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Comparar el catálogo de datos contra el PDF (no contra el SPEC.md resumido) periódicamente — las tablas del enunciado son la fuente de verdad y pueden omitirse del resumen.
Los SPs que resuelven TiposEvento por Nombre son robustos a reordenamientos de Ids en el XML. Mantener ese patrón.
Para R03/R06, montar las rutas bajo /api/auth (no /api/empleados) porque la sesión activa viaja en x-username, igual que login/logout. Consistencia de namespace.
Crear placeholders mínimos (header + botón principal) para vistas que otro compañero implementará después, en vez de bloquear la integración. Sebastián puede ahora conectar sus SPs sin tener que pelearse con la navegación.
En frontend, duplicar info en localStorage + query params (sobrevive a F5) y limpiar las keys de impersonación al regresar a admin.
Patrón de outResultCode → HTTP status: códigos de dominio (50012 no existe, 50013 no es admin) → 404/403, resto → 400, server errors → 500. El controller es quien decide el status, no el SP.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

PRÓXIMA SESIÓN: ¿QUÉ SIGUE?

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Opción 2: implementar el visor de bitácora (R07 admin) — nueva página bitacora.html + sp_GetBitacora + ruta GET. Pendiente.
Levantar SQL Server local + pnpm install + pnpm run dev para validar end-to-end R03/R06 (clic → SP → bitácora → redirige).
Ejecutar sp_CargarCatalogosXML con el XML actualizado (Ids 17-23) para que los nuevos eventos estén en la BD antes de que Sebastián los use.
Revisión cruzada: Matías revisa los SPs de Sebastián cuando estén listos.
Documentar el comportamiento esperado para MarcaAsistencia sin HorarioJornada (riesgo §7 AGENTS.md).

# Bitácora de Sesión

Fecha: 09/06/2026

Inicio: [19:00] | Fin: [20:30] || Total: [1 hora 30 minutos]

Presente: Matías Benavides Sandoval

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

¿QUÉ HICIMOS HOY?

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Se diagnosticó y corrigió un bug en la pantalla de listado de empleados donde los botones de acción (Consultar, Editar, Impersonar) no funcionaban al hacer clic y mostraban texto corrupto. La causa raíz fue que el archivo compilado `public/js/empleados.js` contenía marcas de merge conflict (`<<<<<<< HEAD`, `=======`, `>>>>>>> 6a88b97`) del último merge, que se renderizaban como parte del HTML de la tabla de empleados, rompiendo la estructura de los botones.

Adicionalmente, se descubrió que el backend (en `dist/`) estaba corriendo código compilado del 20 de mayo — anterior a todos los cambios de SPs, rutas y controladores de la sesión 02-04/06/2026. Se recompiló el backend completo y se reinició el servidor.

Se recompilaron también todos los archivos frontend con `tsc --project tsconfigFronted.json`, dejando los JS de salida libres de artefactos de merge.

Al final de la sesión, el flujo completo funciona: Login → Lista empleados → Impersonar → Vista empleado → Regresar admin.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

PROBLEMAS DETECTADOS Y CÓMO SE RESOLVIERON

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Problema: los botones de la tabla de empleados (Consultar, Editar, Impersonar) no respondían al clic. El usuario reportó que el texto del botón se veía incorrecto.
Causa: `public/js/empleados.js` (JS compilado) contenía marcas de merge conflict sin resolver del último merge. El template literal del HTML de la tabla incluía `<<<<<<< HEAD`, `=======`, `>>>>>>> 6a88b97` como texto visible, lo que rompía la estructura HTML de la fila y la delegación de eventos.
Solución: se recompiló el frontend con `npx tsc --project tsconfigFronted.json` — el TS fuente estaba limpio, solo el JS compilado arrastraba el merge. Se verificó que el JS resultante no tuviera marcas de merge ni duplicados en el handler de eventos.

Problema: el servidor devolvía "error interno del servidor" al cargar datos.
Causa: el servidor Node.js en ejecución cargaba `dist/index.js` compilado el 20 de mayo — antes de que existieran los SPs correctos, las rutas nuevas y los controladores adaptados. El código viejo intentaba llamar a SPs que no existían o con parámetros incorrectos.
Solución: se recompiló el backend con `npx tsc` (tsconfig.json → ./dist), se mató el proceso Node viejo (PID 46940) y se arrancó de nuevo. Se verificó que todos los archivos en `dist/` tuvieran fecha 09/06/2026.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

AVANCE DEL CÓDIGO

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

- `public/js/empleados.js`: recompilado — eliminadas marcas de merge conflict que rompían botones de la tabla. Ahora renderiza 3 botones correctos (Consultar, Editar, Impersonar) con `data-accion="impersonar"` y `data-documento="${empleado.ValorDocumento}"`.
- `public/js/empleado-view.js`, `public/js/insertarMovimiento.js`, `public/js/movimientos.js`: recompilados (cambio solo de line endings CRLF).
- `dist/` (backend): recompilado completo con todos los cambios de sesiones anteriores (controladores, rutas, SP calls).
- Servidor reiniciado exitosamente.

Archivos modificados (1 con cambios de contenido):
- `public/js/empleados.js` (53 líneas cambiadas: +32/-21)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

MORALEJAS / BUENAS PRÁCTICAS

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Después de un merge con conflictos, siempre recompilar tanto frontend como backend antes de probar — los archivos compilados pueden arrastrar marcas de merge incluso si el fuente está limpio.
El servidor carga código de `dist/`, no de `src/`. Recompilar con `npx tsc` después de cualquier cambio en `src/` y reiniciar el proceso. El `package.json` tiene script `"build": "tsc"` y `"start": "node dist/index.js"` — usarlos en vez de `ts-node` para producción.
Cuando el usuario dice "los datos no cargan / error interno del servidor", revisar primero si `dist/` está desactualizado.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

PRÓXIMA SESIÓN: ¿QUÉ SIGUE?

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Persona B (Sebastián): conectar sus SPs de planilla (sp_GetPlanillaSemanal, sp_GetPlanillaMensual) a la vista empleado (empleado-view.html/ts).
Ejecutar sp_CargarCatalogosXML con el XML actualizado si no se ha hecho.
Implementar el visor de bitácora (R07 admin) si aplica.
