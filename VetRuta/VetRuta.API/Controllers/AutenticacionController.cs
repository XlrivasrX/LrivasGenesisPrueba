using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using VetRuta.BusinessLogic.Interfaces;
using VetRuta.Entities.DTOs.Autenticacion;

namespace VetRuta.API.Controllers;

[ApiController]
[Route("autenticacion")]
public class AutenticacionController : ControllerBase
{
    private readonly IAutenticacionServicio _autenticacionServicio;

    public AutenticacionController(IAutenticacionServicio autenticacionServicio)
    {
        _autenticacionServicio = autenticacionServicio;
    }

    [AllowAnonymous]
    [HttpPost("iniciar-sesion")]
    [ProducesResponseType(typeof(LoginRespuestaDto),StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<ActionResult<LoginRespuestaDto>> IniciarSesion([FromBody] LoginSolicitudDto solicitud)
    {
        var direccionIp = HttpContext.Connection.RemoteIpAddress?.ToString();

        var dispositivo = Request.Headers.UserAgent.ToString();
        var respuesta = await _autenticacionServicio.IniciarSesionAsync(solicitud,direccionIp,dispositivo);

        if (respuesta is null)
        {
            return Unauthorized(new
            {
                mensaje = "Usuario o contraseña incorrectos."
            });
        }
        return Ok(respuesta);
    }

    [AllowAnonymous]
    [HttpPost("renovar-token")]
    [ProducesResponseType(typeof(LoginRespuestaDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<ActionResult<LoginRespuestaDto>> RenovarToken(
        [FromBody] RenovarTokenSolicitudDto solicitud)
    {
        var direccionIp = HttpContext.Connection.RemoteIpAddress?.ToString();
        var dispositivo = Request.Headers.UserAgent.ToString();

        var respuesta = await _autenticacionServicio.RenovarTokenAsync(
            solicitud,
            direccionIp,
            dispositivo);

        if (respuesta is null)
        {
            return Unauthorized(new
            {
                mensaje = "El token de actualización no es válido o ha expirado."
            });
        }

        return Ok(respuesta);
    }

    [AllowAnonymous]
    [HttpPost("cerrar-sesion")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> CerrarSesion(
    [FromBody] CerrarSesionSolicitudDto solicitud)
    {
        var sesionCerrada = await _autenticacionServicio.CerrarSesionAsync(solicitud);

        if (!sesionCerrada)
        {
            return Unauthorized(new
            {
                mensaje = "El token de actualización no es válido o ya fue revocado."
            });
        }

        return Ok(new
        {
            mensaje = "Sesión cerrada correctamente."
        });
    }

    [Authorize]
    [HttpPost("cambiar-contrasena")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> CambiarContrasena(
    [FromBody] CambiarContrasenaSolicitudDto solicitud)
    {
        var nombreUsuario = User.Identity?.Name;

        if (string.IsNullOrWhiteSpace(nombreUsuario))
        {
            return Unauthorized();
        }

        var contrasenaActualizada = await _autenticacionServicio.CambiarContrasenaAsync(nombreUsuario, solicitud);

        if (!contrasenaActualizada)
        {
            return BadRequest(new
            {
                mensaje = "La contraseña actual es incorrecta o la nueva contraseña ya está en uso."
            });
        }

        return Ok(new
        {
            mensaje = "Contraseña actualizada correctamente."
        });
    }
}
