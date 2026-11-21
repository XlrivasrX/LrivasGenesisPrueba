USE [PRUEBAS];
GO

IF OBJECT_ID(N'dbo.Servicios', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Servicios
    (
        ServicioId INT IDENTITY(1,1) PRIMARY KEY,
        Codigo NVARCHAR(30) NOT NULL UNIQUE,
        Nombre NVARCHAR(100) NOT NULL,
        Descripcion NVARCHAR(500) NULL,
        Precio DECIMAL(10,2) NOT NULL,
        DuracionEstimadaMinutos INT NOT NULL,
        Activo BIT NOT NULL DEFAULT 1,
        FechaCreacion DATETIME2 NOT NULL DEFAULT GETDATE(),
        FechaActualizacion DATETIME2 NULL
    );
END;
GO

