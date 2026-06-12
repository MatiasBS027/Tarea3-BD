USE [PlanillaDB];
GO

-- =====================================================
-- SP: Regresar a interfaz de administrador (R06)
-- =====================================================
IF OBJECT_ID(N'dbo.sp_RegresarAdmin', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_RegresarAdmin];
GO

CREATE PROCEDURE [dbo].[sp_RegresarAdmin]
    @inIdUsuarioAdmin INT,
    @inIpPostIn VARCHAR(64),
    @inPostTime DATETIME,
    @outResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SET @outResultCode = 0;

    DECLARE @idTipoEvento INT;
    DECLARE @tipoUsuario CHAR(1);
    DECLARE @descripcion VARCHAR(512);

    DECLARE @bitacoraData TABLE (
        idTipoEvento INT,
        Descripcion VARCHAR(512),
        idUsuario INT,
        IpPostIn VARCHAR(64),
        PostTime DATETIME
    );

    BEGIN TRY
        SELECT @tipoUsuario = u.Tipo
        FROM dbo.Usuario u
        WHERE u.id = @inIdUsuarioAdmin;

        IF @tipoUsuario IS NULL
        BEGIN
            SET @outResultCode = 50001;
            RETURN;
        END

        IF @tipoUsuario <> '1'
        BEGIN
            SET @outResultCode = 50013;
            RETURN;
        END

        SELECT @idTipoEvento = t.id
        FROM dbo.TipoEvento t
        WHERE t.Nombre = 'Regresar a interfaz de administrador';

        IF @idTipoEvento IS NULL
        BEGIN
            SET @outResultCode = 50008;
            RETURN;
        END

        SET @descripcion = 'Regreso a interfaz de administrador';

        INSERT INTO @bitacoraData
        SELECT @idTipoEvento, @descripcion, @inIdUsuarioAdmin, @inIpPostIn, @inPostTime;

        BEGIN TRANSACTION
            INSERT INTO dbo.BitacoraEvento (idTipoEvento, Descripcion, idUsuario, IpPostIn, PostTime)
            SELECT idTipoEvento, Descripcion, idUsuario, IpPostIn, PostTime
            FROM @bitacoraData;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;

        INSERT INTO [dbo].[DBError] ([UserName], [Number], [State], [Severity], [Line], [Procedure], [Message], [DateTime])
        VALUES (
            SYSTEM_USER,
            ERROR_NUMBER(),
            ERROR_STATE(),
            ERROR_SEVERITY(),
            ERROR_LINE(),
            ISNULL(ERROR_PROCEDURE(), 'sp_RegresarAdmin'),
            ERROR_MESSAGE(),
            GETDATE()
        );

        SET @outResultCode = 50008;
    END CATCH
END;
GO
