USE [PlanillaDB];
GO

IF OBJECT_ID(N'dbo.sp_GetPuestos', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_GetPuestos];
GO

CREATE PROCEDURE [dbo].[sp_GetPuestos]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT id, Nombre
    FROM dbo.Puesto
    ORDER BY Nombre ASC;
END;
GO
