USE [PlanillaDB]
GO
/****** Object:  Trigger [dbo].[trg_Empleado_Insert_AssignMandatoryDeductions]    Script Date: 6/2/2026 12:00:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER TRIGGER [dbo].[trg_Empleado_Insert_AssignMandatoryDeductions]
ON [dbo].[Empleado]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [dbo].[DeduccionEmpleado] (
        [idEmpleado],
        [idTipoDeduccion],
        [MontoFijo],
        [FechaInicio],
        [FechaFin]
    )
    SELECT
        i.id,
        td.id,
        td.Valor,
        i.FechaContratacion,
        CONVERT(date, '99991231')
    FROM inserted i
    CROSS JOIN [dbo].[TipoDeduccion] td
    WHERE td.EsObligatoria = 1;
END
GO
