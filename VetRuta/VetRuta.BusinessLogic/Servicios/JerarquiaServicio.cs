using VetRuta.BusinessLogic.Interfaces;
using VetRuta.DataAccess.Procedimientos;
using VetRuta.Entities.DTOs.Jerarquia;

namespace VetRuta.BusinessLogic.Servicios;

public class JerarquiaServicio : IJerarquiaServicio
{
    private const int OpcionListarSubordinados = 4;
    private const int OpcionAsignarSubordinado = 6;

    private readonly EjecutorProcedimientos _ejecutorProcedimientos;
    private readonly IUsuarioServicio _usuarioServicio;

    public JerarquiaServicio(
        EjecutorProcedimientos ejecutorProcedimientos,
        IUsuarioServicio usuarioServicio)
    {
        _ejecutorProcedimientos = ejecutorProcedimientos;
        _usuarioServicio = usuarioServicio;
    }

    public async Task<IEnumerable<SubordinadoDto>> ListarSubordinadosAsync(
        int usuarioSuperiorId)
    {
        if (usuarioSuperiorId <= 0)
        {
            return [];
        }

        return await _ejecutorProcedimientos
            .ConsultarListaAsync<SubordinadoDto>(
                OpcionListarSubordinados,
                new
                {
                    UsuarioSuperiorId = usuarioSuperiorId
                });
    }

    public async Task<AsignacionJerarquiaResultadoDto?> AsignarTecnicoAsync(
        AsignarTecnicoSolicitudDto solicitud,
        int creadoPorUsuarioId)
    {
        var medico = await _usuarioServicio.ObtenerPorIdAsync(
            solicitud.MedicoUsuarioId);

        var tecnico = await _usuarioServicio.ObtenerPorIdAsync(
            solicitud.TecnicoUsuarioId);

        if (medico is null ||
            !medico.Activo ||
            medico.CodigoRol != "MEDICO")
        {
            return null;
        }

        if (tecnico is null ||
            !tecnico.Activo ||
            tecnico.CodigoRol != "TECNICO")
        {
            return null;
        }

        return await _ejecutorProcedimientos
            .EjecutarAsync<AsignacionJerarquiaResultadoDto>(
                OpcionAsignarSubordinado,
                new
                {
                    UsuarioSuperiorId = solicitud.MedicoUsuarioId,
                    UsuarioSubordinadoId = solicitud.TecnicoUsuarioId,
                    Observacion = LimpiarTexto(solicitud.Observacion),
                    CreadoPorUsuarioId = creadoPorUsuarioId
                });
    }

    private static string? LimpiarTexto(string? texto)
    {
        return string.IsNullOrWhiteSpace(texto)
            ? null
            : texto.Trim();
    }
}