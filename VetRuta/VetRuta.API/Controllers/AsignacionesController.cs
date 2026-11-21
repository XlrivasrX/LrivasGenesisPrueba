using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using VetRuta.BusinessLogic.Interfaces;
using VetRuta.Entities.DTOs.Asignaciones;

namespace VetRuta.API.Controllers;

[Authorize]
[ApiController]
[Route("asignaciones")]
public class AsignacionesController : ControllerBase
{
    private readonly IAsignacionServicio _asignacionServicio;

    public AsignacionesController(IAsignacionServicio asignacionServicio)
    {
        _asignacionServicio = asignacionServicio;
    }

    [HttpGet("paciente/{pacienteId:int}/activa")]
    [ProducesResponseType(typeof(AsignacionActivaDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<ActionResult<AsignacionActivaDto>> ObtenerActivaPorPaciente(int pacienteId)
    {
        var asignacion = await _asignacionServicio.ObtenerActivaPorPacienteAsync(pacienteId);
        if (asignacion is null)
        {
            return NotFound(new { mensaje = "El paciente no tiene una asignación activa." });
        }
        return Ok(asignacion);
    }

    [Authorize(Roles = "TECNICO")]
    [HttpGet("mis-pacientes")]
    [ProducesResponseType(typeof(IEnumerable<PacienteAsignadoDto>), StatusCodes.Status200OK)]
    public async Task<ActionResult<IEnumerable<PacienteAsignadoDto>>> ListarMisPacientes([FromQuery] PacienteAsignadoFiltroDto filtros)
    {
        var usuarioIdTexto = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!int.TryParse(usuarioIdTexto, out var usuarioId))
        {
            return Unauthorized();
        }
        var pacientes = await _asignacionServicio.ListarPorTecnicoAsync(usuarioId, filtros);
        return Ok(pacientes);
    }

    [Authorize(Roles = "ROOT,DIRECTOR")]
    [HttpGet("tecnico/{tecnicoUsuarioId:int}")]
    [ProducesResponseType(typeof(IEnumerable<PacienteAsignadoDto>), StatusCodes.Status200OK)]
    public async Task<ActionResult<IEnumerable<PacienteAsignadoDto>>> ListarPorTecnico(int tecnicoUsuarioId, [FromQuery] PacienteAsignadoFiltroDto filtros)
    {
        var pacientes = await _asignacionServicio.ListarPorTecnicoAsync(tecnicoUsuarioId, filtros);
        return Ok(pacientes);
    }

    [Authorize(Roles = "ROOT,DIRECTOR")]
    [HttpPost]
    [ProducesResponseType(typeof(AsignacionResultadoDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<ActionResult<AsignacionResultadoDto>> Asignar([FromBody] AsignarPacienteSolicitudDto solicitud)
    {
        var usuarioIdTexto = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!int.TryParse(usuarioIdTexto, out var usuarioId))
        {
            return Unauthorized();
        }

        var resultado = await _asignacionServicio.AsignarAsync(solicitud, usuarioId);
        if (resultado is null)
        {
            return BadRequest(new { mensaje = "El paciente o el técnico seleccionado no es válido." });
        }
        return Ok(resultado);
    }

    [Authorize(Roles = "ROOT,DIRECTOR")]
    [HttpPatch("{asignacionPacienteId:int}/finalizar")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Finalizar(int asignacionPacienteId, [FromBody] FinalizarAsignacionSolicitudDto solicitud)
    {
        var finalizada = await _asignacionServicio.FinalizarAsync(asignacionPacienteId, solicitud);
        if (!finalizada)
        {
            return NotFound(new { mensaje = "Asignación activa no encontrada." });
        }
        return Ok(new { mensaje = "Asignación finalizada correctamente." });
    }
}