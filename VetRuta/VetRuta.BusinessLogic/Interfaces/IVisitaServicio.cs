using VetRuta.Entities.DTOs.Visitas;

namespace VetRuta.BusinessLogic.Interfaces;

public interface IVisitaServicio
{
    Task<IEnumerable<AgendaVisitaDto>> ListarAgendaAsync(VisitaFiltroDto filtros);

    Task<VisitaDetalleDto?> ObtenerDetalleAsync(int visitaId);

    Task<IEnumerable<HistorialClinicoDto>> ObtenerHistorialAsync(int pacienteId, DateTime? fechaDesde, DateTime? fechaHasta);

    Task<IEnumerable<EvidenciaVisitaDto>> ListarEvidenciasAsync(int? registroVisitaId, int? visitaId);

    Task<VisitaResultadoDto?> ProgramarAsync(GuardarVisitaSolicitudDto solicitud, int programadaPorUsuarioId);

    Task<bool> ActualizarAsync(int visitaId, GuardarVisitaSolicitudDto solicitud);

    Task<RegistroVisitaResultadoDto?> CompletarAsync(int visitaId, CompletarVisitaSolicitudDto solicitud, int registradoPorUsuarioId);

    Task<EvidenciaResultadoDto?> RegistrarEvidenciaAsync(RegistrarEvidenciaSolicitudDto solicitud);
}