USE [PRUEBAS];
GO

IF OBJECT_ID(N'dbo.AsignacionesJerarquia', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.AsignacionesJerarquia
    (
        AsignacionJerarquiaId INT IDENTITY(1,1) PRIMARY KEY,
        UsuarioSuperiorId INT NOT NULL,
        UsuarioSubordinadoId INT NOT NULL,
        FechaInicio DATETIME2 NOT NULL DEFAULT GETDATE(),
        FechaFin DATETIME2 NULL,
        Observacion NVARCHAR(250) NULL,
        CreadoPorUsuarioId INT NOT NULL,
        FechaCreacion DATETIME2 NOT NULL DEFAULT GETDATE(),

        FOREIGN KEY (UsuarioSuperiorId) REFERENCES dbo.Usuarios(UsuarioId),
        FOREIGN KEY (UsuarioSubordinadoId) REFERENCES dbo.Usuarios(UsuarioId),
        FOREIGN KEY (CreadoPorUsuarioId) REFERENCES dbo.Usuarios(UsuarioId)
    );
END;
GO
