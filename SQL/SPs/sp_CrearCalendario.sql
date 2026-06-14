USE [PlanillaDB];
GO

-- =====================================================
-- SP: Crear Mes y Semanas del ciclo planilla
-- 
-- El mes planilla va del ultimo viernes del mes anterior
-- al ultimo jueves del mes presente. Se llama cuando se
-- detecta que mañana es el primer viernes del nuevo ciclo.
--
-- =====================================================
IF OBJECT_ID(N'dbo.sp_CrearCalendario', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_CrearCalendario];
GO

CREATE PROCEDURE [dbo].[sp_CrearCalendario]
    @inFechaInicioMes  DATE,   -- Viernes que inicia el nuevo ciclo
    @outResultCode     INT OUTPUT,
    @outIdMes          INT OUTPUT    -- Id del mes creado
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SET @outResultCode = 0;
    SET @outIdMes      = NULL;

    DECLARE
        @fechaInicioSemana DATE,
        @fechaFinSemana    DATE,
        @fechaFinMes       DATE,
        @numJueves         TINYINT,
        @contadorJueves    TINYINT,
        @diaActual         DATE,
        @idMes             INT,
        @idSemana          INT;

    BEGIN TRY

        --   Validación: @inFechaInicioMes debe ser viernes (DATEPART devuelve 6)
        IF DATEPART(WEEKDAY, @inFechaInicioMes) <> 6
        BEGIN
            SET @outResultCode = 60001;     -- La fecha de inicio no es viernes
            RETURN;
        END

        --    Validación: el mes no debe existir ya
        IF EXISTS (
            SELECT 1
            FROM dbo.Mes
            WHERE FechaInicio = @inFechaInicioMes
        )
        BEGIN
            SET @outResultCode = 60002;     -- Ya existe un Mes con esa fecha de inicio
            RETURN;
        END

        -- ============================================================================
        -- Calcular FechaFin del mes (último jueves del ciclo) y NumJueves.
        --
        -- La semana empieza viernes y termina jueves. Recorremos semana a semana desde
        -- @inFechaInicioMes contando los jueves hasta que el PRÓXIMO viernes
        -- ya pertenezca al siguiente mes calendario (es decir, el jueves
        -- actual es el último del mes).
        -- ============================================================================
        SET @contadorJueves  = 0;
        SET @fechaFinMes     = NULL;
        SET @fechaInicioSemana = @inFechaInicioMes;

        WHILE 1 = 1
        BEGIN
            -- El jueves de esta semana es 6 días después del viernes de inicio
            SET @fechaFinSemana = DATEADD(DAY, 6, @fechaInicioSemana);
            SET @contadorJueves = @contadorJueves + 1;

            -- El próximo viernes es un día después de este jueves
            DECLARE @proximoViernes DATE = DATEADD(DAY, 1, @fechaFinSemana);

            -- Si el próximo viernes cae en un mes calendario distinto
            -- al mes calendario del jueves actual significa este jueves es el último
            IF MONTH(@proximoViernes) <> MONTH(@fechaFinSemana)
                OR YEAR(@proximoViernes)  <> YEAR(@fechaFinSemana)
            BEGIN
                SET @fechaFinMes = @fechaFinSemana;
                BREAK;
            END

            -- Avanzar a la siguiente semana
            SET @fechaInicioSemana = @proximoViernes;
        END

        SET @numJueves = @contadorJueves;

        -- ========= Insertar Mes =============
        BEGIN TRANSACTION;

            INSERT INTO dbo.Mes (FechaInicio, FechaFin, NumJueves)
            VALUES (@inFechaInicioMes, @fechaFinMes, @numJueves);

            SET @idMes = SCOPE_IDENTITY();

            -- ==== Insertar Semanas (una por cada jueves contado) ====
            SET @fechaInicioSemana = @inFechaInicioMes;

            DECLARE @i TINYINT = 0;
            WHILE @i < @numJueves
            BEGIN
                SET @fechaFinSemana = DATEADD(DAY, 6, @fechaInicioSemana);

                INSERT INTO dbo.Semana (idMes, FechaInicio, FechaFin)
                VALUES (@idMes, @fechaInicioSemana, @fechaFinSemana);

                SET @fechaInicioSemana = DATEADD(DAY, 1, @fechaFinSemana); -- siguiente viernes
                SET @i = @i + 1;
            END

        COMMIT TRANSACTION;

        SET @outIdMes      = @idMes;
        SET @outResultCode = 0;

    END TRY
    BEGIN CATCH

        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;

        INSERT INTO dbo.DBError (
            UserName, Number, State, Severity,
            Line, [Procedure], Message, DateTime
        )
        VALUES (
            SYSTEM_USER,
            ERROR_NUMBER(),
            ERROR_STATE(),
            ERROR_SEVERITY(),
            ERROR_LINE(),
            ISNULL(ERROR_PROCEDURE(), 'sp_CrearCalendario'),
            ERROR_MESSAGE(),
            GETDATE()
        );

        SET @outResultCode = 50008;     -- Error inesperado de BD

    END CATCH
END;
GO