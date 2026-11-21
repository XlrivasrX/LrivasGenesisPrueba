USE [PRUEBAS];
GO

IF OBJECT_ID(N'dbo.Propietarios', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Propietarios
    (
        PropietarioId INT IDENTITY(1,1) PRIMARY KEY,
        ZonaId INT NULL,
        Nombres NVARCHAR(100) NOT NULL,
        Apellidos NVARCHAR(100) NOT NULL,
        Telefono NVARCHAR(25) NOT NULL,
        TelefonoAlternativo NVARCHAR(25) NULL,
        Direccion NVARCHAR(500) NOT NULL,
        Latitud DECIMAL(9,6) NULL,
        Longitud DECIMAL(9,6) NULL,
        Activo BIT NOT NULL DEFAULT 1,
        FechaCreacion DATETIME2 NOT NULL DEFAULT GETDATE(),
        FechaActualizacion DATETIME2 NULL,

        FOREIGN KEY (ZonaId) REFERENCES dbo.Zonas(ZonaId)
    );
END;
GO
