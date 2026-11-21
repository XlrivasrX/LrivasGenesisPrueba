USE [PRUEBAS];
GO

IF OBJECT_ID(N'dbo.Usuarios', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Usuarios
    (
        UsuarioId INT IDENTITY(1,1) PRIMARY KEY,
        RolId INT NOT NULL,
        NombreUsuario NVARCHAR(100) NOT NULL UNIQUE,
        ContrasenaHash NVARCHAR(500) NOT NULL,
        Nombres NVARCHAR(100) NOT NULL,
        Apellidos NVARCHAR(100) NOT NULL,
        Correo NVARCHAR(254) NULL,
        Telefono NVARCHAR(25) NULL,
        Activo BIT NOT NULL DEFAULT 1,
        DebeCambiarContrasena BIT NOT NULL DEFAULT 1,
        FechaUltimoAcceso DATETIME2 NULL,
        FechaCreacion DATETIME2 NOT NULL DEFAULT GETDATE(),
        FechaActualizacion DATETIME2 NULL,

        FOREIGN KEY (RolId) REFERENCES dbo.Roles(RolId)
    );
END;
GO

