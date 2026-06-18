USE [PlanillaDB];
GO

-- =====================================================
-- SP: Obtener id de Empleado asociado a un Usuario
-- =====================================================
IF OBJECT_ID(N'dbo.sp_GetEmpleadoIdByUsuario', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_GetEmpleadoIdByUsuario];
GO

CREATE PROCEDURE [dbo].[sp_GetEmpleadoIdByUsuario]
    @inIdUsuario  INT,
    @outIdEmpleado INT OUTPUT,
    @outResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    SET @outResultCode = 0;
    SET @outIdEmpleado = NULL;

    BEGIN TRY
        SELECT @outIdEmpleado = e.id
        FROM dbo.Empleado e
        WHERE e.idUsuario = @inIdUsuario
            AND e.Activo = 1;

        -- Si no existe empleado activo para ese usuario, no es error fatal:
        -- el output quedará en NULL y el caller decide qué hacer.
        SET @outResultCode = 0;
    END TRY
    BEGIN CATCH
        INSERT INTO [dbo].[DBError]
            ([UserName], [Number], [State], [Severity], [Line], [Procedure], [Message], [DateTime])
        VALUES (
            SYSTEM_USER,
            ERROR_NUMBER(),
            ERROR_STATE(),
            ERROR_SEVERITY(),
            ERROR_LINE(),
            ISNULL(ERROR_PROCEDURE(), 'sp_GetEmpleadoIdByUsuario'),
            ERROR_MESSAGE(),
            GETDATE()
        );

        SET @outResultCode = 50008;
    END CATCH
END;
GO
