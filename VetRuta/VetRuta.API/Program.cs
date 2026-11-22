using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using System.Text;
using VetRuta.BusinessLogic.Interfaces;
using VetRuta.BusinessLogic.Servicios;
using VetRuta.DataAccess.Conexion;
using VetRuta.DataAccess.Procedimientos;
using VetRuta.Entities.Configuracion;
using Microsoft.OpenApi.Models;
using VetRuta.API.Middleware;

var builder = WebApplication.CreateBuilder(args);

var cadenaConexion = builder.Configuration
    .GetConnectionString("VetRuta")
    ?? throw new InvalidOperationException(
        "No se encontró la cadena de conexión VetRuta.");

var jwtConfiguracion = builder.Configuration
    .GetSection(JwtConfiguracion.Seccion)
    .Get<JwtConfiguracion>()
    ?? throw new InvalidOperationException(
        "No se encontró la configuración de JWT.");

if (string.IsNullOrWhiteSpace(jwtConfiguracion.Clave)
    || Encoding.UTF8.GetByteCount(jwtConfiguracion.Clave) < 32)
{
    throw new InvalidOperationException(
        "La clave de JWT debe contener al menos 32 caracteres.");
}

builder.Services.AddSingleton(
    new ConexionBaseDatos(cadenaConexion));

builder.Services.AddSingleton(jwtConfiguracion);
builder.Services.AddScoped<EjecutorProcedimientos>();
//El servicio de roles
builder.Services.AddScoped<IRolServicio, RolServicio>();
//el servicio que auntentrica usuarios
builder.Services.AddScoped<IAutenticacionServicio, AutenticacionServicio>();
//El servicio de usuarios creados etc.
builder.Services.AddScoped<IUsuarioServicio, UsuarioServicio>();
//El servicio de las especies, razas etc.
builder.Services.AddScoped<ICatalogoServicio, CatalogoServicio>();
//Este es el servicio de los propiestarios de visitas
builder.Services.AddScoped<IPropietarioServicio, PropietarioServicio>();
//El servicio del registros de pacientes etc.
builder.Services.AddScoped<IPacienteServicio, PacienteServicio>();
//Este es el servicio que asigna pacientes a tecnicos y medicos
builder.Services.AddScoped<IAsignacionServicio, AsignacionServicio>();
//Este es el servicio que asigna las visitas y las registra, un  te3cnico ve lkas de él, un medico tambien etc.
builder.Services.AddScoped<IVisitaServicio, VisitaServicio>();
//Registra el servicio que obtiene los datos del panel principal.
builder.Services.AddScoped<IPanelServicio, PanelServicio>();
// Registra el servicio encargado de consultar y guardar la bitácora de auditoría.
builder.Services.AddScoped<IAuditoriaServicio, AuditoriaServicio>();
// Registra el servicio que administra la jerarquía entre médicos y técnicos.
builder.Services.AddScoped<IJerarquiaServicio, JerarquiaServicio>();

builder.Services
    .AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(opciones =>
    {
        opciones.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuerSigningKey = true,
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtConfiguracion.Clave)),
            ValidateIssuer = true,
            ValidIssuer = jwtConfiguracion.Emisor,
            ValidateAudience = true,
            ValidAudience = jwtConfiguracion.Audiencia,
            ValidateLifetime = true,
            ClockSkew = TimeSpan.Zero
        };
    });

builder.Services.AddAuthorization();

// Add services to the container.

builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(opciones =>
{
    opciones.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Name = "Authorization",
        Type = SecuritySchemeType.Http,
        Scheme = "bearer",
        BearerFormat = "JWT",
        In = ParameterLocation.Header,
        Description = "Ingrese el token JWT."
    });

    opciones.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer"
                }
            },
            Array.Empty<string>()
        }
    });
});

var app = builder.Build();

// Convierte las excepciones inesperadas en respuestas seguras y uniformes.
app.UseMiddleware<ManejadorExcepcionesMiddleware>();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// Redirige las solicitudes a HTTPS fuera del ambiente local de desarrollo.
if (!app.Environment.IsDevelopment())
{
    app.UseHttpsRedirection();
}

// Las evidencias solo se entregan mediante un endpoint autenticado.
app.Use(async (context, siguiente) =>
{
    if (context.Request.Path.StartsWithSegments("/evidencias")
        || context.Request.Path.StartsWithSegments("/fotos-pacientes"))
    {
        context.Response.StatusCode = StatusCodes.Status404NotFound;
        return;
    }

    await siguiente();
});

// Permite consultar otros archivos públicos guardados en wwwroot.
app.UseStaticFiles();

app.UseAuthentication();
app.UseAuthorization();

// Registra automáticamente en la bitácora las operaciones exitosas que modifican información.
app.UseMiddleware<AuditoriaMiddleware>();

app.MapControllers();

app.Run();
