USE [PRUEBAS];
GO

IF OBJECT_ID(N'dbo.SP_VetRuta_Inserts_Updates', N'P') IS NULL
    EXEC(N'CREATE PROCEDURE dbo.SP_VetRuta_Inserts_Updates AS BEGIN SET NOCOUNT ON; END');
GO

ALTER PROCEDURE dbo.SP_VetRuta_Inserts_Updates
    @Opcion INT,
    @UsuarioId INT = NULL,
    @RolId INT = NULL,
    @NombreUsuario NVARCHAR(100) = NULL,
    @ContrasenaHash NVARCHAR(500) = NULL,
    @Nombres NVARCHAR(100) = NULL,
    @Apellidos NVARCHAR(100) = NULL,
    @Correo NVARCHAR(254) = NULL,
    @Telefono NVARCHAR(25) = NULL,
    @Activo BIT = NULL,
    @DebeCambiarContrasena BIT = 1,
    @UsuarioSuperiorId INT = NULL,
    @UsuarioSubordinadoId INT = NULL,
    @CreadoPorUsuarioId INT = NULL,
    @Observacion NVARCHAR(250) = NULL,
    @EspecieId INT = NULL,
    @RazaId INT = NULL,
    @ServicioId INT = NULL,
    @ZonaId INT = NULL,
    @CodigoCatalogo NVARCHAR(30) = NULL,
    @NombreCatalogo NVARCHAR(100) = NULL,
    @DescripcionCatalogo NVARCHAR(500) = NULL,
    @Precio DECIMAL(10,2) = NULL,
    @DuracionEstimadaMinutos INT = NULL,
    @PropietarioId INT = NULL,
    @PacienteId INT = NULL,
    @TelefonoAlternativo NVARCHAR(25) = NULL,
    @Direccion NVARCHAR(500) = NULL,
    @Latitud DECIMAL(9,6) = NULL,
    @Longitud DECIMAL(9,6) = NULL,
    @NombrePaciente NVARCHAR(100) = NULL,
    @FechaNacimientoAproximada DATE = NULL,
    @RutaFoto NVARCHAR(500) = NULL,
    @Observaciones NVARCHAR(500) = NULL,
    @AsignacionPacienteId INT = NULL,
    @TecnicoUsuarioId INT = NULL,
    @AsignadoPorUsuarioId INT = NULL,
    @VisitaId INT = NULL,
    @MedicoResponsableUsuarioId INT = NULL,
    @ProgramadaPorUsuarioId INT = NULL,
    @FechaProgramada DATETIME2 = NULL,
    @PrecioProgramado DECIMAL(10,2) = NULL,
    @ObservacionesProgramacion NVARCHAR(500) = NULL,
    @RegistroVisitaId INT = NULL,
    @PesoKg DECIMAL(8,2) = NULL,
    @AlturaCm DECIMAL(8,2) = NULL,
    @TemperaturaCelsius DECIMAL(5,2) = NULL,
    @CondicionCorporal NVARCHAR(100) = NULL,
    @ObservacionesAtencion NVARCHAR(1000) = NULL,
    @RegistradoPorUsuarioId INT = NULL,
    @NombreArchivo NVARCHAR(255) = NULL,
    @RutaArchivo NVARCHAR(500) = NULL,
    @TipoContenido NVARCHAR(100) = NULL,
    @FechaCaptura DATETIME2 = NULL,
    @Accion NVARCHAR(100) = NULL,
    @Entidad NVARCHAR(100) = NULL,
    @EntidadId NVARCHAR(100) = NULL,
    @Detalle NVARCHAR(MAX) = NULL,
    @DireccionIp NVARCHAR(50) = NULL,
    @TokenHash VARCHAR(64) = NULL,
    @FechaExpiracion DATETIME2 = NULL,
    @Dispositivo NVARCHAR(250) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Opción 1: crear un usuario
    IF @Opcion = 1
    BEGIN
        IF EXISTS (SELECT 1 FROM dbo.Usuarios WHERE NombreUsuario = @NombreUsuario)
            THROW 50002, N'El nombre de usuario ya está registrado.', 1;

        INSERT INTO dbo.Usuarios
        (
            RolId,
            NombreUsuario,
            ContrasenaHash,
            Nombres,
            Apellidos,
            Correo,
            Telefono,
            DebeCambiarContrasena
        )
        VALUES
        (
            @RolId,
            @NombreUsuario,
            @ContrasenaHash,
            @Nombres,
            @Apellidos,
            @Correo,
            @Telefono,
            @DebeCambiarContrasena
        );

        SELECT CAST(SCOPE_IDENTITY() AS INT) AS UsuarioId,
               N'Usuario creado correctamente.' AS Mensaje;
    END

    -- Opción 2: actualizar los datos generales de un usuario
    ELSE IF @Opcion = 2
    BEGIN
        UPDATE dbo.Usuarios
        SET RolId = @RolId,
            Nombres = @Nombres,
            Apellidos = @Apellidos,
            Correo = @Correo,
            Telefono = @Telefono,
            FechaActualizacion = GETDATE()
        WHERE UsuarioId = @UsuarioId;

        SELECT @UsuarioId AS UsuarioId, N'Usuario actualizado correctamente.' AS Mensaje;
    END

    -- Opción 3: activar o desactivar un usuario
    ELSE IF @Opcion = 3
    BEGIN
        UPDATE dbo.Usuarios
        SET Activo = @Activo,
            FechaActualizacion = GETDATE()
        WHERE UsuarioId = @UsuarioId;

        SELECT @UsuarioId AS UsuarioId, N'Estado del usuario actualizado correctamente.' AS Mensaje;
    END

    -- Opción 4: cambiar la contraseña de un usuario
    ELSE IF @Opcion = 4
    BEGIN
        UPDATE dbo.Usuarios
        SET ContrasenaHash = @ContrasenaHash,
            DebeCambiarContrasena = @DebeCambiarContrasena,
            FechaActualizacion = GETDATE()
        WHERE UsuarioId = @UsuarioId;

        SELECT @UsuarioId AS UsuarioId, N'Contraseña actualizada correctamente.' AS Mensaje;
    END

    -- Opción 5: registrar el último acceso al sistema
    ELSE IF @Opcion = 5
    BEGIN
        UPDATE dbo.Usuarios
        SET FechaUltimoAcceso = GETDATE()
        WHERE UsuarioId = @UsuarioId;

        SELECT @UsuarioId AS UsuarioId, N'Último acceso registrado correctamente.' AS Mensaje;
    END

    -- Opción 6: asignar o reasignar un subordinado
    ELSE IF @Opcion = 6
    BEGIN
        BEGIN TRY
            BEGIN TRANSACTION;

            UPDATE dbo.AsignacionesJerarquia
            SET FechaFin = GETDATE()
            WHERE UsuarioSubordinadoId = @UsuarioSubordinadoId
              AND FechaFin IS NULL;

            INSERT INTO dbo.AsignacionesJerarquia
            (
                UsuarioSuperiorId,
                UsuarioSubordinadoId,
                Observacion,
                CreadoPorUsuarioId
            )
            VALUES
            (
                @UsuarioSuperiorId,
                @UsuarioSubordinadoId,
                @Observacion,
                @CreadoPorUsuarioId
            );

            COMMIT TRANSACTION;

            SELECT CAST(SCOPE_IDENTITY() AS INT) AS AsignacionJerarquiaId,
                   N'Asignación realizada correctamente.' AS Mensaje;
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;

            THROW;
        END CATCH
    END

    -- Opción 7: insertar una especie
    ELSE IF @Opcion = 7
    BEGIN
        IF EXISTS (SELECT 1 FROM dbo.Especies WHERE Nombre = @NombreCatalogo)
            THROW 50004, N'La especie ya está registrada.', 1;

        INSERT INTO dbo.Especies (Nombre, Descripcion, Activo)
        VALUES (@NombreCatalogo, @DescripcionCatalogo, ISNULL(@Activo, 1));

        SELECT CAST(SCOPE_IDENTITY() AS INT) AS EspecieId,
               N'Especie creada correctamente.' AS Mensaje;
    END

    -- Opción 8: actualizar una especie
    ELSE IF @Opcion = 8
    BEGIN
        UPDATE dbo.Especies
        SET Nombre = @NombreCatalogo,
            Descripcion = @DescripcionCatalogo,
            Activo = ISNULL(@Activo, Activo)
        WHERE EspecieId = @EspecieId;

        SELECT @EspecieId AS EspecieId, N'Especie actualizada correctamente.' AS Mensaje;
    END

    -- Opción 9: insertar una raza
    ELSE IF @Opcion = 9
    BEGIN
        IF EXISTS
        (
            SELECT 1
            FROM dbo.Razas
            WHERE EspecieId = @EspecieId
              AND Nombre = @NombreCatalogo
        )
            THROW 50005, N'La raza ya está registrada para la especie indicada.', 1;

        INSERT INTO dbo.Razas (EspecieId, Nombre, Descripcion, Activo)
        VALUES (@EspecieId, @NombreCatalogo, @DescripcionCatalogo, ISNULL(@Activo, 1));

        SELECT CAST(SCOPE_IDENTITY() AS INT) AS RazaId,
               N'Raza creada correctamente.' AS Mensaje;
    END

    -- Opción 10: actualizar una raza
    ELSE IF @Opcion = 10
    BEGIN
        UPDATE dbo.Razas
        SET EspecieId = @EspecieId,
            Nombre = @NombreCatalogo,
            Descripcion = @DescripcionCatalogo,
            Activo = ISNULL(@Activo, Activo)
        WHERE RazaId = @RazaId;

        SELECT @RazaId AS RazaId, N'Raza actualizada correctamente.' AS Mensaje;
    END

    -- Opción 11: insertar un servicio
    ELSE IF @Opcion = 11
    BEGIN
        IF EXISTS (SELECT 1 FROM dbo.Servicios WHERE Codigo = @CodigoCatalogo)
            THROW 50006, N'El código del servicio ya está registrado.', 1;

        INSERT INTO dbo.Servicios
        (
            Codigo,
            Nombre,
            Descripcion,
            Precio,
            DuracionEstimadaMinutos,
            Activo
        )
        VALUES
        (
            @CodigoCatalogo,
            @NombreCatalogo,
            @DescripcionCatalogo,
            @Precio,
            @DuracionEstimadaMinutos,
            ISNULL(@Activo, 1)
        );

        SELECT CAST(SCOPE_IDENTITY() AS INT) AS ServicioId,
               N'Servicio creado correctamente.' AS Mensaje;
    END

    -- Opción 12: actualizar un servicio
    ELSE IF @Opcion = 12
    BEGIN
        UPDATE dbo.Servicios
        SET Codigo = @CodigoCatalogo,
            Nombre = @NombreCatalogo,
            Descripcion = @DescripcionCatalogo,
            Precio = @Precio,
            DuracionEstimadaMinutos = @DuracionEstimadaMinutos,
            Activo = ISNULL(@Activo, Activo),
            FechaActualizacion = GETDATE()
        WHERE ServicioId = @ServicioId;

        SELECT @ServicioId AS ServicioId, N'Servicio actualizado correctamente.' AS Mensaje;
    END

    -- Opción 13: insertar una zona
    ELSE IF @Opcion = 13
    BEGIN
        IF EXISTS (SELECT 1 FROM dbo.Zonas WHERE Codigo = @CodigoCatalogo)
            THROW 50007, N'El código de la zona ya está registrado.', 1;

        INSERT INTO dbo.Zonas (Codigo, Nombre, Descripcion, Activo)
        VALUES (@CodigoCatalogo, @NombreCatalogo, @DescripcionCatalogo, ISNULL(@Activo, 1));

        SELECT CAST(SCOPE_IDENTITY() AS INT) AS ZonaId,
               N'Zona creada correctamente.' AS Mensaje;
    END

    -- Opción 14: actualizar una zona
    ELSE IF @Opcion = 14
    BEGIN
        UPDATE dbo.Zonas
        SET Codigo = @CodigoCatalogo,
            Nombre = @NombreCatalogo,
            Descripcion = @DescripcionCatalogo,
            Activo = ISNULL(@Activo, Activo)
        WHERE ZonaId = @ZonaId;

        SELECT @ZonaId AS ZonaId, N'Zona actualizada correctamente.' AS Mensaje;
    END

    -- Opción 15: crear un propietario
    ELSE IF @Opcion = 15
    BEGIN
        INSERT INTO dbo.Propietarios
        (
            ZonaId,
            Nombres,
            Apellidos,
            Telefono,
            TelefonoAlternativo,
            Direccion,
            Latitud,
            Longitud,
            Activo
        )
        VALUES
        (
            @ZonaId,
            @Nombres,
            @Apellidos,
            @Telefono,
            @TelefonoAlternativo,
            @Direccion,
            @Latitud,
            @Longitud,
            ISNULL(@Activo, 1)
        );

        SELECT CAST(SCOPE_IDENTITY() AS INT) AS PropietarioId,
               N'Propietario creado correctamente.' AS Mensaje;
    END

    -- Opción 16: actualizar un propietario
    ELSE IF @Opcion = 16
    BEGIN
        UPDATE dbo.Propietarios
        SET ZonaId = @ZonaId,
            Nombres = @Nombres,
            Apellidos = @Apellidos,
            Telefono = @Telefono,
            TelefonoAlternativo = @TelefonoAlternativo,
            Direccion = @Direccion,
            Latitud = @Latitud,
            Longitud = @Longitud,
            Activo = ISNULL(@Activo, Activo),
            FechaActualizacion = GETDATE()
        WHERE PropietarioId = @PropietarioId;

        SELECT @PropietarioId AS PropietarioId,
               N'Propietario actualizado correctamente.' AS Mensaje;
    END

    -- Opción 17: crear un paciente
    ELSE IF @Opcion = 17
    BEGIN
        INSERT INTO dbo.Pacientes
        (
            PropietarioId,
            EspecieId,
            RazaId,
            Nombre,
            FechaNacimientoAproximada,
            RutaFoto,
            Observaciones,
            CreadoPorUsuarioId,
            Activo
        )
        VALUES
        (
            @PropietarioId,
            @EspecieId,
            @RazaId,
            @NombrePaciente,
            @FechaNacimientoAproximada,
            @RutaFoto,
            @Observaciones,
            @CreadoPorUsuarioId,
            ISNULL(@Activo, 1)
        );

        SELECT CAST(SCOPE_IDENTITY() AS INT) AS PacienteId,
               N'Paciente creado correctamente.' AS Mensaje;
    END

    -- Opción 18: actualizar un paciente
    ELSE IF @Opcion = 18
    BEGIN
        UPDATE dbo.Pacientes
        SET PropietarioId = @PropietarioId,
            EspecieId = @EspecieId,
            RazaId = @RazaId,
            Nombre = @NombrePaciente,
            FechaNacimientoAproximada = @FechaNacimientoAproximada,
            RutaFoto = @RutaFoto,
            Observaciones = @Observaciones,
            Activo = ISNULL(@Activo, Activo),
            FechaActualizacion = GETDATE()
        WHERE PacienteId = @PacienteId;

        SELECT @PacienteId AS PacienteId,
               N'Paciente actualizado correctamente.' AS Mensaje;
    END

    -- Opción 19: asignar o reasignar un paciente a un técnico
    ELSE IF @Opcion = 19
    BEGIN
        BEGIN TRY
            BEGIN TRANSACTION;

            UPDATE dbo.AsignacionesPacientes
            SET FechaFin = GETDATE()
            WHERE PacienteId = @PacienteId
              AND FechaFin IS NULL;

            INSERT INTO dbo.AsignacionesPacientes
            (
                PacienteId,
                TecnicoUsuarioId,
                AsignadoPorUsuarioId,
                Observacion
            )
            VALUES
            (
                @PacienteId,
                @TecnicoUsuarioId,
                @AsignadoPorUsuarioId,
                @Observacion
            );

            SET @AsignacionPacienteId = CAST(SCOPE_IDENTITY() AS INT);

            COMMIT TRANSACTION;

            SELECT @AsignacionPacienteId AS AsignacionPacienteId,
                   N'Paciente asignado correctamente.' AS Mensaje;
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;

            THROW;
        END CATCH
    END

    -- Opción 20: finalizar una asignación activa
    ELSE IF @Opcion = 20
    BEGIN
        UPDATE dbo.AsignacionesPacientes
        SET FechaFin = GETDATE(),
            Observacion = ISNULL(@Observacion, Observacion)
        WHERE AsignacionPacienteId = @AsignacionPacienteId
          AND FechaFin IS NULL;

        SELECT @AsignacionPacienteId AS AsignacionPacienteId,
               N'Asignación finalizada correctamente.' AS Mensaje;
    END

    -- Opción 21: programar una visita
    ELSE IF @Opcion = 21
    BEGIN
        INSERT INTO dbo.Visitas
        (
            PacienteId,
            ServicioId,
            MedicoResponsableUsuarioId,
            TecnicoUsuarioId,
            ProgramadaPorUsuarioId,
            FechaProgramada,
            PrecioProgramado,
            ObservacionesProgramacion
        )
        VALUES
        (
            @PacienteId,
            @ServicioId,
            @MedicoResponsableUsuarioId,
            @TecnicoUsuarioId,
            @ProgramadaPorUsuarioId,
            @FechaProgramada,
            @PrecioProgramado,
            @ObservacionesProgramacion
        );

        SELECT CAST(SCOPE_IDENTITY() AS INT) AS VisitaId,
               N'Visita programada correctamente.' AS Mensaje;
    END

    -- Opción 22: actualizar o reprogramar una visita
    ELSE IF @Opcion = 22
    BEGIN
        IF EXISTS
        (
            SELECT 1
            FROM dbo.RegistrosVisitas
            WHERE VisitaId = @VisitaId
        )
            THROW 50008, N'No se puede modificar una visita que ya fue completada.', 1;

        UPDATE dbo.Visitas
        SET PacienteId = @PacienteId,
            ServicioId = @ServicioId,
            MedicoResponsableUsuarioId = @MedicoResponsableUsuarioId,
            TecnicoUsuarioId = @TecnicoUsuarioId,
            FechaProgramada = @FechaProgramada,
            PrecioProgramado = @PrecioProgramado,
            ObservacionesProgramacion = @ObservacionesProgramacion
        WHERE VisitaId = @VisitaId;

        SELECT @VisitaId AS VisitaId,
               N'Visita actualizada correctamente.' AS Mensaje;
    END

    -- Opción 23: completar una visita y guardar su registro clínico
    ELSE IF @Opcion = 23
    BEGIN
        IF EXISTS
        (
            SELECT 1
            FROM dbo.RegistrosVisitas
            WHERE VisitaId = @VisitaId
        )
            THROW 50009, N'La visita ya tiene un registro clínico.', 1;

        INSERT INTO dbo.RegistrosVisitas
        (
            VisitaId,
            PesoKg,
            AlturaCm,
            TemperaturaCelsius,
            CondicionCorporal,
            Observaciones,
            Latitud,
            Longitud,
            RegistradoPorUsuarioId
        )
        VALUES
        (
            @VisitaId,
            @PesoKg,
            @AlturaCm,
            @TemperaturaCelsius,
            @CondicionCorporal,
            @ObservacionesAtencion,
            @Latitud,
            @Longitud,
            @RegistradoPorUsuarioId
        );

        SELECT CAST(SCOPE_IDENTITY() AS INT) AS RegistroVisitaId,
               N'Visita completada correctamente.' AS Mensaje;
    END

    -- Opción 24: agregar una evidencia a una visita completada
    ELSE IF @Opcion = 24
    BEGIN
        INSERT INTO dbo.EvidenciasVisitas
        (
            RegistroVisitaId,
            NombreArchivo,
            RutaArchivo,
            TipoContenido,
            FechaCaptura
        )
        VALUES
        (
            @RegistroVisitaId,
            @NombreArchivo,
            @RutaArchivo,
            @TipoContenido,
            @FechaCaptura
        );

        SELECT CAST(SCOPE_IDENTITY() AS INT) AS EvidenciaVisitaId,
               N'Evidencia guardada correctamente.' AS Mensaje;
    END

    -- Opción 25: registrar una acción en la bitácora de auditoría
    ELSE IF @Opcion = 25
    BEGIN
        INSERT INTO dbo.BitacoraAuditoria
        (
            UsuarioId,
            Accion,
            Entidad,
            EntidadId,
            Detalle,
            DireccionIp
        )
        VALUES
        (
            @UsuarioId,
            @Accion,
            @Entidad,
            @EntidadId,
            @Detalle,
            @DireccionIp
        );

        SELECT CAST(SCOPE_IDENTITY() AS INT) AS BitacoraAuditoriaId,
               N'Acción registrada correctamente.' AS Mensaje;
    END

    -- Opción 26: crear un token de actualización
    ELSE IF @Opcion = 26
    BEGIN
        IF EXISTS
        (
            SELECT 1
            FROM dbo.TokensActualizacion
            WHERE TokenHash = @TokenHash
        )
            THROW 50010, N'El token de actualización ya está registrado.', 1;

        INSERT INTO dbo.TokensActualizacion
        (
            UsuarioId,
            TokenHash,
            FechaExpiracion,
            Dispositivo,
            DireccionIp
        )
        VALUES
        (
            @UsuarioId,
            @TokenHash,
            @FechaExpiracion,
            @Dispositivo,
            @DireccionIp
        );

        SELECT CAST(SCOPE_IDENTITY() AS INT) AS TokenActualizacionId,
               N'Token de actualización creado correctamente.' AS Mensaje;
    END

    -- Opción 27: revocar un token de actualización
    ELSE IF @Opcion = 27
    BEGIN
        UPDATE dbo.TokensActualizacion
        SET FechaRevocacion = GETDATE()
        WHERE TokenHash = @TokenHash
          AND FechaRevocacion IS NULL;

        SELECT TokenActualizacionId,
               N'Token de actualización revocado correctamente.' AS Mensaje
        FROM dbo.TokensActualizacion
        WHERE TokenHash = @TokenHash;
    END

    ELSE
    BEGIN
        THROW 50003, N'La opción indicada no existe en SP_VetRuta_Inserts_Updates.', 1;
    END
END;
GO
