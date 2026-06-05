USE [PlanillaDB];
GO

-- =====================================================
-- SP: Impersonar un empleado (R03)
-- =====================================================
IF OBJECT_ID(N'dbo.sp_ImpersonarEmpleado', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_ImpersonarEmpleado];
GO

CREATE PROCEDURE [dbo].[sp_ImpersonarEmpleado]
    @inValorDocumento VARCHAR(32),
    @inIdUsuarioAdmin INT,
    @inIpPostIn VARCHAR(64),
    @inPostTime DATETIME,
    @outIdEmpleado INT OUTPUT,
    @outResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @outResultCode = 0;
    SET @outIdEmpleado = NULL;

    DECLARE @idTipoEvento INT;
    DECLARE @descripcion VARCHAR(512);

    DECLARE @bitacoraData TABLE (
        idTipoEvento INT,
        Descripcion VARCHAR(512),
        idUsuario INT,
        IpPostIn VARCHAR(64),
        PostTime DATETIME
    );

    BEGIN TRY
        SELECT @outIdEmpleado = e.id
        FROM dbo.Empleado e
        WHERE e.ValorDocumento = @inValorDocumento
            AND e.Activo = 1;

        IF @outIdEmpleado IS NULL
        BEGIN
            SET @outResultCode = 50012;
            RETURN;
        END

        SELECT @idTipoEvento = t.id
        FROM dbo.TipoEvento t
        WHERE t.Nombre = 'Impersonar empleado';

        IF @idTipoEvento IS NULL
        BEGIN
            SET @outResultCode = 50008;
            RETURN;
        END

        SET @descripcion = 'Empleado.Id = ' + CAST(@outIdEmpleado AS VARCHAR(32));

        INSERT INTO @bitacoraData
        SELECT @idTipoEvento, @descripcion, @inIdUsuarioAdmin, @inIpPostIn, @inPostTime;

        BEGIN TRANSACTION
            INSERT INTO dbo.BitacoraEvento (idTipoEvento, Descripcion, idUsuario, IpPostIn, PostTime)
            SELECT idTipoEvento, Descripcion, idUsuario, IpPostIn, PostTime
            FROM @bitacoraData;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;

        INSERT INTO [dbo].[DBError] ([UserName], [Number], [State], [Severity], [Line], [Procedure], [Message], [DateTime])
        VALUES (
            SYSTEM_USER,
            ERROR_NUMBER(),
            ERROR_STATE(),
            ERROR_SEVERITY(),
            ERROR_LINE(),
            ISNULL(ERROR_PROCEDURE(), 'sp_ImpersonarEmpleado'),
            ERROR_MESSAGE(),
            GETDATE()
        );

        SET @outResultCode = 50008;
    END CATCH
END;
GO
