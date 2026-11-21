using VetRuta.Entities.DTOs.Catalogos;

namespace VetRuta.BusinessLogic.Interfaces;

public interface ICatalogoServicio
{
    Task<IEnumerable<EspecieDto>> ListarEspeciesAsync(bool? activo, string? textoBusqueda);

    Task<IEnumerable<RazaDto>> ListarRazasAsync(int? especieId, bool? activo, string? textoBusqueda);

    Task<IEnumerable<ServicioDto>> ListarServiciosAsync(int? servicioId, bool? activo, string? textoBusqueda);

    Task<IEnumerable<ZonaDto>> ListarZonasAsync(int? zonaId, bool? activo, string? textoBusqueda);
}