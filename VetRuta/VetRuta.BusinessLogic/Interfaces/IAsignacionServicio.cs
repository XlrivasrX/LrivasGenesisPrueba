using VetRuta.Entities.DTOs.Asignaciones;

namespace VetRuta.BusinessLogic.Interfaces;

public interface IAsignacionServicio
{
    Task<AsignacionActivaDto?> ObtenerActivaPorPacienteAsync(int pacienteId);

    Task<IEnumerable<PacienteAsignadoDto>> ListarPorTecnicoAsync(int tecnicoUsuarioId, PacienteAsignadoFiltroDto filtros);

    Task<AsignacionResultadoDto?> AsignarAsync(AsignarPacienteSolicitudDto solicitud, int asignadoPorUsuarioId);

    Task<bool> FinalizarAsync(int asignacionPacienteId, FinalizarAsignacionSolicitudDto solicitud);
}