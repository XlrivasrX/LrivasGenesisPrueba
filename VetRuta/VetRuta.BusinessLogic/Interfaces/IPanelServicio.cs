using VetRuta.Entities.DTOs.Panel;

namespace VetRuta.BusinessLogic.Interfaces;

public interface IPanelServicio
{
    Task<ResumenPanelDto?> ObtenerResumenAsync(PanelFiltroDto filtros);

    Task<IEnumerable<VisitasPorServicioDto>> ObtenerVisitasPorServicioAsync(PanelFiltroDto filtros);

    Task<IEnumerable<VisitasPorFechaDto>> ObtenerVisitasPorFechaAsync(PanelFiltroDto filtros);
}