USE [PlanillaDB];
GO

IF OBJECT_ID(N'dbo.sp_ProcesarAsistencia', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_ProcesarAsistencia];
GO

-- =====================================================================
-- sp_ProcesarAsistencia
--
-- Procesa una marca de asistencia ya insertada en dbo.MarcaAsistencia.
-- Por cada marca genera hasta 4 MovHoras (puede haber ordinarias y/o
-- extras en dos días distintos cuando la jornada cruza medianoche)
-- y acumula el monto total en PlanillaSemanal.SalarioBruto.
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
        @idEmpleado     INT,
        @fecha          DATE,
        @horaEntrada    DATETIME,
        @horaSalida     DATETIME,
        @salarioXHora   DECIMAL(10, 2),
        @idSemana       INT,
        @idPlanSem      INT,
        @idTipoJornada  INT,
        @jornadaInicio  TIME(0),
        @jornadaFin     TIME(0),
        @horaFinJornada DATETIME,   -- HoraEntrada + duración de jornada (8h)
        @totalMonto     DECIMAL(10, 2) = 0;

    -- ----------------------------------------------------------------
    -- Tabla temporal de segmentos a procesar
    --   TipoSeg: 'O' = ordinario, 'E' = extra
    --   Dia: fecha calendario del segmento
    --   Horas: horas enteras del segmento
    -- ----------------------------------------------------------------
    CREATE TABLE #Segmentos (
        TipoSeg CHAR(1)        NOT NULL,   -- 'O' ordinario | 'E' extra
        Dia     DATE           NOT NULL,
        Horas   INT            NOT NULL,
        Monto   DECIMAL(10,2)  NOT NULL DEFAULT 0
    );

    BEGIN TRY

        -- ============================================================
        -- 1. Leer la marca de asistencia
        -- ============================================================
        SELECT
            @idEmpleado   = ma.idEmpleado,
            @fecha        = ma.Fecha,
            @horaEntrada  = ma.HoraEntrada,
            @horaSalida   = ma.HoraSalida
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

        -- ===============================================================
        -- 3. Obtener la semana activa y la planilla semanal del empleado
        -- ===============================================================
        SELECT @idSemana = s.id
        FROM dbo.Semana s
        WHERE @fecha BETWEEN s.FechaInicio AND s.FechaFin;

        IF @idSemana IS NULL
        BEGIN
            SET @outResultCode = 50008;   -- No hay semana abierta para esta fecha
            RETURN;
        END

        SELECT @idPlanSem = ps.id
        FROM dbo.PlanillaSemanal ps
        WHERE ps.idEmpleado = @idEmpleado
          AND ps.idSemana   = @idSemana;

        IF @idPlanSem IS NULL
        BEGIN
            SET @outResultCode = 50008;   -- No hay PlanillaSemanal abierta
            RETURN;
        END

        -- ============================================================
        -- 4. Obtener la jornada asignada al empleado para esta semana
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
            SET @outResultCode = 60003;   -- Sin jornada asignada para esta semana
            RETURN;
        END

        -- ============================================================
        -- 5. Calcular HoraFinJornada como DATETIME
        -- ============================================================
        SET @horaFinJornada = DATEADD(HOUR, 8, @horaEntrada);

        -- ============================================================
        -- 6. Partir el tiempo trabajado en días.
        -- ============================================================

        -- ---- Jornada ordinaria ----
        DECLARE
            @tramOrdIni  DATETIME = @horaEntrada,
            @tramOrdFin  DATETIME = CASE
                                        WHEN @horaSalida < @horaFinJornada
                                        THEN @horaSalida
                                        ELSE @horaFinJornada
                                    END,
            @cursor      DATETIME,
            @medianoche  DATETIME,
            @horas       INT,
            @diaSeg      DATE;

        -- Partir jornada ordinaria en sub-partes por día
        SET @cursor = @tramOrdIni;
        WHILE @cursor < @tramOrdFin
        BEGIN
            SET @diaSeg     = CAST(@cursor AS DATE);
            SET @medianoche = CAST(DATEADD(DAY, 1, @diaSeg) AS DATETIME);  -- 00:00 del día siguiente

            DECLARE @subFin DATETIME = CASE
                                           WHEN @tramOrdFin < @medianoche THEN @tramOrdFin
                                           ELSE @medianoche
                                       END;

            SET @horas = FLOOR(DATEDIFF(MINUTE, @cursor, @subFin) / 60);

            IF @horas > 0
                INSERT INTO #Segmentos (TipoSeg, Dia, Horas)
                VALUES ('O', @diaSeg, @horas);

            SET @cursor = @subFin;
        END

        -- ---- Parte extra (solo si @horaSalida > @horaFinJornada) ----
        IF @horaSalida > @horaFinJornada
        BEGIN
            DECLARE
                @tramExtIni DATETIME = @horaFinJornada,
                @tramExtFin DATETIME = @horaSalida;

            SET @cursor = @tramExtIni;
            WHILE @cursor < @tramExtFin
            BEGIN
                SET @diaSeg     = CAST(@cursor AS DATE);
                SET @medianoche = CAST(DATEADD(DAY, 1, @diaSeg) AS DATETIME);

                DECLARE @subFinExt DATETIME = CASE
                                                  WHEN @tramExtFin < @medianoche THEN @tramExtFin
                                                  ELSE @medianoche
                                              END;

                SET @horas = FLOOR(DATEDIFF(MINUTE, @cursor, @subFinExt) / 60);

                IF @horas > 0
                    INSERT INTO #Segmentos (TipoSeg, Dia, Horas)
                    VALUES ('E', @diaSeg, @horas);

                SET @cursor = @subFinExt;
            END
        END

        -- ============================================================
        -- 7. Calcular monto de cada parte según tarifa del día
        -- ============================================================
        UPDATE s
        SET s.Monto = s.Horas * @salarioXHora *
            CASE
                -- Día especial (domingo o feriado)
                WHEN DATEPART(WEEKDAY, s.Dia) = 1          -- domingo (@@DATEFIRST=7 por defecto)
                  OR EXISTS (SELECT 1 FROM dbo.Feriado f WHERE f.Fecha = s.Dia)
                THEN
                    CASE s.TipoSeg
                        WHEN 'O' THEN 2.0   -- ordinaria en día especial
                        WHEN 'E' THEN 2.0   -- extra en día especial
                    END
                -- Día normal
                ELSE
                    CASE s.TipoSeg
                        WHEN 'O' THEN 1.0
                        WHEN 'E' THEN 1.5
                    END
            END
        FROM #Segmentos s;

        -- ============================================================
        --  8. Determinar idTipoMov por segmento
        --  Insertar MovHoras y acumular en PlanillaSemanal
        --  Todo en una sola transacción por empleado.
        --  Determinar idTipoMov por segmento
        -- ============================================================
        BEGIN TRANSACTION;

            -- Insertar un MovHoras por cada segmento
            INSERT INTO dbo.MovHoras (QHoras, Monto, idAsistencia, idTipoMov)
            SELECT
                s.Horas,
                s.Monto,
                @inIdMarcaAsistencia,
                CASE
                    WHEN s.TipoSeg = 'O' THEN 1   -- Credito Horas Ordinarias
                    WHEN s.TipoSeg = 'E'
                         AND (DATEPART(WEEKDAY, s.Dia) = 1
                              OR EXISTS (SELECT 1 FROM dbo.Feriado f WHERE f.Fecha = s.Dia))
                         THEN 3                   -- Credito Horas Extra Dobles
                    ELSE 2                        -- Credito Horas Extra Normales
                END
            FROM #Segmentos s;

            -- Acumular total en PlanillaSemanal.SalarioBruto
            SELECT @totalMonto = SUM(Monto) FROM #Segmentos;

            UPDATE dbo.PlanillaSemanal
            SET    SalarioBruto = SalarioBruto + @totalMonto
            WHERE  id = @idPlanSem;

        COMMIT TRANSACTION;

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

    DROP TABLE IF EXISTS #Segmentos;
END;
GO