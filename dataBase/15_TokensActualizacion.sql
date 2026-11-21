USE [PRUEBAS];
GO

IF OBJECT_ID(N'dbo.TokensActualizacion', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.TokensActualizacion
    (
        TokenActualizacionId INT IDENTITY(1,1) PRIMARY KEY,
        UsuarioId INT NOT NULL,
        TokenHash VARCHAR(64) NOT NULL UNIQUE,
        FechaExpiracion DATETIME2 NOT NULL,
        FechaRevocacion DATETIME2 NULL,
        Dispositivo NVARCHAR(250) NULL,
        DireccionIp NVARCHAR(50) NULL,
        FechaCreacion DATETIME2 NOT NULL DEFAULT GETDATE(),

        FOREIGN KEY (UsuarioId) REFERENCES dbo.Usuarios(UsuarioId)
    );
END;
GO
