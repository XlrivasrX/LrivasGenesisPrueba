USE [PRUEBAS];
GO

IF OBJECT_ID(N'dbo.Especies', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Especies
    (
        EspecieId INT IDENTITY(1,1) PRIMARY KEY,
        Nombre NVARCHAR(100) NOT NULL UNIQUE,
        Descripcion NVARCHAR(250) NULL,
        Activo BIT NOT NULL DEFAULT 1,
        FechaCreacion DATETIME2 NOT NULL DEFAULT GETDATE()
    );
END;
GO
