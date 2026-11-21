using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using VetRuta.BusinessLogic.Interfaces;
using VetRuta.Entities.DTOs.Auditoria;

namespace VetRuta.API.Controllers;

[ApiController]
[Route("auditoria")]
[Authorize(Roles = "ROOT")]
public class AuditoriaController : ControllerBase
{
    private readonly IAuditoriaServicio _auditoriaServicio;

    public AuditoriaController(IAuditoriaServicio auditoriaServicio)
    {
        _auditoriaServicio = auditoriaServicio;
    }

    [HttpGet]
    [ProducesResponseType(typeof(IEnumerable<AuditoriaDto>), StatusCodes.Status200OK)]
    public async Task<ActionResult<IEnumerable<AuditoriaDto>>> Listar([FromQuery] AuditoriaFiltroDto filtros)
    {
        var registros = await _auditoriaServicio.ListarAsync(filtros);
        return Ok(registros);
    }
}