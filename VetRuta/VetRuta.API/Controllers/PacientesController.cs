using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using VetRuta.BusinessLogic.Interfaces;
using VetRuta.Entities.DTOs.Pacientes;

namespace VetRuta.API.Controllers;

[Authorize]
[ApiController]
[Route("pacientes")]
public class PacientesController : ControllerBase
{
    private readonly IPacienteServicio _pacienteServicio;

    public PacientesController(IPacienteServicio pacienteServicio)
    {
        _pacienteServicio = pacienteServicio;
    }

    [HttpGet]
    [ProducesResponseType(typeof(IEnumerable<PacienteListadoDto>), StatusCodes.Status200OK)]
    public async Task<ActionResult<IEnumerable<PacienteListadoDto>>> Listar([FromQuery] PacienteFiltroDto filtros)
    {
        var pacientes = await _pacienteServicio.ListarAsync(filtros);
        return Ok(pacientes);
    }

    [HttpGet("{pacienteId:int}")]
    [ProducesResponseType(typeof(PacienteDetalleDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<ActionResult<PacienteDetalleDto>> ObtenerPorId(int pacienteId)
    {
        var paciente = await _pacienteServicio.ObtenerPorIdAsync(pacienteId);
        if (paciente is null)
        {
            return NotFound(new { mensaje = "Paciente no encontrado." });
        }
        return Ok(paciente);
    }

    [Authorize(Roles = "MEDICO")]
    [HttpPost]
    [ProducesResponseType(typeof(PacienteCreadoDto), StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<ActionResult<PacienteCreadoDto>> Crear([FromBody] GuardarPacienteSolicitudDto solicitud)
    {
        var usuarioIdTexto = User.FindFirstValue(ClaimTypes.NameIdentifier);

        if (!int.TryParse(usuarioIdTexto, out var usuarioId))
        {
            return Unauthorized();
        }

        var pacienteCreado = await _pacienteServicio.CrearAsync(solicitud, usuarioId);
        if (pacienteCreado is null)
        {
            return BadRequest(new { mensaje = "No fue posible crear el paciente." });
        }
        return CreatedAtAction(nameof(ObtenerPorId), new { pacienteId = pacienteCreado.PacienteId }, pacienteCreado);
    }

    [Authorize(Roles = "MEDICO")]
    [HttpPut("{pacienteId:int}")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Actualizar(int pacienteId, [FromBody] GuardarPacienteSolicitudDto solicitud)
    {
        var pacienteActualizado = await _pacienteServicio.ActualizarAsync(pacienteId, solicitud);
        if (!pacienteActualizado)
        {
            return NotFound(new { mensaje = "Paciente no encontrado." });
        }
        return Ok(new { mensaje = "Paciente actualizado correctamente." });
    }
}
