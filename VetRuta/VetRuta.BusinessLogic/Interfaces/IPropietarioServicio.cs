using VetRuta.Entities.DTOs.Propietarios;

namespace VetRuta.BusinessLogic.Interfaces;

public interface IPropietarioServicio
{
    Task<IEnumerable<PropietarioListadoDto>> ListarAsync(PropietarioFiltroDto filtros);

    Task<PropietarioDetalleDto?> ObtenerPorIdAsync(int propietarioId);

    Task<PropietarioCreadoDto?> CrearAsync(GuardarPropietarioSolicitudDto solicitud);

    Task<bool> ActualizarAsync(int propietarioId, GuardarPropietarioSolicitudDto solicitud);
}