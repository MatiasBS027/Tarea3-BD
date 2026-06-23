USE [PlanillaDB];
GO

IF OBJECT_ID(N'dbo.sp_UpdateEmpleado', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_UpdateEmpleado];
GO

CREATE PROCEDURE [dbo].[sp_UpdateEmpleado]
    @inId INT,
    @inValorDocumento VARCHAR(32),
    @inNombre VARCHAR(128),
    @inIdPuesto INT,
    @inCuentaBancaria VARCHAR(32),
    @inIdUsuarioAdmin INT,
    @inIpPostIn VARCHAR(64),
    @inPostTime DATETIME,
    @outResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @idTipoEventoSuccess INT,
            @idTipoEventoFail INT,
            @descripcion VARCHAR(512),
            @oldDoc VARCHAR(32),
            @oldNombre VARCHAR(128),
            @oldIdPuesto INT,
            @oldCuenta VARCHAR(32),
            @oldNombrePuesto VARCHAR(128),
            @newNombrePuesto VARCHAR(128);

    SET @outResultCode = 0;

    BEGIN TRY
        SELECT @idTipoEventoSuccess = id FROM dbo.TipoEvento WHERE Nombre = 'Update exitoso';
        SELECT @idTipoEventoFail    = id FROM dbo.TipoEvento WHERE Nombre = 'Update no exitoso';

        SELECT @oldDoc = ValorDocumento, @oldNombre = Nombre,
               @oldIdPuesto = idPuesto, @oldCuenta = CuentaBancaria
        FROM dbo.Empleado
        WHERE id = @inId AND Activo = 1;

        IF @oldDoc IS NULL
        BEGIN
            SET @outResultCode = 50012;
            RETURN;
        END

        SELECT @oldNombrePuesto = Nombre FROM dbo.Puesto WHERE id = @oldIdPuesto;
        SELECT @newNombrePuesto = Nombre FROM dbo.Puesto WHERE id = @inIdPuesto;

        IF @newNombrePuesto IS NULL
        BEGIN
            SET @outResultCode = 50012;
            SET @descripcion = 'Error: Puesto no existe | idPuesto: ' + CAST(@inIdPuesto AS VARCHAR);
            INSERT INTO dbo.BitacoraEvento (idTipoEvento, Descripcion, idUsuario, IpPostIn, PostTime)
            VALUES (@idTipoEventoFail, @descripcion, @inIdUsuarioAdmin, @inIpPostIn, @inPostTime);
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM dbo.Empleado WHERE ValorDocumento = @inValorDocumento AND Activo = 1 AND id <> @inId)
        BEGIN
            SET @outResultCode = 50006;
            SET @descripcion = 'Error: ' + (SELECT Descripcion FROM dbo.Error WHERE Codigo = 50006)
                + ' | DocAntes: ' + @oldDoc + ' | DocDespues: ' + @inValorDocumento
                + ' | NombreAntes: ' + @oldNombre + ' | NombreDespues: ' + @inNombre
                + ' | PuestoAntes: ' + ISNULL(@oldNombrePuesto, '') + ' | PuestoDespues: ' + ISNULL(@newNombrePuesto, '');
            INSERT INTO dbo.BitacoraEvento (idTipoEvento, Descripcion, idUsuario, IpPostIn, PostTime)
            VALUES (@idTipoEventoFail, @descripcion, @inIdUsuarioAdmin, @inIpPostIn, @inPostTime);
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM dbo.Empleado WHERE Nombre = @inNombre AND Activo = 1 AND id <> @inId)
        BEGIN
            SET @outResultCode = 50007;
            SET @descripcion = 'Error: ' + (SELECT Descripcion FROM dbo.Error WHERE Codigo = 50007)
                + ' | DocAntes: ' + @oldDoc + ' | DocDespues: ' + @inValorDocumento
                + ' | NombreAntes: ' + @oldNombre + ' | NombreDespues: ' + @inNombre
                + ' | PuestoAntes: ' + ISNULL(@oldNombrePuesto, '') + ' | PuestoDespues: ' + ISNULL(@newNombrePuesto, '');
            INSERT INTO dbo.BitacoraEvento (idTipoEvento, Descripcion, idUsuario, IpPostIn, PostTime)
            VALUES (@idTipoEventoFail, @descripcion, @inIdUsuarioAdmin, @inIpPostIn, @inPostTime);
            RETURN;
        END

        BEGIN TRANSACTION;

            UPDATE dbo.Empleado
            SET ValorDocumento = @inValorDocumento,
                Nombre = @inNombre,
                idPuesto = @inIdPuesto,
                CuentaBancaria = @inCuentaBancaria
            WHERE id = @inId;

            SET @descripcion = 'DocAntes: ' + @oldDoc + ' | DocDespues: ' + @inValorDocumento
                + ' | NombreAntes: ' + @oldNombre + ' | NombreDespues: ' + @inNombre
                + ' | PuestoAntes: ' + ISNULL(@oldNombrePuesto, '') + ' | PuestoDespues: ' + ISNULL(@newNombrePuesto, '')
                + ' | CuentaAntes: ' + ISNULL(@oldCuenta, '') + ' | CuentaDespues: ' + ISNULL(@inCuentaBancaria, '');

            INSERT INTO dbo.BitacoraEvento (idTipoEvento, Descripcion, idUsuario, IpPostIn, PostTime)
            VALUES (@idTipoEventoSuccess, @descripcion, @inIdUsuarioAdmin, @inIpPostIn, @inPostTime);

        COMMIT TRANSACTION;

        SET @outResultCode = 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;

        INSERT INTO dbo.DBError (UserName, Number, State, Severity, Line, [Procedure], Message, DateTime)
        VALUES (SYSTEM_USER, ERROR_NUMBER(), ERROR_STATE(), ERROR_SEVERITY(),
                ERROR_LINE(), ISNULL(ERROR_PROCEDURE(), 'sp_UpdateEmpleado'),
                ERROR_MESSAGE(), GETDATE());

        SET @descripcion = 'Error: ' + (SELECT Descripcion FROM dbo.Error WHERE Codigo = 50008)
            + ' | id: ' + CAST(@inId AS VARCHAR);

        INSERT INTO dbo.BitacoraEvento (idTipoEvento, Descripcion, idUsuario, IpPostIn, PostTime)
        VALUES (@idTipoEventoFail, @descripcion, @inIdUsuarioAdmin, @inIpPostIn, @inPostTime);

        SET @outResultCode = 50008;
    END CATCH
END;
GO
