USE [PlanillaDB];
GO

IF OBJECT_ID(N'dbo.sp_CargarCatalogosXML', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_CargarCatalogosXML];
GO

-- =====================================================================
-- sp_CargarCatalogosXML
--
-- Carga los catálogos iniciales desde el XML de Datos.xml.
-- Sigue el mismo patrón de sp_xml_preparedocument / OPENXML / idempotencia
-- (WHERE NOT EXISTS) usado en Tarea2-BD.
--
-- Tablas que alimenta (en orden de dependencias FK):
--   1. dbo.Puesto            (IDENTITY — insert por Nombre)
--   2. dbo.TipoEvento        (PK del XML — SET IDENTITY_INSERT OFF, id directo)
--   3. dbo.TipoJornada       (PK del XML)
--   4. dbo.TipoMovimiento    (PK del XML)
--   5. dbo.TipoDeduccion     (PK del XML — FK → TipoMovimiento)
--   6. dbo.Feriado           (PK del XML)
--   7. dbo.Usuario           (PK del XML)
--   8. dbo.Error             (PK = Codigo directo del XML)
--
-- NOTA: Empleados y operaciones vienen en Operaciones.xml (sp_CargarOperacionesXML).
-- =====================================================================

CREATE PROCEDURE [dbo].[sp_CargarCatalogosXML]
    @XmlCatalogos NVARCHAR(MAX),
    @outResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SET @outResultCode = 0;

    DECLARE @handle INT = NULL;

    BEGIN TRY
        EXEC sp_xml_preparedocument @handle OUTPUT, @XmlCatalogos;

        BEGIN TRANSACTION;

        -- ----------------------------------------------------------------
        -- 1. PUESTOS (IDENTITY — se inserta por Nombre, sin id del XML)
        -- ----------------------------------------------------------------
        INSERT INTO dbo.Puesto (Nombre, SalarioXHora)
        SELECT x.Nombre, x.SalarioXHora
        FROM OPENXML(@handle, '/Datos/Puestos/Puesto', 1)
        WITH (
            Nombre       VARCHAR(128)    '@Nombre',
            SalarioXHora DECIMAL(10, 2)  '@SalarioXHora'
        ) AS x
        WHERE NOT EXISTS (
            SELECT 1 FROM dbo.Puesto p WHERE p.Nombre = x.Nombre
        );

        -- ----------------------------------------------------------------
        -- 2. TIPOS DE EVENTO (PK directa del XML — no es IDENTITY)
        -- ----------------------------------------------------------------
        INSERT INTO dbo.TipoEvento (id, Nombre)
        SELECT x.Id, x.Nombre
        FROM OPENXML(@handle, '/Datos/TiposEvento/TipoEvento', 1)
        WITH (
            Id     INT          '@Id',
            Nombre VARCHAR(64)  '@Nombre'
        ) AS x
        WHERE NOT EXISTS (
            SELECT 1 FROM dbo.TipoEvento t WHERE t.id = x.Id
        );

        -- ----------------------------------------------------------------
        -- 3. TIPOS DE JORNADA (PK directa del XML)
        -- ----------------------------------------------------------------
        INSERT INTO dbo.TipoJornada (id, Nombre, HoraInicio, HoraFin)
        SELECT x.Id, x.Nombre, x.HoraInicio, x.HoraFin
        FROM OPENXML(@handle, '/Datos/TiposJornada/TipoJornada', 1)
        WITH (
            Id         INT          '@Id',
            Nombre     VARCHAR(64)  '@Nombre',
            HoraInicio TIME(0)      '@HoraInicio',
            HoraFin    TIME(0)      '@HoraFin'
        ) AS x
        WHERE NOT EXISTS (
            SELECT 1 FROM dbo.TipoJornada t WHERE t.id = x.Id
        );

        -- ----------------------------------------------------------------
        -- 4. TIPOS DE MOVIMIENTO (PK directa del XML)
        --    Accion ya viene como 'C'/'D' directo desde el XML
        -- ----------------------------------------------------------------
        INSERT INTO dbo.TipoMovimiento (id, Nombre, Accion)
        SELECT x.Id, x.Nombre, x.Accion
        FROM OPENXML(@handle, '/Datos/TiposMovimiento/TipoMovimiento', 1)
        WITH (
            Id     INT         '@Id',
            Nombre VARCHAR(64) '@Nombre',
            Accion CHAR(1)     '@Accion'
        ) AS x
        WHERE NOT EXISTS (
            SELECT 1 FROM dbo.TipoMovimiento t WHERE t.id = x.Id
        );

        -- ----------------------------------------------------------------
        -- 5. TIPOS DE DEDUCCION (PK directa del XML — FK → TipoMovimiento)
        --    TipoMovimiento en el XML viene como Nombre → lookup por nombre
        -- ----------------------------------------------------------------
        INSERT INTO dbo.TipoDeduccion (id, Nombre, EsObligatoria, EsPorcentual, Valor, idTipoMovimiento)
        SELECT
            x.Id,
            x.Nombre,
            x.EsObligatoria,
            x.EsPorcentual,
            x.Valor,
            tm.id AS idTipoMovimiento
        FROM OPENXML(@handle, '/Datos/TiposDeduccion/TipoDeduccion', 1)
        WITH (
            Id             INT           '@Id',
            Nombre         VARCHAR(128)  '@Nombre',
            EsObligatoria  BIT           '@EsObligatoria',
            EsPorcentual   BIT           '@EsPorcentual',
            Valor          DECIMAL(8, 4) '@Valor',
            TipoMovimiento VARCHAR(64)   '@TipoMovimiento'
        ) AS x
        INNER JOIN dbo.TipoMovimiento tm ON tm.Nombre = x.TipoMovimiento
        WHERE NOT EXISTS (
            SELECT 1 FROM dbo.TipoDeduccion d WHERE d.id = x.Id
        );

        -- ----------------------------------------------------------------
        -- 6. FERIADOS (PK directa del XML)
        -- ----------------------------------------------------------------
        INSERT INTO dbo.Feriado (id, Nombre, Fecha)
        SELECT x.Id, x.Nombre, x.Fecha
        FROM OPENXML(@handle, '/Datos/Feriados/Feriado', 1)
        WITH (
            Id     INT          '@Id',
            Nombre VARCHAR(128) '@Nombre',
            Fecha  DATE         '@Fecha'
        ) AS x
        WHERE NOT EXISTS (
            SELECT 1 FROM dbo.Feriado f WHERE f.id = x.Id
        );

        -- ----------------------------------------------------------------
        -- 7. USUARIOS (PK directa del XML)
        --    Tipo: '1' = Administrador, '0' = Empleado (según Operaciones.xml)
        -- ----------------------------------------------------------------
        INSERT INTO dbo.Usuario (id, Username, PasswordHash, Tipo)
        SELECT x.Id, x.Username, x.PasswordHash, x.Tipo
        FROM OPENXML(@handle, '/Datos/Usuarios/Usuario', 1)
        WITH (
            Id           INT         '@Id',
            Username     VARCHAR(64) '@Username',
            PasswordHash VARCHAR(64) '@PasswordHash',
            Tipo         VARCHAR(2)  '@Tipo'
        ) AS x
        WHERE NOT EXISTS (
            SELECT 1 FROM dbo.Usuario u WHERE u.id = x.Id
        );

        -- ----------------------------------------------------------------
        -- 8. CODIGOS DE ERROR (Codigo es la PK directa)
        -- ----------------------------------------------------------------
        INSERT INTO dbo.Error (Codigo, Descripcion)
        SELECT x.Codigo, x.Descripcion
        FROM OPENXML(@handle, '/Datos/Error/error', 1)
        WITH (
            Codigo      INT             '@Codigo',
            Descripcion NVARCHAR(256)   '@Descripcion'
        ) AS x
        WHERE NOT EXISTS (
            SELECT 1 FROM dbo.Error e WHERE e.Codigo = x.Codigo
        );

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        IF @handle IS NOT NULL
            EXEC sp_xml_removedocument @handle;

        INSERT INTO dbo.DBError (
            UserName, Number, State, Severity, Line,
            [Procedure], [Message], [DateTime]
        )
        VALUES (
            SUSER_SNAME(),
            ERROR_NUMBER(),
            ERROR_STATE(),
            ERROR_SEVERITY(),
            ERROR_LINE(),
            ISNULL(ERROR_PROCEDURE(), 'sp_CargarCatalogosXML'),
            ERROR_MESSAGE(),
            GETDATE()
        );

        SET @outResultCode = 50008;
        RETURN;
    END CATCH;

    IF @handle IS NOT NULL
        EXEC sp_xml_removedocument @handle;
END;
GO

-- =====================================================================
-- EJECUCIÓN: carga Datos.xml con el contenido embebido
-- =====================================================================
DECLARE @rc INT = 0;

EXEC dbo.sp_CargarCatalogosXML
    @XmlCatalogos = N'<Datos>

    <Puestos>
        <Puesto Nombre="Electricista" SalarioXHora="1200.00"/>
        <Puesto Nombre="Auxiliar de Laboratorio" SalarioXHora="1250.00"/>
        <Puesto Nombre="Operador de Maquina" SalarioXHora="1025.00"/>
        <Puesto Nombre="Cajero" SalarioXHora="1100.00"/>
        <Puesto Nombre="Camarero" SalarioXHora="1000.00"/>
        <Puesto Nombre="Conductor" SalarioXHora="1500.00"/>
        <Puesto Nombre="Asistente" SalarioXHora="1100.00"/>
        <Puesto Nombre="Recepcionista" SalarioXHora="1200.00"/>
        <Puesto Nombre="Fontanero" SalarioXHora="1300.00"/>
        <Puesto Nombre="Albanil" SalarioXHora="1050.00"/>
    </Puestos>

    <TiposJornada>
        <TipoJornada Id="1" Nombre="Diurno" HoraInicio="06:00:00" HoraFin="14:00:00"/>
        <TipoJornada Id="2" Nombre="Vespertino" HoraInicio="14:00:00" HoraFin="22:00:00"/>
        <TipoJornada Id="3" Nombre="Nocturno" HoraInicio="22:00:00" HoraFin="06:00:00"/>
    </TiposJornada>

    <Feriados>
        <Feriado Id="2" Nombre="Jueves Santo" Fecha="2026-04-02"/>
        <Feriado Id="3" Nombre="Viernes Santo" Fecha="2026-04-03"/>
        <Feriado Id="1" Nombre="Dia de Juan Santamaria" Fecha="2026-04-11"/>
        <Feriado Id="4" Nombre="Dia del trabajo" Fecha="2026-05-01"/>
        <Feriado Id="5" Nombre="Anexion del Nicoya" Fecha="2026-07-25"/>
        <Feriado Id="6" Nombre="Dia de la Virgen de los Angeles" Fecha="2026-08-02"/>
        <Feriado Id="7" Nombre="Dia de la Independencia" Fecha="2026-09-15"/>
        <Feriado Id="8" Nombre="Dia de las Culturas" Fecha="2026-10-12"/>
        <Feriado Id="9" Nombre="Navidad" Fecha="2026-12-25"/>
    </Feriados>

    <TiposEvento>
        <TipoEvento Id="1" Nombre="Login Exitoso"/>
        <TipoEvento Id="2" Nombre="Login No Exitoso"/>
        <TipoEvento Id="3" Nombre="Login deshabilitado"/>
        <TipoEvento Id="4" Nombre="Logout"/>
        <TipoEvento Id="5" Nombre="Insercion no exitosa"/>
        <TipoEvento Id="6" Nombre="Insercion exitosa"/>
        <TipoEvento Id="7" Nombre="Update no exitoso"/>
        <TipoEvento Id="8" Nombre="Update exitoso"/>
        <TipoEvento Id="9" Nombre="Intento de borrado"/>
        <TipoEvento Id="10" Nombre="Borrado exitoso"/>
        <TipoEvento Id="11" Nombre="Consulta con filtro de nombre"/>
        <TipoEvento Id="12" Nombre="Consulta con filtro de cedula"/>
        <TipoEvento Id="13" Nombre="Intento de insertar movimiento"/>
        <TipoEvento Id="14" Nombre="Insertar movimiento exitoso"/>
        <TipoEvento Id="15" Nombre="Impersonar empleado"/>
        <TipoEvento Id="16" Nombre="Regresar a interfaz de administrador"/>
        <TipoEvento Id="17" Nombre="Listar empleados"/>
        <TipoEvento Id="18" Nombre="Asociar deduccion"/>
        <TipoEvento Id="19" Nombre="Desasociar deduccion"/>
        <TipoEvento Id="20" Nombre="Consultar planilla semanal"/>
        <TipoEvento Id="21" Nombre="Consultar planilla mensual"/>
        <TipoEvento Id="22" Nombre="Ingreso de marcas de asistencia"/>
        <TipoEvento Id="23" Nombre="Ingreso nuevas jornadas"/>
    </TiposEvento>

    <TiposMovimiento>
        <TipoMovimiento Id="1" Nombre="Credito Horas Ordinarias" Accion="C"/>
        <TipoMovimiento Id="2" Nombre="Credito Horas Extra Normales" Accion="C"/>
        <TipoMovimiento Id="3" Nombre="Credito Horas Extra Dobles" Accion="C"/>
        <TipoMovimiento Id="4" Nombre="Caja" Accion="C"/>
        <TipoMovimiento Id="5" Nombre="Debito CCSS" Accion="D"/>
        <TipoMovimiento Id="6" Nombre="Debito Asociacion Solidarista" Accion="D"/>
        <TipoMovimiento Id="7" Nombre="Debito Ahorro Obligatorio" Accion="D"/>
        <TipoMovimiento Id="8" Nombre="Debito Pension Alimenticia" Accion="D"/>
    </TiposMovimiento>

    <TiposDeduccion>
        <TipoDeduccion Id="1" Nombre="Obligatorio de Ley" EsObligatoria="1" EsPorcentual="1" Valor="0.0950" TipoMovimiento="Debito CCSS"/>
        <TipoDeduccion Id="2" Nombre="Ahorro Asociacion Solidarista" EsObligatoria="0" EsPorcentual="1" Valor="0.0500" TipoMovimiento="Debito Asociacion Solidarista"/>
        <TipoDeduccion Id="3" Nombre="Ahorro Vacacional" EsObligatoria="0" EsPorcentual="0" Valor="0.0000" TipoMovimiento="Debito Ahorro Obligatorio"/>
        <TipoDeduccion Id="4" Nombre="Pension Alimenticia" EsObligatoria="0" EsPorcentual="0" Valor="0.0000" TipoMovimiento="Debito Pension Alimenticia"/>
    </TiposDeduccion>

    <Usuarios>
        <Usuario Id="1" Username="admin" PasswordHash="admin123" Tipo="1"/>
        <Usuario Id="2" Username="Goku" PasswordHash="1234" Tipo="1"/>
        <Usuario Id="3" Username="Willy" PasswordHash="1234" Tipo="1"/>
    </Usuarios>

    <Error>
        <error Codigo="50001" Descripcion="Username no existe"/>
        <error Codigo="50002" Descripcion="Password no existe"/>
        <error Codigo="50003" Descripcion="Login deshabilitado"/>
        <error Codigo="50004" Descripcion="Empleado con ValorDocumentoIdentidad ya existe en insercion"/>
        <error Codigo="50005" Descripcion="Empleado con mismo nombre ya existe en insercion"/>
        <error Codigo="50006" Descripcion="Empleado con ValorDocumentoIdentidad ya existe en actualizacion"/>
        <error Codigo="50007" Descripcion="Empleado con mismo nombre ya existe en actualizacion"/>
        <error Codigo="50008" Descripcion="Error de base de datos"/>
        <error Codigo="50009" Descripcion="Nombre de empleado no alfabetico"/>
        <error Codigo="50010" Descripcion="Valor de documento de identidad no alfabetico"/>
        <error Codigo="50011" Descripcion="Monto del movimiento rechazado pues si se aplicar el saldo seria negativo."/>
        <error Codigo="50012" Descripcion="Empleado no existe o esta inactivo"/>
        <error Codigo="50013" Descripcion="Usuario no es administrador"/>
    </Error>

</Datos>',
    @outResultCode = @rc OUTPUT;

SELECT @rc AS outResultCode;
-- 0 = éxito o 50008 = error

-- Verificación rápida
SELECT 'Puesto'          AS Tabla, COUNT(*) AS Filas FROM dbo.Puesto          UNION ALL
SELECT 'TipoEvento',     COUNT(*) FROM dbo.TipoEvento                         UNION ALL
SELECT 'TipoJornada',    COUNT(*) FROM dbo.TipoJornada                        UNION ALL
SELECT 'TipoMovimiento', COUNT(*) FROM dbo.TipoMovimiento                     UNION ALL
SELECT 'TipoDeduccion',  COUNT(*) FROM dbo.TipoDeduccion                      UNION ALL
SELECT 'Feriado',        COUNT(*) FROM dbo.Feriado                            UNION ALL
SELECT 'Usuario',        COUNT(*) FROM dbo.Usuario                            UNION ALL
SELECT 'Error',          COUNT(*) FROM dbo.Error;
-- Esperado: 10 | 23 | 3 | 8 | 4 | 9 | 3 | 13
GO