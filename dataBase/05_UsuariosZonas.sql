USE [PRUEBAS];
GO

IF OBJECT_ID(N'dbo.UsuariosZonas', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.UsuariosZonas
    (
        UsuarioZonaId INT IDENTITY(1,1) PRIMARY KEY,
        UsuarioId INT NOT NULL,
        ZonaId INT NOT NULL,
        Activo BIT NOT NULL DEFAULT 1,
        FechaAsignacion DATETIME2 NOT NULL DEFAULT GETDATE(),

        UNIQUE (UsuarioId, ZonaId),
        FOREIGN KEY (UsuarioId) REFERENCES dbo.Usuarios(UsuarioId),
        FOREIGN KEY (ZonaId) REFERENCES dbo.Zonas(ZonaId)
    );
END;
GO

