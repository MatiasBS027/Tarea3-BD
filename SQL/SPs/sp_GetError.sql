USE VacacionesDB;
GO

-- =====================================================
-- SP 3: Obtener descripcion de error por codigo
-- =====================================================
DROP PROCEDURE IF EXISTS sp_GetError;
GO

CREATE PROCEDURE sp_GetError
    @inCodigo INT,
    @outResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF EXISTS (SELECT 1 FROM [Error] WHERE Codigo = @inCodigo)
        BEGIN
            SELECT
                Codigo,
                Descripcion
            FROM [Error]
            WHERE Codigo = @inCodigo;

            SET @outResultCode = 0;
        END
        ELSE
        BEGIN
            SET @outResultCode = 50008;
        END;
    END TRY
    BEGIN CATCH
        INSERT INTO DBError ([UserName], [Number], [State], [Severity], [Line], [Procedure], [Message], [DateTime])
        VALUES (
            SYSTEM_USER,
            ERROR_NUMBER(),
            CAST(ERROR_STATE() AS VARCHAR(32)),
            CAST(ERROR_SEVERITY() AS VARCHAR(32)),
            ERROR_LINE(),
            ISNULL(ERROR_PROCEDURE(), 'sp_GetError'),
            ERROR_MESSAGE(),
            GETDATE()
        );

        SET @outResultCode = 50008;
    END CATCH
END;
