USE [PlanillaDB];
GO

IF OBJECT_ID(N'dbo.sp_GetTiposEvento', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_GetTiposEvento];
GO

CREATE PROCEDURE [dbo].[sp_GetTiposEvento]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT id, Nombre
    FROM dbo.TipoEvento
    ORDER BY id ASC;
END;
GO
