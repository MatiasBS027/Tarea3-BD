USE [PlanillaDB];
GO

-- =====================================================
-- SP: Login de usuario
-- =====================================================
IF OBJECT_ID(N'dbo.sp_Login', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_Login];
GO

CREATE PROCEDURE [dbo].[sp_Login]
    @inUsername VARCHAR(128),
    @inPassword VARCHAR(128),
    @inIpPostIn VARCHAR(64),
    @inPostTime DATETIME,
    @outResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    SET @outResultCode = 0;

    DECLARE @idUsuario INT,
        @password VARCHAR(128),
        @idEventoSuccess INT,
        @idEventoFail INT,
        @idEventoDisabled INT,
        @intentosFallidos INT,
        @descripcion VARCHAR(512);

    DECLARE @bitacoraData TABLE (
        idTipoEvento INT,
        Descripcion VARCHAR(512),
        idUsuario INT,
        IpPostIn VARCHAR(64),
        PostTime DATETIME
    );

    BEGIN TRY

        SELECT @idEventoSuccess = t.id
        FROM dbo.TipoEvento t
        WHERE t.Nombre = 'Login Exitoso';

        SELECT @idEventoFail = t.id
        FROM dbo.TipoEvento t
        WHERE t.Nombre = 'Login No Exitoso';

        SELECT @idEventoDisabled = t.id
        FROM dbo.TipoEvento t
        WHERE t.Nombre = 'Login deshabilitado';

        SELECT @idUsuario = u.id, @password = u.PasswordHash
        FROM dbo.Usuario u
        WHERE u.Username = @inUsername;

        IF @idUsuario IS NULL
        BEGIN
            SELECT @intentosFallidos = COUNT(*)
            FROM dbo.BitacoraEvento b
            WHERE b.idTipoEvento = @idEventoFail
                AND b.IpPostIn = @inIpPostIn
                AND b.PostTime >= DATEADD(MINUTE, -20, @inPostTime);

            IF @intentosFallidos >= 5
            BEGIN
                SET @outResultCode = 50003;

                INSERT INTO @bitacoraData
                SELECT @idEventoDisabled, '', NULL, @inIpPostIn, @inPostTime;

                BEGIN TRANSACTION
                    INSERT INTO dbo.BitacoraEvento (idTipoEvento, Descripcion, idUsuario, IpPostIn, PostTime)
                    SELECT idTipoEvento, Descripcion, idUsuario, IpPostIn, PostTime
                    FROM @bitacoraData;
                COMMIT TRANSACTION;

                RETURN;
            END

            SET @descripcion = 'Intento: ' + CAST(@intentosFallidos + 1 AS VARCHAR(10))
                + ' | Error: ' + (SELECT Descripcion FROM dbo.Error WHERE Codigo = 50001);

            INSERT INTO @bitacoraData
            SELECT @idEventoFail, @descripcion, NULL, @inIpPostIn, @inPostTime;

            BEGIN TRANSACTION
                INSERT INTO dbo.BitacoraEvento (idTipoEvento, Descripcion, idUsuario, IpPostIn, PostTime)
                SELECT idTipoEvento, Descripcion, idUsuario, IpPostIn, PostTime
                FROM @bitacoraData;
            COMMIT TRANSACTION;

            SET @outResultCode = 50001;
            RETURN;
        END

        SELECT @intentosFallidos = COUNT(*)
        FROM dbo.BitacoraEvento b
        WHERE b.idTipoEvento = @idEventoFail
            AND b.idUsuario = @idUsuario
            AND b.IpPostIn = @inIpPostIn
            AND b.PostTime >= DATEADD(MINUTE, -20, @inPostTime);

        IF @intentosFallidos >= 5
        BEGIN
            SET @outResultCode = 50003;

            INSERT INTO @bitacoraData
            SELECT @idEventoDisabled, '', @idUsuario, @inIpPostIn, @inPostTime;

            BEGIN TRANSACTION
                INSERT INTO dbo.BitacoraEvento (idTipoEvento, Descripcion, idUsuario, IpPostIn, PostTime)
                SELECT idTipoEvento, Descripcion, idUsuario, IpPostIn, PostTime
                FROM @bitacoraData;
            COMMIT TRANSACTION;

            RETURN;
        END

        IF @password <> @inPassword
        BEGIN
            SET @outResultCode = 50002;

            SET @descripcion = 'Intento: ' + CAST(@intentosFallidos + 1 AS VARCHAR(10))
                + ' | Error: ' + (SELECT Descripcion FROM dbo.Error WHERE Codigo = 50002);

            INSERT INTO @bitacoraData
            SELECT @idEventoFail, @descripcion, @idUsuario, @inIpPostIn, @inPostTime;

            BEGIN TRANSACTION
                INSERT INTO dbo.BitacoraEvento (idTipoEvento, Descripcion, idUsuario, IpPostIn, PostTime)
                SELECT idTipoEvento, Descripcion, idUsuario, IpPostIn, PostTime
                FROM @bitacoraData;
            COMMIT TRANSACTION;

            RETURN;
        END

        INSERT INTO @bitacoraData
        SELECT @idEventoSuccess, 'Exitoso', @idUsuario, @inIpPostIn, @inPostTime;

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
            ISNULL(ERROR_PROCEDURE(), 'sp_Login'),
            ERROR_MESSAGE(),
            GETDATE()
        );

        SET @outResultCode = 50008;

    END CATCH
END;
GO
