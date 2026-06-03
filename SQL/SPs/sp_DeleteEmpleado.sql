USE VacacionesDB;
GO

-- =====================================================
-- SP: Borrado lógico de un empleado
-- =====================================================
DROP PROCEDURE IF EXISTS sp_DeleteEmpleado;
GO

CREATE PROCEDURE sp_DeleteEmpleado
    @inValorDocumentoIdentidad VARCHAR(32),
    @inIdUsuario INT,
    @inIpPostIn VARCHAR(64),
    @inPostTime DATETIME,
    @inConfirmado BIT,
    @outResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

        DECLARE @idEmpleado INT,
            @nombreEmpleado VARCHAR(128),
            @nombrePuesto VARCHAR(128),
            @saldoVacaciones DECIMAL(10,2),
            @idTipoEventoIntento INT,
            @idTipoEventoBorrado INT,
            @descripcion VARCHAR(512);

    SET @outResultCode = 0;

    BEGIN TRY

        -- Obtener id de TipoEvento
        SELECT @idTipoEventoIntento = id FROM TipoEvento WHERE Nombre = 'Intento de borrado';
        SELECT @idTipoEventoBorrado = id FROM TipoEvento WHERE Nombre = 'Borrado exitoso';

        -- Obtener datos del empleado
        SELECT
            @idEmpleado = e.id,
            @nombreEmpleado = e.Nombre,
            @saldoVacaciones = e.SaldoVacaciones,
            @nombrePuesto = p.Nombre
        FROM Empleado e
        INNER JOIN Puesto p ON e.idPuesto = p.id
        WHERE e.ValorDocumentoIdentidad = @inValorDocumentoIdentidad
          AND e.EsActivo = 1;

        -- Si no existe el empleado
        IF @idEmpleado IS NULL
        BEGIN
            SET @outResultCode = 50008;
            RETURN;
        END

        -- Descripción
        SET @descripcion =
            'ValorDocumentoIdentidad: ' + @inValorDocumentoIdentidad
            + ' | Nombre: ' + @nombreEmpleado
            + ' | Puesto: ' + @nombrePuesto
            + ' | Saldo: ' + CAST(@saldoVacaciones AS VARCHAR(20));

        -- Si el usuario NO confirmó entonces registrar intento y salir
        IF @inConfirmado = 0
        BEGIN
            INSERT INTO BitacoraEvento (idTipoEvento, Descripcion, idUsuario, IpPostIn, PostTime)
            VALUES (@idTipoEventoIntento, @descripcion, @inIdUsuario, @inIpPostIn, @inPostTime);

            SET @outResultCode = 0;
            RETURN;
        END

        -- Si confirmó entonces hacer borrado lógico
        BEGIN TRANSACTION;

            UPDATE Empleado
            SET EsActivo = 0
            WHERE id = @idEmpleado;

            INSERT INTO BitacoraEvento (idTipoEvento, Descripcion, idUsuario, IpPostIn, PostTime)
            VALUES (@idTipoEventoBorrado, @descripcion, @inIdUsuario, @inIpPostIn, @inPostTime);

        COMMIT TRANSACTION;

        SET @outResultCode = 0;

    END TRY
    BEGIN CATCH

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        INSERT INTO DBError (UserName, Number, State, Severity, Line, [Procedure], Message, DateTime)
        VALUES (
            SYSTEM_USER,
            ERROR_NUMBER(),
            CAST(ERROR_STATE()    AS VARCHAR(32)),
            CAST(ERROR_SEVERITY() AS VARCHAR(32)),
            ERROR_LINE(),
            ISNULL(ERROR_PROCEDURE(), 'sp_DeleteEmpleado'),
            ERROR_MESSAGE(),
            GETDATE()
        );

        SET @outResultCode = 50008;

    END CATCH
END;
GO