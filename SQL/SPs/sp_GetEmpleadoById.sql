USE [PlanillaDB];
GO

-- =====================================================
-- SP: Obtener un empleado por ValorDocumento (R02)
-- =====================================================
IF OBJECT_ID(N'dbo.sp_GetEmpleadoById', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_GetEmpleadoById];
GO

CREATE PROCEDURE [dbo].[sp_GetEmpleadoById]
    @inValorDocumento VARCHAR(32),
    @outResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SET @outResultCode = 0;

    BEGIN TRY
        IF NOT EXISTS (
            SELECT 1
            FROM dbo.Empleado e
            WHERE e.ValorDocumento = @inValorDocumento
                AND e.Activo = 1
        )
        BEGIN
            SET @outResultCode = 50012;
            RETURN;
        END

        SELECT
            e.id,
            e.Nombre,
            e.ValorDocumento,
            e.idPuesto,
            p.Nombre AS NombrePuesto,
            e.FechaContratacion,
            e.CuentaBancaria,
            e.Activo
        FROM dbo.Empleado e
        INNER JOIN dbo.Puesto p ON e.idPuesto = p.id
        WHERE e.ValorDocumento = @inValorDocumento
            AND e.Activo = 1;

        SET @outResultCode = 0;
    END TRY
    BEGIN CATCH
        INSERT INTO [dbo].[DBError] ([UserName], [Number], [State], [Severity], [Line], [Procedure], [Message], [DateTime])
        VALUES (
            SYSTEM_USER,
            ERROR_NUMBER(),
            ERROR_STATE(),
            ERROR_SEVERITY(),
            ERROR_LINE(),
            ISNULL(ERROR_PROCEDURE(), 'sp_GetEmpleadoById'),
            ERROR_MESSAGE(),
            GETDATE()
        );

        SET @outResultCode = 50008;
    END CATCH
END;
GO
