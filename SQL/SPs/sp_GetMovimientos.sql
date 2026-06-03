USE VacacionesDB;
GO

-- =====================================================
-- SP 1: Obtener todos los movimientos de vacaciones
-- =====================================================
DROP PROCEDURE IF EXISTS sp_GetMovimientos;
GO

CREATE PROCEDURE sp_GetMovimientos
    @inValorDocumentoIdentidad VARCHAR(32),
    @outResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        SELECT
            m.id,
            m.idEmpleado,
            e.Nombre AS NombreEmpleado,
            e.ValorDocumentoIdentidad,
            m.idTipoMovimiento,
            tm.Nombre AS NombreTipoMovimiento,
            tm.TipoAccion,
            m.Monto,
            m.NuevoSaldo,
            m.Fecha,
            m.PostTime,
            m.IpPostIn,
            u.Username AS UsuarioRegistro
        FROM Movimiento m
        INNER JOIN Empleado e ON m.idEmpleado = e.id
        INNER JOIN TipoMovimiento tm ON m.idTipoMovimiento = tm.id
        INNER JOIN Usuario u ON m.idUsuario = u.id
        WHERE e.ValorDocumentoIdentidad = @inValorDocumentoIdentidad
        ORDER BY m.Fecha DESC, m.PostTime DESC;

        SET @outResultCode = 0;
    END TRY
    BEGIN CATCH
        SET @outResultCode = 50008;
    END CATCH
END;