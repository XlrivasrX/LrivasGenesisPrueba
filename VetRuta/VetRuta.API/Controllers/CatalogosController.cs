using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using VetRuta.BusinessLogic.Interfaces;
using VetRuta.Entities.DTOs.Catalogos;

namespace VetRuta.API.Controllers;

[Authorize(Roles = "DIRECTOR,MEDICO,TECNICO")]
[ApiController]
[Route("catalogos")]
public class CatalogosController : ControllerBase
{
    private readonly ICatalogoServicio _catalogoServicio;

    public CatalogosController(ICatalogoServicio catalogoServicio)
    {
        _catalogoServicio = catalogoServicio;
    }

    [HttpGet("especies")]
    [ProducesResponseType(typeof(IEnumerable<EspecieDto>), StatusCodes.Status200OK)]
    public async Task<ActionResult<IEnumerable<EspecieDto>>> ListarEspecies(bool? activo, string? textoBusqueda)
    {
        var especies = await _catalogoServicio.ListarEspeciesAsync(activo, textoBusqueda);
        return Ok(especies);
    }

    [HttpGet("razas")]
    [ProducesResponseType(typeof(IEnumerable<RazaDto>), StatusCodes.Status200OK)]
    public async Task<ActionResult<IEnumerable<RazaDto>>> ListarRazas(int? especieId, bool? activo, string? textoBusqueda)
    {
        var razas = await _catalogoServicio.ListarRazasAsync(especieId, activo, textoBusqueda);
        return Ok(razas);
    }

    [HttpGet("servicios")]
    [ProducesResponseType(typeof(IEnumerable<ServicioDto>), StatusCodes.Status200OK)]
    public async Task<ActionResult<IEnumerable<ServicioDto>>> ListarServicios(int? servicioId, bool? activo, string? textoBusqueda)
    {
        var servicios = await _catalogoServicio.ListarServiciosAsync(servicioId, activo, textoBusqueda);
        return Ok(servicios);
    }

    [HttpGet("zonas")]
    [ProducesResponseType(typeof(IEnumerable<ZonaDto>), StatusCodes.Status200OK)]
    public async Task<ActionResult<IEnumerable<ZonaDto>>> ListarZonas(int? zonaId, bool? activo, string? textoBusqueda)
    {
        var zonas = await _catalogoServicio.ListarZonasAsync(zonaId, activo, textoBusqueda);
        return Ok(zonas);
    }
}
