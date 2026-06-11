USE [PlanillaDB];
GO

IF OBJECT_ID(N'dbo.sp_GetUsuarioId', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_GetUsuarioId];
GO

CREATE PROCEDURE [dbo].[sp_GetUsuarioId]
    @inUsername VARCHAR(128)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT id
    FROM dbo.Usuario
    WHERE Username = @inUsername;
END;
GO
