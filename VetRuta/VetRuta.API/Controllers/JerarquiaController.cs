using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using VetRuta.BusinessLogic.Interfaces;
using VetRuta.Entities.DTOs.Jerarquia;

namespace VetRuta.API.Controllers;

[Authorize]
[ApiController]
[Route("jerarquia")]
public class JerarquiaController : ControllerBase
{
    private readonly IJerarquiaServicio _jerarquiaServicio;

    public JerarquiaController(IJerarquiaServicio jerarquiaServicio)
    {
        _jerarquiaServicio = jerarquiaServicio;
    }

    [Authorize(Roles = "DIRECTOR")]
    [HttpGet("medico/{medicoUsuarioId:int}/tecnicos")]
    [ProducesResponseType(
        typeof(IEnumerable<SubordinadoDto>),
        StatusCodes.Status200OK)]
    public async Task<ActionResult<IEnumerable<SubordinadoDto>>>
        ListarTecnicos(int medicoUsuarioId)
    {
        var tecnicos = await _jerarquiaServicio
            .ListarSubordinadosAsync(medicoUsuarioId);

        return Ok(tecnicos);
    }

    [Authorize(Roles = "MEDICO")]
    [HttpGet("mis-tecnicos")]
    [ProducesResponseType(
        typeof(IEnumerable<SubordinadoDto>),
        StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<ActionResult<IEnumerable<SubordinadoDto>>>
        ListarMisTecnicos()
    {
        var usuarioIdTexto = User.FindFirstValue(
            ClaimTypes.NameIdentifier);

        if (!int.TryParse(usuarioIdTexto, out var usuarioId))
        {
            return Unauthorized();
        }

        var tecnicos = await _jerarquiaServicio
            .ListarSubordinadosAsync(usuarioId);

        return Ok(tecnicos);
    }

    [Authorize(Roles = "DIRECTOR")]
    [HttpPost("asignar-tecnico")]
    [ProducesResponseType(
        typeof(AsignacionJerarquiaResultadoDto),
        StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<ActionResult<AsignacionJerarquiaResultadoDto>>
        AsignarTecnico(AsignarTecnicoSolicitudDto solicitud)
    {
        var usuarioIdTexto = User.FindFirstValue(
            ClaimTypes.NameIdentifier);

        if (!int.TryParse(usuarioIdTexto, out var usuarioId))
        {
            return Unauthorized();
        }

        var resultado = await _jerarquiaServicio.AsignarTecnicoAsync(
            solicitud,
            usuarioId);

        if (resultado is null)
        {
            return BadRequest(new
            {
                mensaje =
                    "El médico o el técnico seleccionado no es válido."
            });
        }

        return Ok(resultado);
    }
}
