USE [PRUEBAS];
GO

IF OBJECT_ID(N'dbo.Pacientes', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Pacientes
    (
        PacienteId INT IDENTITY(1,1) PRIMARY KEY,
        PropietarioId INT NOT NULL,
        EspecieId INT NOT NULL,
        RazaId INT NOT NULL,
        Nombre NVARCHAR(100) NOT NULL,
        FechaNacimientoAproximada DATE NULL,
        RutaFoto NVARCHAR(500) NULL,
        Observaciones NVARCHAR(500) NULL,
        CreadoPorUsuarioId INT NOT NULL,
        Activo BIT NOT NULL DEFAULT 1,
        FechaCreacion DATETIME2 NOT NULL DEFAULT GETDATE(),
        FechaActualizacion DATETIME2 NULL,

        FOREIGN KEY (PropietarioId) REFERENCES dbo.Propietarios(PropietarioId),
        FOREIGN KEY (EspecieId) REFERENCES dbo.Especies(EspecieId),
        FOREIGN KEY (RazaId) REFERENCES dbo.Razas(RazaId),
        FOREIGN KEY (CreadoPorUsuarioId) REFERENCES dbo.Usuarios(UsuarioId)
    );
END;
GO

