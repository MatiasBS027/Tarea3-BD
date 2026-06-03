USE VacacionesDB;
GO

-- =====================================================
-- SP 2: Insertar movimiento de vacaciones
-- =====================================================
DROP PROCEDURE IF EXISTS sp_InsertMovimiento;
GO

CREATE PROCEDURE sp_InsertMovimiento
    @inValorDocumentoIdentidad VARCHAR(32),
    @inNombreTipoMovimiento VARCHAR(64),
    @inMonto DECIMAL(10,2),
    @inUsername VARCHAR(64),
    @inIpPostIn VARCHAR(32),
    @inPostTime DATETIME,
    @inFecha DATE,
    @outResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

        DECLARE @idEmpleado INT,
            @idTipoMovimiento INT,
            @idUsuario INT,
            @tipoAccion VARCHAR(64),
            @saldoActual DECIMAL(10,2),
            @nuevoSaldo DECIMAL(10,2),
            @descripcionBitacora VARCHAR(512),
            @idTipoEventoIntento INT,
            @idTipoEventoExitoso INT;

    BEGIN TRY
        SELECT @idUsuario = u.id
        FROM Usuario u
        WHERE u.Username = @inUsername;

        IF @idUsuario IS NULL
        BEGIN
            SET @outResultCode = 50001;
            RETURN;
        END;

        SELECT @idEmpleado = e.id,
                @saldoActual = e.SaldoVacaciones
        FROM Empleado e
        WHERE e.ValorDocumentoIdentidad = @inValorDocumentoIdentidad
            AND e.EsActivo = 1;

        IF @idEmpleado IS NULL
        BEGIN
            INSERT INTO DBError ([UserName], [Number], [State], [Severity], [Line], [Procedure], [Message], [DateTime])
            VALUES (@inUsername, 50008, '0', '0', 0, 'sp_InsertMovimiento', 'Empleado no encontrado o inactivo: ' + @inValorDocumentoIdentidad, GETDATE());
            SET @outResultCode = 50008;
            RETURN;
        END;

        SELECT @idTipoMovimiento = tm.id,
                @tipoAccion = tm.TipoAccion
        FROM TipoMovimiento tm
        WHERE tm.Nombre = @inNombreTipoMovimiento;

        SELECT @idTipoEventoIntento = id
        FROM TipoEvento
        WHERE Nombre = 'Intento de insertar movimiento';

        SELECT @idTipoEventoExitoso = id
        FROM TipoEvento
        WHERE Nombre = 'Insertar movimiento exitoso';

        IF @idTipoEventoIntento IS NULL OR @idTipoEventoExitoso IS NULL
        BEGIN
            INSERT INTO DBError ([UserName], [Number], [State], [Severity], [Line], [Procedure], [Message], [DateTime])
            VALUES (@inUsername, 50008, '0', '0', 0, 'sp_InsertMovimiento', 'TipoEvento faltante: Intento o Exitoso no existe en tabla TipoEvento', GETDATE());
            SET @outResultCode = 50008;
            RETURN;
        END;

        IF @idTipoMovimiento IS NULL
        BEGIN
            INSERT INTO DBError ([UserName], [Number], [State], [Severity], [Line], [Procedure], [Message], [DateTime])
            VALUES (@inUsername, 50008, '0', '0', 0, 'sp_InsertMovimiento', 'TipoMovimiento no encontrado: ' + @inNombreTipoMovimiento, GETDATE());
            SET @outResultCode = 50008;
            RETURN;
        END;

        IF @tipoAccion = 'A'
            SET @nuevoSaldo = @saldoActual + @inMonto;
        ELSE IF @tipoAccion = 'R'
            SET @nuevoSaldo = @saldoActual - @inMonto;
        ELSE
        BEGIN
            INSERT INTO DBError ([UserName], [Number], [State], [Severity], [Line], [Procedure], [Message], [DateTime])
            VALUES (@inUsername, 50008, '0', '0', 0, 'sp_InsertMovimiento', 'TipoAccion inválido para TipoMovimiento id ' + CAST(@idTipoMovimiento AS VARCHAR(32)) + ': ' + ISNULL(@tipoAccion, 'NULL'), GETDATE());
            SET @outResultCode = 50008;
            RETURN;
        END;

        IF @nuevoSaldo < 0
        BEGIN
            SET @outResultCode = 50011;
            RETURN;
        END;

        SET @descripcionBitacora = 'Intento de insertar movimiento para el empleado con documento ' + @inValorDocumentoIdentidad;

        INSERT INTO BitacoraEvento (idTipoEvento, Descripcion, idUsuario, IpPostIn, PostTime)
        VALUES (@idTipoEventoIntento, @descripcionBitacora, @idUsuario, @inIpPostIn, @inPostTime);

        BEGIN TRANSACTION;

            INSERT INTO Movimiento (idEmpleado, idTipoMovimiento, Fecha, Monto, NuevoSaldo, idUsuario, IpPostIn, PostTime)
            VALUES (@idEmpleado, @idTipoMovimiento, @inFecha, @inMonto, @nuevoSaldo, @idUsuario, @inIpPostIn, @inPostTime);

            UPDATE Empleado
            SET SaldoVacaciones = @nuevoSaldo
            WHERE id = @idEmpleado;

            SET @descripcionBitacora = 'Insertar movimiento exitoso para el empleado con documento ' + @inValorDocumentoIdentidad;

            INSERT INTO BitacoraEvento (idTipoEvento, Descripcion, idUsuario, IpPostIn, PostTime)
            VALUES (@idTipoEventoExitoso, @descripcionBitacora, @idUsuario, @inIpPostIn, @inPostTime);

        COMMIT TRANSACTION;

        SET @outResultCode = 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        INSERT INTO DBError ([UserName], [Number], [State], [Severity], [Line], [Procedure], [Message], [DateTime])
        VALUES (
            @inUsername,
            ERROR_NUMBER(),
            CAST(ERROR_STATE() AS VARCHAR(32)),
            CAST(ERROR_SEVERITY() AS VARCHAR(32)),
            ERROR_LINE(),
            ISNULL(ERROR_PROCEDURE(), 'sp_InsertMovimiento'),
            ERROR_MESSAGE(),
            GETDATE()
        );

        SET @outResultCode = 50008;
    END CATCH
END;
