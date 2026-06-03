USE VacacionesDB;
GO

-- =====================================================
-- SP: Logout de usuario
-- =====================================================

DROP PROCEDURE IF EXISTS sp_Logout;
GO

CREATE PROCEDURE sp_Logout
	@inIdUsuario INT,
	@inIpPostIn VARCHAR(64),
	@inPostTime DATETIME,
	@outResultCode INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @idTipoEventoLogout INT;

	SET @outResultCode = 0;

	BEGIN TRY

		SELECT @idTipoEventoLogout = t.id
		FROM dbo.TipoEvento t
		WHERE t.Nombre = 'Logout';

		INSERT INTO dbo.BitacoraEvento (idTipoEvento,Descripcion, idUsuario, IpPostIn, PostTime)
		VALUES (@idTipoEventoLogout, NULL, @inIdUsuario, @inIpPostIn, @inPostTime)

		SET @outResultCode = 0;
	
	END TRY
	BEGIN CATCH

		INSERT INTO dbo.DBError (UserName, Number, State, Severity, Line, [Procedure], Message, DateTime)
		VALUES (
			SYSTEM_USER,
			ERROR_NUMBER(),
			CAST(ERROR_STATE() AS VARCHAR(32)),
			CAST(ERROR_SEVERITY() AS VARCHAR(32)),
			ERROR_LINE(),
			ISNULL(ERROR_PROCEDURE(), 'sp_Logout'),
			ERROR_MESSAGE(),
			GETDATE()
		);
		
		SET @outResultCode = 50008

	END CATCH
END;
GO