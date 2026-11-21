using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using VetRuta.BusinessLogic.Interfaces;
using VetRuta.DataAccess.Procedimientos;
using VetRuta.Entities.Configuracion;
using VetRuta.Entities.DTOs.Autenticacion;
using VetRuta.Entities.DTOs.Comun;

namespace VetRuta.BusinessLogic.Servicios;

public class AutenticacionServicio : IAutenticacionServicio
{
    private const int OpcionBuscarUsuario = 1;
    private const int OpcionRegistrarUltimoAcceso = 5;
    private const int OpcionBuscarTokenActualizacion = 24;
    private const int OpcionCrearTokenActualizacion = 26;
    private const int OpcionRevocarTokenActualizacion = 27;
    private const int OpcionCambiarContrasena = 4;

    private readonly EjecutorProcedimientos _ejecutorProcedimientos;
    private readonly JwtConfiguracion _jwtConfiguracion;

    public AutenticacionServicio(
        EjecutorProcedimientos ejecutorProcedimientos,
        JwtConfiguracion jwtConfiguracion)
    {
        _ejecutorProcedimientos = ejecutorProcedimientos;
        _jwtConfiguracion = jwtConfiguracion;
    }

    public async Task<LoginRespuestaDto?> IniciarSesionAsync(
        LoginSolicitudDto solicitud,
        string? direccionIp,
        string? dispositivo)
    {
        var usuario = await _ejecutorProcedimientos
            .ConsultarUnoAsync<UsuarioAutenticacionDto>(
                OpcionBuscarUsuario, new { solicitud.NombreUsuario });

        if (usuario is null || !usuario.Activo)
        {
            return null;
        }

        var contrasenaCorrecta = BCrypt.Net.BCrypt.Verify(solicitud.Contrasena, usuario.ContrasenaHash);

        if (!contrasenaCorrecta)
        {
            return null;
        }

        await _ejecutorProcedimientos.EjecutarAsync<ResultadoOperacionDto>(
            OpcionRegistrarUltimoAcceso,
            new { usuario.UsuarioId });

        return await CrearRespuestaSesionAsync(usuario,direccionIp,dispositivo);
    }

    public async Task<LoginRespuestaDto?> RenovarTokenAsync(
        RenovarTokenSolicitudDto solicitud,
        string? direccionIp,
        string? dispositivo)
    {
        if (string.IsNullOrWhiteSpace(solicitud.TokenActualizacion))
        {
            return null;
        }

        var tokenHashAnterior = CalcularHash(solicitud.TokenActualizacion);

        var tokenGuardado = await _ejecutorProcedimientos
            .ConsultarUnoAsync<TokenActualizacionDto>(
                OpcionBuscarTokenActualizacion,
                new { TokenHash = tokenHashAnterior });

        if (tokenGuardado is null)
        {
            return null;
        }

        var usuario = await _ejecutorProcedimientos
            .ConsultarUnoAsync<UsuarioAutenticacionDto>(
                OpcionBuscarUsuario,
                new { tokenGuardado.NombreUsuario });

        if (usuario is null || !usuario.Activo)
        {
            return null;
        }

        await _ejecutorProcedimientos.EjecutarAsync<ResultadoOperacionDto>(
            OpcionRevocarTokenActualizacion,
            new { TokenHash = tokenHashAnterior });

        return await CrearRespuestaSesionAsync(
            usuario,
            direccionIp,
            dispositivo);
    }

    public async Task<bool> CerrarSesionAsync(CerrarSesionSolicitudDto solicitud)
    {
        if (string.IsNullOrWhiteSpace(solicitud.TokenActualizacion))
        {
            return false;
        }

        var tokenHash = CalcularHash(solicitud.TokenActualizacion);

        var tokenGuardado = await _ejecutorProcedimientos
            .ConsultarUnoAsync<TokenActualizacionDto>(
                OpcionBuscarTokenActualizacion,
                new { TokenHash = tokenHash });

        if (tokenGuardado is null)
        {
            return false;
        }

        var resultado = await _ejecutorProcedimientos
            .EjecutarAsync<ResultadoOperacionDto>(
                OpcionRevocarTokenActualizacion,
                new { TokenHash = tokenHash });

        return resultado is not null;
    }

    public async Task<bool> CambiarContrasenaAsync(string nombreUsuario,CambiarContrasenaSolicitudDto solicitud)
    {
        if (string.IsNullOrWhiteSpace(nombreUsuario))
        {
            return false;
        }

        var usuario = await _ejecutorProcedimientos.ConsultarUnoAsync<UsuarioAutenticacionDto>(
                OpcionBuscarUsuario,new { NombreUsuario = nombreUsuario });

        if (usuario is null || !usuario.Activo)
        {
            return false;
        }

        var contrasenaActualCorrecta = BCrypt.Net.BCrypt.Verify(solicitud.ContrasenaActual,usuario.ContrasenaHash);

        if (!contrasenaActualCorrecta)
        {
            return false;
        }

        if (BCrypt.Net.BCrypt.Verify(solicitud.NuevaContrasena,usuario.ContrasenaHash))
        {
            return false;
        }

        var nuevaContrasenaHash = BCrypt.Net.BCrypt.HashPassword(solicitud.NuevaContrasena,workFactor: 12);

        var resultado = await _ejecutorProcedimientos
            .EjecutarAsync<ResultadoOperacionDto>(
                OpcionCambiarContrasena,
                new
                {
                    usuario.UsuarioId,
                    ContrasenaHash = nuevaContrasenaHash,
                    DebeCambiarContrasena = false
                });

        return resultado is not null;
    }

    private async Task<LoginRespuestaDto> CrearRespuestaSesionAsync(
        UsuarioAutenticacionDto usuario,
        string? direccionIp,
        string? dispositivo)
    {
        var fechaExpiracionJwt = DateTime.UtcNow.AddMinutes(
            _jwtConfiguracion.MinutosExpiracion);

        var token = GenerarJwt(usuario, fechaExpiracionJwt);
        var tokenActualizacion = GenerarTokenActualizacion();
        var tokenHash = CalcularHash(tokenActualizacion);

        var fechaExpiracionTokenActualizacion = DateTime.Now.AddDays(
            _jwtConfiguracion.DiasExpiracionTokenActualizacion);

        await _ejecutorProcedimientos.EjecutarAsync<ResultadoOperacionDto>(
            OpcionCrearTokenActualizacion,
            new
            {
                usuario.UsuarioId,
                TokenHash = tokenHash,
                FechaExpiracion = fechaExpiracionTokenActualizacion,
                Dispositivo = LimitarLongitud(dispositivo, 250),
                DireccionIp = LimitarLongitud(direccionIp, 50)
            });

        return new LoginRespuestaDto
        {
            Token = token,
            TokenActualizacion = tokenActualizacion,
            FechaExpiracion = fechaExpiracionJwt,
            Usuario = new UsuarioSesionDto
            {
                UsuarioId = usuario.UsuarioId,
                NombreUsuario = usuario.NombreUsuario,
                Nombres = usuario.Nombres,
                Apellidos = usuario.Apellidos,
                RolId = usuario.RolId,
                CodigoRol = usuario.CodigoRol,
                NombreRol = usuario.NombreRol,
                DebeCambiarContrasena = usuario.DebeCambiarContrasena
            }
        };
    }

    private string GenerarJwt(
        UsuarioAutenticacionDto usuario,
        DateTime fechaExpiracion)
    {
        var claims = new List<Claim>
        {
            new(JwtRegisteredClaimNames.Sub,usuario.UsuarioId.ToString()),
            new(JwtRegisteredClaimNames.UniqueName,usuario.NombreUsuario),
            new(JwtRegisteredClaimNames.Jti,Guid.NewGuid().ToString()),
            new(ClaimTypes.NameIdentifier,usuario.UsuarioId.ToString()),
            new(ClaimTypes.Name,usuario.NombreUsuario),
            new(ClaimTypes.Role,usuario.CodigoRol),
            new("rolId",usuario.RolId.ToString()),
            new("nombreCompleto",$"{usuario.Nombres} {usuario.Apellidos}".Trim())
        };

        var clave = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_jwtConfiguracion.Clave));
        var credenciales = new SigningCredentials(clave, SecurityAlgorithms.HmacSha256);

        var jwt = new JwtSecurityToken(
            issuer: _jwtConfiguracion.Emisor,
            audience: _jwtConfiguracion.Audiencia,
            claims: claims,
            notBefore: DateTime.UtcNow,
            expires: fechaExpiracion,
            signingCredentials: credenciales);
        return new JwtSecurityTokenHandler().WriteToken(jwt);
    }

    private static string GenerarTokenActualizacion()
    {
        var bytes = RandomNumberGenerator.GetBytes(64);
        return Convert.ToBase64String(bytes);
    }

    private static string CalcularHash(string token)
    {
        var bytes = Encoding.UTF8.GetBytes(token);
        var hash = SHA256.HashData(bytes);
        return Convert.ToHexString(hash);
    }

    private static string? LimitarLongitud(string? valor, int longitudMaxima)
    {
        if (string.IsNullOrWhiteSpace(valor))
        {
            return null;
        }
        var valorLimpio = valor.Trim();
        return valorLimpio.Length <= longitudMaxima
            ? valorLimpio
            : valorLimpio[..longitudMaxima];
    }
}
