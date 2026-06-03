USE VacacionesDB;
GO

-- =====================================================
-- SP: Actualizar un empleado
-- =====================================================
DROP PROCEDURE IF EXISTS sp_UpdateEmpleado;
GO

CREATE PROCEDURE sp_UpdateEmpleado
    @inValorDocumentoIdentidadAntes VARCHAR(32),
    @inValorDocumentoIdentidadDespues VARCHAR(32),
    @inNombreAntes VARCHAR(128),
    @inNombreDespues VARCHAR(128),
    @inIdPuestoAntes INT,
    @inIdPuestoDespues INT,
    @inIdUsuario INT,
    @inIpPostIn VARCHAR(64),
    @inPostTime DATETIME,
    @outResultCode INT OUTPUT
AS
BEGIN
    
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @idEmpleado INT,
        @nombrePuestoAntes VARCHAR(128),
        @nombrePuestoDespues VARCHAR(128),
        @saldoVacaciones DECIMAL(10,2),
        @idTipoEventoSuccess INT,
        @idTipoEventoFail INT,
        @descripcion VARCHAR(512);

    SET @outResultCode = 0;

    BEGIN TRY
        
        SELECT @idTipoEventoSuccess = t.id
        FROM dbo.TipoEvento t
        WHERE Nombre = 'Update exitoso';

        SELECT @idTipoEventoFail = t.id
        FROM dbo.TipoEvento t
        WHERE Nombre = 'Update no exitoso';

        -- Obtener id de empleado y saldoVacaciones
        SELECT
            @idEmpleado = e.id, @saldoVacaciones = e.SaldoVacaciones
        FROM dbo.Empleado e
        WHERE e.ValorDocumentoIdentidad = @inValorDocumentoIdentidadAntes
            AND e.EsActivo = 1;

        -- Obtener nombres de puestos para la bitacora
        SELECT @nombrePuestoAntes = p.Nombre
        FROM dbo.Puesto p
        WHERE p.id = @inIdPuestoAntes;

        SELECT @nombrePuestoDespues = p.Nombre
        FROM dbo.Puesto p
        WHERE p.id = @inIdPuestoDespues;

        -- Validar ValorDocumentoIdentidad no duplicado
        IF EXISTS (
            SELECT 1
            FROM dbo.Empleado e
            WHERE e.ValorDocumentoIdentidad = @inValorDocumentoIdentidadDespues
                AND e.EsActivo = 1
                AND e.id <> @idEmpleado -- que no sea el mismo empleado 
        )
        BEGIN
            SET @outResultCode = 50006

            SET @descripcion =
                'Error: ' + (SELECT Descripcion FROM Error WHERE Codigo = 50006)
                + ' | DocAntes: '    + @inValorDocumentoIdentidadAntes
                + ' | NombreAntes: ' + @inNombreAntes
                + ' | PuestoAntes: ' + ISNULL(@nombrePuestoAntes, '')
                + ' | DocDespues: '    + @inValorDocumentoIdentidadDespues
                + ' | NombreDespues: ' + @inNombreDespues
                + ' | PuestoDespues: ' + ISNULL(@nombrePuestoDespues, '')
                + ' | Saldo: ' + CAST(@saldoVacaciones AS VARCHAR(20));

            INSERT INTO dbo.BitacoraEvento (idTipoEvento,Descripcion, idUsuario, IpPostIn, PostTime)
            VALUES (@idTipoEventoFail, @descripcion, @inIdUsuario, @inIpPostIn, @inPostTime);

            RETURN;
        END

        -- Validar nombre no duplicado (buscar en otros empleados, no en el mismo)
        IF EXISTS (
            SELECT 1
            FROM dbo.Empleado e
            WHERE e.Nombre = @inNombreDespues
                AND e.EsActivo = 1
                AND e.id <> @idEmpleado
        )
        BEGIN
            SET @outResultCode = 50007

            SET @descripcion =
                'Error: ' + (SELECT Descripcion FROM Error WHERE Codigo = 50007)
                + ' | DocAntes: '    + @inValorDocumentoIdentidadAntes
                + ' | NombreAntes: ' + @inNombreAntes
                + ' | PuestoAntes: ' + ISNULL(@nombrePuestoAntes, '')
                + ' | DocDespues: '    + @inValorDocumentoIdentidadDespues
                + ' | NombreDespues: ' + @inNombreDespues
                + ' | PuestoDespues: ' + ISNULL(@nombrePuestoDespues, '')
                + ' | Saldo: ' + CAST(@saldoVacaciones AS VARCHAR(20));

            INSERT INTO dbo.BitacoraEvento (idTipoEvento, Descripcion, idUsuario, IpPostIn, PostTime)
            VALUES (@idTipoEventoFail, @descripcion, @inIdUsuario, @inIpPostIn, @inPostTime);

            RETURN;
        END

        -- Update:
        BEGIN TRANSACTION;

            -- Solo se actualiza el empleado que se encontró por su documento anterior.
            -- Usar "=" aquí es crítico: con "<>" tocaríamos a todos los demás empleados.
            UPDATE dbo.Empleado
            SET ValorDocumentoIdentidad = @inValorDocumentoIdentidadDespues,
                Nombre = @inNombreDespues,
                idPuesto = @inIdPuestoDespues
            WHERE id = @idEmpleado;

            SET @descripcion =
                'DocAntes: '    + @inValorDocumentoIdentidadAntes
                + ' | NombreAntes: ' + @inNombreAntes
                + ' | PuestoAntes: ' + ISNULL(@nombrePuestoAntes, '')
                + ' | DocDespues: '    + @inValorDocumentoIdentidadDespues
                + ' | NombreDespues: ' + @inNombreDespues
                + ' | PuestoDespues: ' + ISNULL(@nombrePuestoDespues, '')
                + ' | Saldo: ' + CAST(@saldoVacaciones AS VARCHAR(20));

            INSERT INTO BitacoraEvento (idTipoEvento, Descripcion, idUsuario, IpPostIn, PostTime)
            VALUES (@idTipoEventoSuccess, @descripcion, @inIdUsuario, @inIpPostIn, @inPostTime);

        COMMIT TRANSACTION;

        SET @outResultCode = 0;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        INSERT INTO dbo.DBError (UserName, Number, State, Severity, Line, [Procedure], Message, DateTime)
        VALUES (
            SYSTEM_USER,
            ERROR_NUMBER(),
            CAST(ERROR_STATE() AS VARCHAR(32)),
            CAST(ERROR_SEVERITY() AS VARCHAR(32)),
            ERROR_LINE(),
            ISNULL(ERROR_PROCEDURE(), 'sp_UpdateEmpleado'),
            ERROR_MESSAGE(),
            GETDATE()
        );

        SET @descripcion =
            'Error: ' + (SELECT Descripcion FROM Error WHERE Codigo = 50008)
            + ' | DocAntes: '    + @inValorDocumentoIdentidadAntes
            + ' | NombreAntes: ' + @inNombreAntes
            + ' | PuestoAntes: ' + ISNULL(@nombrePuestoAntes, '')
            + ' | DocDespues: '    + @inValorDocumentoIdentidadDespues
            + ' | NombreDespues: ' + @inNombreDespues
            + ' | PuestoDespues: ' + ISNULL(@nombrePuestoDespues, '')
            + ' | Saldo: ' + CAST(@saldoVacaciones AS VARCHAR(20));

        INSERT INTO BitacoraEvento (idTipoEvento, Descripcion, idUsuario, IpPostIn, PostTime)
        VALUES (@idTipoEventoFail, @descripcion, @inIdUsuario, @inIpPostIn, @inPostTime);

        SET @outResultCode = 50008;
    
    END CATCH

END;
GO