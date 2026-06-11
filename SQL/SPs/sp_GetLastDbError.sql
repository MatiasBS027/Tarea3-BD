USE [PlanillaDB];
GO

IF OBJECT_ID(N'dbo.sp_GetLastDbError', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_GetLastDbError];
GO

CREATE PROCEDURE [dbo].[sp_GetLastDbError]
    @inUsername NVARCHAR(128) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @inUsername IS NOT NULL
    BEGIN
        SELECT TOP 1 [Message], DateTime
        FROM dbo.DBError
        WHERE UserName = @inUsername
        ORDER BY DateTime DESC;
    END
    ELSE
    BEGIN
        SELECT TOP 1 [Message], DateTime
        FROM dbo.DBError
        ORDER BY DateTime DESC;
    END;
END;
GO
