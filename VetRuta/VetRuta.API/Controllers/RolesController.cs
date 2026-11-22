using Microsoft.AspNetCore.Mvc;
using VetRuta.BusinessLogic.Interfaces;
using VetRuta.Entities.DTOs.Roles;
using Microsoft.AspNetCore.Authorization;

namespace VetRuta.API.Controllers;

[Authorize(Roles = "ROOT")]
[ApiController]
[Route("roles")]
public class RolesController : ControllerBase
{
    private readonly IRolServicio _rolServicio;

    public RolesController(IRolServicio rolServicio)
    {
        _rolServicio = rolServicio;
    }

    [HttpGet]
    [ProducesResponseType(typeof(IEnumerable<RolDto>), StatusCodes.Status200OK)]
    public async Task<ActionResult<IEnumerable<RolDto>>> ObtenerRoles()
    {
        var roles = await _rolServicio.ObtenerRolesAsync();

        return Ok(roles);
    }
}
