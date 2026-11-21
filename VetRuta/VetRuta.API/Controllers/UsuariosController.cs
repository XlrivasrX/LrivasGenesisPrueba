using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using VetRuta.BusinessLogic.Interfaces;
using VetRuta.Entities.DTOs.Usuarios;
using System.Security.Claims;

namespace VetRuta.API.Controllers;

[Authorize(Roles = "ROOT,DIRECTOR")]
[ApiController]
[Route("usuarios")]
public class UsuariosController : ControllerBase
{
    private readonly IUsuarioServicio _usuarioServicio;

    public UsuariosController(IUsuarioServicio usuarioServicio)
    {
        _usuarioServicio = usuarioServicio;
    }

    [HttpGet]
    [ProducesResponseType(typeof(IEnumerable<UsuarioListadoDto>), StatusCodes.Status200OK)]
    public async Task<ActionResult<IEnumerable<UsuarioListadoDto>>> Listar([FromQuery] UsuarioFiltroDto filtros)
    {
        var usuarios = await _usuarioServicio.ListarAsync(filtros);
        return Ok(usuarios);
    }

    [HttpGet("{usuarioId:int}")]
    [ProducesResponseType(typeof(UsuarioDetalleDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<ActionResult<UsuarioDetalleDto>> ObtenerPorId(int usuarioId)
    {
        var usuario = await _usuarioServicio.ObtenerPorIdAsync(usuarioId);

        if (usuario is null)
        {
            return NotFound(new
            {
                mensaje = "Usuario no encontrado."
            });
        }

        return Ok(usuario);
    }

    [Authorize(Roles = "ROOT")]
    [HttpPost]
    [ProducesResponseType(typeof(UsuarioCreadoDto), StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public async Task<ActionResult<UsuarioCreadoDto>> Crear([FromBody] CrearUsuarioSolicitudDto solicitud)
    {
        var usuarioCreado = await _usuarioServicio.CrearAsync(solicitud);

        if (usuarioCreado is null)
        {
            return BadRequest(new
            {
                mensaje = "No fue posible crear el usuario."
            });
        }

        return CreatedAtAction(
            nameof(ObtenerPorId),
            new { usuarioId = usuarioCreado.UsuarioId },
            usuarioCreado);
    }

    [Authorize(Roles = "ROOT")]
    [HttpPut("{usuarioId:int}")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Actualizar(int usuarioId, [FromBody] ActualizarUsuarioSolicitudDto solicitud)
    {
        var usuarioActualizado = await _usuarioServicio.ActualizarAsync(usuarioId, solicitud);

        if (!usuarioActualizado)
        {
            return NotFound(new
            {
                mensaje = "Usuario no encontrado."
            });
        }

        return Ok(new
        {
            mensaje = "Usuario actualizado correctamente."
        });
    }

    [Authorize(Roles = "ROOT")]
    [HttpPatch("{usuarioId:int}/estado")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> CambiarEstado(int usuarioId, [FromBody] CambiarEstadoUsuarioSolicitudDto solicitud)
    {
        var usuarioIdActualTexto = User.FindFirstValue(ClaimTypes.NameIdentifier);

        if (!int.TryParse(usuarioIdActualTexto, out var usuarioIdActual))
        {
            return Unauthorized();
        }

        if (usuarioId == usuarioIdActual && !solicitud.Activo)
        {
            return BadRequest(new
            {
                mensaje = "No puedes desactivar tu propio usuario."
            });
        }

        var estadoActualizado = await _usuarioServicio.CambiarEstadoAsync(usuarioId, solicitud.Activo);

        if (!estadoActualizado)
        {
            return NotFound(new
            {
                mensaje = "Usuario no encontrado."
            });
        }

        return Ok(new
        {
            mensaje = solicitud.Activo
                ? "Usuario activado correctamente."
                : "Usuario desactivado correctamente."
        });
    }

    [Authorize(Roles = "ROOT")]
    [HttpPost("{usuarioId:int}/restablecer-contrasena")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> RestablecerContrasena(int usuarioId, [FromBody] RestablecerContrasenaSolicitudDto solicitud)
    {
        var contrasenaRestablecida = await _usuarioServicio.RestablecerContrasenaAsync(usuarioId, solicitud);

        if (!contrasenaRestablecida)
        {
            return NotFound(new
            {
                mensaje = "Usuario no encontrado."
            });
        }

        return Ok(new
        {
            mensaje = "Contraseña restablecida correctamente. El usuario deberá cambiarla al iniciar sesión."
        });
    }
}