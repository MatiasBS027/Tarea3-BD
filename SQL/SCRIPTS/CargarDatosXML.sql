-- =====================================================================
-- PlanillaDB - Carga inicial de catalogos desde XML.
--
-- ESTADO: SCAFFOLD / PENDIENTE.
-- Este archivo deja la firma del SP lista para que, cuando se defina el
-- XML final de catalogos, solo haya que rellenar el cuerpo.
--
-- Mientras tanto, la BD ya cuenta con una semilla minima inline en
-- Tablas.sql (codigos de Error y Tipos de Evento basicos) para que
-- el backend pueda correr sin necesidad de invocar este SP.
--
-- Tablas que este SP deberia alimentar (mapeo conceptual -> BD):
--   XML de catalogos                      Tabla(s) destino
--   -----------------------------------   --------------------------------------
--   <Puestos>                             dbo.Puesto (por Nombre)
--   <TiposJornada>                        dbo.TipoJornada (por Nombre)
--   <Feriados>                            dbo.Feriados (por Fecha)
--   <TiposEvento>                         dbo.TipoEvento (por Nombre)
--   <TiposMovimiento>                     dbo.TipoMov (por Nombre; mapear
--                                          TipoAccion "Credito"/"Debito" -> 'C'/'D')
--   <TiposDeduccion>                      dbo.TipoDeduccion + DeduccionXLEy /
--                                          DeduccionNoObligatoria /
--                                          DeduccionMontoFijo /
--                                          DeduccionPorcentual
--   <Empleados>                           dbo.Empleado + dbo.Usuario +
--                                          dbo.UsuarioEmpleado (el trigger
--                                          trg_Empleado_Insert_AssignMandatoryDeductions
--                                          asigna deducciones de ley)
--   <Movimientos>                         dbo.MovPlanilla
--   <Usuarios>                            dbo.Usuario (Username, Password)
--
-- NOTA: NO se cargan tablas Departamento ni TipoDocumentoIdentidad.
-- Esos catalogos existenian en el XML de operacion del enunciado original
-- pero el modelo conceptual corregido los omitio por no aportar a la
-- logica de planilla.
-- =====================================================================

USE [PlanillaDB];
GO

IF OBJECT_ID(N'dbo.sp_CargarCatalogosXML', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_CargarCatalogosXML];
GO

CREATE PROCEDURE [dbo].[sp_CargarCatalogosXML]
    @XmlCatalogos NVARCHAR(MAX),
    @outResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SET @outResultCode = 0;

    -- TODO: implementar el cuerpo del SP siguiendo el patron de
    -- Tarea2-BD\SQL\Scripts\CargarDatosXML.sql (sp_CargarDatosInicialesXML):
    --   1. sp_xml_preparedocument sobre @XmlCatalogos
    --   2. OPENXML para cada seccion del XML
    --   3. INSERT ... WHERE NOT EXISTS para idempotencia
    --   4. BEGIN TRANSACTION / COMMIT (o ROLLBACK en CATCH)
    --   5. sp_xml_removedocument al final
    --
    -- Recordar que este SP se invoca desde la aplicacion o desde un
    -- script de bootstrap, no desde los SPs de negocio.

    -- PLACEHOLDER: emitir un error claro para que no se ejecute en silencio.
    RAISERROR(N'sp_CargarCatalogosXML es un scaffold pendiente de implementacion. Definir el XML final antes de poblar.', 16, 1);
    SET @outResultCode = 50008;
END;
GO
