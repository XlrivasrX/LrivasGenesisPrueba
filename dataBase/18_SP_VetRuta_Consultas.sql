USE [PRUEBAS];
GO

IF OBJECT_ID(N'dbo.SP_VetRuta_Consultas', N'P') IS NULL
    EXEC(N'CREATE PROCEDURE dbo.SP_VetRuta_Consultas AS BEGIN SET NOCOUNT ON; END');
GO

ALTER PROCEDURE dbo.SP_VetRuta_Consultas
    @Opcion INT,
    @UsuarioId INT = NULL,
    @NombreUsuario NVARCHAR(100) = NULL,
    @RolId INT = NULL,
    @Activo BIT = NULL,
    @UsuarioSuperiorId INT = NULL,
    @TextoBusqueda NVARCHAR(100) = NULL,
    @EspecieId INT = NULL,
    @ServicioId INT = NULL,
    @ZonaId INT = NULL,
    @PropietarioId INT = NULL,
    @PacienteId INT = NULL,
    @TecnicoUsuarioId INT = NULL,
    @VisitaId INT = NULL,
    @MedicoResponsableUsuarioId INT = NULL,
    @FechaDesde DATE = NULL,
    @FechaHasta DATE = NULL,
    @RegistroVisitaId INT = NULL,
    @Accion NVARCHAR(100) = NULL,
    @Entidad NVARCHAR(100) = NULL,
    @TokenHash VARCHAR(64) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Opción 1: buscar los datos necesarios para iniciar sesión
    IF @Opcion = 1
    BEGIN
        SELECT
            U.UsuarioId,
            U.NombreUsuario,
            U.ContrasenaHash,
            U.Nombres,
            U.Apellidos,
            U.Activo,
            U.DebeCambiarContrasena,
            R.RolId,
            R.Codigo AS CodigoRol,
            R.Nombre AS NombreRol
        FROM dbo.Usuarios U
        INNER JOIN dbo.Roles R ON R.RolId = U.RolId
        WHERE U.NombreUsuario = @NombreUsuario;
    END

    -- Opción 2: listar usuarios con filtros opcionales
    ELSE IF @Opcion = 2
    BEGIN
        SELECT
            U.UsuarioId,
            U.NombreUsuario,
            U.Nombres,
            U.Apellidos,
            U.Correo,
            U.Telefono,
            U.Activo,
            U.FechaUltimoAcceso,
            U.FechaCreacion,
            R.RolId,
            R.Codigo AS CodigoRol,
            R.Nombre AS NombreRol
        FROM dbo.Usuarios U
        INNER JOIN dbo.Roles R ON R.RolId = U.RolId
        WHERE (@RolId IS NULL OR U.RolId = @RolId)
          AND (@Activo IS NULL OR U.Activo = @Activo)
          AND
          (
              @TextoBusqueda IS NULL
              OR U.NombreUsuario LIKE N'%' + @TextoBusqueda + N'%'
              OR U.Nombres LIKE N'%' + @TextoBusqueda + N'%'
              OR U.Apellidos LIKE N'%' + @TextoBusqueda + N'%'
          )
        ORDER BY U.Nombres, U.Apellidos;
    END

    -- Opción 3: consultar un usuario por su identificador
    ELSE IF @Opcion = 3
    BEGIN
        SELECT
            U.UsuarioId,
            U.RolId,
            U.NombreUsuario,
            U.Nombres,
            U.Apellidos,
            U.Correo,
            U.Telefono,
            U.Activo,
            U.DebeCambiarContrasena,
            U.FechaUltimoAcceso,
            U.FechaCreacion,
            U.FechaActualizacion,
            R.Codigo AS CodigoRol,
            R.Nombre AS NombreRol
        FROM dbo.Usuarios U
        INNER JOIN dbo.Roles R ON R.RolId = U.RolId
        WHERE U.UsuarioId = @UsuarioId;
    END

    -- Opción 4: consultar los subordinados activos de un usuario
    ELSE IF @Opcion = 4
    BEGIN
        SELECT
            A.AsignacionJerarquiaId,
            A.UsuarioSuperiorId,
            A.UsuarioSubordinadoId,
            U.NombreUsuario,
            U.Nombres,
            U.Apellidos,
            U.Correo,
            U.Telefono,
            U.Activo,
            R.RolId,
            R.Codigo AS CodigoRol,
            R.Nombre AS NombreRol,
            A.FechaInicio
        FROM dbo.AsignacionesJerarquia A
        INNER JOIN dbo.Usuarios U ON U.UsuarioId = A.UsuarioSubordinadoId
        INNER JOIN dbo.Roles R ON R.RolId = U.RolId
        WHERE A.UsuarioSuperiorId = @UsuarioSuperiorId
          AND A.FechaFin IS NULL
        ORDER BY U.Nombres, U.Apellidos;
    END

    -- Opción 5: listar los roles disponibles
    ELSE IF @Opcion = 5
    BEGIN
        SELECT
            RolId,
            Codigo,
            Nombre,
            Descripcion
        FROM dbo.Roles
        WHERE Activo = 1
        ORDER BY RolId;
    END

    -- Opción 6: listar especies
    ELSE IF @Opcion = 6
    BEGIN
        SELECT
            EspecieId,
            Nombre,
            Descripcion,
            Activo
        FROM dbo.Especies
        WHERE (@Activo IS NULL OR Activo = @Activo)
          AND (@TextoBusqueda IS NULL OR Nombre LIKE N'%' + @TextoBusqueda + N'%')
        ORDER BY Nombre;
    END

    -- Opción 7: listar razas de una especie
    ELSE IF @Opcion = 7
    BEGIN
        SELECT
            R.RazaId,
            R.EspecieId,
            E.Nombre AS NombreEspecie,
            R.Nombre,
            R.Descripcion,
            R.Activo
        FROM dbo.Razas R
        INNER JOIN dbo.Especies E ON E.EspecieId = R.EspecieId
        WHERE (@EspecieId IS NULL OR R.EspecieId = @EspecieId)
          AND (@Activo IS NULL OR R.Activo = @Activo)
          AND (@TextoBusqueda IS NULL OR R.Nombre LIKE N'%' + @TextoBusqueda + N'%')
        ORDER BY E.Nombre, R.Nombre;
    END

    -- Opción 8: listar servicios
    ELSE IF @Opcion = 8
    BEGIN
        SELECT
            ServicioId,
            Codigo,
            Nombre,
            Descripcion,
            Precio,
            DuracionEstimadaMinutos,
            Activo
        FROM dbo.Servicios
        WHERE (@ServicioId IS NULL OR ServicioId = @ServicioId)
          AND (@Activo IS NULL OR Activo = @Activo)
          AND
          (
              @TextoBusqueda IS NULL
              OR Codigo LIKE N'%' + @TextoBusqueda + N'%'
              OR Nombre LIKE N'%' + @TextoBusqueda + N'%'
          )
        ORDER BY Nombre;
    END

    -- Opción 9: listar zonas
    ELSE IF @Opcion = 9
    BEGIN
        SELECT
            ZonaId,
            Codigo,
            Nombre,
            Descripcion,
            Activo
        FROM dbo.Zonas
        WHERE (@ZonaId IS NULL OR ZonaId = @ZonaId)
          AND (@Activo IS NULL OR Activo = @Activo)
          AND
          (
              @TextoBusqueda IS NULL
              OR Codigo LIKE N'%' + @TextoBusqueda + N'%'
              OR Nombre LIKE N'%' + @TextoBusqueda + N'%'
          )
        ORDER BY Nombre;
    END

    -- Opción 10: listar propietarios con filtros opcionales
    ELSE IF @Opcion = 10
    BEGIN
        SELECT
            P.PropietarioId,
            P.ZonaId,
            Z.Nombre AS NombreZona,
            P.Nombres,
            P.Apellidos,
            P.Telefono,
            P.TelefonoAlternativo,
            P.Direccion,
            P.Latitud,
            P.Longitud,
            P.Activo,
            P.FechaCreacion
        FROM dbo.Propietarios P
        LEFT JOIN dbo.Zonas Z ON Z.ZonaId = P.ZonaId
        WHERE (@ZonaId IS NULL OR P.ZonaId = @ZonaId)
          AND (@Activo IS NULL OR P.Activo = @Activo)
          AND
          (
              @TextoBusqueda IS NULL
              OR P.Nombres LIKE N'%' + @TextoBusqueda + N'%'
              OR P.Apellidos LIKE N'%' + @TextoBusqueda + N'%'
              OR P.Telefono LIKE N'%' + @TextoBusqueda + N'%'
              OR P.TelefonoAlternativo LIKE N'%' + @TextoBusqueda + N'%'
          )
        ORDER BY P.Nombres, P.Apellidos;
    END

    -- Opción 11: consultar un propietario por su identificador
    ELSE IF @Opcion = 11
    BEGIN
        SELECT
            P.PropietarioId,
            P.ZonaId,
            Z.Nombre AS NombreZona,
            P.Nombres,
            P.Apellidos,
            P.Telefono,
            P.TelefonoAlternativo,
            P.Direccion,
            P.Latitud,
            P.Longitud,
            P.Activo,
            P.FechaCreacion,
            P.FechaActualizacion
        FROM dbo.Propietarios P
        LEFT JOIN dbo.Zonas Z ON Z.ZonaId = P.ZonaId
        WHERE P.PropietarioId = @PropietarioId;
    END

    -- Opción 12: listar pacientes con filtros opcionales
    ELSE IF @Opcion = 12
    BEGIN
        SELECT
            P.PacienteId,
            P.Nombre,
            P.FechaNacimientoAproximada,
            P.RutaFoto,
            P.Activo,
            P.PropietarioId,
            CONCAT(PR.Nombres, N' ', PR.Apellidos) AS NombrePropietario,
            PR.Telefono AS TelefonoPropietario,
            P.EspecieId,
            E.Nombre AS NombreEspecie,
            P.RazaId,
            R.Nombre AS NombreRaza,
            P.FechaCreacion
        FROM dbo.Pacientes P
        INNER JOIN dbo.Propietarios PR ON PR.PropietarioId = P.PropietarioId
        INNER JOIN dbo.Especies E ON E.EspecieId = P.EspecieId
        INNER JOIN dbo.Razas R ON R.RazaId = P.RazaId
        WHERE (@PropietarioId IS NULL OR P.PropietarioId = @PropietarioId)
          AND (@EspecieId IS NULL OR P.EspecieId = @EspecieId)
          AND (@Activo IS NULL OR P.Activo = @Activo)
          AND
          (
              @TextoBusqueda IS NULL
              OR P.Nombre LIKE N'%' + @TextoBusqueda + N'%'
              OR PR.Nombres LIKE N'%' + @TextoBusqueda + N'%'
              OR PR.Apellidos LIKE N'%' + @TextoBusqueda + N'%'
          )
        ORDER BY P.Nombre;
    END

    -- Opción 13: consultar el detalle de un paciente
    ELSE IF @Opcion = 13
    BEGIN
        SELECT
            P.PacienteId,
            P.PropietarioId,
            CONCAT(PR.Nombres, N' ', PR.Apellidos) AS NombrePropietario,
            PR.Telefono AS TelefonoPropietario,
            PR.TelefonoAlternativo,
            PR.Direccion,
            PR.Latitud,
            PR.Longitud,
            PR.ZonaId,
            Z.Nombre AS NombreZona,
            P.EspecieId,
            E.Nombre AS NombreEspecie,
            P.RazaId,
            R.Nombre AS NombreRaza,
            P.Nombre,
            P.FechaNacimientoAproximada,
            P.RutaFoto,
            P.Observaciones,
            P.CreadoPorUsuarioId,
            P.Activo,
            P.FechaCreacion,
            P.FechaActualizacion
        FROM dbo.Pacientes P
        INNER JOIN dbo.Propietarios PR ON PR.PropietarioId = P.PropietarioId
        INNER JOIN dbo.Especies E ON E.EspecieId = P.EspecieId
        INNER JOIN dbo.Razas R ON R.RazaId = P.RazaId
        LEFT JOIN dbo.Zonas Z ON Z.ZonaId = PR.ZonaId
        WHERE P.PacienteId = @PacienteId;
    END

    -- Opción 14: consultar la asignación activa de un paciente
    ELSE IF @Opcion = 14
    BEGIN
        SELECT
            A.AsignacionPacienteId,
            A.PacienteId,
            P.Nombre AS NombrePaciente,
            A.TecnicoUsuarioId,
            CONCAT(T.Nombres, N' ', T.Apellidos) AS NombreTecnico,
            T.Telefono AS TelefonoTecnico,
            A.AsignadoPorUsuarioId,
            CONCAT(U.Nombres, N' ', U.Apellidos) AS AsignadoPor,
            A.FechaInicio,
            A.Observacion,
            A.FechaCreacion
        FROM dbo.AsignacionesPacientes A
        INNER JOIN dbo.Pacientes P ON P.PacienteId = A.PacienteId
        INNER JOIN dbo.Usuarios T ON T.UsuarioId = A.TecnicoUsuarioId
        INNER JOIN dbo.Usuarios U ON U.UsuarioId = A.AsignadoPorUsuarioId
        WHERE A.PacienteId = @PacienteId
          AND A.FechaFin IS NULL
        ORDER BY A.FechaInicio DESC;
    END

    -- Opción 15: listar los pacientes asignados a un técnico
    ELSE IF @Opcion = 15
    BEGIN
        SELECT
            A.AsignacionPacienteId,
            A.TecnicoUsuarioId,
            A.FechaInicio,
            A.Observacion,
            P.PacienteId,
            P.Nombre AS NombrePaciente,
            P.RutaFoto,
            P.Activo,
            E.EspecieId,
            E.Nombre AS NombreEspecie,
            R.RazaId,
            R.Nombre AS NombreRaza,
            PR.PropietarioId,
            CONCAT(PR.Nombres, N' ', PR.Apellidos) AS NombrePropietario,
            PR.Telefono AS TelefonoPropietario,
            PR.Direccion,
            PR.Latitud,
            PR.Longitud
        FROM dbo.AsignacionesPacientes A
        INNER JOIN dbo.Pacientes P ON P.PacienteId = A.PacienteId
        INNER JOIN dbo.Propietarios PR ON PR.PropietarioId = P.PropietarioId
        INNER JOIN dbo.Especies E ON E.EspecieId = P.EspecieId
        INNER JOIN dbo.Razas R ON R.RazaId = P.RazaId
        WHERE A.TecnicoUsuarioId = @TecnicoUsuarioId
          AND A.FechaFin IS NULL
          AND (@Activo IS NULL OR P.Activo = @Activo)
          AND
          (
              @TextoBusqueda IS NULL
              OR P.Nombre LIKE N'%' + @TextoBusqueda + N'%'
              OR PR.Nombres LIKE N'%' + @TextoBusqueda + N'%'
              OR PR.Apellidos LIKE N'%' + @TextoBusqueda + N'%'
          )
        ORDER BY P.Nombre;
    END

    -- Opción 16: consultar la agenda de visitas
    ELSE IF @Opcion = 16
    BEGIN
        SELECT
            V.VisitaId,
            V.FechaProgramada,
            CASE
                WHEN RV.RegistroVisitaId IS NULL THEN N'PROGRAMADA'
                ELSE N'COMPLETADA'
            END AS Estado,
            V.PacienteId,
            P.Nombre AS NombrePaciente,
            E.Nombre AS NombreEspecie,
            R.Nombre AS NombreRaza,
            PR.PropietarioId,
            CONCAT(PR.Nombres, N' ', PR.Apellidos) AS NombrePropietario,
            PR.Telefono AS TelefonoPropietario,
            PR.Direccion,
            PR.Latitud,
            PR.Longitud,
            V.ServicioId,
            S.Nombre AS NombreServicio,
            V.PrecioProgramado,
            V.MedicoResponsableUsuarioId,
            CONCAT(M.Nombres, N' ', M.Apellidos) AS NombreMedico,
            V.TecnicoUsuarioId,
            CONCAT(T.Nombres, N' ', T.Apellidos) AS NombreTecnico
        FROM dbo.Visitas V
        INNER JOIN dbo.Pacientes P ON P.PacienteId = V.PacienteId
        INNER JOIN dbo.Propietarios PR ON PR.PropietarioId = P.PropietarioId
        INNER JOIN dbo.Especies E ON E.EspecieId = P.EspecieId
        INNER JOIN dbo.Razas R ON R.RazaId = P.RazaId
        INNER JOIN dbo.Servicios S ON S.ServicioId = V.ServicioId
        INNER JOIN dbo.Usuarios M ON M.UsuarioId = V.MedicoResponsableUsuarioId
        INNER JOIN dbo.Usuarios T ON T.UsuarioId = V.TecnicoUsuarioId
        LEFT JOIN dbo.RegistrosVisitas RV ON RV.VisitaId = V.VisitaId
        WHERE (@PacienteId IS NULL OR V.PacienteId = @PacienteId)
          AND (@ServicioId IS NULL OR V.ServicioId = @ServicioId)
          AND (@MedicoResponsableUsuarioId IS NULL OR V.MedicoResponsableUsuarioId = @MedicoResponsableUsuarioId)
          AND (@TecnicoUsuarioId IS NULL OR V.TecnicoUsuarioId = @TecnicoUsuarioId)
          AND (@FechaDesde IS NULL OR V.FechaProgramada >= @FechaDesde)
          AND (@FechaHasta IS NULL OR V.FechaProgramada < DATEADD(DAY, 1, @FechaHasta))
          AND
          (
              @TextoBusqueda IS NULL
              OR P.Nombre LIKE N'%' + @TextoBusqueda + N'%'
              OR PR.Nombres LIKE N'%' + @TextoBusqueda + N'%'
              OR PR.Apellidos LIKE N'%' + @TextoBusqueda + N'%'
          )
        ORDER BY V.FechaProgramada;
    END

    -- Opción 17: consultar el detalle de una visita
    ELSE IF @Opcion = 17
    BEGIN
        SELECT
            V.VisitaId,
            V.FechaProgramada,
            CASE
                WHEN RV.RegistroVisitaId IS NULL THEN N'PROGRAMADA'
                ELSE N'COMPLETADA'
            END AS Estado,
            V.PacienteId,
            P.Nombre AS NombrePaciente,
            P.RutaFoto,
            P.FechaNacimientoAproximada,
            P.Observaciones AS ObservacionesPaciente,
            E.EspecieId,
            E.Nombre AS NombreEspecie,
            R.RazaId,
            R.Nombre AS NombreRaza,
            PR.PropietarioId,
            CONCAT(PR.Nombres, N' ', PR.Apellidos) AS NombrePropietario,
            PR.Telefono AS TelefonoPropietario,
            PR.TelefonoAlternativo,
            PR.Direccion,
            PR.Latitud AS LatitudPropietario,
            PR.Longitud AS LongitudPropietario,
            V.ServicioId,
            S.Nombre AS NombreServicio,
            V.PrecioProgramado,
            V.ObservacionesProgramacion,
            V.MedicoResponsableUsuarioId,
            CONCAT(M.Nombres, N' ', M.Apellidos) AS NombreMedico,
            V.TecnicoUsuarioId,
            CONCAT(T.Nombres, N' ', T.Apellidos) AS NombreTecnico,
            V.ProgramadaPorUsuarioId,
            CONCAT(U.Nombres, N' ', U.Apellidos) AS ProgramadaPor,
            V.FechaCreacion,
            RV.RegistroVisitaId,
            RV.PesoKg,
            RV.AlturaCm,
            RV.TemperaturaCelsius,
            RV.CondicionCorporal,
            RV.Observaciones AS ObservacionesAtencion,
            RV.Latitud AS LatitudAtencion,
            RV.Longitud AS LongitudAtencion,
            RV.RegistradoPorUsuarioId,
            RV.FechaRegistro
        FROM dbo.Visitas V
        INNER JOIN dbo.Pacientes P ON P.PacienteId = V.PacienteId
        INNER JOIN dbo.Propietarios PR ON PR.PropietarioId = P.PropietarioId
        INNER JOIN dbo.Especies E ON E.EspecieId = P.EspecieId
        INNER JOIN dbo.Razas R ON R.RazaId = P.RazaId
        INNER JOIN dbo.Servicios S ON S.ServicioId = V.ServicioId
        INNER JOIN dbo.Usuarios M ON M.UsuarioId = V.MedicoResponsableUsuarioId
        INNER JOIN dbo.Usuarios T ON T.UsuarioId = V.TecnicoUsuarioId
        INNER JOIN dbo.Usuarios U ON U.UsuarioId = V.ProgramadaPorUsuarioId
        LEFT JOIN dbo.RegistrosVisitas RV ON RV.VisitaId = V.VisitaId
        WHERE V.VisitaId = @VisitaId;
    END

    -- Opción 18: consultar el historial clínico de un paciente
    ELSE IF @Opcion = 18
    BEGIN
        SELECT
            RV.RegistroVisitaId,
            V.VisitaId,
            V.PacienteId,
            P.Nombre AS NombrePaciente,
            V.FechaProgramada,
            RV.FechaRegistro,
            V.ServicioId,
            S.Nombre AS NombreServicio,
            V.PrecioProgramado,
            V.MedicoResponsableUsuarioId,
            CONCAT(M.Nombres, N' ', M.Apellidos) AS NombreMedico,
            V.TecnicoUsuarioId,
            CONCAT(T.Nombres, N' ', T.Apellidos) AS NombreTecnico,
            RV.PesoKg,
            RV.AlturaCm,
            RV.TemperaturaCelsius,
            RV.CondicionCorporal,
            RV.Observaciones,
            RV.Latitud,
            RV.Longitud,
            RV.RegistradoPorUsuarioId,
            CONCAT(U.Nombres, N' ', U.Apellidos) AS RegistradoPor,
            (SELECT COUNT(1)
             FROM dbo.EvidenciasVisitas EV
             WHERE EV.RegistroVisitaId = RV.RegistroVisitaId) AS CantidadEvidencias
        FROM dbo.RegistrosVisitas RV
        INNER JOIN dbo.Visitas V ON V.VisitaId = RV.VisitaId
        INNER JOIN dbo.Pacientes P ON P.PacienteId = V.PacienteId
        INNER JOIN dbo.Servicios S ON S.ServicioId = V.ServicioId
        INNER JOIN dbo.Usuarios M ON M.UsuarioId = V.MedicoResponsableUsuarioId
        INNER JOIN dbo.Usuarios T ON T.UsuarioId = V.TecnicoUsuarioId
        INNER JOIN dbo.Usuarios U ON U.UsuarioId = RV.RegistradoPorUsuarioId
        WHERE V.PacienteId = @PacienteId
          AND (@FechaDesde IS NULL OR RV.FechaRegistro >= @FechaDesde)
          AND (@FechaHasta IS NULL OR RV.FechaRegistro < DATEADD(DAY, 1, @FechaHasta))
        ORDER BY RV.FechaRegistro DESC;
    END

    -- Opción 19: consultar las evidencias de una visita completada
    ELSE IF @Opcion = 19
    BEGIN
        SELECT
            EV.EvidenciaVisitaId,
            EV.RegistroVisitaId,
            RV.VisitaId,
            EV.NombreArchivo,
            EV.RutaArchivo,
            EV.TipoContenido,
            EV.FechaCaptura,
            EV.FechaCreacion
        FROM dbo.EvidenciasVisitas EV
        INNER JOIN dbo.RegistrosVisitas RV ON RV.RegistroVisitaId = EV.RegistroVisitaId
        WHERE
        (
            @RegistroVisitaId IS NOT NULL
            AND EV.RegistroVisitaId = @RegistroVisitaId
        )
        OR
        (
            @RegistroVisitaId IS NULL
            AND @VisitaId IS NOT NULL
            AND RV.VisitaId = @VisitaId
        )
        ORDER BY EV.FechaCreacion;
    END

    -- Opción 20: consultar el resumen general del panel principal
    ELSE IF @Opcion = 20
    BEGIN
        SELECT
            (SELECT COUNT(1)
             FROM dbo.Propietarios
             WHERE Activo = 1) AS PropietariosActivos,
            (SELECT COUNT(1)
             FROM dbo.Pacientes
             WHERE Activo = 1) AS PacientesActivos,
            (SELECT COUNT(1)
             FROM dbo.Visitas V
             LEFT JOIN dbo.RegistrosVisitas RV ON RV.VisitaId = V.VisitaId
             WHERE RV.RegistroVisitaId IS NULL
               AND (@FechaDesde IS NULL OR V.FechaProgramada >= @FechaDesde)
               AND (@FechaHasta IS NULL OR V.FechaProgramada < DATEADD(DAY, 1, @FechaHasta))) AS VisitasProgramadas,
            (SELECT COUNT(1)
             FROM dbo.Visitas V
             INNER JOIN dbo.RegistrosVisitas RV ON RV.VisitaId = V.VisitaId
             WHERE (@FechaDesde IS NULL OR V.FechaProgramada >= @FechaDesde)
               AND (@FechaHasta IS NULL OR V.FechaProgramada < DATEADD(DAY, 1, @FechaHasta))) AS VisitasCompletadas,
            (SELECT COUNT(1)
             FROM dbo.Visitas V
             WHERE V.FechaProgramada >= CONVERT(DATE, GETDATE())
               AND V.FechaProgramada < DATEADD(DAY, 1, CONVERT(DATE, GETDATE()))) AS VisitasDeHoy;
    END

    -- Opción 21: consultar las visitas agrupadas por servicio
    ELSE IF @Opcion = 21
    BEGIN
        SELECT
            S.ServicioId,
            S.Codigo,
            S.Nombre AS NombreServicio,
            COUNT(V.VisitaId) AS CantidadVisitas,
            SUM(CASE WHEN RV.RegistroVisitaId IS NOT NULL THEN 1 ELSE 0 END) AS Completadas,
            SUM(CASE WHEN V.VisitaId IS NOT NULL AND RV.RegistroVisitaId IS NULL THEN 1 ELSE 0 END) AS Programadas,
            ISNULL(SUM(V.PrecioProgramado), 0) AS TotalProgramado
        FROM dbo.Servicios S
        LEFT JOIN dbo.Visitas V
            ON V.ServicioId = S.ServicioId
           AND (@FechaDesde IS NULL OR V.FechaProgramada >= @FechaDesde)
           AND (@FechaHasta IS NULL OR V.FechaProgramada < DATEADD(DAY, 1, @FechaHasta))
        LEFT JOIN dbo.RegistrosVisitas RV ON RV.VisitaId = V.VisitaId
        WHERE S.Activo = 1
        GROUP BY S.ServicioId, S.Codigo, S.Nombre
        ORDER BY S.Nombre;
    END

    -- Opción 22: consultar las visitas agrupadas por fecha
    ELSE IF @Opcion = 22
    BEGIN
        SELECT
            CONVERT(DATE, V.FechaProgramada) AS Fecha,
            COUNT(1) AS CantidadVisitas,
            SUM(CASE WHEN RV.RegistroVisitaId IS NOT NULL THEN 1 ELSE 0 END) AS Completadas,
            SUM(CASE WHEN RV.RegistroVisitaId IS NULL THEN 1 ELSE 0 END) AS Programadas,
            SUM(V.PrecioProgramado) AS TotalProgramado
        FROM dbo.Visitas V
        LEFT JOIN dbo.RegistrosVisitas RV ON RV.VisitaId = V.VisitaId
        WHERE (@FechaDesde IS NULL OR V.FechaProgramada >= @FechaDesde)
          AND (@FechaHasta IS NULL OR V.FechaProgramada < DATEADD(DAY, 1, @FechaHasta))
        GROUP BY CONVERT(DATE, V.FechaProgramada)
        ORDER BY Fecha;
    END

    -- Opción 23: consultar la bitácora de auditoría
    ELSE IF @Opcion = 23
    BEGIN
        SELECT
            B.BitacoraAuditoriaId,
            B.UsuarioId,
            CONCAT(U.Nombres, N' ', U.Apellidos) AS NombreUsuario,
            B.Accion,
            B.Entidad,
            B.EntidadId,
            B.Detalle,
            B.DireccionIp,
            B.FechaCreacion
        FROM dbo.BitacoraAuditoria B
        LEFT JOIN dbo.Usuarios U ON U.UsuarioId = B.UsuarioId
        WHERE (@UsuarioId IS NULL OR B.UsuarioId = @UsuarioId)
          AND (@Accion IS NULL OR B.Accion = @Accion)
          AND (@Entidad IS NULL OR B.Entidad = @Entidad)
          AND (@FechaDesde IS NULL OR B.FechaCreacion >= @FechaDesde)
          AND (@FechaHasta IS NULL OR B.FechaCreacion < DATEADD(DAY, 1, @FechaHasta))
          AND
          (
              @TextoBusqueda IS NULL
              OR B.EntidadId LIKE N'%' + @TextoBusqueda + N'%'
              OR B.Detalle LIKE N'%' + @TextoBusqueda + N'%'
          )
        ORDER BY B.FechaCreacion DESC;
    END

    -- Opción 24: consultar un token de actualización válido
    ELSE IF @Opcion = 24
    BEGIN
        SELECT
            T.TokenActualizacionId,
            T.UsuarioId,
            T.TokenHash,
            T.FechaExpiracion,
            T.Dispositivo,
            T.DireccionIp,
            T.FechaCreacion,
            U.NombreUsuario,
            U.Nombres,
            U.Apellidos,
            U.RolId
        FROM dbo.TokensActualizacion T
        INNER JOIN dbo.Usuarios U ON U.UsuarioId = T.UsuarioId
        WHERE T.TokenHash = @TokenHash
          AND T.FechaRevocacion IS NULL
          AND T.FechaExpiracion > GETDATE()
          AND U.Activo = 1;
    END

    -- Opción 25: consultar las mascotas atendidas agrupadas por especie
    ELSE IF @Opcion = 25
    BEGIN
        SELECT
            E.EspecieId,
            E.Nombre AS NombreEspecie,
            COUNT(DISTINCT V.PacienteId) AS CantidadMascotas
        FROM dbo.Especies E
        INNER JOIN dbo.Pacientes P ON P.EspecieId = E.EspecieId
        INNER JOIN dbo.Visitas V ON V.PacienteId = P.PacienteId
        INNER JOIN dbo.RegistrosVisitas RV ON RV.VisitaId = V.VisitaId
        WHERE (@FechaDesde IS NULL OR V.FechaProgramada >= @FechaDesde)
          AND (@FechaHasta IS NULL OR V.FechaProgramada < DATEADD(DAY, 1, @FechaHasta))
        GROUP BY E.EspecieId, E.Nombre
        ORDER BY E.Nombre;
    END

    -- Opción 26: consultar las visitas agrupadas por técnico
    ELSE IF @Opcion = 26
    BEGIN
        SELECT
            U.UsuarioId AS TecnicoUsuarioId,
            LTRIM(RTRIM(CONCAT(U.Nombres, ' ', U.Apellidos))) AS NombreTecnico,
            COUNT(V.VisitaId) AS CantidadVisitas,
            SUM(CASE WHEN RV.RegistroVisitaId IS NOT NULL THEN 1 ELSE 0 END) AS Completadas,
            SUM(CASE WHEN RV.RegistroVisitaId IS NULL THEN 1 ELSE 0 END) AS Programadas
        FROM dbo.Visitas V
        INNER JOIN dbo.Usuarios U ON U.UsuarioId = V.TecnicoUsuarioId
        LEFT JOIN dbo.RegistrosVisitas RV ON RV.VisitaId = V.VisitaId
        WHERE (@FechaDesde IS NULL OR V.FechaProgramada >= @FechaDesde)
          AND (@FechaHasta IS NULL OR V.FechaProgramada < DATEADD(DAY, 1, @FechaHasta))
        GROUP BY U.UsuarioId, U.Nombres, U.Apellidos
        ORDER BY CantidadVisitas DESC, NombreTecnico;
    END

    ELSE
    BEGIN
        THROW 50001, N'La opción indicada no existe en SP_VetRuta_Consultas.', 1;
    END
END;
GO

