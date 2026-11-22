using VetRuta.Entities.DTOs.Jerarquia;

namespace VetRuta.BusinessLogic.Interfaces;

public interface IJerarquiaServicio
{
    Task<IEnumerable<SubordinadoDto>> ListarSubordinadosAsync(int usuarioSuperiorId);

    Task<AsignacionJerarquiaResultadoDto?> AsignarTecnicoAsync(AsignarTecnicoSolicitudDto solicitud,int creadoPorUsuarioId);
}