USE VacacionesDB;
GO
-- =====================================================
-- SP 4: Obtener lista de empleados
-- =====================================================
DROP PROCEDURE IF EXISTS sp_GetEmpleados;
GO

CREATE PROCEDURE sp_GetEmpleados
    @outResultCode INT OUTPUT,
    @inFiltro VARCHAR(128) = NULL,
    @inUsername VARCHAR(128) = NULL,
    @inIpPostIn VARCHAR(64) = NULL,
    @inPostTime DATETIME = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @filtroNomvbrePuesto VARCHAR(128),
            @tipoFiltro VARCHAR(32),
            @usernameParaLog VARCHAR(128),
            @idUsuario INT,
            @idTipoEventoNombre INT,
            @idTipoEventoCedula INT;

    BEGIN TRY
        -- Normalizar
        SET @filtroNomvbrePuesto = LTRIM(RTRIM(ISNULL(@inFiltro, '')));
        SET @filtroNomvbrePuesto = UPPER(@filtroNomvbrePuesto);

        -- Clasificar filtro 
        IF @filtroNomvbrePuesto = ''
            SET @tipoFiltro = 'TODOS';
        ELSE IF PATINDEX('%[^0-9]%', @filtroNomvbrePuesto) = 0
            SET @tipoFiltro = 'CEDULA';
        ELSE IF PATINDEX('%[^A-Z ]%', @filtroNomvbrePuesto) = 0
            SET @tipoFiltro = 'NOMBRE_PUESTO';
        ELSE
            SET @tipoFiltro = 'NOMBRE_PUESTO';
        
        -- Obtener usuario para bitácora. Si el username no existe, usar uno válido del sistema.
        SET @usernameParaLog = LTRIM(RTRIM(ISNULL(@inUsername, '')));

        IF @usernameParaLog <> ''
            SELECT @idUsuario = Id FROM [dbo].[Usuario] WHERE Username = @usernameParaLog;

        IF @idUsuario IS NULL
            SELECT TOP 1 @idUsuario = Id FROM [dbo].[Usuario] ORDER BY Id;

        -- Obtener tipos de eventos
        SELECT @idTipoEventoNombre = id
        FROM [dbo].[TipoEvento]
        WHERE Nombre = 'Consulta con filtro de nombre';

        SELECT @idTipoEventoCedula = Id
        FROM [dbo].[TipoEvento]
        WHERE Nombre = 'Consulta con filtro de cedula';

        -- Log evento
        IF @tipoFiltro = 'NOMBRE_PUESTO' AND @idUsuario IS NOT NULL AND @idTipoEventoNombre IS NOT NULL
        BEGIN
            INSERT INTO [dbo].[BitacoraEvento] (IdUsuario, IdTipoEvento, Descripcion, IpPostIn, PostTime)
            VALUES (@idUsuario, @idTipoEventoNombre, @filtroNomvbrePuesto, @inIpPostIn, @inPostTime);
        END
        ELSE IF @tipoFiltro = 'CEDULA' AND @idUsuario IS NOT NULL AND @idTipoEventoCedula IS NOT NULL
        BEGIN
            INSERT INTO [dbo].[BitacoraEvento] (IdUsuario, IdTipoEvento, Descripcion, IpPostIn, PostTime)
            VALUES (@idUsuario, @idTipoEventoCedula, @filtroNomvbrePuesto, @inIpPostIn, @inPostTime);
        END

                -- Obtener empleados
        IF @tipoFiltro = 'NOMBRE_PUESTO'
            SELECT
                e.Id,
                e.Nombre,
                e.ValorDocumentoIdentidad,
                e.idPuesto,
                p.Nombre AS NombrePuesto
            FROM [dbo].[Empleado] e
            INNER JOIN [dbo].[Puesto] p ON e.idPuesto = p.Id
            WHERE (
                e.Nombre LIKE '%' + @filtroNomvbrePuesto + '%'
                OR p.Nombre LIKE '%' + @filtroNomvbrePuesto + '%'
            )
            AND e.EsActivo = 1
            ORDER BY e.Nombre ASC;
        
        ELSE IF @tipoFiltro = 'CEDULA'
            SELECT
                e.Id,
                e.Nombre,
                e.ValorDocumentoIdentidad,
                e.idPuesto,
                p.Nombre AS NombrePuesto
            FROM [dbo].[Empleado] e
            INNER JOIN [dbo].[Puesto] p ON e.idPuesto = p.Id
            WHERE e.ValorDocumentoIdentidad LIKE '%' + @filtroNomvbrePuesto + '%'
            AND e.EsActivo = 1
            ORDER BY e.Nombre ASC;
        
        ELSE IF @tipoFiltro = 'TODOS'
            SELECT
                e.Id,
                e.Nombre,
                e.ValorDocumentoIdentidad,
                e.idPuesto,
                p.Nombre AS NombrePuesto
            FROM [dbo].[Empleado] e
            INNER JOIN [dbo].[Puesto] p ON e.idPuesto = p.Id
            WHERE e.EsActivo = 1
            ORDER BY e.Nombre ASC;
        
        SET @outResultCode = 0;
    END TRY
    BEGIN CATCH
        INSERT INTO DBError (UserName, Number, State, Severity, Line, [Procedure], Message, DateTime)
        VALUES (
            ISNULL(@inUsername, SYSTEM_USER),
            ERROR_NUMBER(),
            CAST(ERROR_STATE() AS VARCHAR(32)),
            CAST(ERROR_SEVERITY() AS VARCHAR(32)),
            ERROR_LINE(),
            ISNULL(ERROR_PROCEDURE(), 'sp_GetEmpleados'),
            ERROR_MESSAGE(),
            GETDATE()
        );
        SET @outResultCode = 50008;
    END CATCH
END;
