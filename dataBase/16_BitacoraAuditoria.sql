USE [PRUEBAS];
GO

IF OBJECT_ID(N'dbo.BitacoraAuditoria', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.BitacoraAuditoria
    (
        BitacoraAuditoriaId INT IDENTITY(1,1) PRIMARY KEY,
        UsuarioId INT NULL,
        Accion NVARCHAR(100) NOT NULL,
        Entidad NVARCHAR(100) NOT NULL,
        EntidadId NVARCHAR(100) NULL,
        Detalle NVARCHAR(MAX) NULL,
        DireccionIp NVARCHAR(50) NULL,
        FechaCreacion DATETIME2 NOT NULL DEFAULT GETDATE(),

        FOREIGN KEY (UsuarioId) REFERENCES dbo.Usuarios(UsuarioId)
    );
END;
GO
