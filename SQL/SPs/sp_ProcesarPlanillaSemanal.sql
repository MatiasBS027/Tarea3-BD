USE [PlanillaDB];
GO

IF OBJECT_ID(N'dbo.sp_ProcesarPlanillaSemanal', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_ProcesarPlanillaSemanal];
GO

-- =====================================================================
-- sp_ProcesarPlanillaSemanal
--
-- Cierre semanal: se ejecuta TODOS los jueves.
--
-- 1. Calcular deducciones porcentuales y fijas vigentes al jueves.
-- 2. Insertar MovPlanilla por cada deducción de cada empleado.
-- 3. Actualizar TotalDeducciones y SalarioNeto en PlanillaSemanal.
-- =====================================================================

CREATE PROCEDURE [dbo].[sp_ProcesarPlanillaSemanal]
    @inFechaJueves DATE
    , @outResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SET @outResultCode = 0;

    DECLARE
        @idSemana INT
        , @idMes INT
        , @numJueves TINYINT;

    BEGIN TRY

        -- ============================================================
        -- 1. Buscar la semana cuyo FechaFin = @inFechaJueves
        -- ============================================================
        SELECT
            @idSemana = S.id
            , @idMes = S.idMes
            , @numJueves = M.NumJueves
        FROM dbo.Semana S
        INNER JOIN dbo.Mes M ON M.id = S.idMes
        WHERE S.FechaFin = @inFechaJueves;

        IF @idSemana IS NULL
        BEGIN
            SET @outResultCode = 60004;
            RETURN;
        END

        -- ============================================================
        -- 2. Calcular deducciones por empleado en tabla temporal
        --
        --    Una fila por (empleado, tipoDeduccion).
        --    Porcentual : Monto = SalarioBruto × Valor
        --    Fija       : Monto = MontoFijo / NumJueves
        -- ============================================================
        SELECT
            PS.idEmpleado
            , PS.id AS idPlanSem
            , PS.SalarioBruto
            , DE.idTipoDeduccion
            , TD.idTipoMovimiento
            , ROUND(
                CASE
                    WHEN TD.EsPorcentual = 1
                    THEN PS.SalarioBruto * TD.Valor
                    ELSE DE.MontoFijo / CAST(@numJueves AS DECIMAL(4,2))
                END, 2
            ) AS MontoDeduccion
        INTO #Deducciones
        FROM dbo.PlanillaSemanal PS
        INNER JOIN dbo.DeduccionEmpleado DE
            ON DE.idEmpleado = PS.idEmpleado
            AND DE.FechaInicio <= @inFechaJueves
            AND DE.FechaFin >= @inFechaJueves
        INNER JOIN dbo.TipoDeduccion TD
            ON TD.id = DE.idTipoDeduccion
        WHERE PS.idSemana = @idSemana;

        -- ============================================================
        -- 3. Totales por empleado
        -- ============================================================
        SELECT
            idEmpleado
            , idPlanSem
            , SalarioBruto
            , SUM(MontoDeduccion) AS TotalDeducciones
            , SalarioBruto - SUM(MontoDeduccion) AS SalarioNeto
        INTO #TotalesEmpleado
        FROM #Deducciones
        GROUP BY idEmpleado, idPlanSem, SalarioBruto;

        -- Incluir empleados sin deducciones (SalarioNeto = SalarioBruto)
        INSERT INTO #TotalesEmpleado (idEmpleado, idPlanSem, SalarioBruto, TotalDeducciones, SalarioNeto)
        SELECT
            PS.idEmpleado
            , PS.id
            , PS.SalarioBruto
            , 0
            , PS.SalarioBruto
        FROM dbo.PlanillaSemanal PS
        WHERE PS.idSemana = @idSemana
          AND NOT EXISTS (
              SELECT 1 FROM #TotalesEmpleado T WHERE T.idPlanSem = PS.id
          );

        BEGIN TRANSACTION;

            -- ============================================================
            -- 4. Insertar MovPlanilla
            --    NuevoSaldo = SalarioBruto - suma acumulada de deducciones
            --    hasta e incluyendo la actual (ordenadas por idTipoDeduccion)
            -- ============================================================
            INSERT INTO dbo.MovPlanilla (idPlanillaSemanal, idTipoMovimiento, Monto, NuevoSaldo)
            SELECT
                D.idPlanSem
                , D.idTipoMovimiento
                , D.MontoDeduccion
                , D.SalarioBruto - (
                    SELECT SUM(D2.MontoDeduccion)
                    FROM #Deducciones D2
                    WHERE D2.idPlanSem = D.idPlanSem
                      AND D2.idTipoDeduccion <= D.idTipoDeduccion
                ) AS NuevoSaldo
            FROM #Deducciones D;

            -- ============================================================
            -- 5. Cerrar PlanillaSemanal
            -- ============================================================
            UPDATE PS
            SET    PS.TotalDeducciones = T.TotalDeducciones
                   , PS.SalarioNeto = T.SalarioNeto
            FROM   dbo.PlanillaSemanal PS
            INNER JOIN #TotalesEmpleado T ON T.idPlanSem = PS.id;

        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        INSERT INTO dbo.DBError (
            UserName, Number, State, Severity, Line
            ,[Procedure], [Message], [DateTime]
        )
        VALUES (
            SUSER_SNAME()
            , ERROR_NUMBER()
            , ERROR_STATE()
            , ERROR_SEVERITY()
            , ERROR_LINE()
            , ISNULL(ERROR_PROCEDURE(), 'sp_ProcesarPlanillaSemanal')
            , ERROR_MESSAGE()
            , GETDATE()
        );

        SET @outResultCode = 50008;
    END CATCH;

    DROP TABLE IF EXISTS #Deducciones;
    DROP TABLE IF EXISTS #TotalesEmpleado;
END;
GO