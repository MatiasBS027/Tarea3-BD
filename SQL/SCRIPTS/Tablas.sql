-- =====================================================================
-- PlanillaDB - Esquema fisico
-- ITCR - Escuela de Ing. en Computacion - Base de Datos 1 - Prof. fquiros
-- Mayo 2026 - Proyecto: Control de asistencia y Planilla Obrera
--
-- Origen del modelo:
--   * Modelo conceptual provisto por el profesor (Modelo Conceptual.png),
--     con la correccion de NO incluir Departamento ni TipoDocumentoIdentidad
--     (catalogos que existian en el XML de operacion pero no aportan a la
--     logica de planilla).
--   * Convenciones estructurales copiadas de Tarea2-BD (ids en minuscula,
--     tablas DBError y [Error] para trazabilidad de SPs, uso de
--     @outResultCode INT OUTPUT en cada SP).
--
-- Convenciones:
--   * Tablas con id INT IDENTITY(1,1) (los catalogos tambien - ver nota).
--   * FKs nombradas FK_Origen_Destino.
--   * UNIQUE nombradas UQ_Tabla_Cols.
--   * CHECK nombradas CK_Tabla_Restriccion.
--   * Tipos:
--       Montos   -> money
--       Porcents -> decimal(8,4)
--       Fechas   -> date / datetime / time(0)
--       IDs      -> int
--
-- Nota sobre catalogos:
--   En Tarea2-BD todos los catalogos llevan IDENTITY(1,1) y se referencian
--   por id. Se mantiene el mismo criterio para consistencia, aunque el XML
--   de operacion original del profesor sugiriera ids manuales. El SP de
--   carga sp_CargarCatalogosXML queda como scaffold pendiente del XML
--   definitivo (ver CargarDatosXML.sql).
--
-- Nota sobre uso:
--   Este script NO crea ni recrea la base. Asume que [PlanillaDB] ya
--   existe (al igual que el CrearBD.sql de Tarea2-BD asume [VacacionesDB]).
--   La creacion/recarga de la base se hace por separado. La carga de
--   catalogos (incluyendo los codigos de Error y los TipoEvento) la hace
--   sp_CargarCatalogosXML, no este archivo.
-- =====================================================================

USE [PlanillaDB];
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

-- =====================================================================
-- CATALOGOS (12 tablas)
-- =====================================================================

-- ----------------------------------------------------
-- TipoEvento: catalogo de eventos para la BitacoraEvento
-- ----------------------------------------------------
IF OBJECT_ID(N'dbo.TipoEvento', N'U') IS NOT NULL
    DROP TABLE [dbo].[TipoEvento];
GO

CREATE TABLE [dbo].[TipoEvento](
    [id]     [int]       IDENTITY(1,1) NOT NULL,
    [Nombre] [varchar](64) NOT NULL,
    CONSTRAINT [PK_TipoEvento] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [UQ_TipoEvento_Nombre] UNIQUE ([Nombre])
);
GO

-- ----------------------------------------------------
-- TipoMov: catalogo de tipos de movimiento
--   Accion = 'C' (Credito) | 'D' (Debito)
--   Solo se usa para MovPlanilla y MovHoras.
-- ----------------------------------------------------
IF OBJECT_ID(N'dbo.TipoMov', N'U') IS NOT NULL
    DROP TABLE [dbo].[TipoMov];
GO

CREATE TABLE [dbo].[TipoMov](
    [id]     [int]       IDENTITY(1,1) NOT NULL,
    [Nombre] [varchar](64) NOT NULL,
    [Accion] [char](1)   NOT NULL,
    CONSTRAINT [PK_TipoMov] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [UQ_TipoMov_Nombre] UNIQUE ([Nombre]),
    CONSTRAINT [CK_TipoMov_Accion] CHECK ([Accion] IN ('C', 'D'))
);
GO

-- ----------------------------------------------------
-- TipoJornada: catalogo de turnos (Diurno, Vespertino, Nocturno, etc.)
-- ----------------------------------------------------
IF OBJECT_ID(N'dbo.TipoJornada', N'U') IS NOT NULL
    DROP TABLE [dbo].[TipoJornada];
GO

CREATE TABLE [dbo].[TipoJornada](
    [id]         [int]       IDENTITY(1,1) NOT NULL,
    [Nombre]     [varchar](64) NOT NULL,
    [HoraInicio] [time](0)   NOT NULL,
    [HoraFin]    [time](0)   NOT NULL,
    CONSTRAINT [PK_TipoJornada] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [UQ_TipoJornada_Nombre] UNIQUE ([Nombre]),
    CONSTRAINT [CK_TipoJornada_Horas] CHECK ([HoraFin] <> [HoraInicio])
);
GO

-- ----------------------------------------------------
-- Puesto: catalogo de puestos. SalarioXHora es la base para planilla.
-- ----------------------------------------------------
IF OBJECT_ID(N'dbo.Puesto', N'U') IS NOT NULL
    DROP TABLE [dbo].[Puesto];
GO

CREATE TABLE [dbo].[Puesto](
    [id]            [int]            IDENTITY(1,1) NOT NULL,
    [Nombre]        [varchar](128)   NOT NULL,
    [SalarioXHora]  [decimal](10, 2) NOT NULL,
    CONSTRAINT [PK_Puesto] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [UQ_Puesto_Nombre] UNIQUE ([Nombre]),
    CONSTRAINT [CK_Puesto_SalarioXHora] CHECK ([SalarioXHora] >= 0)
);
GO

-- ----------------------------------------------------
-- TipoDeduccion: raiz de la jerarquia de deducciones.
--   FlagObligatorio = 1 -> existe fila en DeduccionXLEy (Porcentaje, de ley)
--   FlagObligatorio = 0 -> existe fila en DeduccionNoObligatoria
-- ----------------------------------------------------
IF OBJECT_ID(N'dbo.TipoDeduccion', N'U') IS NOT NULL
    DROP TABLE [dbo].[TipoDeduccion];
GO

CREATE TABLE [dbo].[TipoDeduccion](
    [id]              [int] IDENTITY(1,1) NOT NULL,
    [FlagObligatorio] [bit] NOT NULL,
    CONSTRAINT [PK_TipoDeduccion] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [CK_TipoDeduccion_FlagObligatorio] CHECK ([FlagObligatorio] IN (0, 1))
);
GO

-- ----------------------------------------------------
-- DeduccionXLEy: subtipo de TipoDeduccion cuando es obligatoria (de ley).
--   Porcentaje es lo que se retiene por planilla semanal.
-- ----------------------------------------------------
IF OBJECT_ID(N'dbo.DeduccionXLEy', N'U') IS NOT NULL
    DROP TABLE [dbo].[DeduccionXLEy];
GO

CREATE TABLE [dbo].[DeduccionXLEy](
    [idTipoDeduccion] [int]            NOT NULL,
    [Porcentaje]      [decimal](8, 4)  NOT NULL,
    CONSTRAINT [PK_DeduccionXLEy] PRIMARY KEY CLUSTERED ([idTipoDeduccion] ASC),
    CONSTRAINT [FK_DeduccionXLEy_TipoDeduccion] FOREIGN KEY ([idTipoDeduccion])
        REFERENCES [dbo].[TipoDeduccion]([id]),
    CONSTRAINT [CK_DeduccionXLEy_Porcentaje] CHECK ([Porcentaje] >= 0 AND [Porcentaje] <= 1)
);
GO

-- ----------------------------------------------------
-- DeduccionNoObligatoria: subtipo de TipoDeduccion cuando es opcional.
--   FlagFijo = 1 -> existe fila en DeduccionMontoFijo (Monto)
--   FlagFijo = 0 -> existe fila en DeduccionPorcentual (Porcentaje)
-- ----------------------------------------------------
IF OBJECT_ID(N'dbo.DeduccionNoObligatoria', N'U') IS NOT NULL
    DROP TABLE [dbo].[DeduccionNoObligatoria];
GO

CREATE TABLE [dbo].[DeduccionNoObligatoria](
    [idTipoDeduccion] [int] NOT NULL,
    [FlagFijo]        [bit] NOT NULL,
    CONSTRAINT [PK_DeduccionNoObligatoria] PRIMARY KEY CLUSTERED ([idTipoDeduccion] ASC),
    CONSTRAINT [FK_DeduccionNoObligatoria_TipoDeduccion] FOREIGN KEY ([idTipoDeduccion])
        REFERENCES [dbo].[TipoDeduccion]([id]),
    CONSTRAINT [CK_DeduccionNoObligatoria_FlagFijo] CHECK ([FlagFijo] IN (0, 1))
);
GO

-- ----------------------------------------------------
-- DeduccionMontoFijo: subtipo de DeduccionNoObligatoria con monto fijo.
-- ----------------------------------------------------
IF OBJECT_ID(N'dbo.DeduccionMontoFijo', N'U') IS NOT NULL
    DROP TABLE [dbo].[DeduccionMontoFijo];
GO

CREATE TABLE [dbo].[DeduccionMontoFijo](
    [idTipoDeduccion] [int]   NOT NULL,
    [Monto]           [money] NOT NULL,
    CONSTRAINT [PK_DeduccionMontoFijo] PRIMARY KEY CLUSTERED ([idTipoDeduccion] ASC),
    CONSTRAINT [FK_DeduccionMontoFijo_DeduccionNoObligatoria] FOREIGN KEY ([idTipoDeduccion])
        REFERENCES [dbo].[DeduccionNoObligatoria]([idTipoDeduccion]),
    CONSTRAINT [CK_DeduccionMontoFijo_Monto] CHECK ([Monto] >= 0)
);
GO

-- ----------------------------------------------------
-- DeduccionPorcentual: subtipo de DeduccionNoObligatoria con porcentaje.
-- ----------------------------------------------------
IF OBJECT_ID(N'dbo.DeduccionPorcentual', N'U') IS NOT NULL
    DROP TABLE [dbo].[DeduccionPorcentual];
GO

CREATE TABLE [dbo].[DeduccionPorcentual](
    [idTipoDeduccion] [int]           NOT NULL,
    [Porcentaje]      [decimal](8, 4) NOT NULL,
    CONSTRAINT [PK_DeduccionPorcentual] PRIMARY KEY CLUSTERED ([idTipoDeduccion] ASC),
    CONSTRAINT [FK_DeduccionPorcentual_DeduccionNoObligatoria] FOREIGN KEY ([idTipoDeduccion])
        REFERENCES [dbo].[DeduccionNoObligatoria]([idTipoDeduccion]),
    CONSTRAINT [CK_DeduccionPorcentual_Porcentaje] CHECK ([Porcentaje] >= 0 AND [Porcentaje] <= 1)
);
GO

-- ----------------------------------------------------
-- Feriados: catalogo. Fecha es UNIQUE (no se repiten feriados).
-- ----------------------------------------------------
IF OBJECT_ID(N'dbo.Feriados', N'U') IS NOT NULL
    DROP TABLE [dbo].[Feriados];
GO

CREATE TABLE [dbo].[Feriados](
    [id]     [int]          IDENTITY(1,1) NOT NULL,
    [Nombre] [varchar](128) NOT NULL,
    [Fecha]  [date]         NOT NULL,
    CONSTRAINT [PK_Feriados] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [UQ_Feriados_Fecha] UNIQUE ([Fecha])
);
GO

-- ----------------------------------------------------
-- Mes: ciclo de planilla mensual (ultimo viernes mes anterior -> ultimo jueves mes en curso).
-- ----------------------------------------------------
IF OBJECT_ID(N'dbo.Mes', N'U') IS NOT NULL
    DROP TABLE [dbo].[Mes];
GO

CREATE TABLE [dbo].[Mes](
    [id]          [int]  IDENTITY(1,1) NOT NULL,
    [FechaInicio] [date] NOT NULL,
    [FechaFin]    [date] NOT NULL,
    CONSTRAINT [PK_Mes] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [CK_Mes_Fechas] CHECK ([FechaFin] > [FechaInicio])
);
GO

-- ----------------------------------------------------
-- Semana: ciclo de planilla semanal (viernes -> jueves).
-- ----------------------------------------------------
IF OBJECT_ID(N'dbo.Semana', N'U') IS NOT NULL
    DROP TABLE [dbo].[Semana];
GO

CREATE TABLE [dbo].[Semana](
    [id]          [int]  IDENTITY(1,1) NOT NULL,
    [FechaInicio] [date] NOT NULL,
    [FechaFin]    [date] NOT NULL,
    CONSTRAINT [PK_Semana] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [CK_Semana_Fechas] CHECK ([FechaFin] > [FechaInicio])
);
GO

-- =====================================================================
-- DOMINIO (10 tablas)
-- =====================================================================

-- ----------------------------------------------------
-- Usuario: cuentas del sistema.
--   Tipo = 1 (Administrador) | 2 (Empleado)
--   Las subtablas UsuarioAdministrador y UsuarioEmpleado materializan
--   el "child" del modelo conceptual.
-- ----------------------------------------------------
IF OBJECT_ID(N'dbo.Usuario', N'U') IS NOT NULL
    DROP TABLE [dbo].[Usuario];
GO

CREATE TABLE [dbo].[Usuario](
    [id]       [int]          IDENTITY(1,1) NOT NULL,
    [Username] [varchar](64)  NOT NULL,
    [Password] [varchar](64)  NOT NULL,
    [Tipo]     [tinyint]      NOT NULL,
    CONSTRAINT [PK_Usuario] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [UQ_Usuario_Username] UNIQUE ([Username]),
    CONSTRAINT [CK_Usuario_Tipo] CHECK ([Tipo] IN (1, 2))
);
GO

-- ----------------------------------------------------
-- UsuarioAdministrador: 1:1 con Usuario cuando Tipo = 1.
-- ----------------------------------------------------
IF OBJECT_ID(N'dbo.UsuarioAdministrador', N'U') IS NOT NULL
    DROP TABLE [dbo].[UsuarioAdministrador];
GO

CREATE TABLE [dbo].[UsuarioAdministrador](
    [idUsuario] [int] NOT NULL,
    CONSTRAINT [PK_UsuarioAdministrador] PRIMARY KEY CLUSTERED ([idUsuario] ASC),
    CONSTRAINT [FK_UsuarioAdministrador_Usuario] FOREIGN KEY ([idUsuario])
        REFERENCES [dbo].[Usuario]([id])
);
GO

-- ----------------------------------------------------
-- Empleado: personas que reciben planilla.
--   ValorDocumentoIdentidad es UNIQUE (control de duplicados).
--   Nota: el nombre de columna sigue Tarea2-BD / controladores; el modelo
--   conceptual dice "documentoIdentidad" pero la columna larga es la que
--   esperan los SPs ya escritos.
-- ----------------------------------------------------
IF OBJECT_ID(N'dbo.Empleado', N'U') IS NOT NULL
    DROP TABLE [dbo].[Empleado];
GO

CREATE TABLE [dbo].[Empleado](
    [id]                      [int]          IDENTITY(1,1) NOT NULL,
    [idPuesto]                [int]          NOT NULL,
    [ValorDocumentoIdentidad] [nvarchar](32) NOT NULL,
    [Nombre]                  [varchar](128) NOT NULL,
    [CuentaBancaria]          [varchar](32)  NOT NULL,
    CONSTRAINT [PK_Empleado] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [UQ_Empleado_ValorDocumentoIdentidad] UNIQUE ([ValorDocumentoIdentidad]),
    CONSTRAINT [FK_Empleado_Puesto] FOREIGN KEY ([idPuesto])
        REFERENCES [dbo].[Puesto]([id])
);
GO

-- ----------------------------------------------------
-- UsuarioEmpleado: 1:1 con Usuario cuando Tipo = 2.
--   Creado despues de Empleado por la FK.
-- ----------------------------------------------------
IF OBJECT_ID(N'dbo.UsuarioEmpleado', N'U') IS NOT NULL
    DROP TABLE [dbo].[UsuarioEmpleado];
GO

CREATE TABLE [dbo].[UsuarioEmpleado](
    [idUsuario]  [int] NOT NULL,
    [idEmpleado] [int] NOT NULL,
    CONSTRAINT [PK_UsuarioEmpleado] PRIMARY KEY CLUSTERED ([idUsuario] ASC),
    CONSTRAINT [UQ_UsuarioEmpleado_idEmpleado] UNIQUE ([idEmpleado]),
    CONSTRAINT [FK_UsuarioEmpleado_Usuario] FOREIGN KEY ([idUsuario])
        REFERENCES [dbo].[Usuario]([id]),
    CONSTRAINT [FK_UsuarioEmpleado_Empleado] FOREIGN KEY ([idEmpleado])
        REFERENCES [dbo].[Empleado]([id])
);
GO

-- ----------------------------------------------------
-- Asistencia: marcas de entrada/salida del empleado.
--   Una asistencia cubre un dia de trabajo. De aqui se derivan MovHoras.
-- ----------------------------------------------------
IF OBJECT_ID(N'dbo.Asistencia', N'U') IS NOT NULL
    DROP TABLE [dbo].[Asistencia];
GO

CREATE TABLE [dbo].[Asistencia](
    [id]          [int]       IDENTITY(1,1) NOT NULL,
    [Fecha]       [date]      NOT NULL,
    [MarcaInicio] [datetime]  NOT NULL,
    [MarcaFin]    [datetime]  NOT NULL,
    [idEmpleado]  [int]       NOT NULL,
    CONSTRAINT [PK_Asistencia] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [CK_Asistencia_Marcas] CHECK ([MarcaFin] > [MarcaInicio]),
    CONSTRAINT [FK_Asistencia_Empleado] FOREIGN KEY ([idEmpleado])
        REFERENCES [dbo].[Empleado]([id])
);
GO

-- ----------------------------------------------------
-- MovHoras: horas (ordinarias / extras / extras dobles) generadas por una asistencia.
--   idTipoMov clasifica el movimiento (Credito 'C' o Debito 'D' en TipoMov).
-- ----------------------------------------------------
IF OBJECT_ID(N'dbo.MovHoras', N'U') IS NOT NULL
    DROP TABLE [dbo].[MovHoras];
GO

CREATE TABLE [dbo].[MovHoras](
    [id]          [int] IDENTITY(1,1) NOT NULL,
    [QHoras]      [int] NOT NULL,
    [idAsistencia] [int] NOT NULL,
    [idTipoMov]    [int] NOT NULL,
    CONSTRAINT [PK_MovHoras] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [CK_MovHoras_QHoras] CHECK ([QHoras] >= 0),
    CONSTRAINT [FK_MovHoras_Asistencia] FOREIGN KEY ([idAsistencia])
        REFERENCES [dbo].[Asistencia]([id]),
    CONSTRAINT [FK_MovHoras_TipoMov] FOREIGN KEY ([idTipoMov])
        REFERENCES [dbo].[TipoMov]([id])
);
GO

-- ----------------------------------------------------
-- HorarioJornada: jornada que un empleado tiene asignada en una semana.
-- ----------------------------------------------------
IF OBJECT_ID(N'dbo.HorarioJornada', N'U') IS NOT NULL
    DROP TABLE [dbo].[HorarioJornada];
GO

CREATE TABLE [dbo].[HorarioJornada](
    [id]           [int] IDENTITY(1,1) NOT NULL,
    [idEmpleado]   [int] NOT NULL,
    [idSemana]     [int] NOT NULL,
    [idTipoJornada][int] NOT NULL,
    CONSTRAINT [PK_HorarioJornada] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [UQ_HorarioJornada_EmpSem] UNIQUE ([idEmpleado], [idSemana]),
    CONSTRAINT [FK_HorarioJornada_Empleado] FOREIGN KEY ([idEmpleado])
        REFERENCES [dbo].[Empleado]([id]),
    CONSTRAINT [FK_HorarioJornada_Semana] FOREIGN KEY ([idSemana])
        REFERENCES [dbo].[Semana]([id]),
    CONSTRAINT [FK_HorarioJornada_TipoJornada] FOREIGN KEY ([idTipoJornada])
        REFERENCES [dbo].[TipoJornada]([id])
);
GO

-- ----------------------------------------------------
-- PlanillaMensual: acumulacion mensual por empleado.
--   Creada antes que PlanillaSemanal por la FK idPlanillaMensual.
-- ----------------------------------------------------
IF OBJECT_ID(N'dbo.PlanillaMensual', N'U') IS NOT NULL
    DROP TABLE [dbo].[PlanillaMensual];
GO

CREATE TABLE [dbo].[PlanillaMensual](
    [id]          [int]   IDENTITY(1,1) NOT NULL,
    [SalarioBruto][money] NOT NULL,
    [idEmpleado]  [int]   NOT NULL,
    [idMes]       [int]   NOT NULL,
    CONSTRAINT [PK_PlanillaMensual] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [UQ_PlanillaMensual_EmpMes] UNIQUE ([idEmpleado], [idMes]),
    CONSTRAINT [FK_PlanillaMensual_Empleado] FOREIGN KEY ([idEmpleado])
        REFERENCES [dbo].[Empleado]([id]),
    CONSTRAINT [FK_PlanillaMensual_Mes] FOREIGN KEY ([idMes])
        REFERENCES [dbo].[Mes]([id])
);
GO

-- ----------------------------------------------------
-- DeduccionMensual: deduccion acumulada del mes (una fila por tipo de deduccion).
-- ----------------------------------------------------
IF OBJECT_ID(N'dbo.DeduccionMensual', N'U') IS NOT NULL
    DROP TABLE [dbo].[DeduccionMensual];
GO

CREATE TABLE [dbo].[DeduccionMensual](
    [id]                [int]   IDENTITY(1,1) NOT NULL,
    [Monto]             [money] NOT NULL,
    [idPlanillaMensual] [int]   NOT NULL,
    [idTipoDeduccion]   [int]   NOT NULL,
    CONSTRAINT [PK_DeduccionMensual] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [UQ_DeduccionMensual_PM_TD] UNIQUE ([idPlanillaMensual], [idTipoDeduccion]),
    CONSTRAINT [FK_DeduccionMensual_PlanillaMensual] FOREIGN KEY ([idPlanillaMensual])
        REFERENCES [dbo].[PlanillaMensual]([id]),
    CONSTRAINT [FK_DeduccionMensual_TipoDeduccion] FOREIGN KEY ([idTipoDeduccion])
        REFERENCES [dbo].[TipoDeduccion]([id])
);
GO

-- ----------------------------------------------------
-- PlanillaSemanal: cabecera semanal de planilla por empleado.
--   idPlanillaMensual es NULL hasta el cierre mensual.
-- ----------------------------------------------------
IF OBJECT_ID(N'dbo.PlanillaSemanal', N'U') IS NOT NULL
    DROP TABLE [dbo].[PlanillaSemanal];
GO

CREATE TABLE [dbo].[PlanillaSemanal](
    [id]               [int]   IDENTITY(1,1) NOT NULL,
    [SalarioBruto]     [money] NOT NULL,
    [SalarioNeto]      [money] NOT NULL,
    [idEmpleado]       [int]   NOT NULL,
    [idSemana]         [int]   NOT NULL,
    [idPlanillaMensual][int]   NULL,
    CONSTRAINT [PK_PlanillaSemanal] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [UQ_PlanillaSemanal_EmpSem] UNIQUE ([idEmpleado], [idSemana]),
    CONSTRAINT [FK_PlanillaSemanal_Empleado] FOREIGN KEY ([idEmpleado])
        REFERENCES [dbo].[Empleado]([id]),
    CONSTRAINT [FK_PlanillaSemanal_Semana] FOREIGN KEY ([idSemana])
        REFERENCES [dbo].[Semana]([id]),
    CONSTRAINT [FK_PlanillaSemanal_PlanillaMensual] FOREIGN KEY ([idPlanillaMensual])
        REFERENCES [dbo].[PlanillaMensual]([id])
);
GO

-- ----------------------------------------------------
-- MovPlanilla: movimientos (creditos y debitos) de la planilla semanal.
--   TipoAccion del TipoMov asociado determina si suma o resta.
-- ----------------------------------------------------
IF OBJECT_ID(N'dbo.MovPlanilla', N'U') IS NOT NULL
    DROP TABLE [dbo].[MovPlanilla];
GO

CREATE TABLE [dbo].[MovPlanilla](
    [id]               [int]     IDENTITY(1,1) NOT NULL,
    [Fecha]            [date]    NOT NULL,
    [Monto]            [money]   NOT NULL,
    [NuevoSaldo]       [money]   NOT NULL,
    [idPlanillaSemanal][int]     NOT NULL,
    [idTipoMov]        [int]     NOT NULL,
    CONSTRAINT [PK_MovPlanilla] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_MovPlanilla_PlanillaSemanal] FOREIGN KEY ([idPlanillaSemanal])
        REFERENCES [dbo].[PlanillaSemanal]([id]),
    CONSTRAINT [FK_MovPlanilla_TipoMov] FOREIGN KEY ([idTipoMov])
        REFERENCES [dbo].[TipoMov]([id])
);
GO

-- =====================================================================
-- EMPLEADO <-> TIPO DEDUCCION (4 tablas)
-- =====================================================================

-- ----------------------------------------------------
-- EmpXTipoDed: asignacion de una deduccion a un empleado.
--   FechaFin NULL = asignacion vigente.
-- ----------------------------------------------------
IF OBJECT_ID(N'dbo.EmpXTipoDed', N'U') IS NOT NULL
    DROP TABLE [dbo].[EmpXTipoDed];
GO

CREATE TABLE [dbo].[EmpXTipoDed](
    [id]             [int]  IDENTITY(1,1) NOT NULL,
    [FechaInicio]    [date] NOT NULL,
    [FechaFin]       [date] NULL,
    [idEmpleado]     [int]  NOT NULL,
    [idTipoDeduccion][int]  NOT NULL,
    CONSTRAINT [PK_EmpXTipoDed] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_EmpXTipoDed_Empleado] FOREIGN KEY ([idEmpleado])
        REFERENCES [dbo].[Empleado]([id]),
    CONSTRAINT [FK_EmpXTipoDed_TipoDeduccion] FOREIGN KEY ([idTipoDeduccion])
        REFERENCES [dbo].[TipoDeduccion]([id])
);
GO

-- ----------------------------------------------------
-- EXTDMontoFijo: extension 1:1 con EmpXTipoDed cuando el monto es fijo.
--   La FK es unidireccional (no hay FK de EmpXTipoDed hacia aca).
-- ----------------------------------------------------
IF OBJECT_ID(N'dbo.EXTDMontoFijo', N'U') IS NOT NULL
    DROP TABLE [dbo].[EXTDMontoFijo];
GO

CREATE TABLE [dbo].[EXTDMontoFijo](
    [idEmpXTipoDed] [int]   NOT NULL,
    [Monto]         [money] NOT NULL,
    CONSTRAINT [PK_EXTDMontoFijo] PRIMARY KEY CLUSTERED ([idEmpXTipoDed] ASC),
    CONSTRAINT [FK_EXTDMontoFijo_EmpXTipoDed] FOREIGN KEY ([idEmpXTipoDed])
        REFERENCES [dbo].[EmpXTipoDed]([id]),
    CONSTRAINT [CK_EXTDMontoFijo_Monto] CHECK ([Monto] >= 0)
);
GO

-- ----------------------------------------------------
-- EXTDPorcentual: extension 1:1 con EmpXTipoDed cuando el porcentaje es propio.
-- ----------------------------------------------------
IF OBJECT_ID(N'dbo.EXTDPorcentual', N'U') IS NOT NULL
    DROP TABLE [dbo].[EXTDPorcentual];
GO

CREATE TABLE [dbo].[EXTDPorcentual](
    [idEmpXTipoDed] [int]            NOT NULL,
    [Porcentaje]    [decimal](8, 4)  NOT NULL,
    CONSTRAINT [PK_EXTDPorcentual] PRIMARY KEY CLUSTERED ([idEmpXTipoDed] ASC),
    CONSTRAINT [FK_EXTDPorcentual_EmpXTipoDed] FOREIGN KEY ([idEmpXTipoDed])
        REFERENCES [dbo].[EmpXTipoDed]([id]),
    CONSTRAINT [CK_EXTDPorcentual_Porcentaje] CHECK ([Porcentaje] >= 0 AND [Porcentaje] <= 1)
);
GO

-- =====================================================================
-- TRAZABILIDAD (3 tablas)
-- =====================================================================

-- ----------------------------------------------------
-- BitacoraEvento: log de operaciones de la aplicacion.
--   idUsuario NULL = evento de sistema (ej. login fallido sin usuario).
-- ----------------------------------------------------
IF OBJECT_ID(N'dbo.BitacoraEvento', N'U') IS NOT NULL
    DROP TABLE [dbo].[BitacoraEvento];
GO

CREATE TABLE [dbo].[BitacoraEvento](
    [id]          [int]           IDENTITY(1,1) NOT NULL,
    [idTipoEvento][int]           NOT NULL,
    [Descripcion] [varchar](512)  NOT NULL,
    [idUsuario]   [int]           NULL,
    [IpPostIn]    [varchar](64)   NOT NULL,
    [PostTime]    [datetime]      NOT NULL,
    CONSTRAINT [PK_BitacoraEvento] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_BitacoraEvento_TipoEvento] FOREIGN KEY ([idTipoEvento])
        REFERENCES [dbo].[TipoEvento]([id]),
    CONSTRAINT [FK_BitacoraEvento_Usuario] FOREIGN KEY ([idUsuario])
        REFERENCES [dbo].[Usuario]([id])
);
GO

-- ----------------------------------------------------
-- Error: catalogo de codigos de error semanticos (5xxxx).
--   El backend resuelve el mensaje con sp_GetError.
-- ----------------------------------------------------
IF OBJECT_ID(N'dbo.Error', N'U') IS NOT NULL
    DROP TABLE [dbo].[Error];
GO

CREATE TABLE [dbo].[Error](
    [id]         [int]           IDENTITY(1,1) NOT NULL,
    [Codigo]     [int]           NOT NULL,
    [Descripcion][varchar](512)  NOT NULL,
    CONSTRAINT [PK_Error] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [UQ_Error_Codigo] UNIQUE ([Codigo])
);
GO

-- ----------------------------------------------------
-- DBError: bitacora de excepciones no controladas de SQL Server.
--   Los SPs la llenan en su bloque CATCH.
-- ----------------------------------------------------
IF OBJECT_ID(N'dbo.DBError', N'U') IS NOT NULL
    DROP TABLE [dbo].[DBError];
GO

CREATE TABLE [dbo].[DBError](
    [id]        [int]           IDENTITY(1,1) NOT NULL,
    [UserName]  [varchar](64)   NOT NULL,
    [Number]    [int]           NOT NULL,
    [State]     [varchar](32)   NOT NULL,
    [Severity]  [varchar](32)   NOT NULL,
    [Line]      [int]           NOT NULL,
    [Procedure] [varchar](64)   NOT NULL,
    [Message]   [varchar](512)  NOT NULL,
    [DateTime]  [datetime]      NOT NULL,
    CONSTRAINT [PK_DBError] PRIMARY KEY CLUSTERED ([id] ASC)
);
GO

-- =====================================================================
-- TRIGGERS
-- =====================================================================

-- ----------------------------------------------------
-- trg_Empleado_Insert_AssignMandatoryDeductions
--   Al insertar un Empleado, crea automaticamente:
--     * una fila en EmpXTipoDed para cada TipoDeduccion con
--       FlagObligatorio = 1 (es decir, con fila en DeduccionXLEy).
--     * la extension 1:1 en EXTDPorcentual copiando el Porcentaje
--       del subtipo DeduccionXLEy.
--   Asi, las deducciones de ley quedan pre-asignadas y vigentes
--   (FechaFin = NULL) desde el primer dia del empleado.
-- ----------------------------------------------------
IF OBJECT_ID(N'dbo.trg_Empleado_Insert_AssignMandatoryDeductions', N'TR') IS NOT NULL
    DROP TRIGGER [dbo].[trg_Empleado_Insert_AssignMandatoryDeductions];
GO

CREATE TRIGGER [dbo].[trg_Empleado_Insert_AssignMandatoryDeductions]
ON [dbo].[Empleado]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @newAssignments TABLE (
        [idEmpXTipoDed]   INT,
        [idTipoDeduccion] INT
    );

    INSERT INTO [dbo].[EmpXTipoDed] ([idEmpleado], [idTipoDeduccion], [FechaInicio], [FechaFin])
    OUTPUT [inserted].[id], [inserted].[idTipoDeduccion]
    INTO @newAssignments ([idEmpXTipoDed], [idTipoDeduccion])
    SELECT
        i.id,
        t.id,
        CAST(GETDATE() AS DATE),
        NULL
    FROM inserted i
    CROSS JOIN [dbo].[TipoDeduccion] t
    INNER JOIN [dbo].[DeduccionXLEy] xle ON xle.[idTipoDeduccion] = t.[id]
    WHERE t.[FlagObligatorio] = 1;

    INSERT INTO [dbo].[EXTDPorcentual] ([idEmpXTipoDed], [Porcentaje])
    SELECT n.[idEmpXTipoDed], xle.[Porcentaje]
    FROM @newAssignments n
    INNER JOIN [dbo].[DeduccionXLEy] xle ON xle.[idTipoDeduccion] = n.[idTipoDeduccion];
END;
GO

