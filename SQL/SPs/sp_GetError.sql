USE [PlanillaDB];
GO

-- =====================================================
-- SP: Obtener descripcion de error por codigo
-- =====================================================
IF OBJECT_ID(N'dbo.sp_GetError', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_GetError];
GO

CREATE PROCEDURE [dbo].[sp_GetError]
    @inCodigo INT,
    @outResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    SET @outResultCode = 0;

    BEGIN TRY
        IF EXISTS (SELECT 1 FROM [dbo].[Error] WHERE Codigo = @inCodigo)
        BEGIN
            SELECT
                Codigo,
                Descripcion
            FROM [dbo].[Error]
            WHERE Codigo = @inCodigo;

            SET @outResultCode = 0;
        END
        ELSE
        BEGIN
            SET @outResultCode = 50008;
        END;
    END TRY
    BEGIN CATCH

        INSERT INTO DBError (UserName, Number, State, Severity, Line, [Procedure], Message, DateTime)
        VALUES (
            SYSTEM_USER,
            ERROR_NUMBER(),
            ERROR_STATE(),
            ERROR_SEVERITY(),
            ERROR_LINE(),
            ISNULL(ERROR_PROCEDURE(), 'sp_GetError'),
            ERROR_MESSAGE(),
            GETDATE()
        );

        SET @outResultCode = 50008;

    END CATCH
END;
GO
