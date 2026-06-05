USE [PlanillaDB]
GO
/****** Object:  Table [dbo].[BitacoraEvento]    Script Date: 6/2/2026 12:00:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BitacoraEvento](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[idTipoEvento] [int] NOT NULL,
	[idUsuario] [int] NOT NULL,
	[PostTime] [datetime] NOT NULL,
	[IpPostIn] [varchar](64) NOT NULL,
	[Descripcion] [nvarchar](512) NOT NULL,
CONSTRAINT [PK_BitacoraEvento] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DBError]    Script Date: 6/2/2026 12:00:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DBError](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[UserName] [nvarchar](64) NOT NULL,
	[Number] [int] NOT NULL,
	[State] [int] NOT NULL,
	[Severity] [int] NOT NULL,
	[Line] [int] NOT NULL,
	[Procedure] [nvarchar](128) NOT NULL,
	[Message] [nvarchar](512) NOT NULL,
	[DateTime] [datetime] NOT NULL,
CONSTRAINT [PK_DBError] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DeduccionEmpleado]    Script Date: 6/2/2026 12:00:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DeduccionEmpleado](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[idEmpleado] [int] NOT NULL,
	[idTipoDeduccion] [int] NOT NULL,
	[MontoFijo] [decimal](10, 2) NOT NULL,
	[FechaInicio] [date] NOT NULL,
	[FechaFin] [date] NOT NULL,
CONSTRAINT [PK_DeduccionEmpleado] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DeduccionXMes]    Script Date: 6/2/2026 12:00:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DeduccionXMes](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[idPlanillaMensual] [int] NOT NULL,
	[idEmpleado] [int] NOT NULL,
	[idTipoDeduccion] [int] NOT NULL,
	[MontoTotal] [decimal](10, 2) NOT NULL,
CONSTRAINT [PK_DeduccionXMes] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Empleado]    Script Date: 6/2/2026 12:00:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Empleado](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[idPuesto] [int] NOT NULL,
	[idUsuario] [int] NOT NULL,
	[ValorDocumento] [varchar](32) NOT NULL,
	[Nombre] [varchar](128) NOT NULL,
	[CuentaBancaria] [varchar](32) NOT NULL,
	[FechaContratacion] [date] NOT NULL,
	[Activo] [bit] NOT NULL,
CONSTRAINT [PK_Empleado] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Error]    Script Date: 6/2/2026 12:00:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Error](
	[Codigo] [int] NOT NULL,
	[Descripcion] [nvarchar](256) NOT NULL,
CONSTRAINT [PK_Error] PRIMARY KEY CLUSTERED 
(
	[Codigo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Feriado]    Script Date: 6/2/2026 12:00:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Feriado](
	[id] [int] NOT NULL,
	[Nombre] [varchar](128) NOT NULL,
	[Fecha] [date] NOT NULL,
CONSTRAINT [PK_Feriado] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[HorarioJornada]    Script Date: 6/2/2026 12:00:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[HorarioJornada](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[idEmpleado] [int] NOT NULL,
	[idSemana] [int] NOT NULL,
	[idTipoJornada] [int] NOT NULL,
CONSTRAINT [PK_HorarioJornada] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MarcaAsistencia]    Script Date: 6/2/2026 12:00:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MarcaAsistencia](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[idEmpleado] [int] NOT NULL,
	[Fecha] [date] NOT NULL,
	[HoraEntrada] [datetime] NOT NULL,
	[HoraSalida] [datetime] NOT NULL,
CONSTRAINT [PK_MarcaAsistencia] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Mes]    Script Date: 6/2/2026 12:00:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Mes](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[FechaInicio] [date] NOT NULL,
	[FechaFin] [date] NOT NULL,
	[NumJueves] [tinyint] NOT NULL,
CONSTRAINT [PK_Mes] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MovHoras]    Script Date: 6/2/2026 12:00:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MovHoras](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[QHoras] [int] NOT NULL,
	[Monto] [decimal](10, 2) NOT NULL,
	[idAsistencia] [int] NOT NULL,
	[idTipoMov] [int] NOT NULL,
CONSTRAINT [PK_MovHoras] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MovPlanilla]    Script Date: 6/2/2026 12:00:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MovPlanilla](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[idPlanillaSemanal] [int] NOT NULL,
	[idTipoMovimiento] [int] NOT NULL,
	[Monto] [decimal](10, 2) NOT NULL,
	[NuevoSaldo] [decimal](10, 2) NOT NULL,
CONSTRAINT [PK_MovPlanilla] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PlanillaMensual]    Script Date: 6/2/2026 12:00:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PlanillaMensual](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[idEmpleado] [int] NOT NULL,
	[idMes] [int] NOT NULL,
	[SalarioBruto] [decimal](10, 2) NOT NULL,
	[TotalDeducciones] [decimal](10, 2) NOT NULL,
	[SalarioNeto] [decimal](10, 2) NOT NULL,
CONSTRAINT [PK_PlanillaMensual] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PlanillaSemanal]    Script Date: 6/2/2026 12:00:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PlanillaSemanal](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[idEmpleado] [int] NOT NULL,
	[idSemana] [int] NOT NULL,
	[SalarioBruto] [decimal](10, 2) NOT NULL,
	[TotalDeducciones] [decimal](10, 2) NOT NULL,
	[SalarioNeto] [decimal](10, 2) NOT NULL,
	[Comprobante] [varbinary](max) NULL,
CONSTRAINT [PK_PlanillaSemanal] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Puesto]    Script Date: 6/2/2026 12:00:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Puesto](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [varchar](128) NOT NULL,
	[SalarioXHora] [decimal](10, 2) NOT NULL,
CONSTRAINT [PK_Puesto] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Semana]    Script Date: 6/2/2026 12:00:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Semana](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[idMes] [int] NOT NULL,
	[FechaInicio] [date] NOT NULL,
	[FechaFin] [date] NOT NULL,
CONSTRAINT [PK_Semana] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TipoDeduccion]    Script Date: 6/2/2026 12:00:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TipoDeduccion](
	[id] [int] NOT NULL,
	[Nombre] [varchar](128) NOT NULL,
	[EsObligatoria] [bit] NOT NULL,
	[EsPorcentual] [bit] NOT NULL,
	[Valor] [decimal](8, 4) NOT NULL,
	[idTipoMovimiento] [int] NOT NULL,
CONSTRAINT [PK_TipoDeduccion] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TipoEvento]    Script Date: 6/2/2026 12:00:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TipoEvento](
	[id] [int] NOT NULL,
	[Nombre] [varchar](64) NOT NULL,
CONSTRAINT [PK_TipoEvento] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TipoJornada]    Script Date: 6/2/2026 12:00:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TipoJornada](
	[id] [int] NOT NULL,
	[Nombre] [varchar](64) NOT NULL,
	[HoraInicio] [time](0) NOT NULL,
	[HoraFin] [time](0) NOT NULL,
CONSTRAINT [PK_TipoJornada] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TipoMovimiento]    Script Date: 6/2/2026 12:00:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TipoMovimiento](
	[id] [int] NOT NULL,
	[Nombre] [varchar](64) NOT NULL,
	[Accion] [char](1) NOT NULL,
CONSTRAINT [PK_TipoMovimiento] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Usuario]    Script Date: 6/2/2026 12:00:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Usuario](
	[id] [int] NOT NULL,
	[Username] [varchar](64) NOT NULL,
	[PasswordHash] [varchar](64) NOT NULL,
	[Tipo] [varchar](2) NOT NULL,
CONSTRAINT [PK_Usuario] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BitacoraEvento]  WITH CHECK ADD  CONSTRAINT [FK_BitacoraEvento_TipoEvento] FOREIGN KEY([idTipoEvento])
REFERENCES [dbo].[TipoEvento] ([id])
GO
ALTER TABLE [dbo].[BitacoraEvento] CHECK CONSTRAINT [FK_BitacoraEvento_TipoEvento]
GO
ALTER TABLE [dbo].[BitacoraEvento]  WITH CHECK ADD  CONSTRAINT [FK_BitacoraEvento_Usuario] FOREIGN KEY([idUsuario])
REFERENCES [dbo].[Usuario] ([id])
GO
ALTER TABLE [dbo].[BitacoraEvento] CHECK CONSTRAINT [FK_BitacoraEvento_Usuario]
GO
ALTER TABLE [dbo].[DeduccionEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_DeduccionEmpleado_Empleado] FOREIGN KEY([idEmpleado])
REFERENCES [dbo].[Empleado] ([id])
GO
ALTER TABLE [dbo].[DeduccionEmpleado] CHECK CONSTRAINT [FK_DeduccionEmpleado_Empleado]
GO
ALTER TABLE [dbo].[DeduccionEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_DeduccionEmpleado_TipoDeduccion] FOREIGN KEY([idTipoDeduccion])
REFERENCES [dbo].[TipoDeduccion] ([id])
GO
ALTER TABLE [dbo].[DeduccionEmpleado] CHECK CONSTRAINT [FK_DeduccionEmpleado_TipoDeduccion]
GO
ALTER TABLE [dbo].[DeduccionXMes]  WITH CHECK ADD  CONSTRAINT [FK_DeduccionXMes_PlanillaMensual] FOREIGN KEY([idPlanillaMensual])
REFERENCES [dbo].[PlanillaMensual] ([id])
GO
ALTER TABLE [dbo].[DeduccionXMes] CHECK CONSTRAINT [FK_DeduccionXMes_PlanillaMensual]
GO
ALTER TABLE [dbo].[DeduccionXMes]  WITH CHECK ADD  CONSTRAINT [FK_DeduccionXMes_TipoDeduccion] FOREIGN KEY([idTipoDeduccion])
REFERENCES [dbo].[TipoDeduccion] ([id])
GO
ALTER TABLE [dbo].[DeduccionXMes] CHECK CONSTRAINT [FK_DeduccionXMes_TipoDeduccion]
GO
ALTER TABLE [dbo].[DeduccionXMes]  WITH CHECK ADD  CONSTRAINT [FK_DeduccionXMes_Empleado] FOREIGN KEY([idEmpleado])
REFERENCES [dbo].[Empleado] ([id])
GO
ALTER TABLE [dbo].[DeduccionXMes] CHECK CONSTRAINT [FK_DeduccionXMes_Empleado]
GO
ALTER TABLE [dbo].[Empleado]  WITH CHECK ADD  CONSTRAINT [FK_Empleado_Puesto] FOREIGN KEY([idPuesto])
REFERENCES [dbo].[Puesto] ([id])
GO
ALTER TABLE [dbo].[Empleado] CHECK CONSTRAINT [FK_Empleado_Puesto]
GO
ALTER TABLE [dbo].[Empleado]  WITH CHECK ADD  CONSTRAINT [FK_Empleado_Usuario] FOREIGN KEY([idUsuario])
REFERENCES [dbo].[Usuario] ([id])
GO
ALTER TABLE [dbo].[Empleado] CHECK CONSTRAINT [FK_Empleado_Usuario]
GO
ALTER TABLE [dbo].[HorarioJornada]  WITH CHECK ADD  CONSTRAINT [FK_HorarioJornada_Empleado] FOREIGN KEY([idEmpleado])
REFERENCES [dbo].[Empleado] ([id])
GO
ALTER TABLE [dbo].[HorarioJornada] CHECK CONSTRAINT [FK_HorarioJornada_Empleado]
GO
ALTER TABLE [dbo].[HorarioJornada]  WITH CHECK ADD  CONSTRAINT [FK_HorarioJornada_Semana] FOREIGN KEY([idSemana])
REFERENCES [dbo].[Semana] ([id])
GO
ALTER TABLE [dbo].[HorarioJornada] CHECK CONSTRAINT [FK_HorarioJornada_Semana]
GO
ALTER TABLE [dbo].[HorarioJornada]  WITH CHECK ADD  CONSTRAINT [FK_HorarioJornada_TipoJornada] FOREIGN KEY([idTipoJornada])
REFERENCES [dbo].[TipoJornada] ([id])
GO
ALTER TABLE [dbo].[HorarioJornada] CHECK CONSTRAINT [FK_HorarioJornada_TipoJornada]
GO
ALTER TABLE [dbo].[MarcaAsistencia]  WITH CHECK ADD  CONSTRAINT [FK_MarcaAsistencia_Empleado] FOREIGN KEY([idEmpleado])
REFERENCES [dbo].[Empleado] ([id])
GO
ALTER TABLE [dbo].[MarcaAsistencia] CHECK CONSTRAINT [FK_MarcaAsistencia_Empleado]
GO
ALTER TABLE [dbo].[MovHoras]  WITH CHECK ADD  CONSTRAINT [FK_MovHoras_MarcaAsistencia] FOREIGN KEY([idAsistencia])
REFERENCES [dbo].[MarcaAsistencia] ([id])
GO
ALTER TABLE [dbo].[MovHoras] CHECK CONSTRAINT [FK_MovHoras_MarcaAsistencia]
GO
ALTER TABLE [dbo].[MovHoras]  WITH CHECK ADD  CONSTRAINT [FK_MovHoras_TipoMovimiento] FOREIGN KEY([idTipoMov])
REFERENCES [dbo].[TipoMovimiento] ([id])
GO
ALTER TABLE [dbo].[MovHoras] CHECK CONSTRAINT [FK_MovHoras_TipoMovimiento]
GO
ALTER TABLE [dbo].[MovPlanilla]  WITH CHECK ADD  CONSTRAINT [FK_MovPlanilla_PlanillaSemanal] FOREIGN KEY([idPlanillaSemanal])
REFERENCES [dbo].[PlanillaSemanal] ([id])
GO
ALTER TABLE [dbo].[MovPlanilla] CHECK CONSTRAINT [FK_MovPlanilla_PlanillaSemanal]
GO
ALTER TABLE [dbo].[MovPlanilla]  WITH CHECK ADD  CONSTRAINT [FK_MovPlanilla_TipoMovimiento] FOREIGN KEY([idTipoMovimiento])
REFERENCES [dbo].[TipoMovimiento] ([id])
GO
ALTER TABLE [dbo].[MovPlanilla] CHECK CONSTRAINT [FK_MovPlanilla_TipoMovimiento]
GO
ALTER TABLE [dbo].[PlanillaMensual]  WITH CHECK ADD  CONSTRAINT [FK_PlanillaMensual_Empleado] FOREIGN KEY([idEmpleado])
REFERENCES [dbo].[Empleado] ([id])
GO
ALTER TABLE [dbo].[PlanillaMensual] CHECK CONSTRAINT [FK_PlanillaMensual_Empleado]
GO
ALTER TABLE [dbo].[PlanillaMensual]  WITH CHECK ADD  CONSTRAINT [FK_PlanillaMensual_Mes] FOREIGN KEY([idMes])
REFERENCES [dbo].[Mes] ([id])
GO
ALTER TABLE [dbo].[PlanillaMensual] CHECK CONSTRAINT [FK_PlanillaMensual_Mes]
GO
ALTER TABLE [dbo].[PlanillaSemanal]  WITH CHECK ADD  CONSTRAINT [FK_PlanillaSemanal_Empleado] FOREIGN KEY([idEmpleado])
REFERENCES [dbo].[Empleado] ([id])
GO
ALTER TABLE [dbo].[PlanillaSemanal] CHECK CONSTRAINT [FK_PlanillaSemanal_Empleado]
GO
ALTER TABLE [dbo].[PlanillaSemanal]  WITH CHECK ADD  CONSTRAINT [FK_PlanillaSemanal_Semana] FOREIGN KEY([idSemana])
REFERENCES [dbo].[Semana] ([id])
GO
ALTER TABLE [dbo].[PlanillaSemanal] CHECK CONSTRAINT [FK_PlanillaSemanal_Semana]
GO
ALTER TABLE [dbo].[Semana]  WITH CHECK ADD  CONSTRAINT [FK_Semana_Mes] FOREIGN KEY([idMes])
REFERENCES [dbo].[Mes] ([id])
GO
ALTER TABLE [dbo].[Semana] CHECK CONSTRAINT [FK_Semana_Mes]
GO
ALTER TABLE [dbo].[TipoDeduccion]  WITH CHECK ADD  CONSTRAINT [FK_TipoDeduccion_TipoMovimiento] FOREIGN KEY([idTipoMovimiento])
REFERENCES [dbo].[TipoMovimiento] ([id])
GO
ALTER TABLE [dbo].[TipoDeduccion] CHECK CONSTRAINT [FK_TipoDeduccion_TipoMovimiento]
GO
