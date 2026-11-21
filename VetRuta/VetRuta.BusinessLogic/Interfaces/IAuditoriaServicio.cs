using VetRuta.Entities.DTOs.Auditoria;

namespace VetRuta.BusinessLogic.Interfaces
{
    public interface IAuditoriaServicio
    {
        Task<IEnumerable<AuditoriaDto>> ListarAsync(AuditoriaFiltroDto filtros);
        Task<AuditoriaResultadoDto?> RegistrarAsync(RegistrarAuditoriaSolicitudDto solicitud);
    }
}