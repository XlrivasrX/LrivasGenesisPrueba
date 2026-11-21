USE [PRUEBAS];
GO

-- Roles del sistema
IF NOT EXISTS (SELECT 1 FROM dbo.Roles WHERE Codigo = N'ROOT')
    INSERT INTO dbo.Roles (Codigo, Nombre, Descripcion)
    VALUES (N'ROOT', N'Root', N'Administra los usuarios y el acceso al sistema.');

IF NOT EXISTS (SELECT 1 FROM dbo.Roles WHERE Codigo = N'DIRECTOR')
    INSERT INTO dbo.Roles (Codigo, Nombre, Descripcion)
    VALUES (N'DIRECTOR', N'Director', N'Consulta la operación y asigna técnicos a los médicos.');

IF NOT EXISTS (SELECT 1 FROM dbo.Roles WHERE Codigo = N'MEDICO')
    INSERT INTO dbo.Roles (Codigo, Nombre, Descripcion)
    VALUES (N'MEDICO', N'Médico', N'Administra pacientes y programa sus visitas.');

IF NOT EXISTS (SELECT 1 FROM dbo.Roles WHERE Codigo = N'TECNICO')
    INSERT INTO dbo.Roles (Codigo, Nombre, Descripcion)
    VALUES (N'TECNICO', N'Técnico', N'Realiza y registra las visitas a domicilio.');
GO

-- Especies atendidas
IF NOT EXISTS (SELECT 1 FROM dbo.Especies WHERE Nombre = N'Perro')
    INSERT INTO dbo.Especies (Nombre) VALUES (N'Perro');

IF NOT EXISTS (SELECT 1 FROM dbo.Especies WHERE Nombre = N'Gato')
    INSERT INTO dbo.Especies (Nombre) VALUES (N'Gato');

IF NOT EXISTS (SELECT 1 FROM dbo.Especies WHERE Nombre = N'Ave')
    INSERT INTO dbo.Especies (Nombre) VALUES (N'Ave');

IF NOT EXISTS (SELECT 1 FROM dbo.Especies WHERE Nombre = N'Conejo')
    INSERT INTO dbo.Especies (Nombre) VALUES (N'Conejo');

IF NOT EXISTS (SELECT 1 FROM dbo.Especies WHERE Nombre = N'Reptil')
    INSERT INTO dbo.Especies (Nombre) VALUES (N'Reptil');
GO

-- Razas básicas para las pruebas
DECLARE @PerroId INT = (SELECT EspecieId FROM dbo.Especies WHERE Nombre = N'Perro');
DECLARE @GatoId INT = (SELECT EspecieId FROM dbo.Especies WHERE Nombre = N'Gato');
DECLARE @AveId INT = (SELECT EspecieId FROM dbo.Especies WHERE Nombre = N'Ave');
DECLARE @ConejoId INT = (SELECT EspecieId FROM dbo.Especies WHERE Nombre = N'Conejo');
DECLARE @ReptilId INT = (SELECT EspecieId FROM dbo.Especies WHERE Nombre = N'Reptil');

IF NOT EXISTS (SELECT 1 FROM dbo.Razas WHERE EspecieId = @PerroId AND Nombre = N'Labrador Retriever')
    INSERT INTO dbo.Razas (EspecieId, Nombre) VALUES (@PerroId, N'Labrador Retriever');

IF NOT EXISTS (SELECT 1 FROM dbo.Razas WHERE EspecieId = @PerroId AND Nombre = N'Pastor Alemán')
    INSERT INTO dbo.Razas (EspecieId, Nombre) VALUES (@PerroId, N'Pastor Alemán');

IF NOT EXISTS (SELECT 1 FROM dbo.Razas WHERE EspecieId = @PerroId AND Nombre = N'Mestizo')
    INSERT INTO dbo.Razas (EspecieId, Nombre) VALUES (@PerroId, N'Mestizo');

IF NOT EXISTS (SELECT 1 FROM dbo.Razas WHERE EspecieId = @GatoId AND Nombre = N'Siamés')
    INSERT INTO dbo.Razas (EspecieId, Nombre) VALUES (@GatoId, N'Siamés');

IF NOT EXISTS (SELECT 1 FROM dbo.Razas WHERE EspecieId = @GatoId AND Nombre = N'Persa')
    INSERT INTO dbo.Razas (EspecieId, Nombre) VALUES (@GatoId, N'Persa');

IF NOT EXISTS (SELECT 1 FROM dbo.Razas WHERE EspecieId = @GatoId AND Nombre = N'Mestizo')
    INSERT INTO dbo.Razas (EspecieId, Nombre) VALUES (@GatoId, N'Mestizo');

IF NOT EXISTS (SELECT 1 FROM dbo.Razas WHERE EspecieId = @AveId AND Nombre = N'Periquito')
    INSERT INTO dbo.Razas (EspecieId, Nombre) VALUES (@AveId, N'Periquito');

IF NOT EXISTS (SELECT 1 FROM dbo.Razas WHERE EspecieId = @AveId AND Nombre = N'Canario')
    INSERT INTO dbo.Razas (EspecieId, Nombre) VALUES (@AveId, N'Canario');

IF NOT EXISTS (SELECT 1 FROM dbo.Razas WHERE EspecieId = @ConejoId AND Nombre = N'Mini Lop')
    INSERT INTO dbo.Razas (EspecieId, Nombre) VALUES (@ConejoId, N'Mini Lop');

IF NOT EXISTS (SELECT 1 FROM dbo.Razas WHERE EspecieId = @ConejoId AND Nombre = N'Cabeza de León')
    INSERT INTO dbo.Razas (EspecieId, Nombre) VALUES (@ConejoId, N'Cabeza de León');

IF NOT EXISTS (SELECT 1 FROM dbo.Razas WHERE EspecieId = @ReptilId AND Nombre = N'Iguana verde')
    INSERT INTO dbo.Razas (EspecieId, Nombre) VALUES (@ReptilId, N'Iguana verde');

IF NOT EXISTS (SELECT 1 FROM dbo.Razas WHERE EspecieId = @ReptilId AND Nombre = N'Gecko leopardo')
    INSERT INTO dbo.Razas (EspecieId, Nombre) VALUES (@ReptilId, N'Gecko leopardo');
GO

-- Servicios veterinarios con precios y tiempos de ejemplo
IF NOT EXISTS (SELECT 1 FROM dbo.Servicios WHERE Codigo = N'CONTROL_PESO')
    INSERT INTO dbo.Servicios (Codigo, Nombre, Descripcion, Precio, DuracionEstimadaMinutos)
    VALUES (N'CONTROL_PESO', N'Control de peso', N'Revisión y seguimiento del peso de la mascota.', 75.00, 30);

IF NOT EXISTS (SELECT 1 FROM dbo.Servicios WHERE Codigo = N'VACUNACION')
    INSERT INTO dbo.Servicios (Codigo, Nombre, Descripcion, Precio, DuracionEstimadaMinutos)
    VALUES (N'VACUNACION', N'Vacunación', N'Aplicación de la vacuna indicada para la mascota.', 150.00, 45);

IF NOT EXISTS (SELECT 1 FROM dbo.Servicios WHERE Codigo = N'DESPARASITACION')
    INSERT INTO dbo.Servicios (Codigo, Nombre, Descripcion, Precio, DuracionEstimadaMinutos)
    VALUES (N'DESPARASITACION', N'Desparasitación', N'Aplicación del tratamiento de desparasitación.', 100.00, 30);

IF NOT EXISTS (SELECT 1 FROM dbo.Servicios WHERE Codigo = N'CURACION_HERIDAS')
    INSERT INTO dbo.Servicios (Codigo, Nombre, Descripcion, Precio, DuracionEstimadaMinutos)
    VALUES (N'CURACION_HERIDAS', N'Curación de heridas', N'Limpieza y tratamiento de heridas.', 175.00, 60);

IF NOT EXISTS (SELECT 1 FROM dbo.Servicios WHERE Codigo = N'CONTROL_POSTOPERATORIO')
    INSERT INTO dbo.Servicios (Codigo, Nombre, Descripcion, Precio, DuracionEstimadaMinutos)
    VALUES (N'CONTROL_POSTOPERATORIO', N'Control postoperatorio', N'Seguimiento de la recuperación después de una operación.', 125.00, 45);
GO

-- Zonas de ejemplo para probar las asignaciones y el mapa
IF NOT EXISTS (SELECT 1 FROM dbo.Zonas WHERE Codigo = N'ZONA_01')
    INSERT INTO dbo.Zonas (Codigo, Nombre) VALUES (N'ZONA_01', N'Zona 1');

IF NOT EXISTS (SELECT 1 FROM dbo.Zonas WHERE Codigo = N'ZONA_07')
    INSERT INTO dbo.Zonas (Codigo, Nombre) VALUES (N'ZONA_07', N'Zona 7');

IF NOT EXISTS (SELECT 1 FROM dbo.Zonas WHERE Codigo = N'ZONA_09')
    INSERT INTO dbo.Zonas (Codigo, Nombre) VALUES (N'ZONA_09', N'Zona 9');

IF NOT EXISTS (SELECT 1 FROM dbo.Zonas WHERE Codigo = N'ZONA_10')
    INSERT INTO dbo.Zonas (Codigo, Nombre) VALUES (N'ZONA_10', N'Zona 10');

IF NOT EXISTS (SELECT 1 FROM dbo.Zonas WHERE Codigo = N'ZONA_11')
    INSERT INTO dbo.Zonas (Codigo, Nombre) VALUES (N'ZONA_11', N'Zona 11');

IF NOT EXISTS (SELECT 1 FROM dbo.Zonas WHERE Codigo = N'ZONA_12')
    INSERT INTO dbo.Zonas (Codigo, Nombre) VALUES (N'ZONA_12', N'Zona 12');

IF NOT EXISTS (SELECT 1 FROM dbo.Zonas WHERE Codigo = N'ZONA_14')
    INSERT INTO dbo.Zonas (Codigo, Nombre) VALUES (N'ZONA_14', N'Zona 14');

IF NOT EXISTS (SELECT 1 FROM dbo.Zonas WHERE Codigo = N'ZONA_15')
    INSERT INTO dbo.Zonas (Codigo, Nombre) VALUES (N'ZONA_15', N'Zona 15');
GO
