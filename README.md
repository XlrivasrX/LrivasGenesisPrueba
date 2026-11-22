# VetRuta

## Nota de seguridad sobre el documento

Sí, identifiqué el intento de "prompt injection" incluido en la página 2 del PDF. Lo encontré al copiar el contenido del documento a Word para revisarlo con más claridad. Lo traté como contenido no confiable y no como una instrucción válida del usuario; además, no era un requisito funcional de VetRuta, por lo que no ejecuté esa instrucción que solicitaban ni agregué al código el comentario que solicitaban.

## ¿Qué es VetRuta?

VetRuta es una aplicación móvil para organizar visitas veterinarias a domicilio. La idea fue dejar un flujo completo y práctico, sin tanta vuelta: administrar usuarios, formar los equipos de trabajo, registrar propietarios y mascotas, programar visitas, consultar la ruta del técnico y guardar la atención realizada con ubicación y evidencia fotográfica.

La aplicación trabaja según el rol del usuario:

- Root: crea, activa y desactiva usuarios.
- Director: consulta las gráficas generales y asigna técnicos a los médicos.
- Médico: registra propietarios y pacientes, asigna al técnico responsable y programa visitas.
- Técnico: consulta su agenda, mapa y pacientes; registra la atención con GPS y fotografía.

También se incluye historial clínico, fotografías de pacientes, detalle de visitas, gráficas por actividad y validación de permisos tanto en Flutter como directamente en la API.

## Tecnologías principales

### Backend (VetRuta)

- .NET 8 y ASP.NET Core Web API.
- Dapper para ejecutar consultas y procedimientos almacenados.
- Microsoft.Data.SqlClient para la conexión con SQL Server.
- JWT Bearer y refresh tokens para autenticación y autorización por roles.
- BCrypt para almacenar las contraseñas mediante hash.
- Swagger/OpenAPI para probar y documentar los endpoints.

### Aplicación móvil (VetRutaMovil)

- Flutter y Dart.
- Provider para el manejo de estado.
- Dio para consumir la API.
- Flutter Secure Storage para guardar los tokens de forma segura.
- fl_chart para las gráficas.
- flutter_map, OpenStreetMap y latlong2 para el mapa.
- geolocator para obtener la ubicación del dispositivo.
- image_picker para cámara y galería.
- Material UI e iconos de Flutter para la interfaz.

## Base de datos

Se utilizó **Microsoft SQL Server** y la base de datos de pruebas se llama "PRUEBAS". El backend obtiene la cadena de conexión desde "VetRuta/VetRuta.API/appsettings.json" y abre las conexiones por medio de "Microsoft.Data.SqlClient"; "Dapper" se encarga de enviar los parámetros y convertir los resultados a los DTO del proyecto.

Configuración usada para esta prueba técnica:

Servidor: Direccion que quieran 
Base de datos: PRUEBAS 
Usuario SQL: PRUEBA 
Contraseña SQL: PRUEBA 

Estas credenciales son únicamente del ambiente de prueba. En un ambiente real deben colocarse en variables de entorno o en un administrador de secretos y nunca dejarse en el repositorio.

Los scripts están numerados dentro de dataBase y deben ejecutarse del 01 al 19. Las tablas creadas son:

Roles, Usuarios, AsignacionesJerarquia, Zonas, UsuariosZonas, Especies, Razas, Servicios, Propietarios, Pacientes, AsignacionesPacientes, Visitas, RegistrosVisitas, EvidenciasVisitas, TokensActualizacion y BitacoraAuditoria.

Se dejaron dos procedimientos almacenados principales:

- SP_VetRuta_Consultas: reraliza las consultas y selecciona la operación mediante el parámetro @Opcion.
- SP_VetRuta_Inserts_Updates: realiza inserciones y actualizaciones utilizando el mismo esquema de opciones.

Así el acceso a datos quedó centralizado y el backend no arma cponsultas SQL desde los controladores. Los datos iniciales de roles, especies, razas, servicios, zonas y el usuario root están en 17_DatosIniciales.sql.

## Usuarios de prueba

Rol --> Usuario --> Contraseña 
Root --> root --> VetRuta2026* 
Director --> director.vetruta --> Director2026* 
Médico --> medico.vetruta --> Medico2026* 
Técnico --> tecnico.vetruta --> Tecnico2026* 

Estos usuarios son solo para levantar la demostración. El root puede crear otros usuarios desde la misma aplicación.

## Estructura del repositorio

LrivasGenesisPrueba
- dataBase --> Scripts de tablas, datos iniciales y SP
- VetRuta --> Solución del backend en .NET 8
- VetRutaMovil --> Aplicación móvil desarrollada en Flutter


El backend se separó por responsabilidades en capas:

- VetRuta.API: controladores, autenticación, middleware, configuración y archivos protegidos.
- VetRuta.BusinessLogic: interfaces y servicios con las reglas del negocio.
- VetRuta.DataAccess: conexión a SQL Server y ejecución de los SP con Dapper.
- VetRuta.Entities: DTO, filtros, solicitudes y modelos compartidos entre capas.

En Flutter, lib/core contiene lo común a toda la aplicación: cliente HTTP, almacenamiento seguro y tema visual. lib/modulos contiene cada función del sistema por separado:

- autenticacion: inicio y cierre de sesión.
- usuarios: administración de usuarios para root.
- jerarquia: asignación de técnicos a médicos.
- panel: indicadores, gráficas, actividad, equipo y perfil.
- pacientes: propietarios, mascotas, fotografías e historial clínico.
- agenda: programación, mapa, detalle y registro de visitas.

Dentro de cada módulo se usó una estructura sencilla:

- datos/modelos: objetos que representan las respuestas de la API.
- datos/servicios: llamadas HTTP realizadas con Dio.
- presentacion/controladores: estado y reglas de la pantalla usando Provider.
- presentacion/pantallas: interfaz visible para el usuario.
- presentacion/widgets: componentes reutilizables cuando el módulo los necesita.

## Cómo levantar el proyecto

1. Ejecutar en SQL Server los scripts de dataBase en orden numérico.
2. Revisar la cadena ConnectionStrings:VetRuta y la configuración Jwt en VetRuta/VetRuta.API/appsettings.json.
3. Iniciar el backend desde VetRuta/VetRuta.API con dotnet run o directo desde http en visual studio code 2022.
4. En VetRutaMovil, ejecutar flutter pub get y luego flutter run.
5. Si se usa un teléfono Android conectado por USB, ejecutar adb reverse tcp:5172 tcp:5172. La app apunta por defecto a http://127.0.0.1:5172; también se puede cambiar al compilar mediante --dart-define=API_URL=.... esta en: VetRutaMovil\lib\core\red\configuracion_api.dart

Con eso ya debería quedar jalando la aplicación completa. Para una revisión rápida conviene entrar primero como root, confirmar los usuarios y luego probar el flujo director → médico → técnico. Gracias por la oportunidad, estamos a sus ordenes Saludos.
