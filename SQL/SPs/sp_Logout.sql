USE [PlanillaDB];
GO

-- =====================================================
-- SP: Logout de usuario
-- =====================================================
IF OBJECT_ID(N'dbo.sp_Logout', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_Logout];
GO

CREATE PROCEDURE [dbo].[sp_Logout]
    @inIdUsuario INT,
    @inIpPostIn VARCHAR(64),
    @inPostTime DATETIME,
    @outResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    SET @outResultCode = 0;

    DECLARE @idTipoEventoLogout INT;

    DECLARE @bitacoraData TABLE (
        idTipoEvento INT,
        Descripcion VARCHAR(512),
        idUsuario INT,
        IpPostIn VARCHAR(64),
        PostTime DATETIME
    );

    BEGIN TRY

        SELECT @idTipoEventoLogout = t.id
        FROM dbo.TipoEvento t
        WHERE t.Nombre = 'Logout';

        INSERT INTO @bitacoraData
        SELECT @idTipoEventoLogout, '', @inIdUsuario, @inIpPostIn, @inPostTime;

        BEGIN TRANSACTION
            INSERT INTO dbo.BitacoraEvento (idTipoEvento, Descripcion, idUsuario, IpPostIn, PostTime)
            SELECT idTipoEvento, Descripcion, idUsuario, IpPostIn, PostTime
            FROM @bitacoraData;
        COMMIT TRANSACTION;

        SET @outResultCode = 0;

    END TRY
    BEGIN CATCH

        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;

        INSERT INTO DBError (UserName, Number, State, Severity, Line, [Procedure], Message, DateTime)
        VALUES (
            SYSTEM_USER,
            ERROR_NUMBER(),
            CAST(ERROR_STATE()    AS VARCHAR(32)),
            CAST(ERROR_SEVERITY() AS VARCHAR(32)),
            ERROR_LINE(),
            ISNULL(ERROR_PROCEDURE(), 'sp_Logout'),
            ERROR_MESSAGE(),
            GETDATE()
        );

        SET @outResultCode = 50008;

    END CATCH
END;
GO
