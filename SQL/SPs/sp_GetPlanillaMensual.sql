USE [PlanillaDB];
GO

IF OBJECT_ID(N'dbo.sp_GetPlanillaMensual', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_GetPlanillaMensual];
GO

CREATE PROCEDURE [dbo].[sp_GetPlanillaMensual]
    @inIdEmpleado INT,
    @inCantidadMeses INT = 6,
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

        IF @inCantidadMeses IS NULL OR @inCantidadMeses < 1
            SET @inCantidadMeses = 6;

        -- ============================================================
        -- 0. Validar empleado
        -- ============================================================
        IF NOT EXISTS (SELECT 1 FROM dbo.Empleado WHERE id = @inIdEmpleado AND Activo = 1)
        BEGIN
            SET @outResultCode = 50012;
            RETURN;
        END

        -- ============================================================
        -- 1. Obtener de forma única las últimas N planillas mensuales
        -- ============================================================
        SELECT TOP (@inCantidadMeses)
            pm.id,
            pm.idMes,
            m.FechaInicio,
            m.FechaFin,
            pm.SalarioBruto,
            pm.TotalDeducciones,
            pm.SalarioNeto
        INTO #PlanillasMensuales
        FROM dbo.PlanillaMensual pm
        INNER JOIN dbo.Mes m ON m.id = pm.idMes
        WHERE pm.idEmpleado = @inIdEmpleado
        GROUP BY 
            pm.id, pm.idMes, m.FechaInicio, m.FechaFin, 
            pm.SalarioBruto, pm.TotalDeducciones, pm.SalarioNeto
        ORDER BY m.FechaFin DESC;

        -- ============================================================
        -- RESULT SET 1: Grid Principal Mensual
        -- ============================================================
        SELECT
            pmm.id AS idPlanillaMensual,
            pmm.idMes,
            pmm.FechaInicio,
            pmm.FechaFin,
            pmm.SalarioBruto,
            pmm.TotalDeducciones,
            pmm.SalarioNeto,
            ISNULL(SUM(CASE WHEN mh.idTipoMov = 1 THEN mh.QHoras END), 0) AS QHorasOrdinarias,
            ISNULL(SUM(CASE WHEN mh.idTipoMov = 2 THEN mh.QHoras END), 0) AS QHorasExtraNormales,
            ISNULL(SUM(CASE WHEN mh.idTipoMov = 3 THEN mh.QHoras END), 0) AS QHorasExtraDobles
        FROM #PlanillasMensuales pmm
        LEFT JOIN dbo.MarcaAsistencia ma ON ma.idEmpleado = @inIdEmpleado AND ma.Fecha BETWEEN pmm.FechaInicio AND pmm.FechaFin
        LEFT JOIN dbo.MovHoras mh ON mh.idAsistencia = ma.id
        GROUP BY 
            pmm.id, pmm.idMes, pmm.FechaInicio, pmm.FechaFin, 
            pmm.SalarioBruto, pmm.TotalDeducciones, pmm.SalarioNeto
        ORDER BY pmm.FechaFin DESC;

        -- ============================================================
        -- RESULT SET 2: Detalle de deducciones mensuales (Usando DeduccionXMes)
        -- ============================================================
        SELECT DISTINCT
            pmm.id        AS idPlanillaMensual,
            td.id         AS idTipoDeduccion,
            td.Nombre     AS NombreDeduccion,
            td.EsPorcentual,
            CASE WHEN td.EsPorcentual = 1 THEN td.Valor ELSE NULL END AS PorcentajeAplicado,
            dxm.MontoTotal AS MontoDeduccion
        FROM dbo.DeduccionXMes dxm
        INNER JOIN #PlanillasMensuales pmm ON pmm.id = dxm.idPlanillaMensual
        INNER JOIN dbo.TipoDeduccion td ON td.id = dxm.idTipoDeduccion
        WHERE dxm.idEmpleado = @inIdEmpleado
        ORDER BY pmm.id ASC, td.Nombre ASC;

        -- ============================================================
        -- RESULT SET 3: Detalle por sub-periodos (Planillas Semanales del mes)
        -- ============================================================
        SELECT
            pmm.id AS idPlanillaMensual,
            ps.id  AS idPlanillaSemanal,
            s.id   AS idSemana,
            s.FechaInicio,
            s.FechaFin,
            ps.SalarioBruto,
            ps.TotalDeducciones,
            ps.SalarioNeto
        FROM #PlanillasMensuales pmm
        INNER JOIN dbo.Semana s ON s.idMes = pmm.idMes
        INNER JOIN dbo.PlanillaSemanal ps ON ps.idSemana = s.id AND ps.idEmpleado = @inIdEmpleado
        GROUP BY 
            pmm.id, ps.id, s.id, s.FechaInicio, s.FechaFin, 
            ps.SalarioBruto, ps.TotalDeducciones, ps.SalarioNeto
        ORDER BY pmm.id ASC, s.FechaInicio ASC;

        -- ============================================================
        -- Trazabilidad — Consultar planilla mensual
        -- ============================================================
        SELECT
            @fechaInicioRng = MIN(FechaInicio),
            @fechaFinRng    = MAX(FechaFin)
        FROM #PlanillasMensuales;

        IF @fechaFinRng IS NOT NULL
        BEGIN
            SELECT @idTipoEvento = t.id
            FROM dbo.TipoEvento t
            WHERE t.Nombre = 'Consultar planilla mensual';

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
            ISNULL(ERROR_PROCEDURE(), 'sp_GetPlanillaMensual'),
            ERROR_MESSAGE(),
            GETDATE()
        );

        SET @outResultCode = 50009;
    END CATCH

    DROP TABLE IF EXISTS #PlanillasMensuales;
END;
GO