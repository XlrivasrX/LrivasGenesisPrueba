USE [PRUEBAS];
GO

IF OBJECT_ID(N'dbo.Razas', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Razas
    (
        RazaId INT IDENTITY(1,1) PRIMARY KEY,
        EspecieId INT NOT NULL,
        Nombre NVARCHAR(100) NOT NULL,
        Descripcion NVARCHAR(250) NULL,
        Activo BIT NOT NULL DEFAULT 1,
        FechaCreacion DATETIME2 NOT NULL DEFAULT GETDATE(),

        UNIQUE (EspecieId, Nombre),
        FOREIGN KEY (EspecieId) REFERENCES dbo.Especies(EspecieId)
    );
END;
GO

