using VetRuta.BusinessLogic.Interfaces;
using VetRuta.DataAccess.Procedimientos;
using VetRuta.Entities.DTOs.Auditoria;

namespace VetRuta.BusinessLogic.Servicios;

public class AuditoriaServicio : IAuditoriaServicio
{
    private const int OpcionConsultarAuditoria = 23;
    private const int OpcionRegistrarAuditoria = 25;

    private readonly EjecutorProcedimientos _ejecutorProcedimientos;

    public AuditoriaServicio(EjecutorProcedimientos ejecutorProcedimientos)
    {
        _ejecutorProcedimientos = ejecutorProcedimientos;
    }

    public async Task<IEnumerable<AuditoriaDto>> ListarAsync(AuditoriaFiltroDto filtros)
    {
        return await _ejecutorProcedimientos.ConsultarListaAsync<AuditoriaDto>(OpcionConsultarAuditoria, new
        {
            filtros.UsuarioId,
            Accion = LimpiarTexto(filtros.Accion),
            Entidad = LimpiarTexto(filtros.Entidad),
            filtros.FechaDesde,
            filtros.FechaHasta,
            TextoBusqueda = LimpiarTexto(filtros.TextoBusqueda)
        });
    }

    public async Task<AuditoriaResultadoDto?> RegistrarAsync(RegistrarAuditoriaSolicitudDto solicitud)
    {
        if (string.IsNullOrWhiteSpace(solicitud.Accion) || string.IsNullOrWhiteSpace(solicitud.Entidad))
        {
            throw new ArgumentException("La acción y la entidad son obligatorias.");
        }

        return await _ejecutorProcedimientos.EjecutarAsync<AuditoriaResultadoDto>(OpcionRegistrarAuditoria, new
        {
            solicitud.UsuarioId,
            Accion = solicitud.Accion.Trim(),
            Entidad = solicitud.Entidad.Trim(),
            EntidadId = LimpiarTexto(solicitud.EntidadId),
            Detalle = LimpiarTexto(solicitud.Detalle),
            DireccionIp = LimpiarTexto(solicitud.DireccionIp)
        });
    }

    private static string? LimpiarTexto(string? texto)
    {
        return string.IsNullOrWhiteSpace(texto) ? null : texto.Trim();
    }
}