using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using VetRuta.BusinessLogic.Interfaces;
using VetRuta.Entities.DTOs.Panel;

namespace VetRuta.API.Controllers;

[Authorize(Roles = "DIRECTOR,MEDICO,TECNICO")]
[ApiController]
[Route("panel")]
public class PanelController : ControllerBase
{
    private readonly IPanelServicio _panelServicio;

    public PanelController(IPanelServicio panelServicio)
    {
        _panelServicio = panelServicio;
    }

    [HttpGet("resumen")]
    [ProducesResponseType(typeof(ResumenPanelDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<ActionResult<ResumenPanelDto>> ObtenerResumen([FromQuery] PanelFiltroDto filtros)
    {
        if (!AplicarAlcance(filtros))
        {
            return Unauthorized();
        }

        if (!FechasValidas(filtros))
        {
            return BadRequest(new { mensaje = "La fecha inicial no puede ser mayor que la fecha final." });
        }

        var resumen = await _panelServicio.ObtenerResumenAsync(filtros);
        return Ok(resumen);
    }

    [HttpGet("visitas-por-servicio")]
    [ProducesResponseType(typeof(IEnumerable<VisitasPorServicioDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<ActionResult<IEnumerable<VisitasPorServicioDto>>> ObtenerVisitasPorServicio([FromQuery] PanelFiltroDto filtros)
    {
        if (!AplicarAlcance(filtros))
        {
            return Unauthorized();
        }

        if (!FechasValidas(filtros))
        {
            return BadRequest(new { mensaje = "La fecha inicial no puede ser mayor que la fecha final." });
        }

        var visitas = await _panelServicio.ObtenerVisitasPorServicioAsync(filtros);
        return Ok(visitas);
    }

    [HttpGet("visitas-por-fecha")]
    [ProducesResponseType(typeof(IEnumerable<VisitasPorFechaDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<ActionResult<IEnumerable<VisitasPorFechaDto>>> ObtenerVisitasPorFecha([FromQuery] PanelFiltroDto filtros)
    {
        if (!AplicarAlcance(filtros))
        {
            return Unauthorized();
        }

        if (!FechasValidas(filtros))
        {
            return BadRequest(new { mensaje = "La fecha inicial no puede ser mayor que la fecha final." });
        }

        var visitas = await _panelServicio.ObtenerVisitasPorFechaAsync(filtros);
        return Ok(visitas);
    }

    [HttpGet("mascotas-atendidas")]
    [ProducesResponseType(typeof(IEnumerable<MascotasAtendidasDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<ActionResult<IEnumerable<MascotasAtendidasDto>>> ObtenerMascotasAtendidas([FromQuery] PanelFiltroDto filtros)
    {
        if (!AplicarAlcance(filtros))
        {
            return Unauthorized();
        }

        if (!FechasValidas(filtros))
        {
            return BadRequest(new { mensaje = "La fecha inicial no puede ser mayor que la fecha final." });
        }

        var mascotas = await _panelServicio.ObtenerMascotasAtendidasAsync(filtros);
        return Ok(mascotas);
    }

    [HttpGet("visitas-por-tecnico")]
    [ProducesResponseType(typeof(IEnumerable<VisitasPorTecnicoDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<ActionResult<IEnumerable<VisitasPorTecnicoDto>>> ObtenerVisitasPorTecnico([FromQuery] PanelFiltroDto filtros)
    {
        if (!AplicarAlcance(filtros))
        {
            return Unauthorized();
        }

        if (!FechasValidas(filtros))
        {
            return BadRequest(new { mensaje = "La fecha inicial no puede ser mayor que la fecha final." });
        }

        var visitas = await _panelServicio.ObtenerVisitasPorTecnicoAsync(filtros);
        return Ok(visitas);
    }

    [HttpGet("pacientes-por-especie")]
    [ProducesResponseType(typeof(IEnumerable<PacientesPorEspecieDto>), StatusCodes.Status200OK)]
    public async Task<ActionResult<IEnumerable<PacientesPorEspecieDto>>> ObtenerPacientesPorEspecie([FromQuery] PanelFiltroDto filtros)
    {
        if (!AplicarAlcance(filtros))
        {
            return Unauthorized();
        }

        var pacientes = await _panelServicio.ObtenerPacientesPorEspecieAsync(filtros);
        return Ok(pacientes);
    }

    private static bool FechasValidas(PanelFiltroDto filtros)
    {
        return filtros.FechaDesde is null
            || filtros.FechaHasta is null
            || filtros.FechaDesde.Value.Date <= filtros.FechaHasta.Value.Date;
    }

    private bool AplicarAlcance(PanelFiltroDto filtros)
    {
        filtros.MedicoResponsableUsuarioId = null;
        filtros.TecnicoUsuarioId = null;

        if (User.IsInRole("DIRECTOR"))
        {
            return true;
        }

        var usuarioIdTexto = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!int.TryParse(usuarioIdTexto, out var usuarioId))
        {
            return false;
        }

        if (User.IsInRole("MEDICO"))
        {
            filtros.MedicoResponsableUsuarioId = usuarioId;
            return true;
        }

        if (User.IsInRole("TECNICO"))
        {
            filtros.TecnicoUsuarioId = usuarioId;
            return true;
        }

        return false;
    }
}
