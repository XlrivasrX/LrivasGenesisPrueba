using VetRuta.Entities.DTOs.Roles;

namespace VetRuta.BusinessLogic.Interfaces;

public interface IRolServicio
{
    Task<IEnumerable<RolDto>> ObtenerRolesAsync();
}
