ITCR – Escuela de Ing. en Computación – Base de Datos 1 – Prof. fquiros – Mayo 2026 
Proyecto que se realiza como 3era y opcionalmente como 4ta (Si en la entrega para la 
3era fue incompleta o incorrecta) 
Uno. Objetivos: Implementar una base de datos física, así como escribir el código en capa 
lógica y física, para la implementación de 2 sitios web (para administradores y empleados), 
para el mantenimiento de entidades (CRUD) y la realización de consultas. Escribir en SQL un 
script que realice una simulación la operación del sistema por varios meses. 
Dos. Descripción. 
Control de asistencia y Planilla Obrera. 
Los obreros en una fábrica tienen horarios rotativos que cambian semana a semana, según el 
tipo de jornada (matutina, vespertina o nocturna). La fábrica nunca se detiene, así que los 
horarios incluyen fines de semana y días feriados. Los obreros trabajan 6 días, descansan un 
día. 
El salario por hora, usado para calcular el salario semanal, depende del puesto y la jornada de 
trabajo, hay 3 tipos de jornadas: jornada diurna (cuando inicia a las 6 am y es por 8 horas), y 
otro para jornada vespertina (que inicia a las 2 pm y es de 8 horas) y para jornada nocturna 
(inicia a las 7 pm y es de 8 horas).  El valor de la hora extra es 1.5 del valor de la hora 
ordinaria, siempre que la hora trabajada no sea en domingo ni feriado, en cuyo caso es 2.0 del 
valor de la hora ordinaria. Una hora trabajada extraordinaria, se determina si la hora de marca 
de salida del empleado es superior a la hora de salida según el tipo de jornada en la semana 
actual. 
El pago del salario es semanal, aunque el reporte a la caja del seguro es de manera mensual. 
Para el corte mensual, el cierre es el último jueves de cada mes. O sea que el salario mensual, 
que se reporta a la caja, es el que va desde la semana que inicia el ultimo viernes del mes 
anterior, al último jueves del presente mes. Usualmente el mes será de 4 semanas, pero habrá 
algunos de 5 semanas. Tomar en cuenta, que, según leyes de Costa Rica, la deducción por 
aporte a la Caja, aguinaldo y liquidaciones se hacen según el salario mensual, aunque este se 
pague en tractos semanalmente. 
La información de entrada de la planilla es un archivo xml, que contiene para cada día de la 
semana laboral, la información de asistencia de los empleados: la fecha, la identificación del 
empleado, la marca de hora de entrada y la marca de la hora de salida. El cálculo de 
la planilla semanal, se realiza todos los jueves a las 12 medianoche,  por lo tanto se calcula 
desde el procesamiento de las jornadas nocturnas del jueves previo (que terminan viernes pues 
inician a las 7 pm del jueves) hasta las jornadas vespertinas del siguiente jueves (que terminan 
en la noche del jueves); o sea que procesa todas las asistencias de las jornadas que terminan 
el viernes en la mañana al fin de la jornada vespertina del jueves (el final de jornada nocturna 
del jueves es el viernes).  En el cálculo de la planilla semanal se aplican deducciones, ya sea 
porcentuales o fijas, las deducciones porcentuales se aplican semanalmente, la fijas, aunque el 
monto de deducción es mensual; se aplican semanalmente dividiendo entre 4 o entre 5, según 
si el mes tiene 4 o 5 jueves. 
Por ejemplo, suponga una deducción fija de 10,000 colones mensuales de ahorro vacacional, 
como la planilla es semanal, si el mes tiene 4 jueves: se deducen 2500 cada jueves, si tiene 5 
jueves se deducen 2000 por semana. 
Ejemplo de deducción porcentual: 9% de aporte obrero a la caja de seguro, se aplica al salario 
bruto (sin deducciones) calculado semanalmente. 
Para el cálculo del salario hay devengados (créditos o sea suman al salario) y deducciones 
(débitos o sea restan al salario), los devengados son: 
 salario por hora trabajada,  
 salario por hora extraordinaria (son horas trabajadas, después de fin de la jornada, pero 
no en domingo ni feriado),  
 salario por hora extra doble (son horas trabajadas, después de fin de la jornada y, es 
domingo o feriado),  
 venta de vacaciones y otros. 
Las deducciones, son porcentuales o fijas; ejemplo de porcentuales: Caja del seguro (10.5%) y 
Cuota Asociación Solidarista (5%). Ejemplo de deducción fija son: embargo por pensión 
alimenticia, ahorro vacacional, embargo por deuda, pago de préstamo con la asociación 
solidarista, etc. 
La planilla mensual, es la suma de las planillas semanales, no necesariamente es mes natural. 
Los montos de la planilla mensual son los usados para el cálculo de pago de aguinaldo, 
liquidaciones, y es el salario que se comunica a la caja de seguro. 
La suma de las deducciones es transferida, mensualmente, a las cuentas bancarias de los 
beneficiarios de las deducciones: caja del seguro, asociación solidarista, cuentas para 
embargos de deudas, y cuentas para embargo de pensión alimenticia. 
El pago se realiza haciendo una transferencia por el salario neto (salario bruto menos 
deducciones) a la cuenta bancaria del obrero. El segundo lunes de cada diciembre, se hace el 
pago del aguinaldo, es la suma del salario bruto mensual, de diciembre a noviembre, dividido 
entre 12. El salario bruto es la suma de todos los devengados, ignorando las deducciones 
aplicadas.  
Todos los jueves, ingresa un archivo XML al sistema de planilla, que indica para cada 
empleado cuál será su turno para la siguiente semana que inicia viernes. 
Tres. Requerimientos funcionales. 
Para este proyecto debe implementar un sitio web para 2 tipos de usuarios: Usuario 
administrador y Usuario empleado. 
Al sitio web se ingresa mediante Usuario y Password, dependiendo el tipo de usuario 
(administrador o empleado) la interfaz de usuario puede cambiar. 
Tres.1. Requerimientos para las funcionalidades de usuarios que acceden como 
administrador. 
El interfaz de usuario debe permitir la realización de las siguientes acciones: 
R01. Listar empleados: se listan todos los nombres de los empleados y el nombre de su 
puesto, en orden alfabético del nombre del empleado, y es posible seleccionar uno de ellos 
para editarlo. Esto consulta se ejecuta por default al ingresar, de manera que lo primero que ve 
el usuario es esta lista, es posible seleccionar un empleado para editarlo y hacer otras 
funciones que se especificaran después. 
R02. Listar empleados con filtro: es especifica un filtro, o sea un string que es un patrón de 
búsqueda respecto del nombre de empleado, y se listan los nombres de los empleados y el 
puesto que talque que el nombre del empleado cumple con el patrón, en orden alfabético del 
nombre del empleado. Después de que la lista ha sido filtrada, es posible seleccionar un 
empleado para editarlo y hacer otras funciones que se especificaran después. La interfaz debe 
ser similar a la que se ve en R01. 
R03. Impersonar un empleado.  
Se selecciona un empleado de la lista, al dar click a la opción de impersonar, la 
siguiente interfaz será exactamente igual que la que ve un usuario empleado al entrar a 
la aplicación con su usuario y password. 
Tres.2. Requerimientos para las funcionalidades que puede acceder un empleado: 
Un portal o sitio web, en donde el empleado hace login y puede realizar las siguientes 
operaciones: 
R04. Consultar planilla semanal:  
 Se visualizan las últimas X planillas semanales, se muestran en un grid con columnas 
para el salario bruto (clickeable), total de deducciones (clickeable), salario neto, 
cantidad de horas ordinarias, cantidad de horas extra normales, cantidad de horas 
extras doble. 
 Si se da click sobre el monto de deducciones se podrán ver el detalle de todas las 
deducciones aplicadas en esa semana para el empleado, el cual debe incluir para cada 
deducción asociada al empleado en esa semana: el nombre de la deducción, el 
porcentaje aplicado (si es que es porcentual) y el monto de la deducción. 
 Si se da click sobre el salario bruto: se visualizan; en un grid, para cada día de la 
semana, la hora de entrada, la hora de salida, y los movimientos que genero esa 
asistencia, o sea: horas ordinarias y monto devengado, horas extras normales y monto 
devengado; o, horas extras dobles y el monto devengado. 
R05. Consultar planilla mensual: 
 Se visualizan los últimos X meses, se muestra el salario bruto, el total de deducciones y 
el salario neto. 
 Si se da click sobre el monto de deducciones se podrán ver el nombre de la deducción, 
el porcentaje aplicado (si es que es porcentual) y el monto de la deducción, para todas 
las deducciones aplicadas ese mes a ese empleado, que a su vez son la suma de las 
deducciones mensuales. 
R06. Regresar a interfaz de administrador. 
Si se ingreso a la interfaz de empleado, como usuario administrador aunque impersonando un 
empleado, esta opción será visible, de otra manera no lo será. Al dar click aquí, la interfaz 
regresa a la interfaz inicial de un usuario administrador. Ver R01. 
Otros requisitos no funcionales. 
R07. Trazabilidad. 
En una tabla de bitácora de eventos, se guarda la historia de toda acción en las aplicaciones ya 
sea ejecución consultas, modificaciones en línea de CE (CRUD), , asignación y des asignación 
de deducciones (ya sea desde la interfaz de usuario, desde el script de simulación), login, 
logout. Los datos de pruebas proveerán un catalogo de tipos de eventos. 
Recordar que no hay interfaz de usuario para asignar o desasignar deducciones, excepto la 
que se asigna por default al insertar un empleado, esto para mantener el proyecto de manera 
menos compleja. 
Para cada tipo de evento se almacena el Id de Usuario, la IP desde donde se ejecuta la acción, 
una estampa de tiempo, el id del tipo de evento, la lista de parámetros necesaria para realizar 
la operación, y en el caso de un crud, los campos del registro “antes” de la operación y los 
campos de los registros “despues” de la operación. 
Para todo evento se guarda el User.Id, IP y estampa de tiempo. La información que se 
guarda puede tener formato JSON. 
Tipo de Evento 
Información que se guarda en el 
Event Log 
Login 
UserName, resultado: exitoso, no 
exitoso 
Logout 
Listar empleados 
Nada 
Nada 
Listar empleados con filtro 
Insertar empleado 
Descripción del filtro 
Todos los atributos del nuevo 
empleado 
Eliminar empleado 
Todos los atributos del empleado que 
se borrar 
Asociar deducción 
Empleado.Id, TipoDeduccion.Id, valor 
porcentual, valor monto fijo 
Desasociar deducción 
Consultar una planilla semanal 
Empleado.Id, TipoDeduccion.Id 
Empleado.Id, Fecha Inicio y Fecha fin 
de planilla 
Consultar una planilla mensual 
Empleado.Id, Fecha Inicio y Fecha fin 
de planilla 
Editar empleado 
Todos los atributos antes de la 
edición, todos los atributos después 
de la edición 
Impersonar empleado 
Regresar a interfaz de administrador 
Empleado.Id que se está 
impersonando 
Ingreso de marcas de asistencia 
Nada 
Empleado.Id marca de inicio, marca 
de fin 
Ingreso nuevas jornadas 
Empleado.Id, TipoJornada.Id 
Cuatro. Datos de prueba. 
La carga de datos de prueba, así como una simulación de la ejecución del sistema para varios 
meses (al menos 4 meses) se hará desde un archivo XML. 
Nodos XML para Catálogos. 
La carga de datos de prueba respecto de catálogos se hará a través desde un archivo XML que 
tendrá nodos con la siguiente estructura. 
<!-- catalogos--> 
<Catalogo> 
<TiposDeJornada> 
<TipoDeJornada> id=”1” Nombre=”Diurno” HoraInicio=”6:00” HoraFin=”14:00”/> 
<TipoDeJornada> id=”2” Nombre=”Vespertino” HoraInicio=”14:00” HoraFin=”22:00”/> 
<TipoDeJornada> id=”3” Nombre=”Nocturno” HoraInicio=”22:00” HoraFin=”06:00”/> 
</TiposDeJornada> 
<Puestos> 
<Puesto Nombre="Electricista" SalarioXHora="1200"/> 
<Puesto Nombre="Auxiliar de Laboratorio" SalarioXHora="1250"/> 
<Puesto Nombre="Operador de Maquina" SalarioXHora="1025"/> 
…. 
</Puestos> 
<Feriados> 
<Feriado Id="1" Nombre="Dia de Juan Santamaria" Fecha=”20220411”/> 
<Feriado Id="2" Nombre="Jueves Santo" Fecha=”20220414”/> 
<Feriado Id="3" Nombre="Viernes Santo" Fecha=”20220415”/> 
<Feriado Id="4" Nombre="Dia del trabajo" Fecha=”20220501”/> 
… 
</ Feriados > 
<TiposDeMovimiento> 
<TipoDeMovimiento Id="1" Nombre="Credito Horas ordinarias" /> 
<TipoDeMovimiento Id="2" Nombre="Credito Horas Extra Normales" /> 
<TipoDeMovimiento Id="3" Nombre="Credito Horas Extra Dobles" /> 
Inicio Mejorarlo … 
<TipoDeMovimiento Id="4" Nombre="Caja" /> 
<TipoDeMovimiento Id="4" Nombre="Deducciones Asociacion Solidarista" /> 
<TipoDeMovimiento Id="5" Nombre="Deduccion Ahorro Olbigatorio" /> 
… 
</TiposDeMovimiento> 
<TiposDeDeduccion> 
<TipoDeDeduccion Id="1" Nombre="Obligatorio de Ley" Obligatorio="Si" Porcentual="Si" 
Valor="0.095" /> 
<TipoDeDeduccion Id="2" Nombre="Ahorro Asociacion Solidarista" Obligatorio="No" 
Porcentual="Si" Valor="0.05" /> 
<TipoDeDeduccion Id="3" Nombre="Ahorro Vacacional" Obligatorio="No" Porcentual="No" 
Valor="0" /> 
<TipoDeDeduccion Id="4" Nombre="Pension Alimenticia" Obligatorio="No" Porcentual="No" 
Valor="0" /> 
… 
</TiposDeDeduccion> 
<UsuariosAdministrador> 
<!—Usuario tipo 1 es administrador, tipo 2 es empleado> 
<Usuario pwd="1234" username="Goku" /> 
<Usuario pwd="1234" username="Willy" /> 
</UsuariosAdmnistrador> 
<!— En la BD en CE Usuarios se debe guardar tipo="1” si es administrador =”2” >  
<!— si es empleado > ---- fin mejorarlo 
<TiposdeEvento> 
<TipoEvento> Id=”1” Nombre: “login”/> 
<TipoEvento> Id=”2” Nombre: “logout”/> 
<TipoEvento> Id=”3” Nombre: “Listar empleados”/> 
<TipoEvento> Id=”4” Nombre: “Listar empleados con filtro”/> 
<TipoEvento> Id=”5” Nombre: “Insertar empleado”/> 
… 
<\TiposdeEvento> 
<\Catalogo> 
Las llaves de las tablas catálogo, se insertan tal cual vienen en el archivo XML, excepto para 
Puestos cuyo mapeo será a través del nombre. O sea que las llaves en estas entidades tipo 
catálogo (excepto puesto) no son llaves identity, ni autoincrementales; excepto en Puesto. 
“Mapeo” es la forma en que se obtienen los atributos de una entidad, usualmente el mapeo es 
a través de la llave primaria PK, pero si esta no se conoce o no se puede deducir hay que 
hacerlo a través de una llave secundaria, en el caso de Puesto, ya que en la tabla el Id será 
autoincremental, cada proyecto de cada grupo puede ser que tenga id diferente para el puesto 
electricista, entonces para obtener el id, hay que “mapear” nombre de puesto. 
Para las tablas no-catálogo, sus llaves SI son identity, por lo tanto, cada proyecto genera llaves 
propias. 
Especificación de pruebas mediante una simulación del sistema y el XML con los datos 
de operación. 
Para realizar la simulación se utilizarán dos documento xml uno para la inserción de catálogos 
o datos básicos (TipoDocumentoIdentidad, Puestos, Departamento, TipoJornada (turnos), 
TipoMovimientoPlanilla, Usuarios y Tipos de Evento), y un documento xml cuyo nodo en su 
nivel más alto representa una fecha de operación del sistema, las fechas serán consecutivas.  
Dentro de cada fecha de operación, habrá nodos para: 
 Inserción de nuevos empleados 
 Eliminar un empleado 
 Asociar un empleado con una deducción no obligatoria. 
 Desasociar un empleado con una deducción no obligatoria. 
 La representación de marcas de asistencia que corresponden a la fecha de operación. 
Estos nodos indican la hora de entrada y la hora de salida de los empleados, las marcas 
incluyen la fecha (AAAAMMDD hh:mm). Una marca puede iniciar una fecha y terminar 
en fecha del día siguiente, para las jornadas nocturnas. 
 Si es jueves, para cada empleado el tipo de jornada para la siguiente semana. 
El XML de operación incluirá al menos X meses de datos. Al insertar un empleado, este debe 
asociarse automáticamente con las deducciones obligatorias, a través de un trigger. 
Todos los catalogos se mapearán por Id (excepto Puestos), desde el XML de operación. 
La estructura del xml de operación es similar a esta: 
Nota temporal: Aclaración: este formato de XML debe ser mejorado, se hará para una próxima 
versión del documento. 
Nota: <AsociaEmpleadoConDeduccion …/>, asocia en empleado con un tipo de deducción no 
obligatoria. <DesasociaEmpleadoConDeduccion …/>, desasocia un empelado con un tipo de 
deducción no obligatorio. Una deducción de tipo obligatoria (caja) no se asocian. 
Los mapeos a empleados en el XML de operación serán a través del valor del documento de 
idéntica, típicamente el número de cédula. 
La simulación, itera sobre todas las fechas, de manera consecutiva ascendentemente por valor 
de fecha, y debe realizar las siguientes funciones en cada fecha: 
 Insertar empleados que inician a trabajar en próximo inicio de semana. NO puede ser 
que inicien al siguiente día (a menos que se inserten jueves), pues aun no tendrán 
asignado una jornada de trabajo. 
 Eliminar empleados que dejan de trabajar en esa fecha de operación. 
 Asociar empleados con tipo de deducción, aplicable a partir del próximo inicio de 
semana. 
 Desasociar empleados con tipo de deducción, aplicable a partir del próximo inicio de 
semana. 
 Procesar asistencias, para cada empleado reportado con un nodo de asistencia: 
o Calcular cantidad de horas trabajadas ordinarias, y crear un movimiento por 
horas trabajadas ordinarias, cuyo monto será la cantidad de horas trabajadas 
multiplicado por salario por hora del puesto del empleado. Solo se pagan horas 
completas, si el empleado trabajo 7.5 horas se pagan 7 horas. 
o Calcular cantidad de horas trabajadas extras normales, es el exceso de horas 
respecto de la hora de salida según la jornada de la semana actual, solo se 
pagan horas extras completas, se debe generar un movimiento cuyo monto es la 
cantidad de horas extras completas multiplicada por el salario x hora del puesto 
multiplicado por 1.5 si la fecha no es domingo ni feriado 
o Calcular cantidad de horas extras dobles trabajadas, si el obrero trabajo horas 
extras, y la fecha es domingo o feriado, son horas extras dobles, el monto 
ganado es el salario por hora multiplicado por la cantidad de horas, multiplicado 
por 2. Nota: en un caso extremo la asistencia del empleado a una fecha puede 
generar 3 movimientos, suponga que su fin de jornada es a las 10 pm, sin 
embargo, su marca de salida es 3 am del día siguiente y este es feriado, genera 
movimiento de horas ordinarias (de su jornada), 2 horas extras normales 
(pagadas a 1.5 del salario de su puesto), y 3 horas extras dobles. 
Al calcular movimientos de salario por hora, debe generarse movimientos en la 
planilla semanal, y debe incrementarse el SalarioBruto. 
 Si fecha de operación es jueves, después de procesar lo anterior, se debe hacer cierre 
de semana de planilla: 
o El salario bruto ya estará calculado al llegar al final del jueves. 
o Aplicar todas las deducciones porcentuales respecto del salario bruto, esto es, a 
cada empleado por cada tipo de deducción porcentual asociada al empleado, se 
calcula la deducción, se agrega un movimiento de débito y se acumula en 
totaldeducciones. Esto para todos los empleados. 
o Aplique todas las deducciones por monto fijo (las no obligatorias), esto es 
genere un movimiento de débito por el monto de la deducción por cada tipo de 
deducción asociado al empleado con monto fijo (o sea no es porcentual), se 
agrega un movimiento de débito y se acumula en totaldeducciones.  Se aplica a 
todos los empleados que tienen asociados deducciones no obligatorias, no 
vencidas. 
o A todos los empleados, acumule las deducciones en el resumen mensual de 
deducciones (deducciones x empleado x mes). 
o Como resultado de lo anterior, el salario neto será el SalarioBruto – 
TotalDeducciones. 
o Procesar el depósito bancario a la cuenta del empleado con el salario neto. 
(salario bruto menos deducciones). Este paso no se hará. 
Aclaración sobre las deducciones: las deducciones porcentuales, simplemente se aplica el 
porcentaje. Las deducciones fijas, el monto de la deducción es mensual, al aplicarse 
semanalmente, debe dividirse este monto entre 4 o 5, dependiendo si el mes planilla es de 
4 o de 5 semanas. 
 Si la fecha de operación es jueves y el siguiente día es el primer viernes del mes, hacer 
apertura para el siguiente mes. 
o Crear encabezado del mes para todos los empleados respecto del mes que 
inicia ese primer viernes del mes, esto es necesario para llevar los acumulados 
mensuales de SalarioBrutoMensual, DeduccionesMensuales y detalle de las 
deduccionesXmes. 
 Si fecha de operación es jueves, abrir proceso de nueva semana, esto preparar las 
estructuras de datos o tablas para su proceso diario: 
o Crear encabezado de semana (de la planilla semanal) para todos los empleados 
para la semana que inicia el día siguiente asociado con el mes que le 
corresponde. 
o Procesar los nodos que asocian el empleado con el tipo de jornada que cumplirá 
en la siguiente semana. 
Cinco. ¿Qué se pide? 
La BD física para implementar la solución del problema. 
El código del trigger que asocia un nuevo empleado con las deducciones obligatorias. 
El script para para llenado de catalogos 
El script que hace la simulación y su corrida. 
El código en capa lógica para la el sitio web ya sea que el susuario es administrador o 
empleado. 
El código de los SP para las simulaciones y todas las consultas. 
Un portal o sitio web, en donde el empleado hace login y puede realizar las operaciones, que 
se definieron antes, 
La documentación acostumbrada 
Seis. Reglas. 
Por cada empleado, al final de su procesamiento independientemente de si es día normal o día 
de cierre, debe existir una sola transacción de BD que haga todo para ese empleado, esto es: 
 insertar movimientos por horas,  
 insertar movimientos por deducciones solo en día de cierre,  
 acumular Salario Bruto Semanal y Total Deducciones semanal (en 
PlanillaSemXEmpleado),  
 acumular Salario Bruto Mensual y Total Deducciones mensuales (en 
PlanillaMexXEmpleado),  
 acumular en DeduccionesXEmpleadoxMes, para cada tipo de deducción asociado con 
el empleado. 
 si es el primer empleado que se procesa preguntar  
o si es ultima semana del mes, y si sí, aperturar (crear instancia) mesPlanilla para 
siguiente ciclo mensual (CE MesPlanilla) 
o crear instancia para siguiente ciclo semanal (CE SemanaPlanilla) 
 Crear instancia para PlanillaSemXEmpleado, del nuevo ciclo semanal, con los 
acumuladores en cero. 
 Si se esta procesando la última semana del mes, debe crearse instancia de 
PlanillaMexXEmpleado, así como una nueva instancia de 
DeduccionesXEmpleadoxMes. 
Todo el código referido a base de datos, debe ser un procedimiento almacenado. No puede 
haber SQL incrustado en capa lógica. 
Grupos de 2 personas. Motor de base de datos: MS SQL cualquier versión superior a 2014. 
Código en capa lógica, en el lenguaje o framework de su preferencia.  
Fecha de entrega: 13 de junio 2026 (Primera entrega), 1 de Julio (segunda entrega, fecha 
anterior a entrega de actas (2 Julio). 
La meta debe ser entregar el proyecto completo el xx de junio, con un valor de 26.66%, o sea 
vale como 2 tareas programadas (la 3era y la 4ta), si la primera entrega está muy incompleta o 
incorrecta se evalúa sobre la base de un 13.33% (se evalúa como 3era tarea) de manera que el 
estudiante la puede completar y mejorar para la 2da entrega, que en este caso se valora en 
13.33%. 