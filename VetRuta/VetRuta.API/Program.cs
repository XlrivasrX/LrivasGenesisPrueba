using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using System.Text;
using VetRuta.BusinessLogic.Interfaces;
using VetRuta.BusinessLogic.Servicios;
using VetRuta.DataAccess.Conexion;
using VetRuta.DataAccess.Procedimientos;
using VetRuta.Entities.Configuracion;
using Microsoft.OpenApi.Models;

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
builder.Services.AddScoped<IRolServicio, RolServicio>();
builder.Services.AddScoped<IAutenticacionServicio, AutenticacionServicio>();
builder.Services.AddScoped<IUsuarioServicio, UsuarioServicio>();

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

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

app.Run();
