USE [PlanillaDB];
GO

IF OBJECT_ID(N'dbo.sp_InsertarEmpleado', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_InsertarEmpleado];
GO

CREATE PROCEDURE [dbo].[sp_InsertarEmpleado]
    @inValorDocumento VARCHAR(32),
    @inNombre VARCHAR(128),
    @inIdPuesto INT,
    @inCuentaBancaria VARCHAR(32),
    @inUsername VARCHAR(64),
    @inPassword VARCHAR(64),
    @inFechaContratacion DATE = NULL,
    @inIdUsuarioAdmin INT,
    @inIpPostIn VARCHAR(64),
    @inPostTime DATETIME,
    @outIdEmpleado INT OUTPUT,
    @outResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @idTipoEventoOk INT,
            @idTipoEventoFail INT,
            @descripcion VARCHAR(512),
            @nuevoIdUsuario INT;

    SET @outResultCode = 0;
    SET @outIdEmpleado = NULL;

    IF @inFechaContratacion IS NULL
        SET @inFechaContratacion = CAST(GETDATE() AS DATE);

    BEGIN TRY
        SELECT @idTipoEventoOk   = id FROM dbo.TipoEvento WHERE Nombre = 'Insercion exitosa';
        SELECT @idTipoEventoFail = id FROM dbo.TipoEvento WHERE Nombre = 'Insercion no exitosa';

        IF NOT EXISTS (SELECT 1 FROM dbo.Puesto WHERE id = @inIdPuesto)
        BEGIN
            SET @outResultCode = 50012;
            SET @descripcion = 'Error: Puesto no existe | idPuesto: ' + CAST(@inIdPuesto AS VARCHAR);
            INSERT INTO dbo.BitacoraEvento (idTipoEvento, Descripcion, idUsuario, IpPostIn, PostTime)
            VALUES (@idTipoEventoFail, @descripcion, @inIdUsuarioAdmin, @inIpPostIn, @inPostTime);
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM dbo.Empleado WHERE ValorDocumento = @inValorDocumento AND Activo = 1)
        BEGIN
            SET @outResultCode = 50004;
            SET @descripcion = 'Error: ' + (SELECT Descripcion FROM dbo.Error WHERE Codigo = 50004)
                + ' | ValorDocumento: ' + @inValorDocumento
                + ' | Nombre: ' + @inNombre;
            INSERT INTO dbo.BitacoraEvento (idTipoEvento, Descripcion, idUsuario, IpPostIn, PostTime)
            VALUES (@idTipoEventoFail, @descripcion, @inIdUsuarioAdmin, @inIpPostIn, @inPostTime);
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM dbo.Empleado WHERE Nombre = @inNombre AND Activo = 1)
        BEGIN
            SET @outResultCode = 50005;
            SET @descripcion = 'Error: ' + (SELECT Descripcion FROM dbo.Error WHERE Codigo = 50005)
                + ' | ValorDocumento: ' + @inValorDocumento
                + ' | Nombre: ' + @inNombre;
            INSERT INTO dbo.BitacoraEvento (idTipoEvento, Descripcion, idUsuario, IpPostIn, PostTime)
            VALUES (@idTipoEventoFail, @descripcion, @inIdUsuarioAdmin, @inIpPostIn, @inPostTime);
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM dbo.Usuario WHERE Username = @inUsername)
        BEGIN
            SET @outResultCode = 50005;
            SET @descripcion = 'Error: Username ya existe | Username: ' + @inUsername;
            INSERT INTO dbo.BitacoraEvento (idTipoEvento, Descripcion, idUsuario, IpPostIn, PostTime)
            VALUES (@idTipoEventoFail, @descripcion, @inIdUsuarioAdmin, @inIpPostIn, @inPostTime);
            RETURN;
        END

        BEGIN TRANSACTION;

            SELECT @nuevoIdUsuario = ISNULL(MAX(id), 0) + 1 FROM dbo.Usuario;

            INSERT INTO dbo.Usuario (id, Username, PasswordHash, Tipo)
            VALUES (@nuevoIdUsuario, @inUsername, @inPassword, '2');

            INSERT INTO dbo.Empleado (idPuesto, idUsuario, ValorDocumento, Nombre, CuentaBancaria, FechaContratacion, Activo)
            VALUES (@inIdPuesto, @nuevoIdUsuario, @inValorDocumento, @inNombre, @inCuentaBancaria, @inFechaContratacion, 1);

            SET @outIdEmpleado = SCOPE_IDENTITY();

            SET @descripcion = 'ValorDocumento: ' + @inValorDocumento
                + ' | Nombre: ' + @inNombre
                + ' | idPuesto: ' + CAST(@inIdPuesto AS VARCHAR)
                + ' | Username: ' + @inUsername;

            INSERT INTO dbo.BitacoraEvento (idTipoEvento, Descripcion, idUsuario, IpPostIn, PostTime)
            VALUES (@idTipoEventoOk, @descripcion, @inIdUsuarioAdmin, @inIpPostIn, @inPostTime);

        COMMIT TRANSACTION;

        SET @outResultCode = 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;

        INSERT INTO dbo.DBError (UserName, Number, State, Severity, Line, [Procedure], Message, DateTime)
        VALUES (SYSTEM_USER, ERROR_NUMBER(), ERROR_STATE(), ERROR_SEVERITY(),
                ERROR_LINE(), ISNULL(ERROR_PROCEDURE(), 'sp_InsertarEmpleado'),
                ERROR_MESSAGE(), GETDATE());

        SET @descripcion = 'Error: ' + (SELECT Descripcion FROM dbo.Error WHERE Codigo = 50008)
            + ' | ValorDocumento: ' + @inValorDocumento
            + ' | Nombre: ' + @inNombre;

        INSERT INTO dbo.BitacoraEvento (idTipoEvento, Descripcion, idUsuario, IpPostIn, PostTime)
        VALUES (@idTipoEventoFail, @descripcion, @inIdUsuarioAdmin, @inIpPostIn, @inPostTime);

        SET @outResultCode = 50008;
    END CATCH
END;
GO
