USE [PRUEBAS];
GO

IF OBJECT_ID(N'dbo.Visitas', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Visitas
    (
        VisitaId INT IDENTITY(1,1) PRIMARY KEY,
        PacienteId INT NOT NULL,
        ServicioId INT NOT NULL,
        MedicoResponsableUsuarioId INT NOT NULL,
        TecnicoUsuarioId INT NOT NULL,
        ProgramadaPorUsuarioId INT NOT NULL,
        FechaProgramada DATETIME2 NOT NULL,
        PrecioProgramado DECIMAL(10,2) NOT NULL,
        ObservacionesProgramacion NVARCHAR(500) NULL,
        FechaCreacion DATETIME2 NOT NULL DEFAULT GETDATE(),

        FOREIGN KEY (PacienteId) REFERENCES dbo.Pacientes(PacienteId),
        FOREIGN KEY (ServicioId) REFERENCES dbo.Servicios(ServicioId),
        FOREIGN KEY (MedicoResponsableUsuarioId) REFERENCES dbo.Usuarios(UsuarioId),
        FOREIGN KEY (TecnicoUsuarioId) REFERENCES dbo.Usuarios(UsuarioId),
        FOREIGN KEY (ProgramadaPorUsuarioId) REFERENCES dbo.Usuarios(UsuarioId)
    );
END;
GO
