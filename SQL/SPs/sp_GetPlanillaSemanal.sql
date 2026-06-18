USE [PlanillaDB];
GO

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
        -- 1. Obtener de forma única las últimas N planillas semanales
        -- ============================================================
        -- El DISTINCT aquí asegura que la tabla temporal base tenga exactamente 1 fila por planilla
        SELECT DISTINCT TOP (@inCantidadSemanas)
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

        -- RESULT SET 1: Grid Principal (Consolidado mediante LEFT JOIN y GROUP BY)
        -- Para evitar que las horas dupliquen las planillas, agrupamos por los campos de la planilla
        SELECT
            pls.idPlanillaSemanal,
            pls.idSemana,
            pls.FechaInicio,
            pls.FechaFin,
            pls.SalarioBruto,
            pls.TotalDeducciones,
            pls.SalarioNeto,
            ISNULL(SUM(CASE WHEN mh.idTipoMov = 1 THEN mh.QHoras END), 0) AS QHorasOrdinarias,
            ISNULL(SUM(CASE WHEN mh.idTipoMov = 2 THEN mh.QHoras END), 0) AS QHorasExtraNormales,
            ISNULL(SUM(CASE WHEN mh.idTipoMov = 3 THEN mh.QHoras END), 0) AS QHorasExtraDobles
        FROM #PlanillasSemanales pls
        LEFT JOIN dbo.MarcaAsistencia ma ON ma.idEmpleado = @inIdEmpleado AND ma.Fecha BETWEEN pls.FechaInicio AND pls.FechaFin
        LEFT JOIN dbo.MovHoras mh ON mh.idAsistencia = ma.id
        GROUP BY 
            pls.idPlanillaSemanal, pls.idSemana, pls.FechaInicio, pls.FechaFin, 
            pls.SalarioBruto, pls.TotalDeducciones, pls.SalarioNeto
        ORDER BY pls.FechaFin DESC;

        -- ============================================================
        -- 2. Detalle de deducciones (Aplanado con DISTINCT)
        -- ============================================================
        -- Si un TipoMovimiento coincide con múltiples registros, el DISTINCT disuelve la repetición visual
        SELECT DISTINCT
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
        -- 3. Detalle por día: Consolidado por Marca de Asistencia con LEFT JOIN
        -- ============================================================
        -- Agrupamos por la Marca de Asistencia para que se devuelva una sola fila por día,
        -- sumando las horas y montos totales de los movimientos correspondientes a esa marca.
        SELECT
            pls.idPlanillaSemanal,
            ma.id            AS idMarcaAsistencia,
            ma.Fecha,
            ma.HoraEntrada,
            ma.HoraSalida,
            ISNULL(SUM(mh.QHoras), 0) AS QHoras,
            ISNULL(SUM(mh.Monto), 0)  AS Monto
        FROM #PlanillasSemanales pls
        INNER JOIN dbo.MarcaAsistencia ma ON ma.idEmpleado = @inIdEmpleado AND ma.Fecha BETWEEN pls.FechaInicio AND pls.FechaFin
        LEFT JOIN dbo.MovHoras mh ON mh.idAsistencia = ma.id
        GROUP BY 
            pls.idPlanillaSemanal, ma.id, ma.Fecha, ma.HoraEntrada, ma.HoraSalida
        ORDER BY pls.idPlanillaSemanal, ma.Fecha ASC;

        -- ============================================================
        -- R07: Trazabilidad — Consultar planilla semanal
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