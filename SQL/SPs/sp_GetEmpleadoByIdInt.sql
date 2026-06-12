USE [PlanillaDB];
GO

-- =====================================================
-- SP: Obtener empleado por id INT (vista impersonación)
-- =====================================================
IF OBJECT_ID(N'dbo.sp_GetEmpleadoByIdInt', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_GetEmpleadoByIdInt];
GO

CREATE PROCEDURE [dbo].[sp_GetEmpleadoByIdInt]
    @inId INT,
    @outResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    SET @outResultCode = 0;

    BEGIN TRY
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
        WHERE e.id = @inId
            AND e.Activo = 1;
    END TRY
    BEGIN CATCH
        INSERT INTO [dbo].[DBError] ([UserName], [Number], [State], [Severity], [Line], [Procedure], [Message], [DateTime])
        VALUES (
            SYSTEM_USER,
            ERROR_NUMBER(),
            ERROR_STATE(),
            ERROR_SEVERITY(),
            ERROR_LINE(),
            ISNULL(ERROR_PROCEDURE(), 'sp_GetEmpleadoByIdInt'),
            ERROR_MESSAGE(),
            GETDATE()
        );

        SET @outResultCode = 50008;
    END CATCH
END;
GO
