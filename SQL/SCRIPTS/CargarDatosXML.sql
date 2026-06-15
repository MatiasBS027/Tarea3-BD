USE [PlanillaDB];
GO

-- =====================================================================
-- PlanillaDB - Carga inicial de catalogos desde Datos.xml
-- Se puede volver a correr sin duplicar datos.
-- =====================================================================

DECLARE @hDoc INT;
DECLARE @xml  NVARCHAR(MAX);

-- ── Leer el XML desde disco ───────────────────────────────────────────
SELECT @xml = BulkColumn
FROM OPENROWSET(
    BULK 'SQL\DATA\Datos.xml',
    SINGLE_NCLOB
) AS x;

EXEC sp_xml_preparedocument @hDoc OUTPUT, @xml;

BEGIN TRY

    BEGIN TRANSACTION;

    -- ======================================
    -- 1. TipoMovimiento
    --    Accion: 'C' = Credito, 'D' = Debito
    -- ======================================
    INSERT INTO dbo.TipoMovimiento (id, Nombre, Accion)
    SELECT x.Id, x.Nombre, x.Accion
    FROM OPENXML(@hDoc, N'/Datos/TiposMovimiento/TipoMovimiento', 1)
        WITH (
            Id     INT         '@Id',
            Nombre VARCHAR(64) '@Nombre',
            Accion CHAR(1)     '@Accion'
        ) AS x
    WHERE NOT EXISTS (
        SELECT 1 FROM dbo.TipoMovimiento tm WHERE tm.id = x.Id
    );

    -- ================
    -- 2. TipoEvento
    -- ================
    INSERT INTO dbo.TipoEvento (id, Nombre)
    SELECT x.Id, x.Nombre
    FROM OPENXML(@hDoc, N'/Datos/TiposEvento/TipoEvento', 1)
        WITH (
            Id     INT         '@Id',
            Nombre VARCHAR(64) '@Nombre'
        ) AS x
    WHERE NOT EXISTS (
        SELECT 1 FROM dbo.TipoEvento te WHERE te.id = x.Id
    );

    -- =================================
    -- 3. Puesto: mapeo por Nombre
    -- =================================
    INSERT INTO dbo.Puesto (Nombre, SalarioXHora)
    SELECT x.Nombre, x.SalarioXHora
    FROM OPENXML(@hDoc, N'/Datos/Puestos/Puesto', 1)
        WITH (
            Nombre       VARCHAR(128)  '@Nombre',
            SalarioXHora DECIMAL(10,2) '@SalarioXHora'
        ) AS x
    WHERE NOT EXISTS (
        SELECT 1 FROM dbo.Puesto p WHERE p.Nombre = x.Nombre
    );

    -- =====================
    -- 4. TipoJornada 
    -- =====================
    INSERT INTO dbo.TipoJornada (id, Nombre, HoraInicio, HoraFin)
    SELECT x.Id, x.Nombre, CAST(x.HoraInicio AS TIME(0)), CAST(x.HoraFin AS TIME(0))
    FROM OPENXML(@hDoc, N'/Datos/TiposJornada/TipoJornada', 1)
        WITH (
            Id         INT         '@Id',
            Nombre     VARCHAR(64) '@Nombre',
            HoraInicio VARCHAR(8)  '@HoraInicio',
            HoraFin    VARCHAR(8)  '@HoraFin'
        ) AS x
    WHERE NOT EXISTS (
        SELECT 1 FROM dbo.TipoJornada tj WHERE tj.id = x.Id
    );

    -- ================
    -- 5. Feriado
    -- ================
    INSERT INTO dbo.Feriado (id, Nombre, Fecha)
    SELECT x.Id, x.Nombre, CAST(x.Fecha AS DATE)
    FROM OPENXML(@hDoc, N'/Datos/Feriados/Feriado', 1)
        WITH (
            Id     INT          '@Id',
            Nombre VARCHAR(128) '@Nombre',
            Fecha  VARCHAR(10)  '@Fecha'
        ) AS x
    WHERE NOT EXISTS (
        SELECT 1 FROM dbo.Feriado f WHERE f.id = x.Id
    );

    -- ==========================================================
    -- 6. TipoDeduccion
    --    FK a TipoMovimiento resuelta por Nombre del movimiento
    --    EsObligatoria / EsPorcentual: 0/1 en el XML, tipo BIT
    -- ==========================================================
    INSERT INTO dbo.TipoDeduccion (id, Nombre, EsObligatoria, EsPorcentual, Valor, idTipoMovimiento)
    SELECT
        x.Id,
        x.Nombre,
        CAST(x.EsObligatoria AS BIT),
        CAST(x.EsPorcentual  AS BIT),
        x.Valor,
        tm.id
    FROM OPENXML(@hDoc, N'/Datos/TiposDeduccion/TipoDeduccion', 1)
        WITH (
            Id             INT          '@Id',
            Nombre         VARCHAR(128) '@Nombre',
            EsObligatoria  TINYINT      '@EsObligatoria',
            EsPorcentual   TINYINT      '@EsPorcentual',
            Valor          DECIMAL(8,4) '@Valor',
            TipoMovimiento VARCHAR(64)  '@TipoMovimiento'
        ) AS x
    INNER JOIN dbo.TipoMovimiento AS tm ON tm.Nombre = x.TipoMovimiento
    WHERE NOT EXISTS (
        SELECT 1 FROM dbo.TipoDeduccion td WHERE td.id = x.Id
    );

    -- ==================================
    -- 7. Usuarios (Administradores)
    -- ==================================
    INSERT INTO dbo.Usuario (id, Username, PasswordHash, Tipo)
    SELECT x.Id, x.Username, x.PasswordHash, x.Tipo
    FROM OPENXML(@hDoc, N'/Datos/Usuarios/Usuario', 1)
        WITH (
            Id           INT         '@Id',
            Username     VARCHAR(64) '@Username',
            PasswordHash VARCHAR(64) '@PasswordHash',
            Tipo         VARCHAR(2)  '@Tipo'
        ) AS x
    WHERE NOT EXISTS (
        SELECT 1 FROM dbo.Usuario u WHERE u.id = x.Id
    );

    -- =============
    -- 8. Error
    -- =============
    INSERT INTO dbo.Error (Codigo, Descripcion)
    SELECT x.Codigo, x.Descripcion
    FROM OPENXML(@hDoc, N'/Datos/Error/error', 1)
        WITH (
            Codigo      INT            '@Codigo',
            Descripcion NVARCHAR(256)  '@Descripcion'
        ) AS x
    WHERE NOT EXISTS (
        SELECT 1 FROM dbo.Error e WHERE e.Codigo = x.Codigo
    );

    COMMIT TRANSACTION;
    PRINT 'CargarDatosXML: catalogos cargados correctamente.';

END TRY
BEGIN CATCH

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;

    INSERT INTO dbo.DBError (
        UserName, Number, State, Severity,
        Line, [Procedure], Message, DateTime
    )
    VALUES (
        SYSTEM_USER,
        ERROR_NUMBER(),
        ERROR_STATE(),
        ERROR_SEVERITY(),
        ERROR_LINE(),
        'CargarDatosXML',
        ERROR_MESSAGE(),
        GETDATE()
    );

    PRINT 'CargarDatosXML: error al cargar catalogos. Ver tabla DBError.';

    IF @hDoc IS NOT NULL
        EXEC sp_xml_removedocument @hDoc;

    THROW;

END CATCH

-- Liberar el documento XML de memoria (siempre)
IF @hDoc IS NOT NULL
    EXEC sp_xml_removedocument @hDoc;
GO