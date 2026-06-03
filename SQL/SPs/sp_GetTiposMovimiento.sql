USE VacacionesDB;
GO

-- =====================================================
-- SP: Obtener todos los tipos de movimiento
-- =====================================================
DROP PROCEDURE IF EXISTS sp_GetTiposMovimiento;
GO

CREATE PROCEDURE sp_GetTiposMovimiento
	@outResultCode INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY

		SELECT t.id, t.Nombre, t.TipoAccion
		FROM dbo.TipoMovimiento t
		ORDER BY Nombre ASC;

		SET @outResultCode = 0;

	END TRY
	BEGIN CATCH
		
		INSERT INTO dbo.DBError (UserName, Number, State, Severity, Line, [Procedure], Message, DateTime)
		Values(
			SYSTEM_USER,
			ERROR_NUMBER(),
			CAST(ERROR_STATE() AS VARCHAR(32)),
			CAST(ERROR_SEVERITY() AS VARCHAR(32)),
			ERROR_LINE(),
			ISNULL(ERROR_PROCEDURE(), 'sp_GetTiposMovimiento'),
			ERROR_MESSAGE(),
			GETDATE()
		);

		SET @outResultCode = 50008;
	END CATCH
END;
GO