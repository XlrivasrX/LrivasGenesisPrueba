USE [PRUEBAS];
GO

IF OBJECT_ID(N'dbo.AsignacionesPacientes', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.AsignacionesPacientes
    (
        AsignacionPacienteId INT IDENTITY(1,1) PRIMARY KEY,
        PacienteId INT NOT NULL,
        TecnicoUsuarioId INT NOT NULL,
        AsignadoPorUsuarioId INT NOT NULL,
        FechaInicio DATETIME2 NOT NULL DEFAULT GETDATE(),
        FechaFin DATETIME2 NULL,
        Observacion NVARCHAR(250) NULL,
        FechaCreacion DATETIME2 NOT NULL DEFAULT GETDATE(),

        FOREIGN KEY (PacienteId) REFERENCES dbo.Pacientes(PacienteId),
        FOREIGN KEY (TecnicoUsuarioId) REFERENCES dbo.Usuarios(UsuarioId),
        FOREIGN KEY (AsignadoPorUsuarioId) REFERENCES dbo.Usuarios(UsuarioId)
    );
END;
GO

