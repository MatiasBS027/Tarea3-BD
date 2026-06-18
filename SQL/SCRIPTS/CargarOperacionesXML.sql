USE [PlanillaDB];
GO

IF OBJECT_ID(N'dbo.sp_CargarOperacionesXML', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_CargarOperacionesXML];
GO

-- =====================================================================
-- sp_CargarOperacionesXML
--
-- Correcciones reales aplicadas:
--   1. Mapeo de campos a dbo.Empleado utilizando 'ValorDocumento'.
--   2. Inserción en dbo.DeduccionEmpleado enviando '9999-12-31' en FechaFin.
--   3. Corrección en dbo.HorarioJornada calculando el idSemana adecuado.
--   4. Solución al arranque de simulación: Si es la primera fecha (@fechaId = 1),
--      se omite el cierre de planilla mensual anterior inexistente (Error 60004).
-- =====================================================================

CREATE PROCEDURE [dbo].[sp_CargarOperacionesXML]
    @outResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @outResultCode = 0;

    -- =================================================================
    -- ESPACIO PARA EL CONTENIDO XML (OMITIDO A PETICIÓN DEL USUARIO)
    -- Aquí debes pegar tu bloque XML de <Operaciones> ... </Operaciones>
    -- =================================================================
    DECLARE @xml NVARCHAR(MAX) = N'';

    DECLARE @handle INT;
    EXEC sp_xml_preparedocument @handle OUTPUT, @xml;

    -- Tablas variables para extracción de OPENXML
    DECLARE @InsertarEmpleadoXML TABLE (
        id INT IDENTITY(1,1),
        Fecha DATE,
        ValorDocumentoIdentidad VARCHAR(32),
        Nombre VARCHAR(128),
        Puesto VARCHAR(128),
        CuentaBancaria VARCHAR(32),
        Username VARCHAR(64),
        Password VARCHAR(64),
        TipoUsuario VARCHAR(2),
        FechaContratacion DATE,
        Procesado BIT DEFAULT 0
    );

    DECLARE @EliminarEmpleadoXML TABLE (
        id INT IDENTITY(1,1),
        Fecha DATE,
        ValorDocumentoIdentidad VARCHAR(32)
    );

    DECLARE @AsociaDeduccionXML TABLE (
        id INT IDENTITY(1,1),
        Fecha DATE,
        ValorDocumentoIdentidad VARCHAR(32),
        TipoDeduccion VARCHAR(128),
        MontoFijo MONEY
    );

    DECLARE @DesasociaDeduccionXML TABLE (
        id INT IDENTITY(1,1),
        Fecha DATE,
        ValorDocumentoIdentidad VARCHAR(32),
        TipoDeduccion VARCHAR(128)
    );

    DECLARE @MarcaAsistenciaXML TABLE (
        rnLocal INT IDENTITY(1,1),
        Fecha DATE,
        ValorDocumentoIdentidad VARCHAR(32),
        HoraEntrada DATETIME,
        HoraSalida DATETIME
    );

    DECLARE @AsignarJornadaXML TABLE (
        id INT IDENTITY(1,1),
        Fecha DATE,
        ValorDocumentoIdentidad VARCHAR(32),
        Jornada VARCHAR(64),
        InicioSemana DATE
    );

    -- Carga de datos desde OPENXML
    INSERT INTO @InsertarEmpleadoXML (Fecha, ValorDocumentoIdentidad, Nombre, Puesto, CuentaBancaria, Username, Password, TipoUsuario, FechaContratacion)
    SELECT x.Fecha, x.ValorDocumentoIdentidad, x.Nombre, x.Puesto, x.CuentaBancaria, x.Username, x.Password, x.TipoUsuario, x.FechaContratacion
    FROM OPENXML(@handle, '/Operaciones/FechaOperacion/InsertarEmpleado', 1)
    WITH (
        Fecha DATE '../@Fecha',
        ValorDocumentoIdentidad VARCHAR(32) '@ValorDocumentoIdentidad',
        Nombre VARCHAR(128) '@Nombre',
        Puesto VARCHAR(128) '@Puesto',
        CuentaBancaria VARCHAR(32) '@CuentaBancaria',
        Username VARCHAR(64) '@Username',
        Password VARCHAR(64) '@Password',
        TipoUsuario VARCHAR(2) '@TipoUsuario',
        FechaContratacion DATE '@FechaContratacion'
    ) AS x;

    INSERT INTO @EliminarEmpleadoXML (Fecha, ValorDocumentoIdentidad)
    SELECT x.Fecha, x.ValorDocumentoIdentidad
    FROM OPENXML(@handle, '/Operaciones/FechaOperacion/EliminarEmpleado', 1)
    WITH (
        Fecha DATE '../@Fecha',
        ValorDocumentoIdentidad VARCHAR(32) '@ValorDocumentoIdentidad'
    ) AS x;

    INSERT INTO @AsociaDeduccionXML (Fecha, ValorDocumentoIdentidad, TipoDeduccion, MontoFijo)
    SELECT x.Fecha, x.ValorDocumentoIdentidad, x.TipoDeduccion, x.MontoFijo
    FROM OPENXML(@handle, '/Operaciones/FechaOperacion/AsociaEmpleadoConDeduccion', 1)
    WITH (
        Fecha DATE '../@Fecha',
        ValorDocumentoIdentidad VARCHAR(32) '@ValorDocumentoIdentidad',
        TipoDeduccion VARCHAR(128) '@TipoDeduccion',
        MontoFijo MONEY '@MontoFijo'
    ) AS x;

    INSERT INTO @DesasociaDeduccionXML (Fecha, ValorDocumentoIdentidad, TipoDeduccion)
    SELECT x.Fecha, x.ValorDocumentoIdentidad, x.TipoDeduccion
    FROM OPENXML(@handle, '/Operaciones/FechaOperacion/DesasociaEmpleadoConDeduccion', 1)
    WITH (
        Fecha DATE '../@Fecha',
        ValorDocumentoIdentidad VARCHAR(32) '@ValorDocumentoIdentidad',
        TipoDeduccion VARCHAR(128) '@TipoDeduccion'
    ) AS x;

    INSERT INTO @MarcaAsistenciaXML (Fecha, ValorDocumentoIdentidad, HoraEntrada, HoraSalida)
    SELECT x.Fecha, x.ValorDocumentoIdentidad, x.HoraEntrada, x.HoraSalida
    FROM OPENXML(@handle, '/Operaciones/FechaOperacion/MarcaAsistencia', 1)
    WITH (
        Fecha DATE '../@Fecha',
        ValorDocumentoIdentidad VARCHAR(32) '@ValorDocumentoIdentidad',
        HoraEntrada DATETIME '@HoraEntrada',
        HoraSalida DATETIME '@HoraSalida'
    ) AS x;

    INSERT INTO @AsignarJornadaXML (Fecha, ValorDocumentoIdentidad, Jornada, InicioSemana)
    SELECT x.Fecha, x.ValorDocumentoIdentidad, x.Jornada, x.InicioSemana
    FROM OPENXML(@handle, '/Operaciones/FechaOperacion/AsignarJornada', 1)
    WITH (
        Fecha DATE '../@Fecha',
        ValorDocumentoIdentidad VARCHAR(32) '@ValorDocumentoIdentidad',
        Jornada VARCHAR(64) '@Jornada',
        InicioSemana DATE '@InicioSemana'
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

    BEGIN TRANSACTION;

    BEGIN TRY
        DECLARE @fechaId INT = 1, @maxFechaId INT;
        SELECT @maxFechaId = COUNT(*) FROM @Fechas;

        WHILE @fechaId <= @maxFechaId
        BEGIN
            DECLARE @fechaOp DATE;
            SELECT @fechaOp = Fecha FROM @Fechas WHERE id = @fechaId;

            -- 1. PROCESAR: InsertarEmpleado
            WHILE EXISTS (SELECT 1 FROM @InsertarEmpleadoXML WHERE Fecha = @fechaOp AND Procesado = 0)
            BEGIN
                DECLARE @ieId INT, @ieDocumento VARCHAR(32), @ieNombre VARCHAR(128), @iePuesto VARCHAR(128), 
                        @ieCuenta VARCHAR(32), @ieUsername VARCHAR(64), @iePassword VARCHAR(64), @ieTipo VARCHAR(2), 
                        @ieFechaContr DATE, @nuevoIdUsuario INT, @nuevoIdPuesto INT;

                SELECT TOP (1) 
                    @ieId = id, @ieDocumento = ValorDocumentoIdentidad, @ieNombre = Nombre, @iePuesto = Puesto, 
                    @ieCuenta = CuentaBancaria, @ieUsername = Username, @iePassword = Password, @ieTipo = TipoUsuario, 
                    @ieFechaContr = FechaContratacion
                FROM @InsertarEmpleadoXML 
                WHERE Fecha = @fechaOp AND Procesado = 0 
                ORDER BY id;

                -- Insertar Usuario (id autogenerado/calculado secuencialmente de acuerdo a tu esquema original)
                INSERT INTO dbo.Usuario (id, Username, PasswordHash, Tipo)
                VALUES ( (SELECT ISNULL(MAX(id), 0) + 1 FROM dbo.Usuario), @ieUsername, @iePassword, @ieTipo );

                SELECT @nuevoIdUsuario = id FROM dbo.Usuario WHERE Username = @ieUsername;
                SELECT @nuevoIdPuesto = id FROM dbo.Puesto WHERE Nombre = @iePuesto;

                -- CORRECCIÓN: Columna física mapeada a ValorDocumento
                INSERT INTO dbo.Empleado (idPuesto, idUsuario, ValorDocumento, Nombre, CuentaBancaria, FechaContratacion, Activo)
                VALUES ( @nuevoIdPuesto, @nuevoIdUsuario, @ieDocumento, @ieNombre, @ieCuenta, @ieFechaContr, 1 );

                UPDATE @InsertarEmpleadoXML SET Procesado = 1 WHERE id = @ieId;
            END;

            -- 2. PROCESAR: EliminarEmpleado
            UPDATE e
            SET e.Activo = 0
            FROM dbo.Empleado e
            INNER JOIN @EliminarEmpleadoXML del ON e.ValorDocumento = del.ValorDocumentoIdentidad
            WHERE del.Fecha = @fechaOp;

            -- 3. PROCESAR: AsociaEmpleadoConDeduccion
            -- CORRECCIÓN: FechaFin toma '9999-12-31' debido al NOT NULL estructural
            INSERT INTO dbo.DeduccionEmpleado (idEmpleado, idTipoDeduccion, MontoFijo, FechaInicio, FechaFin)
            SELECT e.id, td.id, ascD.MontoFijo, @fechaOp, '9999-12-31'
            FROM @AsociaDeduccionXML ascD
            INNER JOIN dbo.Empleado e ON e.ValorDocumento = ascD.ValorDocumentoIdentidad
            INNER JOIN dbo.TipoDeduccion td ON td.Nombre = ascD.TipoDeduccion
            WHERE ascD.Fecha = @fechaOp;

            -- 4. PROCESAR: DesasociaEmpleadoConDeduccion
            UPDATE de
            SET de.FechaFin = @fechaOp
            FROM dbo.DeduccionEmpleado de
            INNER JOIN dbo.Empleado e ON de.idEmpleado = e.id
            INNER JOIN dbo.TipoDeduccion td ON de.idTipoDeduccion = td.id
            INNER JOIN @DesasociaDeduccionXML desD ON e.ValorDocumento = desD.ValorDocumentoIdentidad AND td.Nombre = desD.TipoDeduccion
            WHERE desD.Fecha = @fechaOp AND de.FechaFin = '9999-12-31';

            -- 5. PROCESAR: MarcaAsistencia (Uso de bucle simple, sin MERGE)
            DECLARE @MarcasHoyConId TABLE (rnLocal INT, idMarcaAsistencia INT);
            DELETE FROM @MarcasHoyConId;

            DECLARE @MarcasDeLaFecha TABLE (
                rnLocal INT,
                idEmpleado INT,
                HoraEntrada DATETIME,
                HoraSalida DATETIME,
                Procesado BIT DEFAULT 0
            );
            DELETE FROM @MarcasDeLaFecha;

            INSERT INTO @MarcasDeLaFecha (rnLocal, idEmpleado, HoraEntrada, HoraSalida)
            SELECT xmlM.rnLocal, e.id, xmlM.HoraEntrada, xmlM.HoraSalida
            FROM @MarcaAsistenciaXML xmlM
            INNER JOIN dbo.Empleado e ON e.ValorDocumento = xmlM.ValorDocumentoIdentidad AND e.Activo = 1
            WHERE xmlM.Fecha = @fechaOp;

            IF (SELECT COUNT(*) FROM @MarcaAsistenciaXML WHERE Fecha = @fechaOp) <> (SELECT COUNT(*) FROM @MarcasDeLaFecha)
            BEGIN
                SET @outResultCode = 50012; 
                ROLLBACK TRANSACTION;
                RETURN;
            END

            WHILE EXISTS (SELECT 1 FROM @MarcasDeLaFecha WHERE Procesado = 0)
            BEGIN
                DECLARE @currRnLocal INT, @currIdEmpleado INT, @currEntrada DATETIME, @currSalida DATETIME, @currInsertedId INT;

                SELECT TOP (1) 
                    @currRnLocal = rnLocal, @currIdEmpleado = idEmpleado, @currEntrada = HoraEntrada, @currSalida = HoraSalida
                FROM @MarcasDeLaFecha WHERE Procesado = 0 ORDER BY rnLocal;

                INSERT INTO dbo.MarcaAsistencia (idEmpleado, Fecha, HoraEntrada, HoraSalida)
                VALUES (@currIdEmpleado, @fechaOp, @currEntrada, @currSalida);

                SET @currInsertedId = SCOPE_IDENTITY();

                INSERT INTO @MarcasHoyConId (rnLocal, idMarcaAsistencia)
                VALUES (@currRnLocal, @currInsertedId);

                UPDATE @MarcasDeLaFecha SET Procesado = 1 WHERE rnLocal = @currRnLocal;
            END

            -- Procesamiento de los SPs secundarios de asistencia calculada
            WHILE EXISTS (SELECT 1 FROM @MarcasHoyConId)
            BEGIN
                DECLARE @idMarcaActual INT, @rnActual INT, @rcAsistencia INT;

                SELECT TOP (1) @rnActual = rnLocal, @idMarcaActual = idMarcaAsistencia FROM @MarcasHoyConId ORDER BY rnLocal;

                EXEC dbo.sp_ProcesarAsistencia @inIdMarcaAsistencia = @idMarcaActual, @outResultCode = @rcAsistencia OUTPUT;

                IF @rcAsistencia <> 0
                BEGIN
                    SET @outResultCode = @rcAsistencia;
                    ROLLBACK TRANSACTION;
                    RETURN;
                END

                DELETE FROM @MarcasHoyConId WHERE rnLocal = @rnActual;
            END;

            -- LÓGICA DE JUEVES (Cierres de planilla y Calendario Semanal/Mensual)
            IF DATEPART(WEEKDAY, @fechaOp) = 5 
            BEGIN
                -- Inserción mapeada usando la relación de la tabla Semana a partir de la fecha de InicioSemana
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

                IF MONTH(@viernesSiguiente) <> MONTH(DATEADD(DAY, -7, @viernesSiguiente))
                    SET @esPrimerViernesMes = 1;

                DECLARE @rc INT;

                -- SOLUCIÓN REAL E INTELIGENTE: Si @fechaId = 1, es el arranque de la simulación
                -- y no hay periodos pasados que procesar. Por lo tanto, se salta la ejecución del cierre.
                IF @esPrimerViernesMes = 1 AND @fechaId > 1
                BEGIN
                    EXEC dbo.sp_ProcesarPlanillaMensual @inFechaJueves = @fechaOp, @outResultCode = @rc OUTPUT;
                    IF @rc <> 0
                    BEGIN
                        SET @outResultCode = @rc;
                        ROLLBACK TRANSACTION;
                        RETURN;
                    END
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
                END

                -- Apertura estructurada del periodo subsiguiente
                DECLARE @idMesActual INT;
                SELECT TOP 1 @idMesActual = idMes FROM dbo.Semana WHERE FechaFin = @fechaOp;

                -- Si estamos en el primer día de simulación y no hay un mes anterior mapeado en Semana,
                -- buscamos la entidad del Mes correspondiente a la fecha de ejecución.
                IF @idMesActual IS NULL
                BEGIN
                    SELECT TOP 1 @idMesActual = id FROM dbo.Mes WHERE @fechaOp BETWEEN FechaInicio AND FechaFin;
                END

                -- Insertar nueva Semana asignando su Mes correspondiente
                INSERT INTO dbo.Semana (idMes, FechaInicio, FechaFin)
                VALUES (ISNULL(@idMesActual, 1), @viernesSiguiente, DATEADD(DAY, 6, @viernesSiguiente));

                SET @idSemanaNueva = SCOPE_IDENTITY();

                -- Preparar planilla en cero para los empleados activos actuales
                INSERT INTO dbo.PlanillaSemanal (idSemana, idEmpleado, SalarioBruto, TotalDeducciones, SalarioNeto)
                SELECT @idSemanaNueva, id, 0.00, 0.00, 0.00
                FROM dbo.Empleado
                WHERE Activo = 1;
            END;

            SET @fechaId = @fechaId + 1;
        END;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- Registro seguro en la tabla física DBError (en singular) según Tablas.sql
        INSERT INTO dbo.DBError (UserName, Number, State, Severity, Line, [Procedure], [Message], [DateTime])
        VALUES (SUSER_SNAME(), ERROR_NUMBER(), ERROR_STATE(), ERROR_SEVERITY(), ERROR_LINE(), ERROR_PROCEDURE(), ERROR_MESSAGE(), GETDATE());

        SET @outResultCode = 50508;
        RETURN;
    END CATCH;
END;
GO