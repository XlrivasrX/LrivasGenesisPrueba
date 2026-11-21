using VetRuta.Entities.DTOs.Pacientes;

namespace VetRuta.BusinessLogic.Interfaces;

public interface IPacienteServicio
{
    Task<IEnumerable<PacienteListadoDto>> ListarAsync(PacienteFiltroDto filtros);
    Task<PacienteDetalleDto?> ObtenerPorIdAsync(int pacienteId);
    Task<PacienteCreadoDto?> CrearAsync(GuardarPacienteSolicitudDto solicitud, int creadoPorUsuarioId);
    Task<bool> ActualizarAsync(int pacienteId, GuardarPacienteSolicitudDto solicitud);
}
