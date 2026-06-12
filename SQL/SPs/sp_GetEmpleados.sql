USE [PlanillaDB];
GO

-- =====================================================
-- SP: Obtener lista de empleados (R01/R02)
-- =====================================================
IF OBJECT_ID(N'dbo.sp_GetEmpleados', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_GetEmpleados];
GO

CREATE PROCEDURE [dbo].[sp_GetEmpleados]
    @inNombre VARCHAR(128) = NULL,
    @inPostTime DATETIME = NULL,
    @inIpPostIn VARCHAR(64) = NULL,
    @outResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    SET @outResultCode = 0;

    BEGIN TRY
        SET @inNombre = LTRIM(RTRIM(ISNULL(@inNombre, '')));

        IF @inNombre = ''
        BEGIN
            SELECT
                e.id,
                e.Nombre,
                e.ValorDocumento,
                e.idPuesto,
                p.Nombre AS NombrePuesto
            FROM dbo.Empleado e
            INNER JOIN dbo.Puesto p ON e.idPuesto = p.id
            WHERE e.Activo = 1
            ORDER BY e.Nombre ASC;
        END
        ELSE
        BEGIN
            -- R07: registrar el filtro usado en BitacoraEvento
            -- TipoEvento 5 = "Filtro empleados" (se asume que existe en catalogo)
            IF EXISTS (SELECT 1 FROM dbo.TipoEvento WHERE id = 5)
            BEGIN
                BEGIN TRANSACTION
                    INSERT INTO dbo.BitacoraEvento (idTipoEvento, idUsuario, PostTime, IpPostIn, Descripcion)
                    VALUES (5, NULL, @inPostTime, @inIpPostIn, 'Filtro empleado: ' + @inNombre);
                COMMIT TRANSACTION;
            END;

            SELECT
                e.id,
                e.Nombre,
                e.ValorDocumento,
                e.idPuesto,
                p.Nombre AS NombrePuesto
            FROM dbo.Empleado e
            INNER JOIN dbo.Puesto p ON e.idPuesto = p.id
            WHERE e.Activo = 1
                AND e.Nombre LIKE '%' + @inNombre + '%'
            ORDER BY e.Nombre ASC;
        END

        SET @outResultCode = 0;
    END TRY
    BEGIN CATCH
        INSERT INTO [dbo].[DBError] ([UserName], [Number], [State], [Severity], [Line], [Procedure], [Message], [DateTime])
        VALUES (
            SYSTEM_USER,
            ERROR_NUMBER(),
            ERROR_STATE(),
            ERROR_SEVERITY(),
            ERROR_LINE(),
            ISNULL(ERROR_PROCEDURE(), 'sp_GetEmpleados'),
            ERROR_MESSAGE(),
            GETDATE()
        );

        SET @outResultCode = 50008;
    END CATCH
END;
GO
