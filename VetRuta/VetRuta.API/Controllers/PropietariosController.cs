using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using VetRuta.BusinessLogic.Interfaces;
using VetRuta.Entities.DTOs.Pacientes;
using VetRuta.Entities.DTOs.Propietarios;

namespace VetRuta.API.Controllers;

[Authorize(Roles = "DIRECTOR,MEDICO")]
[ApiController]
[Route("propietarios")]
public class PropietariosController : ControllerBase
{
    private readonly IPropietarioServicio _propietarioServicio;
    private readonly IPacienteServicio _pacienteServicio;
    private readonly IAsignacionServicio _asignacionServicio;

    public PropietariosController(
        IPropietarioServicio propietarioServicio,
        IPacienteServicio pacienteServicio,
        IAsignacionServicio asignacionServicio)
    {
        _propietarioServicio = propietarioServicio;
        _pacienteServicio = pacienteServicio;
        _asignacionServicio = asignacionServicio;
    }

    [Authorize(Roles = "DIRECTOR")]
    [HttpGet]
    [ProducesResponseType(typeof(IEnumerable<PropietarioListadoDto>), StatusCodes.Status200OK)]
    public async Task<ActionResult<IEnumerable<PropietarioListadoDto>>> Listar([FromQuery] PropietarioFiltroDto filtros)
    {
        var propietarios = await _propietarioServicio.ListarAsync(filtros);
        return Ok(propietarios);
    }

    [Authorize(Roles = "DIRECTOR")]
    [HttpGet("{propietarioId:int}")]
    [ProducesResponseType(typeof(PropietarioDetalleDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<ActionResult<PropietarioDetalleDto>> ObtenerPorId(int propietarioId)
    {
        var propietario = await _propietarioServicio.ObtenerPorIdAsync(propietarioId);

        if (propietario is null)
        {
            return NotFound(new
            {
                mensaje = "Propietario no encontrado."
            });
        }

        return Ok(propietario);
    }

    [Authorize(Roles = "MEDICO")]
    [HttpPost]
    [ProducesResponseType(typeof(PropietarioCreadoDto), StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<ActionResult<PropietarioCreadoDto>> Crear([FromBody] GuardarPropietarioSolicitudDto solicitud)
    {
        var propietarioCreado = await _propietarioServicio.CrearAsync(solicitud);

        if (propietarioCreado is null)
        {
            return BadRequest(new
            {
                mensaje = "No fue posible crear el propietario."
            });
        }

        return CreatedAtAction(
            nameof(ObtenerPorId),
            new { propietarioId = propietarioCreado.PropietarioId },
            propietarioCreado);
    }

    [Authorize(Roles = "MEDICO")]
    [HttpPut("{propietarioId:int}")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Actualizar(int propietarioId, [FromBody] GuardarPropietarioSolicitudDto solicitud)
    {
        if (!await MedicoPuedeAccederPropietarioAsync(propietarioId))
        {
            return Forbid();
        }

        var propietarioActualizado = await _propietarioServicio.ActualizarAsync(propietarioId, solicitud);

        if (!propietarioActualizado)
        {
            return NotFound(new
            {
                mensaje = "Propietario no encontrado."
            });
        }

        return Ok(new
        {
            mensaje = "Propietario actualizado correctamente."
        });
    }

    [Authorize(Roles = "MEDICO")]
    [HttpPatch("{propietarioId:int}/ubicacion")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> ActualizarUbicacion(
        int propietarioId,
        [FromBody] ActualizarUbicacionPropietarioSolicitudDto solicitud)
    {
        if (!await MedicoPuedeAccederPropietarioAsync(propietarioId))
        {
            return Forbid();
        }

        var propietario = await _propietarioServicio.ObtenerPorIdAsync(propietarioId);

        if (propietario is null)
        {
            return NotFound(new
            {
                mensaje = "Propietario no encontrado."
            });
        }

        var actualizado = await _propietarioServicio.ActualizarAsync(
            propietarioId,
            new GuardarPropietarioSolicitudDto
            {
                ZonaId = propietario.ZonaId,
                Nombres = propietario.Nombres,
                Apellidos = propietario.Apellidos,
                Telefono = propietario.Telefono,
                TelefonoAlternativo = propietario.TelefonoAlternativo,
                Direccion = propietario.Direccion,
                Latitud = solicitud.Latitud,
                Longitud = solicitud.Longitud,
                Activo = propietario.Activo
            });

        if (!actualizado)
        {
            return NotFound(new
            {
                mensaje = "Propietario no encontrado."
            });
        }

        return Ok(new
        {
            mensaje = "Ubicación actualizada correctamente."
        });
    }

    private async Task<bool> MedicoPuedeAccederPropietarioAsync(
        int propietarioId)
    {
        var usuarioIdTexto = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!int.TryParse(usuarioIdTexto, out var usuarioId))
        {
            return false;
        }

        var pacientes = await _pacienteServicio.ListarAsync(
            new PacienteFiltroDto
            {
                PropietarioId = propietarioId
            });

        foreach (var paciente in pacientes)
        {
            var asignacion = await _asignacionServicio
                .ObtenerActivaPorPacienteAsync(paciente.PacienteId);

            if (asignacion?.AsignadoPorUsuarioId == usuarioId)
            {
                return true;
            }
        }

        return false;
    }
}
