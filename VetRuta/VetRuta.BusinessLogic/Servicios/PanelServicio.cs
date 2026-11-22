using VetRuta.BusinessLogic.Interfaces;
using VetRuta.DataAccess.Procedimientos;
using VetRuta.Entities.DTOs.Panel;

namespace VetRuta.BusinessLogic.Servicios;

public class PanelServicio : IPanelServicio
{
    private const int OpcionResumenGeneral = 20;
    private const int OpcionVisitasPorServicio = 21;
    private const int OpcionVisitasPorFecha = 22;
    private const int OpcionMascotasAtendidas = 25;
    private const int OpcionVisitasPorTecnico = 26;
    private const int OpcionPacientesPorEspecie = 27;

    private readonly EjecutorProcedimientos _ejecutorProcedimientos;

    public PanelServicio(EjecutorProcedimientos ejecutorProcedimientos)
    {
        _ejecutorProcedimientos = ejecutorProcedimientos;
    }

    public async Task<ResumenPanelDto?> ObtenerResumenAsync(PanelFiltroDto filtros)
    {
        return await _ejecutorProcedimientos.ConsultarUnoAsync<ResumenPanelDto>(OpcionResumenGeneral, CrearParametros(filtros));
    }

    public async Task<IEnumerable<VisitasPorServicioDto>> ObtenerVisitasPorServicioAsync(PanelFiltroDto filtros)
    {
        return await _ejecutorProcedimientos.ConsultarListaAsync<VisitasPorServicioDto>(OpcionVisitasPorServicio, CrearParametros(filtros));
    }

    public async Task<IEnumerable<VisitasPorFechaDto>> ObtenerVisitasPorFechaAsync(PanelFiltroDto filtros)
    {
        return await _ejecutorProcedimientos.ConsultarListaAsync<VisitasPorFechaDto>(OpcionVisitasPorFecha, CrearParametros(filtros));
    }

    public async Task<IEnumerable<MascotasAtendidasDto>> ObtenerMascotasAtendidasAsync(PanelFiltroDto filtros)
    {
        return await _ejecutorProcedimientos.ConsultarListaAsync<MascotasAtendidasDto>(OpcionMascotasAtendidas, CrearParametros(filtros));
    }

    public async Task<IEnumerable<VisitasPorTecnicoDto>> ObtenerVisitasPorTecnicoAsync(PanelFiltroDto filtros)
    {
        return await _ejecutorProcedimientos.ConsultarListaAsync<VisitasPorTecnicoDto>(OpcionVisitasPorTecnico, CrearParametros(filtros));
    }

    public async Task<IEnumerable<PacientesPorEspecieDto>> ObtenerPacientesPorEspecieAsync(PanelFiltroDto filtros)
    {
        return await _ejecutorProcedimientos.ConsultarListaAsync<PacientesPorEspecieDto>(OpcionPacientesPorEspecie, CrearParametros(filtros));
    }

    private static object CrearParametros(PanelFiltroDto filtros)
    {
        return new
        {
            filtros.FechaDesde,
            filtros.FechaHasta,
            filtros.MedicoResponsableUsuarioId,
            filtros.TecnicoUsuarioId
        };
    }
}
