USE VacacionesDB;
GO

-- =====================================================
-- SP: Insertar un nuevo empleado
-- =====================================================
DROP PROCEDURE IF EXISTS sp_InsertEmpleado;
GO

CREATE PROCEDURE sp_InsertEmpleado
    @inValorDocumentoIdentidad VARCHAR(32),
    @inNombre VARCHAR(128),
    @inIdPuesto INT,
    @inIdUsuario INT,
    @inIpPostIn VARCHAR(64),
    @inPostTime DATETIME,
    @outResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

        DECLARE @nombrePuesto VARCHAR(128),
            @idTipoEventoOk INT,
            @idTipoEventoFail INT,
            @descripcion VARCHAR(512);

    SET @outResultCode = 0;

    BEGIN TRY

        -- Obtener id de TipoEvento para bitácora
        SELECT @idTipoEventoOk   = id FROM TipoEvento WHERE Nombre = 'Insercion exitosa';
        SELECT @idTipoEventoFail = id FROM TipoEvento WHERE Nombre = 'Insercion no exitosa';

        -- Obtener nombre del puesto para bitácora
        SELECT @nombrePuesto = Nombre
        FROM Puesto
        WHERE id = @inIdPuesto;

        -- Validar valorDocumentoIdentidad duplicado
        IF EXISTS (
            SELECT 1 FROM Empleado
            WHERE ValorDocumentoIdentidad = @inValorDocumentoIdentidad
            AND EsActivo = 1
        )
        BEGIN
            SET @outResultCode = 50004;

            SET @descripcion =
                'Error: ' + (SELECT Descripcion FROM Error WHERE Codigo = 50004)
                + ' | ValorDocumentoIdentidad: ' + @inValorDocumentoIdentidad
                + ' | Nombre: ' + @inNombre
                + ' | Puesto: ' + ISNULL(@nombrePuesto, '');

            INSERT INTO BitacoraEvento (idTipoEvento, Descripcion, idUsuario, IpPostIn, PostTime)
            VALUES (@idTipoEventoFail, @descripcion, @inIdUsuario, @inIpPostIn, @inPostTime);

            RETURN;
        END

        -- Validar nombre duplicado
        IF EXISTS (
            SELECT 1 FROM Empleado
            WHERE Nombre = @inNombre
            AND EsActivo = 1
        )
        BEGIN
            SET @outResultCode = 50005;

            SET @descripcion =
                'Error: ' + (SELECT Descripcion FROM Error WHERE Codigo = 50005)
                + ' | ValorDocumentoIdentidad: ' + @inValorDocumentoIdentidad
                + ' | Nombre: ' + @inNombre
                + ' | Puesto: ' + ISNULL(@nombrePuesto, '');

            INSERT INTO BitacoraEvento (idTipoEvento, Descripcion, idUsuario, IpPostIn, PostTime)
            VALUES (@idTipoEventoFail, @descripcion, @inIdUsuario, @inIpPostIn, @inPostTime);

            RETURN;
        END

        -- Insertar empleado
        BEGIN TRANSACTION;

            INSERT INTO Empleado
            VALUES (@inIdPuesto, @inValorDocumentoIdentidad, @inNombre, CAST(GETDATE() AS DATE), 0.00, 1);

            -- Bitacora: Insercion exitosa
            SET @descripcion =
                'ValorDocumentoIdentidad: ' + @inValorDocumentoIdentidad
                + ' | Nombre: ' + @inNombre
                + ' | Puesto: ' + ISNULL(@nombrePuesto, '');

            INSERT INTO BitacoraEvento (idTipoEvento, Descripcion, idUsuario, IpPostIn, PostTime)
            VALUES (@idTipoEventoOk, @descripcion, @inIdUsuario, @inIpPostIn, @inPostTime);

        COMMIT TRANSACTION;

        SET @outResultCode = 0;

    END TRY
    BEGIN CATCH

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- Registrar en DBError
        INSERT INTO DBError (UserName, Number, State, Severity, Line, [Procedure], Message, DateTime)
        VALUES (
            SYSTEM_USER,
            ERROR_NUMBER(),
            CAST(ERROR_STATE() AS VARCHAR(32)),
            CAST(ERROR_SEVERITY() AS VARCHAR(32)),
            ERROR_LINE(),
            ISNULL(ERROR_PROCEDURE(), 'sp_InsertarEmpleado'),
            ERROR_MESSAGE(),
            GETDATE()
        );

        -- Bitacora: Insercion no exitosa por error de BD
        SET @descripcion =
            'Error: ' + (SELECT Descripcion FROM Error WHERE Codigo = 50008)
            + ' | ValorDocumentoIdentidad: ' + @inValorDocumentoIdentidad
            + ' | Nombre: ' + @inNombre
            + ' | Puesto: ' + ISNULL(@nombrePuesto, '');

        INSERT INTO BitacoraEvento (idTipoEvento, Descripcion, idUsuario, IpPostIn, PostTime)
        VALUES (@idTipoEventoFail, @descripcion, @inIdUsuario, @inIpPostIn, @inPostTime);

        SET @outResultCode = 50008;

    END CATCH
END;
GO