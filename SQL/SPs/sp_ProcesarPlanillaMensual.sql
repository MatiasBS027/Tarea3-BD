USE [PlanillaDB];
GO

IF OBJECT_ID(N'dbo.sp_ProcesarPlanillaMensual', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_ProcesarPlanillaMensual];
GO

-- =====================================================================
-- sp_ProcesarPlanillaMensual
--
-- Cierre mensual: se ejecuta solo el último jueves del mes,
-- después de sp_ProcesarPlanillaSemanal.
--
-- 1. Crear PlanillaMensual para todos los empleados activos del mes.
-- 2. Acumular SalarioBruto, TotalDeducciones y SalarioNeto sumando
--    todas las semanas del mes desde PlanillaSemanal.
-- 3. Crear/acumular DeduccionXMes sumando todas las semanas del mes.
-- 4. Llamar a sp_CrearCalendario con el primer viernes del siguiente ciclo.
-- 5. Crear filas de PlanillaSemanal en cero para todos los empleados
--    activos en la nueva semana.
-- =====================================================================

CREATE PROCEDURE [dbo].[sp_ProcesarPlanillaMensual]
    @inFechaJueves DATE
    , @outResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SET @outResultCode = 0;

    DECLARE
        @idMes          INT
        , @idSemanaActual INT
        , @proximoViernes DATE
        , @idMesNuevo     INT
        , @idSemanaNueva  INT
        , @rcCalendario   INT;

    BEGIN TRY

        -- ============================================================
        -- 1. Obtener el mes actual a partir del jueves de cierre
        -- ============================================================
        SELECT
            @idMes          = S.idMes
            , @idSemanaActual = S.id
        FROM dbo.Semana S
        WHERE S.FechaFin = @inFechaJueves;

        IF @idMes IS NULL
        BEGIN
            SET @outResultCode = 60004;
            RETURN;
        END

        -- ============================================================
        -- 2. Calcular resumen mensual por empleado en tabla temporal
        --    Suma todas las PlanillaSemanal del mes para cada empleado
        -- ============================================================
        SELECT
            PS.idEmpleado
            , SUM(PS.SalarioBruto) AS SalarioBruto
            , SUM(PS.TotalDeducciones) AS TotalDeducciones
            , SUM(PS.SalarioNeto) AS SalarioNeto
        INTO #ResumenMensual
        FROM dbo.PlanillaSemanal PS
        INNER JOIN dbo.Semana S ON S.id = PS.idSemana
        WHERE S.idMes = @idMes
        GROUP BY PS.idEmpleado;

        -- ============================================================
        -- 3. Calcular DeduccionXMes por empleado y tipo en tabla temporal
        --    Suma todos los MovPlanilla del mes agrupados por tipo
        -- ============================================================
        SELECT
            PS.idEmpleado
            , MP.idTipoMovimiento
            -- Relacionar TipoMovimiento con TipoDeduccion para guardar idTipoDeduccion
            , TD.id AS idTipoDeduccion
            , SUM(MP.Monto) AS MontoTotal
        INTO #ResumenDeducciones
        FROM dbo.MovPlanilla MP
        INNER JOIN dbo.PlanillaSemanal PS ON PS.id = MP.idPlanillaSemanal
        INNER JOIN dbo.Semana S ON S.id  = PS.idSemana
        INNER JOIN dbo.TipoDeduccion TD ON TD.idTipoMovimiento = MP.idTipoMovimiento
        WHERE S.idMes = @idMes
        GROUP BY PS.idEmpleado, MP.idTipoMovimiento, TD.id;

        BEGIN TRANSACTION;

            -- ============================================================
            -- 4. Crear PlanillaMensual para empleados que no la tienen
            -- ============================================================
            INSERT INTO dbo.PlanillaMensual (idEmpleado, idMes, SalarioBruto, TotalDeducciones, SalarioNeto)
            SELECT R.idEmpleado, @idMes, 0, 0, 0
            FROM #ResumenMensual R
            WHERE NOT EXISTS (
                SELECT 1
                FROM dbo.PlanillaMensual PM
                WHERE PM.idEmpleado = R.idEmpleado
                  AND PM.idMes = @idMes
            );

            -- ============================================================
            -- 5. Acumular totales en PlanillaMensual
            -- ============================================================
            UPDATE PM
            SET PM.SalarioBruto = R.SalarioBruto
                , PM.TotalDeducciones = R.TotalDeducciones
                , PM.SalarioNeto = R.SalarioNeto
            FROM dbo.PlanillaMensual PM
            INNER JOIN #ResumenMensual R
                ON R.idEmpleado = PM.idEmpleado
                AND PM.idMes = @idMes;

            -- ============================================================
            -- 6. Insertar DeduccionXMes para filas nuevas
            -- ============================================================
            INSERT INTO dbo.DeduccionXMes (idPlanillaMensual, idEmpleado, idTipoDeduccion, MontoTotal)
            SELECT
                PM.id
                , R.idEmpleado
                , R.idTipoDeduccion
                , R.MontoTotal
            FROM #ResumenDeducciones R
            INNER JOIN dbo.PlanillaMensual PM
                ON  PM.idEmpleado = R.idEmpleado
                AND PM.idMes = @idMes
            WHERE NOT EXISTS (
                SELECT 1
                FROM dbo.DeduccionXMes DXM
                WHERE DXM.idPlanillaMensual = PM.id
                  AND DXM.idEmpleado = R.idEmpleado
                  AND DXM.idTipoDeduccion = R.idTipoDeduccion
            );

            -- ============================================================
            -- 7. Abrir el siguiente ciclo: crear Mes y Semanas
            --    El próximo viernes es el día siguiente al jueves de cierre
            -- ============================================================
            SET @proximoViernes = DATEADD(DAY, 1, @inFechaJueves);

            EXEC dbo.sp_CrearCalendario
                @inFechaInicioMes = @proximoViernes,
                @outResultCode = @rcCalendario OUTPUT,
                @outIdMes = @idMesNuevo   OUTPUT;

            IF @rcCalendario <> 0
            BEGIN
                ROLLBACK TRANSACTION;
                SET @outResultCode = @rcCalendario;
                RETURN;
            END

            -- ============================================================
            -- 8. Obtener la primera semana del nuevo mes (la del viernes)
            -- ============================================================
            SELECT @idSemanaNueva = S.id
            FROM dbo.Semana S
            WHERE S.idMes = @idMesNuevo
              AND S.FechaInicio = @proximoViernes;

            -- ============================================================
            -- 9. Crear PlanillaSemanal en cero para todos los empleados
            --    activos en la nueva semana
            -- ============================================================
            INSERT INTO dbo.PlanillaSemanal (idEmpleado, idSemana, SalarioBruto, TotalDeducciones, SalarioNeto)
            SELECT E.id, @idSemanaNueva, 0, 0, 0
            FROM dbo.Empleado E
            WHERE E.EsActivo = 1
              AND NOT EXISTS (
                  SELECT 1
                  FROM dbo.PlanillaSemanal PS
                  WHERE PS.idEmpleado = E.id
                    AND PS.idSemana = @idSemanaNueva
              );

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
            SUSER_SNAME()
            , ERROR_NUMBER()
            , ERROR_STATE()
            , ERROR_SEVERITY()
            , ERROR_LINE()
            , ISNULL(ERROR_PROCEDURE(), 'sp_ProcesarPlanillaMensual')
            , ERROR_MESSAGE()
            , GETDATE()
        );

        SET @outResultCode = 50008;
    END CATCH;

    DROP TABLE IF EXISTS #ResumenMensual;
    DROP TABLE IF EXISTS #ResumenDeducciones;
END;
GO