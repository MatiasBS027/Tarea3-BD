USE [PlanillaDB];
GO

-- =====================================================
-- SP: Obtener todos los tipos de movimiento (R04)
-- =====================================================
IF OBJECT_ID(N'dbo.sp_GetTiposMovimiento', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_GetTiposMovimiento];
GO

CREATE PROCEDURE [dbo].[sp_GetTiposMovimiento]
    @inAccion CHAR(1) = NULL,
    @outResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @outResultCode = 0;

    BEGIN TRY
        IF @inAccion IS NULL
        BEGIN
            SELECT
                id,
                Nombre,
                Accion
            FROM dbo.TipoMovimiento
            ORDER BY Accion ASC, Nombre ASC;
        END
        ELSE
        BEGIN
            SELECT
                id,
                Nombre,
                Accion
            FROM dbo.TipoMovimiento
            WHERE Accion = @inAccion
            ORDER BY Nombre ASC;
        END
    END TRY
    BEGIN CATCH
        INSERT INTO [dbo].[DBError] ([UserName], [Number], [State], [Severity], [Line], [Procedure], [Message], [DateTime])
        VALUES (
            SYSTEM_USER,
            ERROR_NUMBER(),
            ERROR_STATE(),
            ERROR_SEVERITY(),
            ERROR_LINE(),
            ISNULL(ERROR_PROCEDURE(), 'sp_GetTiposMovimiento'),
            ERROR_MESSAGE(),
            GETDATE()
        );

        SET @outResultCode = 50008;
    END CATCH
END;
GO
