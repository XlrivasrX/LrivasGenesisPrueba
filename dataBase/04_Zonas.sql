USE [PRUEBAS];
GO

IF OBJECT_ID(N'dbo.Zonas', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Zonas
    (
        ZonaId INT IDENTITY(1,1) PRIMARY KEY,
        Codigo NVARCHAR(20) NOT NULL UNIQUE,
        Nombre NVARCHAR(100) NOT NULL,
        Descripcion NVARCHAR(250) NULL,
        Activo BIT NOT NULL DEFAULT 1,
        FechaCreacion DATETIME2 NOT NULL DEFAULT GETDATE()
    );
END;
GO

