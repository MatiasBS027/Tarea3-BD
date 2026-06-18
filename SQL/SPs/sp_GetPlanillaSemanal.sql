USE [PlanillaDB];
GO

-- =====================================================================
-- SP: sp_GetPlanillaSemanal (R04)
--
-- Devuelve 3 result sets para el empleado indicado:
--
--  1) GRID PRINCIPAL: últimas @inCantidadSemanas planillas semanales,
--     con SalarioBruto, TotalDeducciones, SalarioNeto y la cantidad de
--     horas ordinarias / extra normales / extra dobles de cada semana
--     (agregadas desde MovHoras, ya que PlanillaSemanal no las guarda
--     -- ver AGENTS.md, denormalización evitada).
--
--  2) DETALLE DE DEDUCCIONES: una fila por cada deducción aplicada en
--     cada una de las planillas devueltas en (1). Incluye nombre de la
--     deducción, si es porcentual y el porcentaje aplicado, y el monto
--     (tomado de MovPlanilla, ya calculado por sp_ProcesarPlanillaSemanal).
--     El front filtra por idPlanillaSemanal al hacer click en el monto
--     de deducciones de la fila correspondiente.
--
--  3) DETALLE DE ASISTENCIA/MOVIMIENTOS: una fila por cada movimiento
--     (MovHoras) generado por cada marca de asistencia, para todas las
--     semanas devueltas en (1). Incluye fecha, hora entrada, hora
--     salida, tipo de movimiento (ordinaria/extra normal/extra doble),
--     horas y monto devengado. El front filtra por idPlanillaSemanal
--     (o por el rango de fechas de la semana) al hacer click en el
--     salario bruto de la fila correspondiente.
--
-- R07 Trazabilidad: se inserta en BitacoraEvento (TipoEvento = 20,
-- "Consultar planilla semanal") con Empleado.Id, FechaInicio y FechaFin
-- del rango total consultado.
-- =====================================================================

IF OBJECT_ID(N'dbo.sp_GetPlanillaSemanal', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_GetPlanillaSemanal];
GO

CREATE PROCEDURE [dbo].[sp_GetPlanillaSemanal]
    @inIdEmpleado INT,
    @inCantidadSemanas INT = 10,
    @inIdUsuario INT = NULL,
    @inIpPostIn VARCHAR(64) = NULL,
    @inPostTime DATETIME = NULL,
    @outResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    SET @outResultCode = 0;

    DECLARE
        @idTipoEvento   INT,
        @descripcion    VARCHAR(512),
        @fechaInicioRng DATE,
        @fechaFinRng    DATE;

    BEGIN TRY

        IF @inCantidadSemanas IS NULL OR @inCantidadSemanas < 1
            SET @inCantidadSemanas = 10;

        -- ============================================================
        -- 0. Validar empleado
        -- ============================================================
        IF NOT EXISTS (SELECT 1 FROM dbo.Empleado WHERE id = @inIdEmpleado AND Activo = 1)
        BEGIN
            SET @outResultCode = 50012;
            RETURN;
        END

        -- ============================================================
        -- 1. Últimas @inCantidadSemanas planillas semanales del empleado
        -- ============================================================
        SELECT TOP (@inCantidadSemanas)
            ps.id AS idPlanillaSemanal,
            ps.idSemana,
            s.FechaInicio,
            s.FechaFin,
            ps.SalarioBruto,
            ps.TotalDeducciones,
            ps.SalarioNeto
        INTO #PlanillasSemanales
        FROM dbo.PlanillaSemanal ps
        INNER JOIN dbo.Semana s ON s.id = ps.idSemana
        WHERE ps.idEmpleado = @inIdEmpleado
        ORDER BY s.FechaFin DESC;

        SELECT
            pls.idPlanillaSemanal,
            pls.idSemana,
            pls.FechaInicio,
            pls.FechaFin,
            pls.SalarioBruto,
            pls.TotalDeducciones,
            pls.SalarioNeto,
            ISNULL(ho.QHorasOrdinarias, 0)      AS QHorasOrdinarias,
            ISNULL(he.QHorasExtraNormales, 0)   AS QHorasExtraNormales,
            ISNULL(hd.QHorasExtraDobles, 0)     AS QHorasExtraDobles
        FROM #PlanillasSemanales pls
        OUTER APPLY (
            SELECT SUM(mh.QHoras) AS QHorasOrdinarias
            FROM dbo.MovHoras mh
            INNER JOIN dbo.MarcaAsistencia ma ON ma.id = mh.idAsistencia
            WHERE mh.idTipoMov = 1
              AND ma.idEmpleado = @inIdEmpleado
              AND ma.Fecha BETWEEN pls.FechaInicio AND pls.FechaFin
        ) ho
        OUTER APPLY (
            SELECT SUM(mh.QHoras) AS QHorasExtraNormales
            FROM dbo.MovHoras mh
            INNER JOIN dbo.MarcaAsistencia ma ON ma.id = mh.idAsistencia
            WHERE mh.idTipoMov = 2
              AND ma.idEmpleado = @inIdEmpleado
              AND ma.Fecha BETWEEN pls.FechaInicio AND pls.FechaFin
        ) he
        OUTER APPLY (
            SELECT SUM(mh.QHoras) AS QHorasExtraDobles
            FROM dbo.MovHoras mh
            INNER JOIN dbo.MarcaAsistencia ma ON ma.id = mh.idAsistencia
            WHERE mh.idTipoMov = 3
              AND ma.idEmpleado = @inIdEmpleado
              AND ma.Fecha BETWEEN pls.FechaInicio AND pls.FechaFin
        ) hd
        ORDER BY pls.FechaFin DESC;

        -- ============================================================
        -- 2. Detalle de deducciones por planilla semanal (click en
        --    TotalDeducciones). El front filtra por idPlanillaSemanal.
        -- ============================================================
        SELECT
            mp.idPlanillaSemanal,
            td.id        AS idTipoDeduccion,
            td.Nombre    AS NombreDeduccion,
            td.EsPorcentual,
            CASE WHEN td.EsPorcentual = 1 THEN td.Valor ELSE NULL END AS PorcentajeAplicado,
            mp.Monto     AS MontoDeduccion
        FROM dbo.MovPlanilla mp
        INNER JOIN #PlanillasSemanales pls ON pls.idPlanillaSemanal = mp.idPlanillaSemanal
        INNER JOIN dbo.TipoMovimiento tm ON tm.id = mp.idTipoMovimiento
        INNER JOIN dbo.TipoDeduccion td ON td.idTipoMovimiento = tm.id
        WHERE tm.Accion = 'D'
        ORDER BY mp.idPlanillaSemanal, td.Nombre ASC;

        -- ============================================================
        -- 3. Detalle por día: hora entrada/salida y movimientos
        --    generados por cada asistencia (click en SalarioBruto).
        --    El front filtra por idPlanillaSemanal.
        -- ============================================================
        SELECT
            pls.idPlanillaSemanal,
            ma.id            AS idMarcaAsistencia,
            ma.Fecha,
            ma.HoraEntrada,
            ma.HoraSalida,
            mh.id            AS idMovHoras,
            tm.id            AS idTipoMovimiento,
            tm.Nombre        AS NombreTipoMovimiento,
            mh.QHoras,
            mh.Monto
        FROM #PlanillasSemanales pls
        INNER JOIN dbo.MarcaAsistencia ma
            ON ma.idEmpleado = @inIdEmpleado
            AND ma.Fecha BETWEEN pls.FechaInicio AND pls.FechaFin
        LEFT JOIN dbo.MovHoras mh ON mh.idAsistencia = ma.id
        LEFT JOIN dbo.TipoMovimiento tm ON tm.id = mh.idTipoMov
        ORDER BY pls.idPlanillaSemanal, ma.Fecha ASC, tm.id ASC;

        -- ============================================================
        -- R07: Trazabilidad — Consultar planilla semanal
        --      (Empleado.Id, FechaInicio y FechaFin del rango consultado)
        -- ============================================================
        SELECT
            @fechaInicioRng = MIN(FechaInicio),
            @fechaFinRng    = MAX(FechaFin)
        FROM #PlanillasSemanales;

        IF @fechaFinRng IS NOT NULL
        BEGIN
            SELECT @idTipoEvento = t.id
            FROM dbo.TipoEvento t
            WHERE t.Nombre = 'Consultar planilla semanal';

            IF @idTipoEvento IS NOT NULL
            BEGIN
                SET @descripcion =
                    'Empleado.Id = ' + CAST(@inIdEmpleado AS VARCHAR(32))
                    + ', FechaInicio = ' + CONVERT(VARCHAR(10), @fechaInicioRng, 23)
                    + ', FechaFin = ' + CONVERT(VARCHAR(10), @fechaFinRng, 23);

                BEGIN TRANSACTION;
                    INSERT INTO dbo.BitacoraEvento (idTipoEvento, idUsuario, PostTime, IpPostIn, Descripcion)
                    VALUES (@idTipoEvento, @inIdUsuario, ISNULL(@inPostTime, GETDATE()), ISNULL(@inIpPostIn, ''), @descripcion);
                COMMIT TRANSACTION;
            END
        END

        SET @outResultCode = 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        INSERT INTO [dbo].[DBError] ([UserName], [Number], [State], [Severity], [Line], [Procedure], [Message], [DateTime])
        VALUES (
            SYSTEM_USER,
            ERROR_NUMBER(),
            ERROR_STATE(),
            ERROR_SEVERITY(),
            ERROR_LINE(),
            ISNULL(ERROR_PROCEDURE(), 'sp_GetPlanillaSemanal'),
            ERROR_MESSAGE(),
            GETDATE()
        );

        SET @outResultCode = 50008;
    END CATCH

    DROP TABLE IF EXISTS #PlanillasSemanales;
END;
GO