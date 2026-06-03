USE VacacionesDB;
GO

-- =====================================================
-- SP: Login de usuario
-- =====================================================
DROP PROCEDURE IF EXISTS sp_Login;
GO

CREATE PROCEDURE sp_Login
	@inUsername VARCHAR(128),
	@inPassword VARCHAR(128),
	@inIpPostIn VARCHAR(64),
	@inPostTime DATETIME,
	@outResultCode INT OUTPUT
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @idUsuario INT,
		@password VARCHAR(128),
		@idTipoEventoSuccess INT,
		@idTipoEventoFail INT,
		@idTipoEventoDisabled INT,
		@intentosFallidos INT,
		@descripcion VARCHAR(512)

		SET @outResultCode = 0;

	BEGIN TRY
			
		SELECT @idTipoEventoSuccess = t.id
		FROM dbo.TipoEvento t
		WHERE t.Nombre = 'Login Exitoso';

		SELECT @idTipoEventoFail = t.id
		FROM dbo.TipoEvento t
		WHERE t.Nombre = 'Login No Exitoso';

		SELECT @idTipoEventoDisabled = t.id
		FROM dbo.TipoEvento t
		WHERE t.Nombre = 'Login deshabilitado';

		-- Obtener datos del usuario
		-- @idUsuario y @password serán NULL si no existe @inUsername en la BD
		SELECT @idUsuario = u.id, @password = u.password
		FROM dbo.Usuario u
		WHERE u.Username = @inUsername;

		-- Verificar que existe usuario
		IF @idUsuario IS NULL
		BEGIN

			-- Contat intentos fallidos por IP en los ultimos 20 min
			SELECT @intentosFallidos = COUNT(*)
			FROM dbo.BitacoraEvento b
			WHERE b.idTipoEvento = @idTipoEventoFail
				AND b.IpPostIn = @inIpPostIn
				AND b.PostTime >= DATEADD(MINUTE, -20, @inPostTime);
			
			IF @intentosFallidos >= 5
			BEGIN
				SET @outResultCode = 50003;

				INSERT INTO dbo.BitacoraEvento (idTipoEvento, Descripcion, idUsuario, IpPostIn, PostTime)
				VALUES (@idTipoEventoDisabled, NULL, NULL, @inIpPostIn, @inPostTime)

				RETURN;
			END

			SET @descripcion = 'Intento: ' + CAST(@intentosFallidos + 1 AS VARCHAR(10))
				+ ' | Error: ' + (SELECT Descripcion FROM dbo.Error WHERE Codigo = 50001);

			INSERT INTO dbo.BitacoraEvento (idTipoEvento, Descripcion, idUsuario, IpPostIn, PostTime)
			VALUES (@idTipoEventoFail, @descripcion, NULL, @inIpPostIn, @inPostTime);

			SET @outResultCode = 50001;
			RETURN;
		END

		-- Contar intentos fallidos en los ultimos 20 min
		SELECT @intentosFallidos = COUNT(*)
		FROM dbo.BitacoraEvento b
		WHERE b.idTipoEvento = @idTipoEventoFail
			AND b.idUsuario = @idUsuario
			AND b.IpPostIn = @inIpPostIn
			AND b.PostTime >= DATEADD(MINUTE, -20, @inPostTime);

		IF @intentosFallidos >= 5
		BEGIN
			SET @outResultCode = 50003;

			INSERT INTO dbo.BitacoraEvento (idTipoEvento, Descripcion, idUsuario, IpPostIn, PostTime)
			VALUES (@idTipoEventoDisabled, NULL, @idUsuario, @inIpPostIn, @inPostTime)

			RETURN;
		END

		-- Verficar password
		IF @password <> @inPassword
		BEGIN
			SET @outResultCode = 50002;

			SET @descripcion = 'Intento: ' + CAST(@intentosFallidos + 1 AS VARCHAR(10))
                + ' | Error: ' + (SELECT Descripcion FROM dbo.Error WHERE Codigo = 50002);

            INSERT INTO dbo.BitacoraEvento (idTipoEvento, Descripcion, idUsuario, IpPostIn, PostTime)
            VALUES (@idTipoEventoFail, @descripcion, @idUsuario, @inIpPostIn, @inPostTime);

			RETURN;
		END

		-- Si Login exitoso
		INSERT INTO BitacoraEvento (idTipoEvento, Descripcion, idUsuario, IpPostIn, PostTime)
        VALUES (@idTipoEventoSuccess, 'Exitoso', @idUsuario, @inIpPostIn, @inPostTime);

		SET @outResultCode = 0;
		
	END TRY
	BEGIN CATCH
		
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