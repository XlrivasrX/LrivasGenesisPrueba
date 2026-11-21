USE [PRUEBAS];
GO

IF OBJECT_ID(N'dbo.RegistrosVisitas', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.RegistrosVisitas
    (
        RegistroVisitaId INT IDENTITY(1,1) PRIMARY KEY,
        VisitaId INT NOT NULL UNIQUE,
        PesoKg DECIMAL(8,2) NULL,
        AlturaCm DECIMAL(8,2) NULL,
        TemperaturaCelsius DECIMAL(5,2) NULL,
        CondicionCorporal NVARCHAR(100) NULL,
        Observaciones NVARCHAR(1000) NULL,
        Latitud DECIMAL(9,6) NOT NULL,
        Longitud DECIMAL(9,6) NOT NULL,
        RegistradoPorUsuarioId INT NOT NULL,
        FechaRegistro DATETIME2 NOT NULL DEFAULT GETDATE(),

        FOREIGN KEY (VisitaId) REFERENCES dbo.Visitas(VisitaId),
        FOREIGN KEY (RegistradoPorUsuarioId) REFERENCES dbo.Usuarios(UsuarioId)
    );
END;
GO

