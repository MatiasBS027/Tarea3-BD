-- =====================================================================
-- PlanillaDB - Vaciar (drop + recreate) la base de datos.
--
-- Uso:
--   1. Ejecutar este script contra el servidor (USE [master]).
--   2. Ejecutar SQL/SCRIPTS/Tablas.sql para crear las tablas.
--      (Cada corrida de sqlcmd es independiente, por eso Tablas.sql
--       arranca con su propio USE [PlanillaDB].)
--   3. Ejecutar SQL/SCRIPTS/CargarDatosXML.sql cuando se defina el
--      XML final, para sembrar los catalogos (Puesto, TipoEvento,
--      Error, etc.).
--
-- Precaucion:
--   Este script BORRA la base completa. No hay rollback. Solo correrlo
--   en desarrollo. En produccion se reemplaza por un backup/restore.
-- =====================================================================

USE [master];
GO

IF DB_ID(N'PlanillaDB') IS NOT NULL
BEGIN
    -- Forzar cierre de conexiones activas para poder dropear.
    ALTER DATABASE [PlanillaDB] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE [PlanillaDB];
END
GO

CREATE DATABASE [PlanillaDB];
GO

PRINT 'PlanillaDB vaciada y recreada como base vacia. Ejecutar Tablas.sql a continuacion.';
GO
