using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using VetRuta.BusinessLogic.Interfaces;
using VetRuta.Entities.DTOs.Panel;

namespace VetRuta.API.Controllers;

[Authorize(Roles = "ROOT,DIRECTOR")]
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
        if (!FechasValidas(filtros))
        {
            return BadRequest(new { mensaje = "La fecha inicial no puede ser mayor que la fecha final." });
        }

        var visitas = await _panelServicio.ObtenerVisitasPorTecnicoAsync(filtros);
        return Ok(visitas);
    }

    private static bool FechasValidas(PanelFiltroDto filtros)
    {
        return filtros.FechaDesde is null
            || filtros.FechaHasta is null
            || filtros.FechaDesde.Value.Date <= filtros.FechaHasta.Value.Date;
    }
}