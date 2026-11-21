using VetRuta.BusinessLogic.Interfaces;
using VetRuta.DataAccess.Procedimientos;
using VetRuta.Entities.DTOs.Roles;

namespace VetRuta.BusinessLogic.Servicios;

public class RolServicio : IRolServicio
{
    private const int OpcionListarRoles = 5;
    private readonly EjecutorProcedimientos _ejecutorProcedimientos;

    public RolServicio(EjecutorProcedimientos ejecutorProcedimientos)
    {
        _ejecutorProcedimientos = ejecutorProcedimientos;
    }

    public Task<IEnumerable<RolDto>> ObtenerRolesAsync()
    {
        return _ejecutorProcedimientos
            .ConsultarListaAsync<RolDto>(OpcionListarRoles);
    }
}
