using VetRuta.BusinessLogic.Interfaces;
using VetRuta.DataAccess.Procedimientos;
using VetRuta.Entities.DTOs.Catalogos;

namespace VetRuta.BusinessLogic.Servicios;

public class CatalogoServicio : ICatalogoServicio
{
    private const int OpcionListarEspecies = 6;
    private const int OpcionListarRazas = 7;
    private const int OpcionListarServicios = 8;
    private const int OpcionListarZonas = 9;

    private readonly EjecutorProcedimientos _ejecutorProcedimientos;

    public CatalogoServicio(EjecutorProcedimientos ejecutorProcedimientos)
    {
        _ejecutorProcedimientos = ejecutorProcedimientos;
    }

    public async Task<IEnumerable<EspecieDto>> ListarEspeciesAsync(bool? activo, string? textoBusqueda)
    {
        return await _ejecutorProcedimientos.ConsultarListaAsync<EspecieDto>(OpcionListarEspecies,new
        {
            Activo = activo,
            TextoBusqueda = LimpiarTexto(textoBusqueda)
        });
    }

    public async Task<IEnumerable<RazaDto>> ListarRazasAsync(int? especieId, bool? activo, string? textoBusqueda)
    {
        return await _ejecutorProcedimientos.ConsultarListaAsync<RazaDto>(OpcionListarRazas,new
        {
            EspecieId = especieId,
            Activo = activo,
            TextoBusqueda = LimpiarTexto(textoBusqueda)
        });
    }

    public async Task<IEnumerable<ServicioDto>> ListarServiciosAsync(int? servicioId, bool? activo, string? textoBusqueda)
    {
        return await _ejecutorProcedimientos.ConsultarListaAsync<ServicioDto>(OpcionListarServicios,new
        {
            ServicioId = servicioId,
            Activo = activo,
            TextoBusqueda = LimpiarTexto(textoBusqueda)
        });
    }

    public async Task<IEnumerable<ZonaDto>> ListarZonasAsync(int? zonaId, bool? activo, string? textoBusqueda)
    {
        return await _ejecutorProcedimientos.ConsultarListaAsync<ZonaDto>(OpcionListarZonas,new
        {
            ZonaId = zonaId,
            Activo = activo,
            TextoBusqueda = LimpiarTexto(textoBusqueda)
        });
    }

    private static string? LimpiarTexto(string? texto)
    {
        return string.IsNullOrWhiteSpace(texto) ? null : texto.Trim();
    }
}