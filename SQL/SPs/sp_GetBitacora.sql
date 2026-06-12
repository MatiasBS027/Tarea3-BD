USE [PlanillaDB];
GO

IF OBJECT_ID(N'dbo.sp_GetBitacora', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_GetBitacora];
GO

CREATE PROCEDURE [dbo].[sp_GetBitacora]
    @inIdTipoEvento INT = NULL,
    @inIdUsuario INT = NULL,
    @inFechaDesde DATETIME = NULL,
    @inFechaHasta DATETIME = NULL,
    @inIpPostIn VARCHAR(64) = NULL,
    @inPageSize INT = 50,
    @inPageNumber INT = 1,
    @outResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @outResultCode = 0;

    BEGIN TRY
        DECLARE @offset INT;

        IF @inPageNumber < 1 SET @inPageNumber = 1;
        IF @inPageSize < 1 SET @inPageSize = 50;

        SET @offset = (@inPageNumber - 1) * @inPageSize;

        SELECT
            b.id,
            b.idTipoEvento,
            te.Nombre AS TipoEvento,
            b.idUsuario,
            u.Username,
            b.Descripcion,
            b.PostTime,
            b.IpPostIn
        FROM dbo.BitacoraEvento b
        INNER JOIN dbo.TipoEvento te ON b.idTipoEvento = te.id
        LEFT JOIN dbo.Usuario u ON b.idUsuario = u.id
        WHERE (@inIdTipoEvento IS NULL OR b.idTipoEvento = @inIdTipoEvento)
          AND (@inIdUsuario IS NULL OR b.idUsuario = @inIdUsuario)
          AND (@inFechaDesde IS NULL OR b.PostTime >= @inFechaDesde)
          AND (@inFechaHasta IS NULL OR b.PostTime <= @inFechaHasta)
          AND (@inIpPostIn IS NULL OR b.IpPostIn LIKE '%' + @inIpPostIn + '%')
        ORDER BY b.PostTime DESC
        OFFSET @offset ROWS
        FETCH NEXT @inPageSize ROWS ONLY;

        SELECT COUNT(*) AS Total
        FROM dbo.BitacoraEvento b
        WHERE (@inIdTipoEvento IS NULL OR b.idTipoEvento = @inIdTipoEvento)
          AND (@inIdUsuario IS NULL OR b.idUsuario = @inIdUsuario)
          AND (@inFechaDesde IS NULL OR b.PostTime >= @inFechaDesde)
          AND (@inFechaHasta IS NULL OR b.PostTime <= @inFechaHasta)
          AND (@inIpPostIn IS NULL OR b.IpPostIn LIKE '%' + @inIpPostIn + '%');

    END TRY
    BEGIN CATCH
        INSERT INTO dbo.DBError (UserName, Number, State, Severity, Line, [Procedure], Message, DateTime)
        VALUES (
            SYSTEM_USER,
            ERROR_NUMBER(),
            ERROR_STATE(),
            ERROR_SEVERITY(),
            ERROR_LINE(),
            ISNULL(ERROR_PROCEDURE(), 'sp_GetBitacora'),
            ERROR_MESSAGE(),
            GETDATE()
        );
        SET @outResultCode = 50008;
    END CATCH
END;
GO
