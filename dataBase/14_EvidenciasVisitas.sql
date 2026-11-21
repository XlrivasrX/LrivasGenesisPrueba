USE [PRUEBAS];
GO

IF OBJECT_ID(N'dbo.EvidenciasVisitas', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.EvidenciasVisitas
    (
        EvidenciaVisitaId INT IDENTITY(1,1) PRIMARY KEY,
        RegistroVisitaId INT NOT NULL,
        NombreArchivo NVARCHAR(255) NOT NULL,
        RutaArchivo NVARCHAR(500) NOT NULL,
        TipoContenido NVARCHAR(100) NULL,
        FechaCaptura DATETIME2 NULL,
        FechaCreacion DATETIME2 NOT NULL DEFAULT GETDATE(),

        FOREIGN KEY (RegistroVisitaId) REFERENCES dbo.RegistrosVisitas(RegistroVisitaId)
    );
END;
GO

