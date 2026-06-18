USE [PlanillaDB];
GO

IF OBJECT_ID(N'dbo.sp_CargarOperacionesXML', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_CargarOperacionesXML];
GO

-- =====================================================================
-- sp_CargarOperacionesXML
-- =====================================================================
CREATE PROCEDURE [dbo].[sp_CargarOperacionesXML]
    @outResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET DATEFIRST 7; -- Garantiza estabilidad del DATEPART sin importar el idioma del servidor
    SET @outResultCode = 0;

    DECLARE @xml NVARCHAR(MAX) = N'
<Operaciones>

    <!-- ============================================================
         JUEVES 2026-03-05: inserción de empleados iniciales
         y jornada para semana 1 (inicia 2026-03-06)
    ============================================================ -->
    <FechaOperacion Fecha="2026-03-05">
        <InsertarEmpleado ValorDocumentoIdentidad="110011001" Nombre="Carlos Mendoza"
            Puesto="Electricista" CuentaBancaria="CR2415115201001026284066"
            Username="Mencar" Password="Gojira" TipoUsuario="0" FechaContratacion="2026-03-06"/>
        <InsertarEmpleado ValorDocumentoIdentidad="305827920" Nombre="Ana Rodriguez"
            Puesto="Cajero" CuentaBancaria="CR2415115201901026284067"
            Username="Rodana" Password="Seguridad" TipoUsuario="0" FechaContratacion="2026-03-06"/>
        <InsertarEmpleado ValorDocumentoIdentidad="194739285" Nombre="Nicolas Vargas"
            Puesto="Conductor" CuentaBancaria="CR2415115201901026392748"
            Username="Varnic" Password="EndgamE" TipoUsuario="0" FechaContratacion="2026-03-06"/>
        <InsertarEmpleado ValorDocumentoIdentidad="222333444" Nombre="Laura Castro"
            Puesto="Recepcionista" CuentaBancaria="CR2415115201901026111001"
            Username="Caslaur" Password="Laura123" TipoUsuario="0" FechaContratacion="2026-03-06"/>
        <InsertarEmpleado ValorDocumentoIdentidad="333444555" Nombre="Pedro Arias"
            Puesto="Fontanero" CuentaBancaria="CR2415115201901026111002"
            Username="Ariped" Password="Pedro456" TipoUsuario="0" FechaContratacion="2026-03-06"/>
        <AsociaEmpleadoConDeduccion ValorDocumentoIdentidad="110011001"
            TipoDeduccion="Ahorro Asociacion Solidarista" MontoFijo="0.00"/>
        <AsociaEmpleadoConDeduccion ValorDocumentoIdentidad="194739285"
            TipoDeduccion="Pension Alimenticia" MontoFijo="50000.00"/>
        <AsociaEmpleadoConDeduccion ValorDocumentoIdentidad="222333444"
            TipoDeduccion="Ahorro Vacacional" MontoFijo="20000.00"/>
        <AsociaEmpleadoConDeduccion ValorDocumentoIdentidad="333444555"
            TipoDeduccion="Ahorro Asociacion Solidarista" MontoFijo="0.00"/>
        <!-- Jornada semana 1 (InicioSemana 2026-03-06) -->
        <AsignarJornada ValorDocumentoIdentidad="110011001"
            Jornada="Diurno" InicioSemana="2026-03-06"/>
        <AsignarJornada ValorDocumentoIdentidad="305827920"
            Jornada="Vespertino" InicioSemana="2026-03-06"/>
        <AsignarJornada ValorDocumentoIdentidad="194739285"
            Jornada="Nocturno" InicioSemana="2026-03-06"/>
        <AsignarJornada ValorDocumentoIdentidad="222333444"
            Jornada="Diurno" InicioSemana="2026-03-06"/>
        <AsignarJornada ValorDocumentoIdentidad="333444555"
            Jornada="Vespertino" InicioSemana="2026-03-06"/>
    </FechaOperacion>

    <FechaOperacion Fecha="2026-03-06">  <!-- Viernes -->
        <MarcaAsistencia ValorDocumentoIdentidad="110011001"
            HoraEntrada="2026-03-06 06:00" HoraSalida="2026-03-06 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="305827920"
            HoraEntrada="2026-03-06 14:00" HoraSalida="2026-03-07 00:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="194739285"
            HoraEntrada="2026-03-06 22:00" HoraSalida="2026-03-07 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="222333444"
            HoraEntrada="2026-03-06 06:00" HoraSalida="2026-03-06 16:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="333444555"
            HoraEntrada="2026-03-06 14:00" HoraSalida="2026-03-06 22:00"/>
    </FechaOperacion>

    <FechaOperacion Fecha="2026-03-07"> <!-- Sabado -->
        <MarcaAsistencia ValorDocumentoIdentidad="110011001"
            HoraEntrada="2026-03-07 06:00" HoraSalida="2026-03-07 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="305827920"
            HoraEntrada="2026-03-07 14:00" HoraSalida="2026-03-07 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="194739285"
            HoraEntrada="2026-03-07 22:00" HoraSalida="2026-03-08 08:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="222333444"
            HoraEntrada="2026-03-07 06:00" HoraSalida="2026-03-07 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="333444555"
            HoraEntrada="2026-03-07 14:00" HoraSalida="2026-03-08 00:30"/>
    </FechaOperacion>

    <FechaOperacion Fecha="2026-03-08"> <!-- Domingo -->
        <MarcaAsistencia ValorDocumentoIdentidad="305827920"
            HoraEntrada="2026-03-08 14:00" HoraSalida="2026-03-09 01:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="194739285"
            HoraEntrada="2026-03-08 22:00" HoraSalida="2026-03-09 08:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="222333444"
            HoraEntrada="2026-03-08 06:00" HoraSalida="2026-03-08 17:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="333444555"
            HoraEntrada="2026-03-08 14:00" HoraSalida="2026-03-09 01:00"/>
    </FechaOperacion>

    <FechaOperacion Fecha="2026-03-09"> <!-- Lunes -->
        <MarcaAsistencia ValorDocumentoIdentidad="110011001"
            HoraEntrada="2026-03-09 06:00" HoraSalida="2026-03-09 16:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="194739285"
            HoraEntrada="2026-03-09 22:00" HoraSalida="2026-03-10 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="222333444"
            HoraEntrada="2026-03-09 06:00" HoraSalida="2026-03-09 16:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="333444555"
            HoraEntrada="2026-03-09 14:00" HoraSalida="2026-03-10 00:30"/>
    </FechaOperacion>

    <FechaOperacion Fecha="2026-03-10"> <!-- Martes -->
        <MarcaAsistencia ValorDocumentoIdentidad="110011001"
            HoraEntrada="2026-03-10 06:00" HoraSalida="2026-03-10 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="305827920"
            HoraEntrada="2026-03-10 14:00" HoraSalida="2026-03-10 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="222333444"
            HoraEntrada="2026-03-10 06:00" HoraSalida="2026-03-10 16:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="333444555"
            HoraEntrada="2026-03-10 14:00" HoraSalida="2026-03-10 22:00"/>
    </FechaOperacion>

    <FechaOperacion Fecha="2026-03-11"> <!-- Miercoles -->
        <MarcaAsistencia ValorDocumentoIdentidad="110011001"
            HoraEntrada="2026-03-11 06:00" HoraSalida="2026-03-11 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="305827920"
            HoraEntrada="2026-03-11 14:00" HoraSalida="2026-03-12 00:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="194739285"
            HoraEntrada="2026-03-11 22:00" HoraSalida="2026-03-12 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="333444555"
            HoraEntrada="2026-03-11 14:00" HoraSalida="2026-03-11 22:00"/>
    </FechaOperacion>

    <FechaOperacion Fecha="2026-03-12"> <!-- Jueves -->
        <MarcaAsistencia ValorDocumentoIdentidad="110011001"
            HoraEntrada="2026-03-12 06:00" HoraSalida="2026-03-12 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="305827920"
            HoraEntrada="2026-03-12 14:00" HoraSalida="2026-03-13 00:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="194739285"
            HoraEntrada="2026-03-12 22:00" HoraSalida="2026-03-13 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="222333444"
            HoraEntrada="2026-03-12 06:00" HoraSalida="2026-03-12 14:00"/>
        
        <!-- Nuevos empleados: inician semana 2026-03-13 -->
        <InsertarEmpleado ValorDocumentoIdentidad="444555666" Nombre="Sofia Mora"
            Puesto="Asistente" CuentaBancaria="CR2415115201901026111003"
            Username="Morsofi" Password="Sofia789" TipoUsuario="0" FechaContratacion="2026-03-13"/>
        <InsertarEmpleado ValorDocumentoIdentidad="555666777" Nombre="Andres Vega"
            Puesto="Electricista" CuentaBancaria="CR2415115201901026111004"
            Username="Vegand" Password="Andres321" TipoUsuario="0" FechaContratacion="2026-03-13"/>
        
        <!-- Cierre semana 1: jornada semana 2 (InicioSemana 2026-03-13) -->
        <AsignarJornada ValorDocumentoIdentidad="110011001"
            Jornada="Vespertino" InicioSemana="2026-03-13"/>
        <AsignarJornada ValorDocumentoIdentidad="305827920"
            Jornada="Nocturno" InicioSemana="2026-03-13"/>
        <AsignarJornada ValorDocumentoIdentidad="194739285"
            Jornada="Diurno" InicioSemana="2026-03-13"/>
        <AsignarJornada ValorDocumentoIdentidad="222333444"
            Jornada="Vespertino" InicioSemana="2026-03-13"/>
        <AsignarJornada ValorDocumentoIdentidad="333444555"
            Jornada="Nocturno" InicioSemana="2026-03-13"/>
        <AsignarJornada ValorDocumentoIdentidad="444555666"
            Jornada="Diurno" InicioSemana="2026-03-13"/>
        <AsignarJornada ValorDocumentoIdentidad="555666777"
            Jornada="Vespertino" InicioSemana="2026-03-13"/>
        <AsociaEmpleadoConDeduccion ValorDocumentoIdentidad="305827920"
            TipoDeduccion="Ahorro Vacacional" MontoFijo="25000.00"/>
        <AsociaEmpleadoConDeduccion ValorDocumentoIdentidad="444555666"
            TipoDeduccion="Pension Alimenticia" MontoFijo="35000.00"/>
        <AsociaEmpleadoConDeduccion ValorDocumentoIdentidad="555666777"
            TipoDeduccion="Ahorro Vacacional" MontoFijo="15000.00"/>
    </FechaOperacion>

    <FechaOperacion Fecha="2026-03-13"> <!-- Viernes -->
        <MarcaAsistencia ValorDocumentoIdentidad="110011001"
            HoraEntrada="2026-03-13 14:00" HoraSalida="2026-03-14 00:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="305827920"
            HoraEntrada="2026-03-13 22:00" HoraSalida="2026-03-14 08:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="194739285"
            HoraEntrada="2026-03-13 06:00" HoraSalida="2026-03-13 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="222333444"
            HoraEntrada="2026-03-13 14:00" HoraSalida="2026-03-13 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="333444555"
            HoraEntrada="2026-03-13 22:00" HoraSalida="2026-03-14 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="555666777"
            HoraEntrada="2026-03-13 14:00" HoraSalida="2026-03-13 22:00"/>
    </FechaOperacion>

    <FechaOperacion Fecha="2026-03-14"> <!-- Sabado -->
        <MarcaAsistencia ValorDocumentoIdentidad="110011001"
            HoraEntrada="2026-03-14 14:00" HoraSalida="2026-03-14 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="305827920"
            HoraEntrada="2026-03-14 22:00" HoraSalida="2026-03-15 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="194739285"
            HoraEntrada="2026-03-14 06:00" HoraSalida="2026-03-14 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="222333444"
            HoraEntrada="2026-03-14 14:00" HoraSalida="2026-03-14 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="333444555"
            HoraEntrada="2026-03-14 22:00" HoraSalida="2026-03-15 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="444555666"
            HoraEntrada="2026-03-14 06:00" HoraSalida="2026-03-14 14:00"/>
    </FechaOperacion>

    <FechaOperacion Fecha="2026-03-15"> <!-- Domingo -->
        <MarcaAsistencia ValorDocumentoIdentidad="305827920"
            HoraEntrada="2026-03-15 22:00" HoraSalida="2026-03-16 08:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="194739285"
            HoraEntrada="2026-03-15 06:00" HoraSalida="2026-03-15 17:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="222333444"
            HoraEntrada="2026-03-15 14:00" HoraSalida="2026-03-16 01:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="333444555"
            HoraEntrada="2026-03-15 22:00" HoraSalida="2026-03-16 08:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="444555666"
            HoraEntrada="2026-03-15 06:00" HoraSalida="2026-03-15 17:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="555666777"
            HoraEntrada="2026-03-15 14:00" HoraSalida="2026-03-16 01:00"/>
    </FechaOperacion>

    <FechaOperacion Fecha="2026-03-16"> <!-- Lunes -->
        <MarcaAsistencia ValorDocumentoIdentidad="110011001"
            HoraEntrada="2026-03-16 14:00" HoraSalida="2026-03-16 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="194739285"
            HoraEntrada="2026-03-16 06:00" HoraSalida="2026-03-16 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="222333444"
            HoraEntrada="2026-03-16 14:00" HoraSalida="2026-03-16 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="333444555"
            HoraEntrada="2026-03-16 22:00" HoraSalida="2026-03-17 08:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="444555666"
            HoraEntrada="2026-03-16 06:00" HoraSalida="2026-03-16 16:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="555666777"
            HoraEntrada="2026-03-16 14:00" HoraSalida="2026-03-16 22:00"/>
    </FechaOperacion>

    <FechaOperacion Fecha="2026-03-17"> <!-- Martes -->
        <MarcaAsistencia ValorDocumentoIdentidad="110011001"
            HoraEntrada="2026-03-17 14:00" HoraSalida="2026-03-18 00:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="305827920"
            HoraEntrada="2026-03-17 22:00" HoraSalida="2026-03-18 08:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="222333444"
            HoraEntrada="2026-03-17 14:00" HoraSalida="2026-03-18 00:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="333444555"
            HoraEntrada="2026-03-17 22:00" HoraSalida="2026-03-18 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="444555666"
            HoraEntrada="2026-03-17 06:00" HoraSalida="2026-03-17 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="555666777"
            HoraEntrada="2026-03-17 14:00" HoraSalida="2026-03-17 22:00"/>
    </FechaOperacion>

    <FechaOperacion Fecha="2026-03-18"> <!-- Miercoles -->
        <MarcaAsistencia ValorDocumentoIdentidad="110011001"
            HoraEntrada="2026-03-18 14:00" HoraSalida="2026-03-18 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="305827920"
            HoraEntrada="2026-03-18 22:00" HoraSalida="2026-03-19 08:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="194739285"
            HoraEntrada="2026-03-18 06:00" HoraSalida="2026-03-18 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="333444555"
            HoraEntrada="2026-03-18 22:00" HoraSalida="2026-03-19 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="444555666"
            HoraEntrada="2026-03-18 06:00" HoraSalida="2026-03-18 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="555666777"
            HoraEntrada="2026-03-18 14:00" HoraSalida="2026-03-18 22:00"/>
    </FechaOperacion>

    <FechaOperacion Fecha="2026-03-19"> <!-- Jueves -->
        <MarcaAsistencia ValorDocumentoIdentidad="110011001"
            HoraEntrada="2026-03-19 14:00" HoraSalida="2026-03-20 00:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="305827920"
            HoraEntrada="2026-03-19 22:00" HoraSalida="2026-03-20 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="194739285"
            HoraEntrada="2026-03-19 06:00" HoraSalida="2026-03-19 16:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="222333444"
            HoraEntrada="2026-03-19 14:00" HoraSalida="2026-03-19 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="444555666"
            HoraEntrada="2026-03-19 06:00" HoraSalida="2026-03-19 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="555666777"
            HoraEntrada="2026-03-19 14:00" HoraSalida="2026-03-19 22:00"/>
        
        <!-- Cierre semana 2: jornada semana 3 (InicioSemana 2026-03-20) -->
        <AsignarJornada ValorDocumentoIdentidad="110011001"
            Jornada="Nocturno" InicioSemana="2026-03-20"/>
        <AsignarJornada ValorDocumentoIdentidad="305827920"
            Jornada="Diurno" InicioSemana="2026-03-20"/>
        <AsignarJornada ValorDocumentoIdentidad="194739285"
            Jornada="Vespertino" InicioSemana="2026-03-20"/>
        <AsignarJornada ValorDocumentoIdentidad="222333444"
            Jornada="Nocturno" InicioSemana="2026-03-20"/>
        <AsignarJornada ValorDocumentoIdentidad="333444555"
            Jornada="Diurno" InicioSemana="2026-03-20"/>
        <AsignarJornada ValorDocumentoIdentidad="444555666"
            Jornada="Vespertino" InicioSemana="2026-03-20"/>
        <AsignarJornada ValorDocumentoIdentidad="555666777"
            Jornada="Nocturno" InicioSemana="2026-03-20"/>
        <AsociaEmpleadoConDeduccion ValorDocumentoIdentidad="110011001"
            TipoDeduccion="Ahorro Vacacional" MontoFijo="15000.00"/>
    </FechaOperacion>

    <FechaOperacion Fecha="2026-03-20"> <!-- Viernes -->
        <MarcaAsistencia ValorDocumentoIdentidad="110011001"
            HoraEntrada="2026-03-20 22:00" HoraSalida="2026-03-21 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="305827920"
            HoraEntrada="2026-03-20 06:00" HoraSalida="2026-03-20 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="194739285"
            HoraEntrada="2026-03-20 14:00" HoraSalida="2026-03-20 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="222333444"
            HoraEntrada="2026-03-20 22:00" HoraSalida="2026-03-21 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="333444555"
            HoraEntrada="2026-03-20 06:00" HoraSalida="2026-03-20 16:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="555666777"
            HoraEntrada="2026-03-20 22:00" HoraSalida="2026-03-21 08:00"/>
    </FechaOperacion>

    <FechaOperacion Fecha="2026-03-21"> <!-- Sabado -->
        <MarcaAsistencia ValorDocumentoIdentidad="110011001"
            HoraEntrada="2026-03-21 22:00" HoraSalida="2026-03-22 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="305827920"
            HoraEntrada="2026-03-21 06:00" HoraSalida="2026-03-21 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="194739285"
            HoraEntrada="2026-03-21 14:00" HoraSalida="2026-03-22 00:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="222333444"
            HoraEntrada="2026-03-21 22:00" HoraSalida="2026-03-22 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="333444555"
            HoraEntrada="2026-03-21 06:00" HoraSalida="2026-03-21 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="444555666"
            HoraEntrada="2026-03-21 14:00" HoraSalida="2026-03-21 22:00"/>
    </FechaOperacion>

    <FechaOperacion Fecha="2026-03-22"> <!-- Domingo -->
        <MarcaAsistencia ValorDocumentoIdentidad="305827920"
            HoraEntrada="2026-03-22 06:00" HoraSalida="2026-03-22 17:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="194739285"
            HoraEntrada="2026-03-22 14:00" HoraSalida="2026-03-23 01:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="222333444"
            HoraEntrada="2026-03-22 22:00" HoraSalida="2026-03-23 08:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="333444555"
            HoraEntrada="2026-03-22 06:00" HoraSalida="2026-03-22 17:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="444555666"
            HoraEntrada="2026-03-22 14:00" HoraSalida="2026-03-23 01:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="555666777"
            HoraEntrada="2026-03-22 22:00" HoraSalida="2026-03-23 08:30"/>
    </FechaOperacion>

    <FechaOperacion Fecha="2026-03-23"> <!-- Lunes -->
        <MarcaAsistencia ValorDocumentoIdentidad="110011001"
            HoraEntrada="2026-03-23 22:00" HoraSalida="2026-03-24 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="194739285"
            HoraEntrada="2026-03-23 14:00" HoraSalida="2026-03-23 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="222333444"
            HoraEntrada="2026-03-23 22:00" HoraSalida="2026-03-24 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="333444555"
            HoraEntrada="2026-03-23 06:00" HoraSalida="2026-03-23 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="444555666"
            HoraEntrada="2026-03-23 14:00" HoraSalida="2026-03-23 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="555666777"
            HoraEntrada="2026-03-23 22:00" HoraSalida="2026-03-24 08:00"/>
    </FechaOperacion>

    <FechaOperacion Fecha="2026-03-24"> <!-- Martes -->
        <MarcaAsistencia ValorDocumentoIdentidad="110011001"
            HoraEntrada="2026-03-24 22:00" HoraSalida="2026-03-25 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="305827920"
            HoraEntrada="2026-03-24 06:00" HoraSalida="2026-03-24 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="222333444"
            HoraEntrada="2026-03-24 22:00" HoraSalida="2026-03-25 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="333444555"
            HoraEntrada="2026-03-24 06:00" HoraSalida="2026-03-24 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="444555666"
            HoraEntrada="2026-03-24 14:00" HoraSalida="2026-03-24 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="555666777"
            HoraEntrada="2026-03-24 22:00" HoraSalida="2026-03-25 08:00"/>
    </FechaOperacion>

    <FechaOperacion Fecha="2026-03-25"> <!-- Miercoles -->
        <MarcaAsistencia ValorDocumentoIdentidad="110011001"
            HoraEntrada="2026-03-25 22:00" HoraSalida="2026-03-26 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="305827920"
            HoraEntrada="2026-03-25 06:00" HoraSalida="2026-03-25 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="194739285"
            HoraEntrada="2026-03-25 14:00" HoraSalida="2026-03-26 00:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="333444555"
            HoraEntrada="2026-03-25 06:00" HoraSalida="2026-03-25 16:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="444555666"
            HoraEntrada="2026-03-25 14:00" HoraSalida="2026-03-26 00:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="555666777"
            HoraEntrada="2026-03-25 22:00" HoraSalida="2026-03-26 06:00"/>
    </FechaOperacion>

    <FechaOperacion Fecha="2026-03-26"> <!-- Jueves -->
        <MarcaAsistencia ValorDocumentoIdentidad="110011001"
            HoraEntrada="2026-03-26 22:00" HoraSalida="2026-03-27 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="305827920"
            HoraEntrada="2026-03-26 06:00" HoraSalida="2026-03-26 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="194739285"
            HoraEntrada="2026-03-26 14:00" HoraSalida="2026-03-27 00:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="222333444"
            HoraEntrada="2026-03-26 22:00" HoraSalida="2026-03-27 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="444555666"
            HoraEntrada="2026-03-26 14:00" HoraSalida="2026-03-26 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="555666777"
            HoraEntrada="2026-03-26 22:00" HoraSalida="2026-03-27 06:00"/>
        
        <!-- Nuevos empleados: inician semana 2026-03-27 -->
        <InsertarEmpleado ValorDocumentoIdentidad="666777888" Nombre="Gabriela Leon"
            Puesto="Cajero" CuentaBancaria="CR2415115201901026111005"
            Username="Leogab" Password="Gaby654" TipoUsuario="0" FechaContratacion="2026-03-27"/>
        
        <!-- Eliminar empleado: termina semana 2026-03-27 -->
        <EliminarEmpleado ValorDocumentoIdentidad="305827920"/>
        
        <!-- Cierre semana 3: jornada semana 4 (InicioSemana 2026-03-27) -->
        <AsignarJornada ValorDocumentoIdentidad="110011001"
            Jornada="Diurno" InicioSemana="2026-03-27"/>
        <AsignarJornada ValorDocumentoIdentidad="305827920"
            Jornada="Vespertino" InicioSemana="2026-03-27"/>
        <AsignarJornada ValorDocumentoIdentidad="194739285"
            Jornada="Nocturno" InicioSemana="2026-03-27"/>
        <AsignarJornada ValorDocumentoIdentidad="222333444"
            Jornada="Diurno" InicioSemana="2026-03-27"/>
        <AsignarJornada ValorDocumentoIdentidad="333444555"
            Jornada="Vespertino" InicioSemana="2026-03-27"/>
        <AsignarJornada ValorDocumentoIdentidad="444555666"
            Jornada="Nocturno" InicioSemana="2026-03-27"/>
        <AsignarJornada ValorDocumentoIdentidad="555666777"
            Jornada="Diurno" InicioSemana="2026-03-27"/>
        <AsignarJornada ValorDocumentoIdentidad="666777888"
            Jornada="Vespertino" InicioSemana="2026-03-27"/>
        <AsociaEmpleadoConDeduccion ValorDocumentoIdentidad="194739285"
            TipoDeduccion="Ahorro Asociacion Solidarista" MontoFijo="0.00"/>
        <AsociaEmpleadoConDeduccion ValorDocumentoIdentidad="666777888"
            TipoDeduccion="Ahorro Vacacional" MontoFijo="18000.00"/>
        <DesasociaEmpleadoConDeduccion ValorDocumentoIdentidad="194739285"
            TipoDeduccion="Pension Alimenticia"/>
    </FechaOperacion>

    <FechaOperacion Fecha="2026-03-27"> <!-- Viernes -->
        <MarcaAsistencia ValorDocumentoIdentidad="110011001"
            HoraEntrada="2026-03-27 06:00" HoraSalida="2026-03-27 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="194739285"
            HoraEntrada="2026-03-27 22:00" HoraSalida="2026-03-28 08:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="222333444"
            HoraEntrada="2026-03-27 06:00" HoraSalida="2026-03-27 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="333444555"
            HoraEntrada="2026-03-27 14:00" HoraSalida="2026-03-27 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="555666777"
            HoraEntrada="2026-03-27 06:00" HoraSalida="2026-03-27 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="666777888"
            HoraEntrada="2026-03-27 14:00" HoraSalida="2026-03-27 22:00"/>
    </FechaOperacion>

    <FechaOperacion Fecha="2026-03-28"> <!-- Sabado -->
        <MarcaAsistencia ValorDocumentoIdentidad="110011001"
            HoraEntrada="2026-03-28 06:00" HoraSalida="2026-03-28 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="194739285"
            HoraEntrada="2026-03-28 22:00" HoraSalida="2026-03-29 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="222333444"
            HoraEntrada="2026-03-28 06:00" HoraSalida="2026-03-28 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="333444555"
            HoraEntrada="2026-03-28 14:00" HoraSalida="2026-03-28 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="444555666"
            HoraEntrada="2026-03-28 22:00" HoraSalida="2026-03-29 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="666777888"
            HoraEntrada="2026-03-28 14:00" HoraSalida="2026-03-28 22:00"/>
    </FechaOperacion>

    <FechaOperacion Fecha="2026-03-29"> <!-- Domingo -->
        <MarcaAsistencia ValorDocumentoIdentidad="194739285"
            HoraEntrada="2026-03-29 22:00" HoraSalida="2026-03-30 08:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="222333444"
            HoraEntrada="2026-03-29 06:00" HoraSalida="2026-03-29 17:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="333444555"
            HoraEntrada="2026-03-29 14:00" HoraSalida="2026-03-30 01:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="444555666"
            HoraEntrada="2026-03-29 22:00" HoraSalida="2026-03-30 08:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="555666777"
            HoraEntrada="2026-03-29 06:00" HoraSalida="2026-03-29 17:00"/>
    </FechaOperacion>

    <FechaOperacion Fecha="2026-03-30"> <!-- Lunes -->
        <MarcaAsistencia ValorDocumentoIdentidad="110011001"
            HoraEntrada="2026-03-30 06:00" HoraSalida="2026-03-30 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="194739285"
            HoraEntrada="2026-03-30 22:00" HoraSalida="2026-03-31 08:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="222333444"
            HoraEntrada="2026-03-30 06:00" HoraSalida="2026-03-30 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="333444555"
            HoraEntrada="2026-03-30 14:00" HoraSalida="2026-03-30 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="444555666"
            HoraEntrada="2026-03-30 22:00" HoraSalida="2026-03-31 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="555666777"
            HoraEntrada="2026-03-30 06:00" HoraSalida="2026-03-30 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="666777888"
            HoraEntrada="2026-03-30 14:00" HoraSalida="2026-03-30 22:00"/>
    </FechaOperacion>

    <FechaOperacion Fecha="2026-03-31"> <!-- Martes -->
        <MarcaAsistencia ValorDocumentoIdentidad="110011001"
            HoraEntrada="2026-03-31 06:00" HoraSalida="2026-03-31 16:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="222333444"
            HoraEntrada="2026-03-31 06:00" HoraSalida="2026-03-31 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="333444555"
            HoraEntrada="2026-03-31 14:00" HoraSalida="2026-03-31 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="444555666"
            HoraEntrada="2026-03-31 22:00" HoraSalida="2026-04-01 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="555666777"
            HoraEntrada="2026-03-31 06:00" HoraSalida="2026-03-31 16:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="666777888"
            HoraEntrada="2026-03-31 14:00" HoraSalida="2026-03-31 22:00"/>
    </FechaOperacion>

    <FechaOperacion Fecha="2026-04-01"> <!-- Miercoles -->
        <MarcaAsistencia ValorDocumentoIdentidad="110011001"
            HoraEntrada="2026-04-01 06:00" HoraSalida="2026-04-01 16:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="194739285"
            HoraEntrada="2026-04-01 22:00" HoraSalida="2026-04-02 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="333444555"
            HoraEntrada="2026-04-01 14:00" HoraSalida="2026-04-01 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="444555666"
            HoraEntrada="2026-04-01 22:00" HoraSalida="2026-04-02 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="555666777"
            HoraEntrada="2026-04-01 06:00" HoraSalida="2026-04-01 16:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="666777888"
            HoraEntrada="2026-04-01 14:00" HoraSalida="2026-04-01 22:00"/>
    </FechaOperacion>

    <FechaOperacion Fecha="2026-04-02">
        
        <!-- FERIADO: Jueves Santo -->
        <MarcaAsistencia ValorDocumentoIdentidad="110011001"
            HoraEntrada="2026-04-02 06:00" HoraSalida="2026-04-02 17:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="194739285"
            HoraEntrada="2026-04-02 22:00" HoraSalida="2026-04-03 08:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="222333444"
            HoraEntrada="2026-04-02 06:00" HoraSalida="2026-04-02 17:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="444555666"
            HoraEntrada="2026-04-02 22:00" HoraSalida="2026-04-03 08:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="555666777"
            HoraEntrada="2026-04-02 06:00" HoraSalida="2026-04-02 17:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="666777888"
            HoraEntrada="2026-04-02 14:00" HoraSalida="2026-04-03 01:00"/>
        
        <!-- Cierre semana 4: jornada semana 5 (InicioSemana 2026-04-03) -->
        <AsignarJornada ValorDocumentoIdentidad="110011001"
            Jornada="Vespertino" InicioSemana="2026-04-03"/>
        <AsignarJornada ValorDocumentoIdentidad="194739285"
            Jornada="Diurno" InicioSemana="2026-04-03"/>
        <AsignarJornada ValorDocumentoIdentidad="222333444"
            Jornada="Vespertino" InicioSemana="2026-04-03"/>
        <AsignarJornada ValorDocumentoIdentidad="333444555"
            Jornada="Nocturno" InicioSemana="2026-04-03"/>
        <AsignarJornada ValorDocumentoIdentidad="444555666"
            Jornada="Diurno" InicioSemana="2026-04-03"/>
        <AsignarJornada ValorDocumentoIdentidad="555666777"
            Jornada="Vespertino" InicioSemana="2026-04-03"/>
        <AsignarJornada ValorDocumentoIdentidad="666777888"
            Jornada="Nocturno" InicioSemana="2026-04-03"/>
    </FechaOperacion>

    <FechaOperacion Fecha="2026-04-03">
        
        <!-- FERIADO: Viernes Santo -->
        <MarcaAsistencia ValorDocumentoIdentidad="110011001"
            HoraEntrada="2026-04-03 14:00" HoraSalida="2026-04-04 01:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="194739285"
            HoraEntrada="2026-04-03 06:00" HoraSalida="2026-04-03 17:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="222333444"
            HoraEntrada="2026-04-03 14:00" HoraSalida="2026-04-04 01:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="333444555"
            HoraEntrada="2026-04-03 22:00" HoraSalida="2026-04-04 08:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="555666777"
            HoraEntrada="2026-04-03 14:00" HoraSalida="2026-04-04 01:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="666777888"
            HoraEntrada="2026-04-03 22:00" HoraSalida="2026-04-04 08:30"/>
    </FechaOperacion>

    <FechaOperacion Fecha="2026-04-04"> <!-- Sabado -->
        <MarcaAsistencia ValorDocumentoIdentidad="110011001"
            HoraEntrada="2026-04-04 14:00" HoraSalida="2026-04-04 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="194739285"
            HoraEntrada="2026-04-04 06:00" HoraSalida="2026-04-04 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="222333444"
            HoraEntrada="2026-04-04 14:00" HoraSalida="2026-04-05 00:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="333444555"
            HoraEntrada="2026-04-04 22:00" HoraSalida="2026-04-05 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="444555666"
            HoraEntrada="2026-04-04 06:00" HoraSalida="2026-04-04 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="666777888"
            HoraEntrada="2026-04-04 22:00" HoraSalida="2026-04-05 08:00"/>
    </FechaOperacion>

    <FechaOperacion Fecha="2026-04-05"> <!-- Domingo -->
        <MarcaAsistencia ValorDocumentoIdentidad="194739285"
            HoraEntrada="2026-04-05 06:00" HoraSalida="2026-04-05 17:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="222333444"
            HoraEntrada="2026-04-05 14:00" HoraSalida="2026-04-06 01:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="333444555"
            HoraEntrada="2026-04-05 22:00" HoraSalida="2026-04-06 08:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="444555666"
            HoraEntrada="2026-04-05 06:00" HoraSalida="2026-04-05 17:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="555666777"
            HoraEntrada="2026-04-05 14:00" HoraSalida="2026-04-06 01:00"/>
    </FechaOperacion>

    <FechaOperacion Fecha="2026-04-06"> <!-- Lunes -->
        <MarcaAsistencia ValorDocumentoIdentidad="110011001"
            HoraEntrada="2026-04-06 14:00" HoraSalida="2026-04-06 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="194739285"
            HoraEntrada="2026-04-06 06:00" HoraSalida="2026-04-06 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="222333444"
            HoraEntrada="2026-04-06 14:00" HoraSalida="2026-04-06 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="333444555"
            HoraEntrada="2026-04-06 22:00" HoraSalida="2026-04-07 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="444555666"
            HoraEntrada="2026-04-06 06:00" HoraSalida="2026-04-06 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="555666777"
            HoraEntrada="2026-04-06 14:00" HoraSalida="2026-04-07 00:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="666777888"
            HoraEntrada="2026-04-06 22:00" HoraSalida="2026-04-07 06:00"/>
    </FechaOperacion>

    <FechaOperacion Fecha="2026-04-07"> <!-- Martes -->
        <MarcaAsistencia ValorDocumentoIdentidad="110011001"
            HoraEntrada="2026-04-07 14:00" HoraSalida="2026-04-07 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="222333444"
            HoraEntrada="2026-04-07 14:00" HoraSalida="2026-04-07 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="333444555"
            HoraEntrada="2026-04-07 22:00" HoraSalida="2026-04-08 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="444555666"
            HoraEntrada="2026-04-07 06:00" HoraSalida="2026-04-07 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="555666777"
            HoraEntrada="2026-04-07 14:00" HoraSalida="2026-04-07 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="666777888"
            HoraEntrada="2026-04-07 22:00" HoraSalida="2026-04-08 06:00"/>
    </FechaOperacion>

    <FechaOperacion Fecha="2026-04-08"> <!-- Miercoles -->
        <MarcaAsistencia ValorDocumentoIdentidad="110011001"
            HoraEntrada="2026-04-08 14:00" HoraSalida="2026-04-09 00:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="194739285"
            HoraEntrada="2026-04-08 06:00" HoraSalida="2026-04-08 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="333444555"
            HoraEntrada="2026-04-08 22:00" HoraSalida="2026-04-09 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="444555666"
            HoraEntrada="2026-04-08 06:00" HoraSalida="2026-04-08 16:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="555666777"
            HoraEntrada="2026-04-08 14:00" HoraSalida="2026-04-09 00:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="666777888"
            HoraEntrada="2026-04-08 22:00" HoraSalida="2026-04-09 08:00"/>
    </FechaOperacion>

    <FechaOperacion Fecha="2026-04-09"> <!-- Jueves -->
        <MarcaAsistencia ValorDocumentoIdentidad="110011001"
            HoraEntrada="2026-04-09 14:00" HoraSalida="2026-04-09 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="194739285"
            HoraEntrada="2026-04-09 06:00" HoraSalida="2026-04-09 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="222333444"
            HoraEntrada="2026-04-09 14:00" HoraSalida="2026-04-09 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="444555666"
            HoraEntrada="2026-04-09 06:00" HoraSalida="2026-04-09 16:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="555666777"
            HoraEntrada="2026-04-09 14:00" HoraSalida="2026-04-10 00:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="666777888"
            HoraEntrada="2026-04-09 22:00" HoraSalida="2026-04-10 06:00"/>
        
        <!-- Nuevos empleados: inician semana 2026-04-10 -->
        <InsertarEmpleado ValorDocumentoIdentidad="777888999" Nombre="Mario Quesada"
            Puesto="Conductor" CuentaBancaria="CR2415115201901026111006"
            Username="Quesmar" Password="Mario987" TipoUsuario="0" FechaContratacion="2026-04-10"/>
        <InsertarEmpleado ValorDocumentoIdentidad="888999000" Nombre="Diego Solano"
            Puesto="Asistente" CuentaBancaria="CR2415115201901026111007"
            Username="Soldieg" Password="Diego111" TipoUsuario="0" FechaContratacion="2026-04-10"/>
        
        <!-- Eliminar empleado: termina semana 2026-04-10 -->
        <EliminarEmpleado ValorDocumentoIdentidad="555666777"/>
        
        <!-- Cierre semana 5: jornada semana 6 (InicioSemana 2026-04-10) -->
        <AsignarJornada ValorDocumentoIdentidad="110011001"
            Jornada="Nocturno" InicioSemana="2026-04-10"/>
        <AsignarJornada ValorDocumentoIdentidad="194739285"
            Jornada="Vespertino" InicioSemana="2026-04-10"/>
        <AsignarJornada ValorDocumentoIdentidad="222333444"
            Jornada="Nocturno" InicioSemana="2026-04-10"/>
        <AsignarJornada ValorDocumentoIdentidad="333444555"
            Jornada="Diurno" InicioSemana="2026-04-10"/>
        <AsignarJornada ValorDocumentoIdentidad="444555666"
            Jornada="Vespertino" InicioSemana="2026-04-10"/>
        <AsignarJornada ValorDocumentoIdentidad="555666777"
            Jornada="Nocturno" InicioSemana="2026-04-10"/>
        <AsignarJornada ValorDocumentoIdentidad="666777888"
            Jornada="Diurno" InicioSemana="2026-04-10"/>
        <AsignarJornada ValorDocumentoIdentidad="777888999"
            Jornada="Vespertino" InicioSemana="2026-04-10"/>
        <AsignarJornada ValorDocumentoIdentidad="888999000"
            Jornada="Nocturno" InicioSemana="2026-04-10"/>
        <AsociaEmpleadoConDeduccion ValorDocumentoIdentidad="777888999"
            TipoDeduccion="Ahorro Asociacion Solidarista" MontoFijo="0.00"/>
        <AsociaEmpleadoConDeduccion ValorDocumentoIdentidad="888999000"
            TipoDeduccion="Ahorro Vacacional" MontoFijo="12000.00"/>
        <DesasociaEmpleadoConDeduccion ValorDocumentoIdentidad="110011001"
            TipoDeduccion="Ahorro Asociacion Solidarista"/>
    </FechaOperacion>

    <FechaOperacion Fecha="2026-04-10"> <!-- Viernes -->
        <MarcaAsistencia ValorDocumentoIdentidad="110011001"
            HoraEntrada="2026-04-10 22:00" HoraSalida="2026-04-11 08:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="194739285"
            HoraEntrada="2026-04-10 14:00" HoraSalida="2026-04-10 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="222333444"
            HoraEntrada="2026-04-10 22:00" HoraSalida="2026-04-11 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="333444555"
            HoraEntrada="2026-04-10 06:00" HoraSalida="2026-04-10 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="666777888"
            HoraEntrada="2026-04-10 06:00" HoraSalida="2026-04-10 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="777888999"
            HoraEntrada="2026-04-10 14:00" HoraSalida="2026-04-11 00:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="888999000"
            HoraEntrada="2026-04-10 22:00" HoraSalida="2026-04-11 08:00"/>
    </FechaOperacion>

    <FechaOperacion Fecha="2026-04-11">
        
        <!-- FERIADO: Batalla de Rivas -->
        <MarcaAsistencia ValorDocumentoIdentidad="110011001"
            HoraEntrada="2026-04-11 22:00" HoraSalida="2026-04-12 08:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="194739285"
            HoraEntrada="2026-04-11 14:00" HoraSalida="2026-04-12 01:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="222333444"
            HoraEntrada="2026-04-11 22:00" HoraSalida="2026-04-12 08:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="333444555"
            HoraEntrada="2026-04-11 06:00" HoraSalida="2026-04-11 17:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="444555666"
            HoraEntrada="2026-04-11 14:00" HoraSalida="2026-04-12 01:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="666777888"
            HoraEntrada="2026-04-11 06:00" HoraSalida="2026-04-11 17:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="777888999"
            HoraEntrada="2026-04-11 14:00" HoraSalida="2026-04-12 01:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="888999000"
            HoraEntrada="2026-04-11 22:00" HoraSalida="2026-04-12 08:30"/>
    </FechaOperacion>

    <FechaOperacion Fecha="2026-04-12"> <!-- Domingo -->
        <MarcaAsistencia ValorDocumentoIdentidad="194739285"
            HoraEntrada="2026-04-12 14:00" HoraSalida="2026-04-13 01:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="222333444"
            HoraEntrada="2026-04-12 22:00" HoraSalida="2026-04-13 08:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="333444555"
            HoraEntrada="2026-04-12 06:00" HoraSalida="2026-04-12 17:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="444555666"
            HoraEntrada="2026-04-12 14:00" HoraSalida="2026-04-13 01:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="777888999"
            HoraEntrada="2026-04-12 14:00" HoraSalida="2026-04-13 01:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="888999000"
            HoraEntrada="2026-04-12 22:00" HoraSalida="2026-04-13 08:30"/>
    </FechaOperacion>

    <FechaOperacion Fecha="2026-04-13"> <!-- Lunes -->
        <MarcaAsistencia ValorDocumentoIdentidad="110011001"
            HoraEntrada="2026-04-13 22:00" HoraSalida="2026-04-14 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="194739285"
            HoraEntrada="2026-04-13 14:00" HoraSalida="2026-04-13 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="222333444"
            HoraEntrada="2026-04-13 22:00" HoraSalida="2026-04-14 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="333444555"
            HoraEntrada="2026-04-13 06:00" HoraSalida="2026-04-13 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="444555666"
            HoraEntrada="2026-04-13 14:00" HoraSalida="2026-04-13 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="666777888"
            HoraEntrada="2026-04-13 06:00" HoraSalida="2026-04-13 16:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="888999000"
            HoraEntrada="2026-04-13 22:00" HoraSalida="2026-04-14 06:00"/>
    </FechaOperacion>

    <FechaOperacion Fecha="2026-04-14"> <!-- Martes -->
        <MarcaAsistencia ValorDocumentoIdentidad="110011001"
            HoraEntrada="2026-04-14 22:00" HoraSalida="2026-04-15 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="222333444"
            HoraEntrada="2026-04-14 22:00" HoraSalida="2026-04-15 08:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="333444555"
            HoraEntrada="2026-04-14 06:00" HoraSalida="2026-04-14 16:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="444555666"
            HoraEntrada="2026-04-14 14:00" HoraSalida="2026-04-14 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="666777888"
            HoraEntrada="2026-04-14 06:00" HoraSalida="2026-04-14 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="777888999"
            HoraEntrada="2026-04-14 14:00" HoraSalida="2026-04-15 00:30"/>
    </FechaOperacion>

    <FechaOperacion Fecha="2026-04-15"> <!-- Miercoles -->
        <MarcaAsistencia ValorDocumentoIdentidad="110011001"
            HoraEntrada="2026-04-15 22:00" HoraSalida="2026-04-16 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="194739285"
            HoraEntrada="2026-04-15 14:00" HoraSalida="2026-04-15 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="333444555"
            HoraEntrada="2026-04-15 06:00" HoraSalida="2026-04-15 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="444555666"
            HoraEntrada="2026-04-15 14:00" HoraSalida="2026-04-16 00:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="666777888"
            HoraEntrada="2026-04-15 06:00" HoraSalida="2026-04-15 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="777888999"
            HoraEntrada="2026-04-15 14:00" HoraSalida="2026-04-15 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="888999000"
            HoraEntrada="2026-04-15 22:00" HoraSalida="2026-04-16 06:00"/>
    </FechaOperacion>

    <FechaOperacion Fecha="2026-04-16"> <!-- Jueves -->
        <MarcaAsistencia ValorDocumentoIdentidad="110011001"
            HoraEntrada="2026-04-16 22:00" HoraSalida="2026-04-17 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="194739285"
            HoraEntrada="2026-04-16 14:00" HoraSalida="2026-04-16 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="222333444"
            HoraEntrada="2026-04-16 22:00" HoraSalida="2026-04-17 08:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="444555666"
            HoraEntrada="2026-04-16 14:00" HoraSalida="2026-04-16 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="666777888"
            HoraEntrada="2026-04-16 06:00" HoraSalida="2026-04-16 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="777888999"
            HoraEntrada="2026-04-16 14:00" HoraSalida="2026-04-16 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="888999000"
            HoraEntrada="2026-04-16 22:00" HoraSalida="2026-04-17 06:00"/>
        
        <!-- Eliminar empleado: termina semana 2026-03-27 -->
        <EliminarEmpleado ValorDocumentoIdentidad="777888999"/>
        
        <!-- Cierre semana 6: jornada semana 7 (InicioSemana 2026-04-17) -->
        <AsignarJornada ValorDocumentoIdentidad="110011001"
            Jornada="Diurno" InicioSemana="2026-04-17"/>
        <AsignarJornada ValorDocumentoIdentidad="194739285"
            Jornada="Nocturno" InicioSemana="2026-04-17"/>
        <AsignarJornada ValorDocumentoIdentidad="222333444"
            Jornada="Diurno" InicioSemana="2026-04-17"/>
        <AsignarJornada ValorDocumentoIdentidad="333444555"
            Jornada="Vespertino" InicioSemana="2026-04-17"/>
        <AsignarJornada ValorDocumentoIdentidad="444555666"
            Jornada="Nocturno" InicioSemana="2026-04-17"/>
        <AsignarJornada ValorDocumentoIdentidad="666777888"
            Jornada="Vespertino" InicioSemana="2026-04-17"/>
        <AsignarJornada ValorDocumentoIdentidad="777888999"
            Jornada="Nocturno" InicioSemana="2026-04-17"/>
        <AsignarJornada ValorDocumentoIdentidad="888999000"
            Jornada="Diurno" InicioSemana="2026-04-17"/>
        <AsociaEmpleadoConDeduccion ValorDocumentoIdentidad="222333444"
            TipoDeduccion="Pension Alimenticia" MontoFijo="40000.00"/>
    </FechaOperacion>

    <FechaOperacion Fecha="2026-04-17"> <!-- Viernes -->
        <MarcaAsistencia ValorDocumentoIdentidad="110011001"
            HoraEntrada="2026-04-17 06:00" HoraSalida="2026-04-17 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="194739285"
            HoraEntrada="2026-04-17 22:00" HoraSalida="2026-04-18 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="222333444"
            HoraEntrada="2026-04-17 06:00" HoraSalida="2026-04-17 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="333444555"
            HoraEntrada="2026-04-17 14:00" HoraSalida="2026-04-17 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="666777888"
            HoraEntrada="2026-04-17 14:00" HoraSalida="2026-04-17 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="888999000"
            HoraEntrada="2026-04-17 06:00" HoraSalida="2026-04-17 14:00"/>
    </FechaOperacion>

    <FechaOperacion Fecha="2026-04-18"> <!-- Sabado -->
        <MarcaAsistencia ValorDocumentoIdentidad="110011001"
            HoraEntrada="2026-04-18 06:00" HoraSalida="2026-04-18 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="194739285"
            HoraEntrada="2026-04-18 22:00" HoraSalida="2026-04-19 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="222333444"
            HoraEntrada="2026-04-18 06:00" HoraSalida="2026-04-18 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="333444555"
            HoraEntrada="2026-04-18 14:00" HoraSalida="2026-04-19 00:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="444555666"
            HoraEntrada="2026-04-18 22:00" HoraSalida="2026-04-19 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="666777888"
            HoraEntrada="2026-04-18 14:00" HoraSalida="2026-04-18 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="888999000"
            HoraEntrada="2026-04-18 06:00" HoraSalida="2026-04-18 16:30"/>
    </FechaOperacion>

    <FechaOperacion Fecha="2026-04-19"> <!-- Domingo -->
        <MarcaAsistencia ValorDocumentoIdentidad="194739285"
            HoraEntrada="2026-04-19 22:00" HoraSalida="2026-04-20 08:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="222333444"
            HoraEntrada="2026-04-19 06:00" HoraSalida="2026-04-19 17:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="333444555"
            HoraEntrada="2026-04-19 14:00" HoraSalida="2026-04-20 01:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="444555666"
            HoraEntrada="2026-04-19 22:00" HoraSalida="2026-04-20 08:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="888999000"
            HoraEntrada="2026-04-19 06:00" HoraSalida="2026-04-19 17:00"/>
    </FechaOperacion>

    <FechaOperacion Fecha="2026-04-20"> <!-- Lunes -->
        <MarcaAsistencia ValorDocumentoIdentidad="110011001"
            HoraEntrada="2026-04-20 06:00" HoraSalida="2026-04-20 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="194739285"
            HoraEntrada="2026-04-20 22:00" HoraSalida="2026-04-21 08:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="222333444"
            HoraEntrada="2026-04-20 06:00" HoraSalida="2026-04-20 16:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="333444555"
            HoraEntrada="2026-04-20 14:00" HoraSalida="2026-04-20 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="444555666"
            HoraEntrada="2026-04-20 22:00" HoraSalida="2026-04-21 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="666777888"
            HoraEntrada="2026-04-20 14:00" HoraSalida="2026-04-21 00:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="888999000"
            HoraEntrada="2026-04-20 06:00" HoraSalida="2026-04-20 14:00"/>
    </FechaOperacion>

    <FechaOperacion Fecha="2026-04-21"> <!-- Martes -->
        <MarcaAsistencia ValorDocumentoIdentidad="110011001"
            HoraEntrada="2026-04-21 06:00" HoraSalida="2026-04-21 16:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="222333444"
            HoraEntrada="2026-04-21 06:00" HoraSalida="2026-04-21 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="333444555"
            HoraEntrada="2026-04-21 14:00" HoraSalida="2026-04-21 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="444555666"
            HoraEntrada="2026-04-21 22:00" HoraSalida="2026-04-22 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="666777888"
            HoraEntrada="2026-04-21 14:00" HoraSalida="2026-04-21 22:00"/>
    </FechaOperacion>

    <FechaOperacion Fecha="2026-04-22"> <!-- Miercoles -->
        <MarcaAsistencia ValorDocumentoIdentidad="110011001"
            HoraEntrada="2026-04-22 06:00" HoraSalida="2026-04-22 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="194739285"
            HoraEntrada="2026-04-22 22:00" HoraSalida="2026-04-23 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="333444555"
            HoraEntrada="2026-04-22 14:00" HoraSalida="2026-04-22 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="444555666"
            HoraEntrada="2026-04-22 22:00" HoraSalida="2026-04-23 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="666777888"
            HoraEntrada="2026-04-22 14:00" HoraSalida="2026-04-22 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="888999000"
            HoraEntrada="2026-04-22 06:00" HoraSalida="2026-04-22 14:00"/>
    </FechaOperacion>

    <FechaOperacion Fecha="2026-04-23"> <!-- Jueves -->
        <MarcaAsistencia ValorDocumentoIdentidad="110011001"
            HoraEntrada="2026-04-23 06:00" HoraSalida="2026-04-23 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="194739285"
            HoraEntrada="2026-04-23 22:00" HoraSalida="2026-04-24 08:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="222333444"
            HoraEntrada="2026-04-23 06:00" HoraSalida="2026-04-23 16:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="444555666"
            HoraEntrada="2026-04-23 22:00" HoraSalida="2026-04-24 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="666777888"
            HoraEntrada="2026-04-23 14:00" HoraSalida="2026-04-23 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="888999000"
            HoraEntrada="2026-04-23 06:00" HoraSalida="2026-04-23 14:00"/>
        
        <!-- Nuevos empleados: inician semana 2026-04-24 -->
        <InsertarEmpleado ValorDocumentoIdentidad="999000111" Nombre="Valeria Nunez"
            Puesto="Recepcionista" CuentaBancaria="CR2415115201901026111008"
            Username="Nunval" Password="Vale222" TipoUsuario="0" FechaContratacion="2026-04-24"/>
        <InsertarEmpleado ValorDocumentoIdentidad="100200300" Nombre="Roberto Fallas"
            Puesto="Fontanero" CuentaBancaria="CR2415115201901026111009"
            Username="Falrob" Password="Rober333" TipoUsuario="0" FechaContratacion="2026-04-24"/>
        
        <!-- Cierre semana 7: jornada semana 8 (InicioSemana 2026-04-24) -->
        <AsignarJornada ValorDocumentoIdentidad="110011001"
            Jornada="Vespertino" InicioSemana="2026-04-24"/>
        <AsignarJornada ValorDocumentoIdentidad="194739285"
            Jornada="Diurno" InicioSemana="2026-04-24"/>
        <AsignarJornada ValorDocumentoIdentidad="222333444"
            Jornada="Vespertino" InicioSemana="2026-04-24"/>
        <AsignarJornada ValorDocumentoIdentidad="333444555"
            Jornada="Nocturno" InicioSemana="2026-04-24"/>
        <AsignarJornada ValorDocumentoIdentidad="444555666"
            Jornada="Diurno" InicioSemana="2026-04-24"/>
        <AsignarJornada ValorDocumentoIdentidad="666777888"
            Jornada="Nocturno" InicioSemana="2026-04-24"/>
        <AsignarJornada ValorDocumentoIdentidad="888999000"
            Jornada="Vespertino" InicioSemana="2026-04-24"/>
        <AsignarJornada ValorDocumentoIdentidad="999000111"
            Jornada="Nocturno" InicioSemana="2026-04-24"/>
        <AsignarJornada ValorDocumentoIdentidad="100200300"
            Jornada="Diurno" InicioSemana="2026-04-24"/>
        <AsociaEmpleadoConDeduccion ValorDocumentoIdentidad="999000111"
            TipoDeduccion="Ahorro Vacacional" MontoFijo="22000.00"/>
        <AsociaEmpleadoConDeduccion ValorDocumentoIdentidad="100200300"
            TipoDeduccion="Ahorro Asociacion Solidarista" MontoFijo="0.00"/>
        <DesasociaEmpleadoConDeduccion ValorDocumentoIdentidad="222333444"
            TipoDeduccion="Ahorro Vacacional"/>
    </FechaOperacion>

    <FechaOperacion Fecha="2026-04-24"> <!-- Viernes -->
        <MarcaAsistencia ValorDocumentoIdentidad="110011001"
            HoraEntrada="2026-04-24 14:00" HoraSalida="2026-04-25 00:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="194739285"
            HoraEntrada="2026-04-24 06:00" HoraSalida="2026-04-24 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="222333444"
            HoraEntrada="2026-04-24 14:00" HoraSalida="2026-04-24 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="333444555"
            HoraEntrada="2026-04-24 22:00" HoraSalida="2026-04-25 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="666777888"
            HoraEntrada="2026-04-24 22:00" HoraSalida="2026-04-25 08:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="888999000"
            HoraEntrada="2026-04-24 14:00" HoraSalida="2026-04-24 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="999000111"
            HoraEntrada="2026-04-24 22:00" HoraSalida="2026-04-25 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="100200300"
            HoraEntrada="2026-04-24 06:00" HoraSalida="2026-04-24 14:00"/>
    </FechaOperacion>

    <FechaOperacion Fecha="2026-04-25"> <!-- Sabado -->
        <MarcaAsistencia ValorDocumentoIdentidad="110011001"
            HoraEntrada="2026-04-25 14:00" HoraSalida="2026-04-26 00:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="194739285"
            HoraEntrada="2026-04-25 06:00" HoraSalida="2026-04-25 16:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="222333444"
            HoraEntrada="2026-04-25 14:00" HoraSalida="2026-04-25 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="333444555"
            HoraEntrada="2026-04-25 22:00" HoraSalida="2026-04-26 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="444555666"
            HoraEntrada="2026-04-25 06:00" HoraSalida="2026-04-25 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="666777888"
            HoraEntrada="2026-04-25 22:00" HoraSalida="2026-04-26 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="888999000"
            HoraEntrada="2026-04-25 14:00" HoraSalida="2026-04-25 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="999000111"
            HoraEntrada="2026-04-25 22:00" HoraSalida="2026-04-26 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="100200300"
            HoraEntrada="2026-04-25 06:00" HoraSalida="2026-04-25 14:00"/>
    </FechaOperacion>

    <FechaOperacion Fecha="2026-04-26"> <!-- Domingo -->
        <MarcaAsistencia ValorDocumentoIdentidad="194739285"
            HoraEntrada="2026-04-26 06:00" HoraSalida="2026-04-26 17:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="222333444"
            HoraEntrada="2026-04-26 14:00" HoraSalida="2026-04-27 01:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="333444555"
            HoraEntrada="2026-04-26 22:00" HoraSalida="2026-04-27 08:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="444555666"
            HoraEntrada="2026-04-26 06:00" HoraSalida="2026-04-26 17:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="888999000"
            HoraEntrada="2026-04-26 14:00" HoraSalida="2026-04-27 01:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="999000111"
            HoraEntrada="2026-04-26 22:00" HoraSalida="2026-04-27 08:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="100200300"
            HoraEntrada="2026-04-26 06:00" HoraSalida="2026-04-26 17:00"/>
    </FechaOperacion>

    <FechaOperacion Fecha="2026-04-27"> <!-- Lunes -->
        <MarcaAsistencia ValorDocumentoIdentidad="110011001"
            HoraEntrada="2026-04-27 14:00" HoraSalida="2026-04-27 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="194739285"
            HoraEntrada="2026-04-27 06:00" HoraSalida="2026-04-27 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="222333444"
            HoraEntrada="2026-04-27 14:00" HoraSalida="2026-04-28 00:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="333444555"
            HoraEntrada="2026-04-27 22:00" HoraSalida="2026-04-28 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="444555666"
            HoraEntrada="2026-04-27 06:00" HoraSalida="2026-04-27 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="666777888"
            HoraEntrada="2026-04-27 22:00" HoraSalida="2026-04-28 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="888999000"
            HoraEntrada="2026-04-27 14:00" HoraSalida="2026-04-27 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="999000111"
            HoraEntrada="2026-04-27 22:00" HoraSalida="2026-04-28 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="100200300"
            HoraEntrada="2026-04-27 06:00" HoraSalida="2026-04-27 14:00"/>
    </FechaOperacion>

    <FechaOperacion Fecha="2026-04-28"> <!-- Martes -->
        <MarcaAsistencia ValorDocumentoIdentidad="110011001"
            HoraEntrada="2026-04-28 14:00" HoraSalida="2026-04-28 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="222333444"
            HoraEntrada="2026-04-28 14:00" HoraSalida="2026-04-29 00:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="333444555"
            HoraEntrada="2026-04-28 22:00" HoraSalida="2026-04-29 08:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="444555666"
            HoraEntrada="2026-04-28 06:00" HoraSalida="2026-04-28 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="666777888"
            HoraEntrada="2026-04-28 22:00" HoraSalida="2026-04-29 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="999000111"
            HoraEntrada="2026-04-28 22:00" HoraSalida="2026-04-29 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="100200300"
            HoraEntrada="2026-04-28 06:00" HoraSalida="2026-04-28 16:30"/>
    </FechaOperacion>

    <FechaOperacion Fecha="2026-04-29"> <!-- Miercoles -->
        <MarcaAsistencia ValorDocumentoIdentidad="110011001"
            HoraEntrada="2026-04-29 14:00" HoraSalida="2026-04-30 00:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="194739285"
            HoraEntrada="2026-04-29 06:00" HoraSalida="2026-04-29 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="333444555"
            HoraEntrada="2026-04-29 22:00" HoraSalida="2026-04-30 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="444555666"
            HoraEntrada="2026-04-29 06:00" HoraSalida="2026-04-29 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="666777888"
            HoraEntrada="2026-04-29 22:00" HoraSalida="2026-04-30 08:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="888999000"
            HoraEntrada="2026-04-29 14:00" HoraSalida="2026-04-30 00:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="100200300"
            HoraEntrada="2026-04-29 06:00" HoraSalida="2026-04-29 14:00"/>
    </FechaOperacion>

    <FechaOperacion Fecha="2026-04-30"> <!-- Jueves -->
        <MarcaAsistencia ValorDocumentoIdentidad="110011001"
            HoraEntrada="2026-04-30 14:00" HoraSalida="2026-04-30 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="194739285"
            HoraEntrada="2026-04-30 06:00" HoraSalida="2026-04-30 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="222333444"
            HoraEntrada="2026-04-30 14:00" HoraSalida="2026-05-01 00:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="444555666"
            HoraEntrada="2026-04-30 06:00" HoraSalida="2026-04-30 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="666777888"
            HoraEntrada="2026-04-30 22:00" HoraSalida="2026-05-01 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="888999000"
            HoraEntrada="2026-04-30 14:00" HoraSalida="2026-04-30 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="999000111"
            HoraEntrada="2026-04-30 22:00" HoraSalida="2026-05-01 08:00"/>
        
        <!-- Cierre semana 8: jornada semana 9 (InicioSemana 2026-05-01) -->
        <AsignarJornada ValorDocumentoIdentidad="110011001"
            Jornada="Nocturno" InicioSemana="2026-05-01"/>
        <AsignarJornada ValorDocumentoIdentidad="194739285"
            Jornada="Vespertino" InicioSemana="2026-05-01"/>
        <AsignarJornada ValorDocumentoIdentidad="222333444"
            Jornada="Nocturno" InicioSemana="2026-05-01"/>
        <AsignarJornada ValorDocumentoIdentidad="333444555"
            Jornada="Diurno" InicioSemana="2026-05-01"/>
        <AsignarJornada ValorDocumentoIdentidad="444555666"
            Jornada="Vespertino" InicioSemana="2026-05-01"/>
        <AsignarJornada ValorDocumentoIdentidad="666777888"
            Jornada="Diurno" InicioSemana="2026-05-01"/>
        <AsignarJornada ValorDocumentoIdentidad="888999000"
            Jornada="Nocturno" InicioSemana="2026-05-01"/>
        <AsignarJornada ValorDocumentoIdentidad="999000111"
            Jornada="Diurno" InicioSemana="2026-05-01"/>
        <AsignarJornada ValorDocumentoIdentidad="100200300"
            Jornada="Vespertino" InicioSemana="2026-05-01"/>
    </FechaOperacion>

    <FechaOperacion Fecha="2026-05-01">
        
        <!-- FERIADO: Día del Trabajo -->
        <MarcaAsistencia ValorDocumentoIdentidad="110011001"
            HoraEntrada="2026-05-01 22:00" HoraSalida="2026-05-02 08:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="194739285"
            HoraEntrada="2026-05-01 14:00" HoraSalida="2026-05-02 01:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="222333444"
            HoraEntrada="2026-05-01 22:00" HoraSalida="2026-05-02 08:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="333444555"
            HoraEntrada="2026-05-01 06:00" HoraSalida="2026-05-01 17:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="666777888"
            HoraEntrada="2026-05-01 06:00" HoraSalida="2026-05-01 17:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="888999000"
            HoraEntrada="2026-05-01 22:00" HoraSalida="2026-05-02 08:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="999000111"
            HoraEntrada="2026-05-01 06:00" HoraSalida="2026-05-01 17:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="100200300"
            HoraEntrada="2026-05-01 14:00" HoraSalida="2026-05-02 01:00"/>
    </FechaOperacion>

    <FechaOperacion Fecha="2026-05-02"> <!-- Sabado -->
        <MarcaAsistencia ValorDocumentoIdentidad="110011001"
            HoraEntrada="2026-05-02 22:00" HoraSalida="2026-05-03 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="194739285"
            HoraEntrada="2026-05-02 14:00" HoraSalida="2026-05-02 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="222333444"
            HoraEntrada="2026-05-02 22:00" HoraSalida="2026-05-03 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="333444555"
            HoraEntrada="2026-05-02 06:00" HoraSalida="2026-05-02 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="444555666"
            HoraEntrada="2026-05-02 14:00" HoraSalida="2026-05-02 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="666777888"
            HoraEntrada="2026-05-02 06:00" HoraSalida="2026-05-02 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="888999000"
            HoraEntrada="2026-05-02 22:00" HoraSalida="2026-05-03 08:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="999000111"
            HoraEntrada="2026-05-02 06:00" HoraSalida="2026-05-02 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="100200300"
            HoraEntrada="2026-05-02 14:00" HoraSalida="2026-05-02 22:00"/>
    </FechaOperacion>

    <FechaOperacion Fecha="2026-05-03"> <!-- Domingo -->
        <MarcaAsistencia ValorDocumentoIdentidad="194739285"
            HoraEntrada="2026-05-03 14:00" HoraSalida="2026-05-04 01:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="222333444"
            HoraEntrada="2026-05-03 22:00" HoraSalida="2026-05-04 08:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="333444555"
            HoraEntrada="2026-05-03 06:00" HoraSalida="2026-05-03 17:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="444555666"
            HoraEntrada="2026-05-03 14:00" HoraSalida="2026-05-04 01:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="888999000"
            HoraEntrada="2026-05-03 22:00" HoraSalida="2026-05-04 08:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="999000111"
            HoraEntrada="2026-05-03 06:00" HoraSalida="2026-05-03 17:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="100200300"
            HoraEntrada="2026-05-03 14:00" HoraSalida="2026-05-04 01:00"/>
    </FechaOperacion>

    <FechaOperacion Fecha="2026-05-04"> <!-- Lunes -->
        <MarcaAsistencia ValorDocumentoIdentidad="110011001"
            HoraEntrada="2026-05-04 22:00" HoraSalida="2026-05-05 08:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="194739285"
            HoraEntrada="2026-05-04 14:00" HoraSalida="2026-05-04 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="222333444"
            HoraEntrada="2026-05-04 22:00" HoraSalida="2026-05-05 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="333444555"
            HoraEntrada="2026-05-04 06:00" HoraSalida="2026-05-04 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="444555666"
            HoraEntrada="2026-05-04 14:00" HoraSalida="2026-05-04 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="666777888"
            HoraEntrada="2026-05-04 06:00" HoraSalida="2026-05-04 16:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="888999000"
            HoraEntrada="2026-05-04 22:00" HoraSalida="2026-05-05 08:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="999000111"
            HoraEntrada="2026-05-04 06:00" HoraSalida="2026-05-04 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="100200300"
            HoraEntrada="2026-05-04 14:00" HoraSalida="2026-05-04 22:00"/>
    </FechaOperacion>

    <FechaOperacion Fecha="2026-05-05"> <!-- Martes -->
        <MarcaAsistencia ValorDocumentoIdentidad="110011001"
            HoraEntrada="2026-05-05 22:00" HoraSalida="2026-05-06 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="222333444"
            HoraEntrada="2026-05-05 22:00" HoraSalida="2026-05-06 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="333444555"
            HoraEntrada="2026-05-05 06:00" HoraSalida="2026-05-05 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="444555666"
            HoraEntrada="2026-05-05 14:00" HoraSalida="2026-05-05 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="666777888"
            HoraEntrada="2026-05-05 06:00" HoraSalida="2026-05-05 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="999000111"
            HoraEntrada="2026-05-05 06:00" HoraSalida="2026-05-05 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="100200300"
            HoraEntrada="2026-05-05 14:00" HoraSalida="2026-05-06 00:30"/>
    </FechaOperacion>

    <FechaOperacion Fecha="2026-05-06"> <!-- Miercoles -->
        <MarcaAsistencia ValorDocumentoIdentidad="110011001"
            HoraEntrada="2026-05-06 22:00" HoraSalida="2026-05-07 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="194739285"
            HoraEntrada="2026-05-06 14:00" HoraSalida="2026-05-07 00:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="333444555"
            HoraEntrada="2026-05-06 06:00" HoraSalida="2026-05-06 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="444555666"
            HoraEntrada="2026-05-06 14:00" HoraSalida="2026-05-06 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="666777888"
            HoraEntrada="2026-05-06 06:00" HoraSalida="2026-05-06 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="888999000"
            HoraEntrada="2026-05-06 22:00" HoraSalida="2026-05-07 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="100200300"
            HoraEntrada="2026-05-06 14:00" HoraSalida="2026-05-06 22:00"/>
    </FechaOperacion>

    <FechaOperacion Fecha="2026-05-07"> <!-- Jueves -->
        <MarcaAsistencia ValorDocumentoIdentidad="110011001"
            HoraEntrada="2026-05-07 22:00" HoraSalida="2026-05-08 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="194739285"
            HoraEntrada="2026-05-07 14:00" HoraSalida="2026-05-08 00:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="222333444"
            HoraEntrada="2026-05-07 22:00" HoraSalida="2026-05-08 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="444555666"
            HoraEntrada="2026-05-07 14:00" HoraSalida="2026-05-07 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="666777888"
            HoraEntrada="2026-05-07 06:00" HoraSalida="2026-05-07 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="888999000"
            HoraEntrada="2026-05-07 22:00" HoraSalida="2026-05-08 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="999000111"
            HoraEntrada="2026-05-07 06:00" HoraSalida="2026-05-07 16:30"/>
        
        <!-- Nuevos empleados: inician semana 2026-05-08 -->
        <InsertarEmpleado ValorDocumentoIdentidad="400500600" Nombre="Jimena Salazar"
            Puesto="Cajero" CuentaBancaria="CR2415115201901026111010"
            Username="Saljim" Password="Jime444" TipoUsuario="0" FechaContratacion="2026-05-08"/>
        
        <!-- Cierre semana 9: jornada semana 10 (InicioSemana 2026-05-08) -->
        <AsignarJornada ValorDocumentoIdentidad="110011001"
            Jornada="Diurno" InicioSemana="2026-05-08"/>
        <AsignarJornada ValorDocumentoIdentidad="194739285"
            Jornada="Nocturno" InicioSemana="2026-05-08"/>
        <AsignarJornada ValorDocumentoIdentidad="222333444"
            Jornada="Diurno" InicioSemana="2026-05-08"/>
        <AsignarJornada ValorDocumentoIdentidad="333444555"
            Jornada="Vespertino" InicioSemana="2026-05-08"/>
        <AsignarJornada ValorDocumentoIdentidad="444555666"
            Jornada="Nocturno" InicioSemana="2026-05-08"/>
        <AsignarJornada ValorDocumentoIdentidad="666777888"
            Jornada="Vespertino" InicioSemana="2026-05-08"/>
        <AsignarJornada ValorDocumentoIdentidad="888999000"
            Jornada="Diurno" InicioSemana="2026-05-08"/>
        <AsignarJornada ValorDocumentoIdentidad="999000111"
            Jornada="Vespertino" InicioSemana="2026-05-08"/>
        <AsignarJornada ValorDocumentoIdentidad="100200300"
            Jornada="Nocturno" InicioSemana="2026-05-08"/>
        <AsignarJornada ValorDocumentoIdentidad="400500600"
            Jornada="Diurno" InicioSemana="2026-05-08"/>
        <AsociaEmpleadoConDeduccion ValorDocumentoIdentidad="110011001"
            TipoDeduccion="Pension Alimenticia" MontoFijo="20000.00"/>
        <AsociaEmpleadoConDeduccion ValorDocumentoIdentidad="400500600"
            TipoDeduccion="Pension Alimenticia" MontoFijo="28000.00"/>
    </FechaOperacion>

    <FechaOperacion Fecha="2026-05-08"> <!-- Viernes -->
        <MarcaAsistencia ValorDocumentoIdentidad="110011001"
            HoraEntrada="2026-05-08 06:00" HoraSalida="2026-05-08 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="194739285"
            HoraEntrada="2026-05-08 22:00" HoraSalida="2026-05-09 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="222333444"
            HoraEntrada="2026-05-08 06:00" HoraSalida="2026-05-08 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="333444555"
            HoraEntrada="2026-05-08 14:00" HoraSalida="2026-05-08 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="666777888"
            HoraEntrada="2026-05-08 14:00" HoraSalida="2026-05-08 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="888999000"
            HoraEntrada="2026-05-08 06:00" HoraSalida="2026-05-08 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="999000111"
            HoraEntrada="2026-05-08 14:00" HoraSalida="2026-05-08 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="100200300"
            HoraEntrada="2026-05-08 22:00" HoraSalida="2026-05-09 08:00"/>
    </FechaOperacion>

    <FechaOperacion Fecha="2026-05-09"> <!-- Sabado -->
        <MarcaAsistencia ValorDocumentoIdentidad="110011001"
            HoraEntrada="2026-05-09 06:00" HoraSalida="2026-05-09 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="194739285"
            HoraEntrada="2026-05-09 22:00" HoraSalida="2026-05-10 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="222333444"
            HoraEntrada="2026-05-09 06:00" HoraSalida="2026-05-09 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="333444555"
            HoraEntrada="2026-05-09 14:00" HoraSalida="2026-05-09 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="444555666"
            HoraEntrada="2026-05-09 22:00" HoraSalida="2026-05-10 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="666777888"
            HoraEntrada="2026-05-09 14:00" HoraSalida="2026-05-09 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="888999000"
            HoraEntrada="2026-05-09 06:00" HoraSalida="2026-05-09 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="999000111"
            HoraEntrada="2026-05-09 14:00" HoraSalida="2026-05-09 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="100200300"
            HoraEntrada="2026-05-09 22:00" HoraSalida="2026-05-10 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="400500600"
            HoraEntrada="2026-05-09 06:00" HoraSalida="2026-05-09 14:00"/>
    </FechaOperacion>

    <FechaOperacion Fecha="2026-05-10"> <!-- Domingo -->
        <MarcaAsistencia ValorDocumentoIdentidad="194739285"
            HoraEntrada="2026-05-10 22:00" HoraSalida="2026-05-11 08:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="222333444"
            HoraEntrada="2026-05-10 06:00" HoraSalida="2026-05-10 17:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="333444555"
            HoraEntrada="2026-05-10 14:00" HoraSalida="2026-05-11 01:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="444555666"
            HoraEntrada="2026-05-10 22:00" HoraSalida="2026-05-11 08:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="888999000"
            HoraEntrada="2026-05-10 06:00" HoraSalida="2026-05-10 17:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="999000111"
            HoraEntrada="2026-05-10 14:00" HoraSalida="2026-05-11 01:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="100200300"
            HoraEntrada="2026-05-10 22:00" HoraSalida="2026-05-11 08:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="400500600"
            HoraEntrada="2026-05-10 06:00" HoraSalida="2026-05-10 17:00"/>
    </FechaOperacion>

    <FechaOperacion Fecha="2026-05-11"> <!-- Lunes -->
        <MarcaAsistencia ValorDocumentoIdentidad="110011001"
            HoraEntrada="2026-05-11 06:00" HoraSalida="2026-05-11 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="194739285"
            HoraEntrada="2026-05-11 22:00" HoraSalida="2026-05-12 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="222333444"
            HoraEntrada="2026-05-11 06:00" HoraSalida="2026-05-11 16:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="333444555"
            HoraEntrada="2026-05-11 14:00" HoraSalida="2026-05-11 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="444555666"
            HoraEntrada="2026-05-11 22:00" HoraSalida="2026-05-12 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="666777888"
            HoraEntrada="2026-05-11 14:00" HoraSalida="2026-05-12 00:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="888999000"
            HoraEntrada="2026-05-11 06:00" HoraSalida="2026-05-11 16:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="999000111"
            HoraEntrada="2026-05-11 14:00" HoraSalida="2026-05-11 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="100200300"
            HoraEntrada="2026-05-11 22:00" HoraSalida="2026-05-12 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="400500600"
            HoraEntrada="2026-05-11 06:00" HoraSalida="2026-05-11 14:00"/>
    </FechaOperacion>

    <FechaOperacion Fecha="2026-05-12"> <!-- Martes -->
        <MarcaAsistencia ValorDocumentoIdentidad="110011001"
            HoraEntrada="2026-05-12 06:00" HoraSalida="2026-05-12 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="222333444"
            HoraEntrada="2026-05-12 06:00" HoraSalida="2026-05-12 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="333444555"
            HoraEntrada="2026-05-12 14:00" HoraSalida="2026-05-13 00:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="444555666"
            HoraEntrada="2026-05-12 22:00" HoraSalida="2026-05-13 08:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="666777888"
            HoraEntrada="2026-05-12 14:00" HoraSalida="2026-05-13 00:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="999000111"
            HoraEntrada="2026-05-12 14:00" HoraSalida="2026-05-12 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="100200300"
            HoraEntrada="2026-05-12 22:00" HoraSalida="2026-05-13 08:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="400500600"
            HoraEntrada="2026-05-12 06:00" HoraSalida="2026-05-12 14:00"/>
    </FechaOperacion>

    <FechaOperacion Fecha="2026-05-13"> <!-- Miercoles -->
        <MarcaAsistencia ValorDocumentoIdentidad="110011001"
            HoraEntrada="2026-05-13 06:00" HoraSalida="2026-05-13 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="194739285"
            HoraEntrada="2026-05-13 22:00" HoraSalida="2026-05-14 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="333444555"
            HoraEntrada="2026-05-13 14:00" HoraSalida="2026-05-13 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="444555666"
            HoraEntrada="2026-05-13 22:00" HoraSalida="2026-05-14 08:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="666777888"
            HoraEntrada="2026-05-13 14:00" HoraSalida="2026-05-14 00:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="888999000"
            HoraEntrada="2026-05-13 06:00" HoraSalida="2026-05-13 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="100200300"
            HoraEntrada="2026-05-13 22:00" HoraSalida="2026-05-14 08:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="400500600"
            HoraEntrada="2026-05-13 06:00" HoraSalida="2026-05-13 14:00"/>
    </FechaOperacion>

    <FechaOperacion Fecha="2026-05-14"> <!-- Jueves -->
        <MarcaAsistencia ValorDocumentoIdentidad="110011001"
            HoraEntrada="2026-05-14 06:00" HoraSalida="2026-05-14 16:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="194739285"
            HoraEntrada="2026-05-14 22:00" HoraSalida="2026-05-15 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="222333444"
            HoraEntrada="2026-05-14 06:00" HoraSalida="2026-05-14 16:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="444555666"
            HoraEntrada="2026-05-14 22:00" HoraSalida="2026-05-15 08:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="666777888"
            HoraEntrada="2026-05-14 14:00" HoraSalida="2026-05-14 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="888999000"
            HoraEntrada="2026-05-14 06:00" HoraSalida="2026-05-14 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="999000111"
            HoraEntrada="2026-05-14 14:00" HoraSalida="2026-05-14 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="400500600"
            HoraEntrada="2026-05-14 06:00" HoraSalida="2026-05-14 14:00"/>
        
        <!-- Eliminar empleado: termina semana 2026-03-27 -->
        <EliminarEmpleado ValorDocumentoIdentidad="888999000"/>
        
        <!-- Cierre semana 10: jornada semana 11 (InicioSemana 2026-05-15) -->
        <AsignarJornada ValorDocumentoIdentidad="110011001"
            Jornada="Vespertino" InicioSemana="2026-05-15"/>
        <AsignarJornada ValorDocumentoIdentidad="194739285"
            Jornada="Diurno" InicioSemana="2026-05-15"/>
        <AsignarJornada ValorDocumentoIdentidad="222333444"
            Jornada="Vespertino" InicioSemana="2026-05-15"/>
        <AsignarJornada ValorDocumentoIdentidad="333444555"
            Jornada="Nocturno" InicioSemana="2026-05-15"/>
        <AsignarJornada ValorDocumentoIdentidad="444555666"
            Jornada="Diurno" InicioSemana="2026-05-15"/>
        <AsignarJornada ValorDocumentoIdentidad="666777888"
            Jornada="Nocturno" InicioSemana="2026-05-15"/>
        <AsignarJornada ValorDocumentoIdentidad="999000111"
            Jornada="Nocturno" InicioSemana="2026-05-15"/>
        <AsignarJornada ValorDocumentoIdentidad="100200300"
            Jornada="Diurno" InicioSemana="2026-05-15"/>
        <AsignarJornada ValorDocumentoIdentidad="400500600"
            Jornada="Vespertino" InicioSemana="2026-05-15"/>
        <AsociaEmpleadoConDeduccion ValorDocumentoIdentidad="194739285"
            TipoDeduccion="Ahorro Vacacional" MontoFijo="10000.00"/>
        <AsociaEmpleadoConDeduccion ValorDocumentoIdentidad="666777888"
            TipoDeduccion="Pension Alimenticia" MontoFijo="32000.00"/>
        <DesasociaEmpleadoConDeduccion ValorDocumentoIdentidad="444555666"
            TipoDeduccion="Pension Alimenticia"/>
    </FechaOperacion>

    <FechaOperacion Fecha="2026-05-15"> <!-- Viernes -->
        <MarcaAsistencia ValorDocumentoIdentidad="110011001"
            HoraEntrada="2026-05-15 14:00" HoraSalida="2026-05-15 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="194739285"
            HoraEntrada="2026-05-15 06:00" HoraSalida="2026-05-15 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="222333444"
            HoraEntrada="2026-05-15 14:00" HoraSalida="2026-05-15 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="333444555"
            HoraEntrada="2026-05-15 22:00" HoraSalida="2026-05-16 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="666777888"
            HoraEntrada="2026-05-15 22:00" HoraSalida="2026-05-16 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="999000111"
            HoraEntrada="2026-05-15 22:00" HoraSalida="2026-05-16 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="100200300"
            HoraEntrada="2026-05-15 06:00" HoraSalida="2026-05-15 14:00"/>
    </FechaOperacion>

    <FechaOperacion Fecha="2026-05-16"> <!-- Sabado -->
        <MarcaAsistencia ValorDocumentoIdentidad="110011001"
            HoraEntrada="2026-05-16 14:00" HoraSalida="2026-05-16 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="194739285"
            HoraEntrada="2026-05-16 06:00" HoraSalida="2026-05-16 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="222333444"
            HoraEntrada="2026-05-16 14:00" HoraSalida="2026-05-16 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="333444555"
            HoraEntrada="2026-05-16 22:00" HoraSalida="2026-05-17 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="444555666"
            HoraEntrada="2026-05-16 06:00" HoraSalida="2026-05-16 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="666777888"
            HoraEntrada="2026-05-16 22:00" HoraSalida="2026-05-17 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="999000111"
            HoraEntrada="2026-05-16 22:00" HoraSalida="2026-05-17 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="100200300"
            HoraEntrada="2026-05-16 06:00" HoraSalida="2026-05-16 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="400500600"
            HoraEntrada="2026-05-16 14:00" HoraSalida="2026-05-16 22:00"/>
    </FechaOperacion>

    <FechaOperacion Fecha="2026-05-17"> <!-- Domingo -->
        <MarcaAsistencia ValorDocumentoIdentidad="194739285"
            HoraEntrada="2026-05-17 06:00" HoraSalida="2026-05-17 17:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="222333444"
            HoraEntrada="2026-05-17 14:00" HoraSalida="2026-05-18 01:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="333444555"
            HoraEntrada="2026-05-17 22:00" HoraSalida="2026-05-18 08:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="444555666"
            HoraEntrada="2026-05-17 06:00" HoraSalida="2026-05-17 17:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="999000111"
            HoraEntrada="2026-05-17 22:00" HoraSalida="2026-05-18 08:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="100200300"
            HoraEntrada="2026-05-17 06:00" HoraSalida="2026-05-17 17:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="400500600"
            HoraEntrada="2026-05-17 14:00" HoraSalida="2026-05-18 01:00"/>
    </FechaOperacion>

    <FechaOperacion Fecha="2026-05-18"> <!-- Lunes -->
        <MarcaAsistencia ValorDocumentoIdentidad="110011001"
            HoraEntrada="2026-05-18 14:00" HoraSalida="2026-05-18 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="194739285"
            HoraEntrada="2026-05-18 06:00" HoraSalida="2026-05-18 16:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="222333444"
            HoraEntrada="2026-05-18 14:00" HoraSalida="2026-05-19 00:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="333444555"
            HoraEntrada="2026-05-18 22:00" HoraSalida="2026-05-19 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="444555666"
            HoraEntrada="2026-05-18 06:00" HoraSalida="2026-05-18 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="666777888"
            HoraEntrada="2026-05-18 22:00" HoraSalida="2026-05-19 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="999000111"
            HoraEntrada="2026-05-18 22:00" HoraSalida="2026-05-19 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="100200300"
            HoraEntrada="2026-05-18 06:00" HoraSalida="2026-05-18 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="400500600"
            HoraEntrada="2026-05-18 14:00" HoraSalida="2026-05-19 00:30"/>
    </FechaOperacion>

    <FechaOperacion Fecha="2026-05-19"> <!-- Martes -->
        <MarcaAsistencia ValorDocumentoIdentidad="110011001"
            HoraEntrada="2026-05-19 14:00" HoraSalida="2026-05-19 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="222333444"
            HoraEntrada="2026-05-19 14:00" HoraSalida="2026-05-19 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="333444555"
            HoraEntrada="2026-05-19 22:00" HoraSalida="2026-05-20 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="444555666"
            HoraEntrada="2026-05-19 06:00" HoraSalida="2026-05-19 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="666777888"
            HoraEntrada="2026-05-19 22:00" HoraSalida="2026-05-20 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="999000111"
            HoraEntrada="2026-05-19 22:00" HoraSalida="2026-05-20 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="100200300"
            HoraEntrada="2026-05-19 06:00" HoraSalida="2026-05-19 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="400500600"
            HoraEntrada="2026-05-19 14:00" HoraSalida="2026-05-19 22:00"/>
    </FechaOperacion>

    <FechaOperacion Fecha="2026-05-20"> <!-- Miercoles -->
        <MarcaAsistencia ValorDocumentoIdentidad="110011001"
            HoraEntrada="2026-05-20 14:00" HoraSalida="2026-05-20 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="194739285"
            HoraEntrada="2026-05-20 06:00" HoraSalida="2026-05-20 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="333444555"
            HoraEntrada="2026-05-20 22:00" HoraSalida="2026-05-21 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="444555666"
            HoraEntrada="2026-05-20 06:00" HoraSalida="2026-05-20 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="666777888"
            HoraEntrada="2026-05-20 22:00" HoraSalida="2026-05-21 08:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="100200300"
            HoraEntrada="2026-05-20 06:00" HoraSalida="2026-05-20 16:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="400500600"
            HoraEntrada="2026-05-20 14:00" HoraSalida="2026-05-20 22:00"/>
    </FechaOperacion>

    <FechaOperacion Fecha="2026-05-21"> <!-- Jueves -->
        <MarcaAsistencia ValorDocumentoIdentidad="110011001"
            HoraEntrada="2026-05-21 14:00" HoraSalida="2026-05-21 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="194739285"
            HoraEntrada="2026-05-21 06:00" HoraSalida="2026-05-21 16:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="222333444"
            HoraEntrada="2026-05-21 14:00" HoraSalida="2026-05-21 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="444555666"
            HoraEntrada="2026-05-21 06:00" HoraSalida="2026-05-21 16:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="666777888"
            HoraEntrada="2026-05-21 22:00" HoraSalida="2026-05-22 08:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="999000111"
            HoraEntrada="2026-05-21 22:00" HoraSalida="2026-05-22 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="400500600"
            HoraEntrada="2026-05-21 14:00" HoraSalida="2026-05-22 00:30"/>
        
        <!-- Cierre semana 11: jornada semana 12 (InicioSemana 2026-05-22) -->
        <AsignarJornada ValorDocumentoIdentidad="110011001"
            Jornada="Nocturno" InicioSemana="2026-05-22"/>
        <AsignarJornada ValorDocumentoIdentidad="194739285"
            Jornada="Vespertino" InicioSemana="2026-05-22"/>
        <AsignarJornada ValorDocumentoIdentidad="222333444"
            Jornada="Nocturno" InicioSemana="2026-05-22"/>
        <AsignarJornada ValorDocumentoIdentidad="333444555"
            Jornada="Diurno" InicioSemana="2026-05-22"/>
        <AsignarJornada ValorDocumentoIdentidad="444555666"
            Jornada="Vespertino" InicioSemana="2026-05-22"/>
        <AsignarJornada ValorDocumentoIdentidad="666777888"
            Jornada="Diurno" InicioSemana="2026-05-22"/>
        <AsignarJornada ValorDocumentoIdentidad="999000111"
            Jornada="Diurno" InicioSemana="2026-05-22"/>
        <AsignarJornada ValorDocumentoIdentidad="100200300"
            Jornada="Vespertino" InicioSemana="2026-05-22"/>
        <AsignarJornada ValorDocumentoIdentidad="400500600"
            Jornada="Nocturno" InicioSemana="2026-05-22"/>
        <AsociaEmpleadoConDeduccion ValorDocumentoIdentidad="333444555"
            TipoDeduccion="Ahorro Vacacional" MontoFijo="17000.00"/>
        <DesasociaEmpleadoConDeduccion ValorDocumentoIdentidad="110011001"
            TipoDeduccion="Pension Alimenticia"/>
        <DesasociaEmpleadoConDeduccion ValorDocumentoIdentidad="100200300"
            TipoDeduccion="Ahorro Asociacion Solidarista"/>
    </FechaOperacion>

    <FechaOperacion Fecha="2026-05-22"> <!-- Viernes -->
        <MarcaAsistencia ValorDocumentoIdentidad="110011001"
            HoraEntrada="2026-05-22 22:00" HoraSalida="2026-05-23 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="194739285"
            HoraEntrada="2026-05-22 14:00" HoraSalida="2026-05-22 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="222333444"
            HoraEntrada="2026-05-22 22:00" HoraSalida="2026-05-23 08:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="333444555"
            HoraEntrada="2026-05-22 06:00" HoraSalida="2026-05-22 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="666777888"
            HoraEntrada="2026-05-22 06:00" HoraSalida="2026-05-22 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="999000111"
            HoraEntrada="2026-05-22 06:00" HoraSalida="2026-05-22 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="100200300"
            HoraEntrada="2026-05-22 14:00" HoraSalida="2026-05-22 22:00"/>
    </FechaOperacion>

    <FechaOperacion Fecha="2026-05-23"> <!-- Sabado -->
        <MarcaAsistencia ValorDocumentoIdentidad="110011001"
            HoraEntrada="2026-05-23 22:00" HoraSalida="2026-05-24 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="194739285"
            HoraEntrada="2026-05-23 14:00" HoraSalida="2026-05-24 00:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="222333444"
            HoraEntrada="2026-05-23 22:00" HoraSalida="2026-05-24 08:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="333444555"
            HoraEntrada="2026-05-23 06:00" HoraSalida="2026-05-23 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="444555666"
            HoraEntrada="2026-05-23 14:00" HoraSalida="2026-05-23 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="666777888"
            HoraEntrada="2026-05-23 06:00" HoraSalida="2026-05-23 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="999000111"
            HoraEntrada="2026-05-23 06:00" HoraSalida="2026-05-23 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="100200300"
            HoraEntrada="2026-05-23 14:00" HoraSalida="2026-05-23 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="400500600"
            HoraEntrada="2026-05-23 22:00" HoraSalida="2026-05-24 06:00"/>
    </FechaOperacion>

    <FechaOperacion Fecha="2026-05-24"> <!-- Domingo -->
        <MarcaAsistencia ValorDocumentoIdentidad="194739285"
            HoraEntrada="2026-05-24 14:00" HoraSalida="2026-05-25 01:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="222333444"
            HoraEntrada="2026-05-24 22:00" HoraSalida="2026-05-25 08:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="333444555"
            HoraEntrada="2026-05-24 06:00" HoraSalida="2026-05-24 17:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="444555666"
            HoraEntrada="2026-05-24 14:00" HoraSalida="2026-05-25 01:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="999000111"
            HoraEntrada="2026-05-24 06:00" HoraSalida="2026-05-24 17:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="100200300"
            HoraEntrada="2026-05-24 14:00" HoraSalida="2026-05-25 01:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="400500600"
            HoraEntrada="2026-05-24 22:00" HoraSalida="2026-05-25 08:30"/>
    </FechaOperacion>

    <FechaOperacion Fecha="2026-05-25"> <!-- Lunes -->
        <MarcaAsistencia ValorDocumentoIdentidad="110011001"
            HoraEntrada="2026-05-25 22:00" HoraSalida="2026-05-26 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="194739285"
            HoraEntrada="2026-05-25 14:00" HoraSalida="2026-05-26 00:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="222333444"
            HoraEntrada="2026-05-25 22:00" HoraSalida="2026-05-26 08:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="333444555"
            HoraEntrada="2026-05-25 06:00" HoraSalida="2026-05-25 16:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="444555666"
            HoraEntrada="2026-05-25 14:00" HoraSalida="2026-05-26 00:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="666777888"
            HoraEntrada="2026-05-25 06:00" HoraSalida="2026-05-25 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="999000111"
            HoraEntrada="2026-05-25 06:00" HoraSalida="2026-05-25 16:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="100200300"
            HoraEntrada="2026-05-25 14:00" HoraSalida="2026-05-25 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="400500600"
            HoraEntrada="2026-05-25 22:00" HoraSalida="2026-05-26 06:00"/>
    </FechaOperacion>

    <FechaOperacion Fecha="2026-05-26"> <!-- Martes -->
        <MarcaAsistencia ValorDocumentoIdentidad="110011001"
            HoraEntrada="2026-05-26 22:00" HoraSalida="2026-05-27 08:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="222333444"
            HoraEntrada="2026-05-26 22:00" HoraSalida="2026-05-27 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="333444555"
            HoraEntrada="2026-05-26 06:00" HoraSalida="2026-05-26 16:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="444555666"
            HoraEntrada="2026-05-26 14:00" HoraSalida="2026-05-26 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="666777888"
            HoraEntrada="2026-05-26 06:00" HoraSalida="2026-05-26 16:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="999000111"
            HoraEntrada="2026-05-26 06:00" HoraSalida="2026-05-26 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="100200300"
            HoraEntrada="2026-05-26 14:00" HoraSalida="2026-05-26 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="400500600"
            HoraEntrada="2026-05-26 22:00" HoraSalida="2026-05-27 06:00"/>
    </FechaOperacion>

    <FechaOperacion Fecha="2026-05-27"> <!-- Miercoles -->
        <MarcaAsistencia ValorDocumentoIdentidad="110011001"
            HoraEntrada="2026-05-27 22:00" HoraSalida="2026-05-28 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="194739285"
            HoraEntrada="2026-05-27 14:00" HoraSalida="2026-05-28 00:30"/>
        <MarcaAsistencia ValorDocumentoIdentidad="333444555"
            HoraEntrada="2026-05-27 06:00" HoraSalida="2026-05-27 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="444555666"
            HoraEntrada="2026-05-27 14:00" HoraSalida="2026-05-27 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="666777888"
            HoraEntrada="2026-05-27 06:00" HoraSalida="2026-05-27 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="100200300"
            HoraEntrada="2026-05-27 14:00" HoraSalida="2026-05-27 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="400500600"
            HoraEntrada="2026-05-27 22:00" HoraSalida="2026-05-28 08:00"/>
    </FechaOperacion>

    <FechaOperacion Fecha="2026-05-28"> <!-- Jueves -->
        <MarcaAsistencia ValorDocumentoIdentidad="110011001"
            HoraEntrada="2026-05-28 22:00" HoraSalida="2026-05-29 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="194739285"
            HoraEntrada="2026-05-28 14:00" HoraSalida="2026-05-28 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="222333444"
            HoraEntrada="2026-05-28 22:00" HoraSalida="2026-05-29 06:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="444555666"
            HoraEntrada="2026-05-28 14:00" HoraSalida="2026-05-28 22:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="666777888"
            HoraEntrada="2026-05-28 06:00" HoraSalida="2026-05-28 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="999000111"
            HoraEntrada="2026-05-28 06:00" HoraSalida="2026-05-28 14:00"/>
        <MarcaAsistencia ValorDocumentoIdentidad="400500600"
            HoraEntrada="2026-05-28 22:00" HoraSalida="2026-05-29 08:00"/>
        
        <!-- Cierre semana 12: jornada semana 13 (InicioSemana 2026-05-29) -->
        <AsignarJornada ValorDocumentoIdentidad="110011001"
            Jornada="Diurno" InicioSemana="2026-05-29"/>
        <AsignarJornada ValorDocumentoIdentidad="194739285"
            Jornada="Nocturno" InicioSemana="2026-05-29"/>
        <AsignarJornada ValorDocumentoIdentidad="222333444"
            Jornada="Diurno" InicioSemana="2026-05-29"/>
        <AsignarJornada ValorDocumentoIdentidad="333444555"
            Jornada="Vespertino" InicioSemana="2026-05-29"/>
        <AsignarJornada ValorDocumentoIdentidad="444555666"
            Jornada="Nocturno" InicioSemana="2026-05-29"/>
        <AsignarJornada ValorDocumentoIdentidad="666777888"
            Jornada="Vespertino" InicioSemana="2026-05-29"/>
        <AsignarJornada ValorDocumentoIdentidad="999000111"
            Jornada="Vespertino" InicioSemana="2026-05-29"/>
        <AsignarJornada ValorDocumentoIdentidad="100200300"
            Jornada="Nocturno" InicioSemana="2026-05-29"/>
        <AsignarJornada ValorDocumentoIdentidad="400500600"
            Jornada="Diurno" InicioSemana="2026-05-29"/>
    </FechaOperacion>

</Operaciones>';

    DECLARE @handle INT;
    EXEC sp_xml_preparedocument @handle OUTPUT, @xml;

    -- Tablas variables para extracción de OPENXML
    DECLARE @InsertarEmpleadoXML TABLE (
        id INT IDENTITY(1,1)
        , Fecha DATE
        , ValorDocumentoIdentidad VARCHAR(32)
        , Nombre VARCHAR(128)
        , Puesto VARCHAR(128)
        , CuentaBancaria VARCHAR(32)
        , Username VARCHAR(64)
        , Password VARCHAR(64)
        , TipoUsuario VARCHAR(2)
        , FechaContratacion DATE
        , Procesado BIT DEFAULT 0
    );

    DECLARE @EliminarEmpleadoXML TABLE (
        id INT IDENTITY(1,1)
        , Fecha DATE
        , ValorDocumentoIdentidad VARCHAR(32)
    );

    DECLARE @AsociaDeduccionXML TABLE (
        id INT IDENTITY(1,1)
        , Fecha DATE
        , ValorDocumentoIdentidad VARCHAR(32)
        , TipoDeduccion VARCHAR(128)
        , MontoFijo MONEY
    );

    DECLARE @DesasociaDeduccionXML TABLE (
        id INT IDENTITY(1,1)
        , Fecha DATE
        , ValorDocumentoIdentidad VARCHAR(32)
        , TipoDeduccion VARCHAR(128)
    );

    DECLARE @MarcaAsistenciaXML TABLE (
        rnLocal INT IDENTITY(1,1)
        , Fecha DATE
        , ValorDocumentoIdentidad VARCHAR(32)
        , HoraEntrada DATETIME
        , HoraSalida DATETIME
    );

    DECLARE @AsignarJornadaXML TABLE (
        id INT IDENTITY(1,1)
        , Fecha DATE
        , ValorDocumentoIdentidad VARCHAR(32)
        , Jornada VARCHAR(64)
        , InicioSemana DATE
    );

    -- Carga de datos desde OPENXML
    INSERT INTO @InsertarEmpleadoXML (Fecha, ValorDocumentoIdentidad, Nombre
        , Puesto, CuentaBancaria, Username, Password, TipoUsuario, FechaContratacion)
    SELECT x.Fecha, x.ValorDocumentoIdentidad, x.Nombre, x.Puesto, x.CuentaBancaria
        , x.Username, x.Password, x.TipoUsuario, x.FechaContratacion
    FROM OPENXML(@handle, '/Operaciones/FechaOperacion/InsertarEmpleado', 1)
    WITH (
        Fecha DATE '../@Fecha'
        , ValorDocumentoIdentidad VARCHAR(32) '@ValorDocumentoIdentidad'
        , Nombre VARCHAR(128) '@Nombre'
        , Puesto VARCHAR(128) '@Puesto'
        , CuentaBancaria VARCHAR(32) '@CuentaBancaria'
        , Username VARCHAR(64) '@Username'
        , Password VARCHAR(64) '@Password'
        , TipoUsuario VARCHAR(2) '@TipoUsuario'
        , FechaContratacion DATE '@FechaContratacion'
    ) AS x;

    INSERT INTO @EliminarEmpleadoXML (Fecha, ValorDocumentoIdentidad)
    SELECT x.Fecha, x.ValorDocumentoIdentidad
    FROM OPENXML(@handle, '/Operaciones/FechaOperacion/EliminarEmpleado', 1)
    WITH (
        Fecha DATE '../@Fecha'
        , ValorDocumentoIdentidad VARCHAR(32) '@ValorDocumentoIdentidad'
    ) AS x;

    INSERT INTO @AsociaDeduccionXML (Fecha, ValorDocumentoIdentidad, TipoDeduccion, MontoFijo)
    SELECT x.Fecha, x.ValorDocumentoIdentidad, x.TipoDeduccion, x.MontoFijo
    FROM OPENXML(@handle, '/Operaciones/FechaOperacion/AsociaEmpleadoConDeduccion', 1)
    WITH (
        Fecha DATE '../@Fecha'
        , ValorDocumentoIdentidad VARCHAR(32) '@ValorDocumentoIdentidad'
        , TipoDeduccion VARCHAR(128) '@TipoDeduccion'
        , MontoFijo MONEY '@MontoFijo'
    ) AS x;

    INSERT INTO @DesasociaDeduccionXML (Fecha, ValorDocumentoIdentidad, TipoDeduccion)
    SELECT x.Fecha, x.ValorDocumentoIdentidad, x.TipoDeduccion
    FROM OPENXML(@handle, '/Operaciones/FechaOperacion/DesasociaEmpleadoConDeduccion', 1)
    WITH (
        Fecha DATE '../@Fecha'
        , ValorDocumentoIdentidad VARCHAR(32) '@ValorDocumentoIdentidad'
        , TipoDeduccion VARCHAR(128) '@TipoDeduccion'
    ) AS x;

    INSERT INTO @MarcaAsistenciaXML (Fecha, ValorDocumentoIdentidad, HoraEntrada, HoraSalida)
    SELECT x.Fecha, x.ValorDocumentoIdentidad, x.HoraEntrada, x.HoraSalida
    FROM OPENXML(@handle, '/Operaciones/FechaOperacion/MarcaAsistencia', 1)
    WITH (
        Fecha DATE '../@Fecha'
        , ValorDocumentoIdentidad VARCHAR(32) '@ValorDocumentoIdentidad'
        , HoraEntrada DATETIME '@HoraEntrada'
        , HoraSalida DATETIME '@HoraSalida'
    ) AS x;

    INSERT INTO @AsignarJornadaXML (Fecha, ValorDocumentoIdentidad, Jornada, InicioSemana)
    SELECT x.Fecha, x.ValorDocumentoIdentidad, x.Jornada, x.InicioSemana
    FROM OPENXML(@handle, '/Operaciones/FechaOperacion/AsignarJornada', 1)
    WITH (
        Fecha DATE '../@Fecha'
        , ValorDocumentoIdentidad VARCHAR(32) '@ValorDocumentoIdentidad'
        , Jornada VARCHAR(64) '@Jornada'
        , InicioSemana DATE '@InicioSemana'
    ) AS x;

    EXEC sp_xml_removedocument @handle;

    -- Obtención de las fechas únicas ordenadas cronológicamente
    DECLARE @Fechas TABLE (id INT IDENTITY(1,1), Fecha DATE);
    INSERT INTO @Fechas (Fecha)
    SELECT Fecha FROM @InsertarEmpleadoXML UNION
    SELECT Fecha FROM @EliminarEmpleadoXML UNION
    SELECT Fecha FROM @AsociaDeduccionXML UNION
    SELECT Fecha FROM @DesasociaDeduccionXML UNION
    SELECT Fecha FROM @MarcaAsistenciaXML UNION
    SELECT Fecha FROM @AsignarJornadaXML
    ORDER BY Fecha;

    BEGIN TRY
        BEGIN TRANSACTION;
            DECLARE @fechaId INT = 1, @maxFechaId INT;
            SELECT @maxFechaId = COUNT(*) FROM @Fechas;

            WHILE @fechaId <= @maxFechaId
            BEGIN
                DECLARE @fechaOp DATE;
                SELECT @fechaOp = Fecha
                FROM @Fechas
                WHERE id = @fechaId;

                -- =================================================================
                -- APERTURA INICIAL DEL CALENDARIO (Solo el primer día)
                -- =================================================================
                IF @fechaId = 1 AND NOT EXISTS (SELECT 1 FROM dbo.Semana)
                BEGIN
                    DECLARE @rcCal INT, @idMesCreado INT;
                    DECLARE @viernesRelleno DATE = DATEADD(DAY, -6, @fechaOp); 

                    EXEC dbo.sp_CrearCalendario 
                        @inFechaInicioMes = @viernesRelleno, 
                        @outResultCode = @rcCal OUTPUT, 
                        @outIdMes = @idMesCreado OUTPUT;

                    IF @rcCal <> 0
                    BEGIN
                        SET @outResultCode = @rcCal;
                        ROLLBACK TRANSACTION;
                        RETURN;
                    END
                END;

                -- Diagnóstico de la semana asignada en base de datos para esta fecha
                DECLARE @chkSemanaId INT, @chkSemanaInicio DATE, @chkSemanaFin DATE;
                SELECT TOP 1 @chkSemanaId = id
                    , @chkSemanaInicio = FechaInicio
                    , @chkSemanaFin = FechaFin 
                FROM dbo.Semana
                WHERE @fechaOp BETWEEN FechaInicio AND FechaFin;

                -- 1. PROCESAR: InsertarEmpleado
                WHILE EXISTS (SELECT 1
                                FROM @InsertarEmpleadoXML
                                WHERE Fecha = @fechaOp AND Procesado = 0)
                BEGIN
                    DECLARE @ieId INT
                            , @ieDocumento VARCHAR(32)
                            , @ieNombre VARCHAR(128)
                            , @iePuesto VARCHAR(128)
                            , @ieCuenta VARCHAR(32)
                            , @ieUsername VARCHAR(64)
                            , @iePassword VARCHAR(64)
                            , @ieTipo VARCHAR(2)
                            , @ieFechaContr DATE
                            , @nuevoIdUsuario INT
                            , @nuevoIdPuesto INT
                            , @idEmpleadoCreado INT;

                    SELECT TOP (1) 
                        @ieId = id, @ieDocumento = ValorDocumentoIdentidad
                        , @ieNombre = Nombre, @iePuesto = Puesto, 
                        @ieCuenta = CuentaBancaria, @ieUsername = Username
                        , @iePassword = Password, @ieTipo = TipoUsuario, 
                        @ieFechaContr = FechaContratacion
                    FROM @InsertarEmpleadoXML 
                    WHERE Fecha = @fechaOp AND Procesado = 0 
                    ORDER BY id;

                    INSERT INTO dbo.Usuario (id, Username, PasswordHash, Tipo)
                    VALUES ( (SELECT ISNULL(MAX(id), 0) + 1 FROM dbo.Usuario), @ieUsername
                        , @iePassword, @ieTipo );

                    SELECT @nuevoIdUsuario = id
                    FROM dbo.Usuario
                    WHERE Username = @ieUsername;

                    SELECT @nuevoIdPuesto = id
                    FROM dbo.Puesto
                    WHERE Nombre = @iePuesto;

                    INSERT INTO dbo.Empleado (idPuesto, idUsuario, ValorDocumento, Nombre
                        , CuentaBancaria, FechaContratacion, Activo)
                    VALUES ( @nuevoIdPuesto, @nuevoIdUsuario, @ieDocumento, @ieNombre
                        , @ieCuenta, @ieFechaContr, 1 );

                    SET @idEmpleadoCreado = SCOPE_IDENTITY();

                    -- Enlace de jornada inicial para evitar el 60003 en el bloque de relleno
                    IF @fechaId = 1
                    BEGIN
                        IF @chkSemanaId IS NOT NULL
                        BEGIN
                            INSERT INTO dbo.HorarioJornada (idEmpleado, idSemana, idTipoJornada)
                            VALUES (@idEmpleadoCreado, @chkSemanaId, 1); 
                        END
                    END

                    UPDATE @InsertarEmpleadoXML SET Procesado = 1 WHERE id = @ieId;
                END;

                -- 2. PROCESAR: EliminarEmpleado
                IF EXISTS(SELECT 1 FROM @EliminarEmpleadoXML WHERE Fecha = @fechaOp)
                BEGIN
                    UPDATE e SET e.Activo = 0
                    FROM dbo.Empleado e
                    INNER JOIN @EliminarEmpleadoXML del
                    ON e.ValorDocumento = del.ValorDocumentoIdentidad
                    WHERE del.Fecha = @fechaOp;
                END

                -- 3. PROCESAR: AsociaEmpleadoConDeduccion
                IF EXISTS(SELECT 1 FROM @AsociaDeduccionXML WHERE Fecha = @fechaOp)
                BEGIN
                    INSERT INTO dbo.DeduccionEmpleado (idEmpleado, idTipoDeduccion
                        , MontoFijo, FechaInicio, FechaFin)
                    SELECT e.id, td.id, ascD.MontoFijo, @fechaOp, '9999-12-31'
                    FROM @AsociaDeduccionXML ascD
                    INNER JOIN dbo.Empleado e ON e.ValorDocumento = ascD.ValorDocumentoIdentidad
                    INNER JOIN dbo.TipoDeduccion td ON td.Nombre = ascD.TipoDeduccion
                    WHERE ascD.Fecha = @fechaOp;
                END

                -- 4. PROCESAR: DesasociaEmpleadoConDeduccion
                IF EXISTS(SELECT 1 FROM @DesasociaDeduccionXML WHERE Fecha = @fechaOp)
                BEGIN
                    UPDATE de SET de.FechaFin = @fechaOp
                    FROM dbo.DeduccionEmpleado de
                    INNER JOIN dbo.Empleado e ON de.idEmpleado = e.id
                    INNER JOIN dbo.TipoDeduccion td ON de.idTipoDeduccion = td.id
                    INNER JOIN @DesasociaDeduccionXML desD
                    ON e.ValorDocumento = desD.ValorDocumentoIdentidad
                    AND td.Nombre = desD.TipoDeduccion
                    WHERE desD.Fecha = @fechaOp AND de.FechaFin = '9999-12-31';
                END

                -- 5. PROCESAR: MarcaAsistencia
                DECLARE @MarcasHoyConId TABLE (rnLocal INT, idMarcaAsistencia INT);
                DELETE FROM @MarcasHoyConId;

                DECLARE @MarcasDeLaFecha TABLE (
                    rnLocal INT, idEmpleado INT, ValorDoc VARCHAR(32)
                    , HoraEntrada DATETIME, HoraSalida DATETIME, Procesado BIT DEFAULT 0
                );
                DELETE FROM @MarcasDeLaFecha;

                INSERT INTO @MarcasDeLaFecha (rnLocal, idEmpleado, ValorDoc
                    , HoraEntrada, HoraSalida)
                SELECT xmlM.rnLocal, e.id, xmlM.ValorDocumentoIdentidad
                    , xmlM.HoraEntrada, xmlM.HoraSalida
                FROM @MarcaAsistenciaXML xmlM
                INNER JOIN dbo.Empleado e
                ON e.ValorDocumento = xmlM.ValorDocumentoIdentidad AND e.Activo = 1
                WHERE xmlM.Fecha = @fechaOp;

                WHILE EXISTS (SELECT 1 FROM @MarcasDeLaFecha WHERE Procesado = 0)
                BEGIN
                    DECLARE @currRnLocal INT, @currIdEmpleado INT, @currDoc VARCHAR(32)
                    , @currEntrada DATETIME, @currSalida DATETIME, @currInsertedId INT;

                    SELECT TOP (1) @currRnLocal = rnLocal, @currIdEmpleado = idEmpleado
                        , @currDoc = ValorDoc, @currEntrada = HoraEntrada, @currSalida = HoraSalida
                    FROM @MarcasDeLaFecha
                    WHERE Procesado = 0
                    ORDER BY rnLocal;

                    INSERT INTO dbo.MarcaAsistencia (idEmpleado, Fecha, HoraEntrada, HoraSalida)
                    VALUES (@currIdEmpleado, @fechaOp, @currEntrada, @currSalida);

                    SET @currInsertedId = SCOPE_IDENTITY();

                    INSERT INTO @MarcasHoyConId (rnLocal, idMarcaAsistencia)
                    VALUES (@currRnLocal, @currInsertedId);
                    UPDATE @MarcasDeLaFecha
                    SET Procesado = 1
                    WHERE rnLocal = @currRnLocal;
                END

                -- Procesar cálculo de asistencias
                WHILE EXISTS (SELECT 1 FROM @MarcasHoyConId)
                BEGIN
                    DECLARE @idMarcaActual INT
                        , @rnActual INT
                        , @rcAsistencia INT;

                    DECLARE @dbgIdEmpleado INT
                        , @dbgDoc VARCHAR(32);

                    SELECT TOP (1) @rnActual = rnLocal, @idMarcaActual = idMarcaAsistencia
                    FROM @MarcasHoyConId
                    ORDER BY rnLocal;
                    
                    SELECT @dbgIdEmpleado = idEmpleado
                    FROM dbo.MarcaAsistencia
                    WHERE id = @idMarcaActual;
                    SELECT @dbgDoc = ValorDocumento
                    FROM dbo.Empleado
                    WHERE id = @dbgIdEmpleado;

                    EXEC dbo.sp_ProcesarAsistencia @inIdMarcaAsistencia = @idMarcaActual
                        , @outResultCode = @rcAsistencia OUTPUT;

                    IF @rcAsistencia <> 0
                    BEGIN

                        SET @outResultCode = @rcAsistencia;
                        ROLLBACK TRANSACTION;
                        RETURN;

                    END

                    DELETE
                    FROM @MarcasHoyConId
                    WHERE rnLocal = @rnActual;
                END;

                -- LÓGICA DE JUEVES (Cierres de planilla y enlace de Calendarios)
                DECLARE @diaDeLaSemana INT = DATEPART(WEEKDAY, @fechaOp);

                IF @diaDeLaSemana = 5 
                BEGIN

                    INSERT INTO dbo.HorarioJornada (idEmpleado, idSemana, idTipoJornada)
                    SELECT e.id, s.id, tj.id
                    FROM @AsignarJornadaXML aj
                    INNER JOIN dbo.Empleado e ON e.ValorDocumento = aj.ValorDocumentoIdentidad
                    INNER JOIN dbo.TipoJornada tj ON tj.Nombre = aj.Jornada
                    INNER JOIN dbo.Semana s ON s.FechaInicio = aj.InicioSemana
                    WHERE aj.Fecha = @fechaOp;
                    
                    DECLARE @viernesSiguiente DATE = DATEADD(DAY, 1, @fechaOp);
                    DECLARE @idSemanaNueva INT = NULL;
                    DECLARE @esPrimerViernesMes BIT = 0;

                    -- Determina si el viernes de mañana pertenece a un mes diferente al viernes de la semana pasada
                    IF MONTH(@viernesSiguiente) <> MONTH(DATEADD(DAY, -7, @viernesSiguiente))
                        SET @esPrimerViernesMes = 1;

                    DECLARE @rc INT;

                    IF @esPrimerViernesMes = 1 AND @fechaId > 1
                    BEGIN
                        
                        -- Se llama el procedimiento bajo la instrucción de que este abre el mes siguiente internamente
                        EXEC dbo.sp_ProcesarPlanillaMensual @inFechaJueves = @fechaOp, @outResultCode = @rc OUTPUT;
                        
                        IF @rc <> 0
                        BEGIN
                            SET @outResultCode = @rc;
                            ROLLBACK TRANSACTION;
                            RETURN;
                        END
                        
                        SELECT @idSemanaNueva = s.id FROM dbo.Semana s WHERE s.FechaInicio = @viernesSiguiente;
                    END
                    ELSE IF @esPrimerViernesMes = 0 AND @fechaId > 1
                    BEGIN
                        EXEC dbo.sp_ProcesarPlanillaSemanal @inFechaJueves = @fechaOp, @outResultCode = @rc OUTPUT;
                        IF @rc <> 0
                        BEGIN
                            SET @outResultCode = @rc;
                            ROLLBACK TRANSACTION;
                            RETURN;
                        END
                        
                        SELECT @idSemanaNueva = s.id
                        FROM dbo.Semana s
                        WHERE s.FechaInicio = @viernesSiguiente;
                    END
                    ELSE
                    BEGIN
                        SELECT @idSemanaNueva = s.id
                        FROM dbo.Semana s
                        WHERE s.FechaInicio = @viernesSiguiente;
                    END

                    -- Abrir las estructuras semanales de la planilla para el viernes entrante
                    IF @idSemanaNueva IS NOT NULL
                    AND NOT EXISTS (SELECT 1 
                                    FROM dbo.PlanillaSemanal
                                    WHERE idSemana = @idSemanaNueva)
                    BEGIN
                        INSERT INTO dbo.PlanillaSemanal (idSemana, idEmpleado
                            , SalarioBruto, TotalDeducciones, SalarioNeto)
                        SELECT @idSemanaNueva, id, 0.00, 0.00, 0.00
                        FROM dbo.Empleado
                        WHERE Activo = 1;
                    END
                END;

                SET @fechaId = @fechaId + 1;
            END;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;

        INSERT INTO dbo.DBError (
            UserName
            , Number
            , State
            , Severity
            , Line
            , [Procedure]
            , [Message]
            , [DateTime]
            )
        VALUES (
            SUSER_SNAME()
            , ERROR_NUMBER()
            , ERROR_STATE()
            , ERROR_SEVERITY()
            , ERROR_LINE()
            , ERROR_PROCEDURE()
            , ERROR_MESSAGE()
            , GETDATE()
            );

        SET @outResultCode = 50508;
        RETURN;
    END CATCH;
END;
GO