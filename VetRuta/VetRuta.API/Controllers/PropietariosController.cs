using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using VetRuta.BusinessLogic.Interfaces;
using VetRuta.Entities.DTOs.Propietarios;

namespace VetRuta.API.Controllers;

[Authorize]
[ApiController]
[Route("propietarios")]
public class PropietariosController : ControllerBase
{
    private readonly IPropietarioServicio _propietarioServicio;

    public PropietariosController(IPropietarioServicio propietarioServicio)
    {
        _propietarioServicio = propietarioServicio;
    }

    [HttpGet]
    [ProducesResponseType(typeof(IEnumerable<PropietarioListadoDto>), StatusCodes.Status200OK)]
    public async Task<ActionResult<IEnumerable<PropietarioListadoDto>>> Listar([FromQuery] PropietarioFiltroDto filtros)
    {
        var propietarios = await _propietarioServicio.ListarAsync(filtros);
        return Ok(propietarios);
    }

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
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Actualizar(int propietarioId, [FromBody] GuardarPropietarioSolicitudDto solicitud)
    {
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
}
