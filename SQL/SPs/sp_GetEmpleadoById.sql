USE VacacionesDB;
GO

-- =====================================================
-- SP: Obtener un empleado por ValorDocumentoIdentidad
-- =====================================================
DROP PROCEDURE IF EXISTS sp_GetEmpleadoById;
GO

CREATE PROCEDURE sp_GetEmpleadoById
	@inValorDocumentoIdentidad VARCHAR(32)
	, @outResultCode INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		DECLARE @nombreColumnaFecha SYSNAME,
		        @sql NVARCHAR(MAX);

		SELECT @nombreColumnaFecha = c.name
		FROM sys.columns c
		INNER JOIN sys.tables t ON c.object_id = t.object_id
		INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
		WHERE s.name = 'dbo'
		AND t.name = 'Empleado'
		AND c.name LIKE 'FechaContr%';

		IF @nombreColumnaFecha IS NULL
		BEGIN
			SET @outResultCode = 50008;
			RETURN;
		END

		SET @sql = N'
			SELECT
				e.ValorDocumentoIdentidad
				, e.Nombre
				, e.idPuesto
				, p.Nombre AS NombrePuesto
				, CAST(e.' + QUOTENAME(@nombreColumnaFecha) + N' AS DATE) AS FechaContratacion
				, e.SaldoVacaciones
				, e.EsActivo
			FROM dbo.Empleado e
			INNER JOIN Puesto p ON e.idPuesto = p.id
			WHERE e.ValorDocumentoIdentidad = @inValorDocumentoIdentidad
				AND e.EsActivo = 1';

		EXEC sp_executesql
			@sql,
			N'@inValorDocumentoIdentidad VARCHAR(32)',
			@inValorDocumentoIdentidad = @inValorDocumentoIdentidad;

		-- No hubo errores
		SET @outResultCode = 0;

	END TRY
	BEGIN CATCH
		
		INSERT INTO DBError (UserName, Number, State, Severity, Line, [Procedure], Message, DateTime)
		Values(
			SYSTEM_USER,
			ERROR_NUMBER(),
			CAST(ERROR_STATE() AS VARCHAR(32)),
			CAST(ERROR_SEVERITY() AS VARCHAR(32)),
			ERROR_LINE(),
			ISNULL(ERROR_PROCEDURE(), 'sp_GetEmpleadoById'),
			ERROR_MESSAGE(),
			GETDATE()
		);

		SET @outResultCode = 50008;

	END CATCH

END;
GO