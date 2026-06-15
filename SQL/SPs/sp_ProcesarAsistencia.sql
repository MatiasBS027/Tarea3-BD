USE [PlanillaDB];
GO

IF OBJECT_ID(N'dbo.sp_ProcesarAsistencia', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_ProcesarAsistencia];
GO

-- =====================================================================
-- sp_ProcesarAsistencia
--
-- Procesa una marca de asistencia ya insertada en dbo.MarcaAsistencia.
-- Genera MovHoras y acumula en PlanillaSemanal.SalarioBruto.
-- =====================================================================
CREATE PROCEDURE [dbo].[sp_ProcesarAsistencia]
    @inIdMarcaAsistencia INT,
    @outResultCode       INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SET @outResultCode = 0;

    DECLARE
        @idEmpleado   INT,
        @fecha        DATE,
        @horaEntrada  DATETIME,
        @horaSalida   DATETIME,
        @salarioXHora DECIMAL(10, 2),
        @idSemana     INT,
        @idPlanSem    INT;

    DECLARE
        @idTipoJornada INT,
        @jornadaInicio TIME(0),
        @jornadaFin    TIME(0);

    BEGIN TRY

        -- ============================================================
        -- 1. Leer la marca de asistencia
        -- ============================================================
        SELECT
            @idEmpleado  = ma.idEmpleado,
            @fecha       = ma.Fecha,
            @horaEntrada = ma.HoraEntrada,
            @horaSalida  = ma.HoraSalida
        FROM dbo.MarcaAsistencia ma
        WHERE ma.id = @inIdMarcaAsistencia;

        IF @idEmpleado IS NULL
        BEGIN
            SET @outResultCode = 50008;
            RETURN;
        END

        -- ============================================================
        -- 2. Obtener puesto y salario
        -- ============================================================
        SELECT @salarioXHora = p.SalarioXHora
        FROM dbo.Empleado e
        INNER JOIN dbo.Puesto p ON p.id = e.idPuesto
        WHERE e.id = @idEmpleado;

        -- ============================================================
        -- 3. Obtener la semana activa y la planilla semanal
        -- ============================================================
        SELECT @idSemana = s.id
        FROM dbo.Semana s
        WHERE @fecha BETWEEN s.FechaInicio AND s.FechaFin;

        IF @idSemana IS NULL
        BEGIN
            SET @outResultCode = 50008;
            RETURN;
        END

        SELECT @idPlanSem = ps.id
        FROM dbo.PlanillaSemanal ps
        WHERE ps.idEmpleado = @idEmpleado
          AND ps.idSemana   = @idSemana;

        IF @idPlanSem IS NULL
        BEGIN
            SET @outResultCode = 50008;
            RETURN;
        END

        -- ============================================================
        -- 4. Obtener jornada asignada para esta semana
        -- ============================================================
        SELECT
            @idTipoJornada = hj.idTipoJornada,
            @jornadaInicio = tj.HoraInicio,
            @jornadaFin    = tj.HoraFin
        FROM dbo.HorarioJornada hj
        INNER JOIN dbo.TipoJornada tj ON tj.id = hj.idTipoJornada
        WHERE hj.idEmpleado = @idEmpleado
          AND hj.idSemana   = @idSemana;

        IF @idTipoJornada IS NULL
        BEGIN
            SET @outResultCode = 60003;
            RETURN;
        END

        -- ============================================================
        -- TODO: Calcular segmentos (ordinarios y extras), tarifas
        --       por día normal / domingo / feriado, insertar MovHoras
        --       y acumular en PlanillaSemanal.SalarioBruto.
        -- ============================================================

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        INSERT INTO dbo.DBError (
            UserName, Number, State, Severity, Line,
            [Procedure], [Message], [DateTime]
        )
        VALUES (
            SUSER_SNAME(),
            ERROR_NUMBER(),
            ERROR_STATE(),
            ERROR_SEVERITY(),
            ERROR_LINE(),
            ISNULL(ERROR_PROCEDURE(), 'sp_ProcesarAsistencia'),
            ERROR_MESSAGE(),
            GETDATE()
        );

        SET @outResultCode = 50008;
    END CATCH;
END;
GO