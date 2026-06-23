USE [PlanillaDB];
GO

IF OBJECT_ID(N'dbo.sp_DeleteEmpleado', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_DeleteEmpleado];
GO

CREATE PROCEDURE [dbo].[sp_DeleteEmpleado]
    @inId INT,
    @inIdUsuarioAdmin INT,
    @inIpPostIn VARCHAR(64),
    @inPostTime DATETIME,
    @inConfirmado BIT = 0,
    @outResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @idTipoEventoIntento INT,
            @idTipoEventoBorrado INT,
            @descripcion VARCHAR(512),
            @nombreEmpleado VARCHAR(128),
            @docEmpleado VARCHAR(32),
            @nombrePuesto VARCHAR(128);

    SET @outResultCode = 0;

    BEGIN TRY
        SELECT @idTipoEventoIntento = id FROM dbo.TipoEvento WHERE Nombre = 'Intento de borrado';
        SELECT @idTipoEventoBorrado = id FROM dbo.TipoEvento WHERE Nombre = 'Borrado exitoso';

        SELECT @nombreEmpleado = e.Nombre, @docEmpleado = e.ValorDocumento,
               @nombrePuesto = p.Nombre
        FROM dbo.Empleado e
        INNER JOIN dbo.Puesto p ON e.idPuesto = p.id
        WHERE e.id = @inId AND e.Activo = 1;

        IF @nombreEmpleado IS NULL
        BEGIN
            SET @outResultCode = 50012;
            RETURN;
        END

        SET @descripcion = 'id: ' + CAST(@inId AS VARCHAR)
            + ' | ValorDocumento: ' + @docEmpleado
            + ' | Nombre: ' + @nombreEmpleado
            + ' | Puesto: ' + @nombrePuesto;

        IF @inConfirmado = 0
        BEGIN
            INSERT INTO dbo.BitacoraEvento (idTipoEvento, Descripcion, idUsuario, IpPostIn, PostTime)
            VALUES (@idTipoEventoIntento, @descripcion, @inIdUsuarioAdmin, @inIpPostIn, @inPostTime);

            SET @outResultCode = 0;
            RETURN;
        END

        BEGIN TRANSACTION;

            UPDATE dbo.Empleado
            SET Activo = 0
            WHERE id = @inId;

            INSERT INTO dbo.BitacoraEvento (idTipoEvento, Descripcion, idUsuario, IpPostIn, PostTime)
            VALUES (@idTipoEventoBorrado, @descripcion, @inIdUsuarioAdmin, @inIpPostIn, @inPostTime);

        COMMIT TRANSACTION;

        SET @outResultCode = 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;

        INSERT INTO dbo.DBError (UserName, Number, State, Severity, Line, [Procedure], Message, DateTime)
        VALUES (SYSTEM_USER, ERROR_NUMBER(), ERROR_STATE(), ERROR_SEVERITY(),
                ERROR_LINE(), ISNULL(ERROR_PROCEDURE(), 'sp_DeleteEmpleado'),
                ERROR_MESSAGE(), GETDATE());

        SET @outResultCode = 50008;
    END CATCH
END;
GO
