using VetRuta.BusinessLogic.Interfaces;
using VetRuta.DataAccess.Procedimientos;
using VetRuta.Entities.DTOs.Asignaciones;

namespace VetRuta.BusinessLogic.Servicios;

public class AsignacionServicio : IAsignacionServicio
{
    private const int OpcionObtenerAsignacionActiva = 14;
    private const int OpcionListarPorTecnico = 15;
    private const int OpcionAsignarPaciente = 19;
    private const int OpcionFinalizarAsignacion = 20;

    private readonly EjecutorProcedimientos _ejecutorProcedimientos;
    private readonly IPacienteServicio _pacienteServicio;
    private readonly IUsuarioServicio _usuarioServicio;

    public AsignacionServicio(EjecutorProcedimientos ejecutorProcedimientos, IPacienteServicio pacienteServicio, IUsuarioServicio usuarioServicio)
    {
        _ejecutorProcedimientos = ejecutorProcedimientos;
        _pacienteServicio = pacienteServicio;
        _usuarioServicio = usuarioServicio;
    }

    public async Task<AsignacionActivaDto?> ObtenerActivaPorPacienteAsync(int pacienteId)
    {
        if (pacienteId <= 0)
        {
            return null;
        }

        return await _ejecutorProcedimientos.ConsultarUnoAsync<AsignacionActivaDto>(OpcionObtenerAsignacionActiva,new 
        { 
            PacienteId = pacienteId 
        });
    }

    public async Task<IEnumerable<PacienteAsignadoDto>> ListarPorTecnicoAsync(int tecnicoUsuarioId, PacienteAsignadoFiltroDto filtros)
    {
        return await _ejecutorProcedimientos.ConsultarListaAsync<PacienteAsignadoDto>(OpcionListarPorTecnico,new
        {
            TecnicoUsuarioId = tecnicoUsuarioId,
            filtros.Activo,
            TextoBusqueda = LimpiarTexto(filtros.TextoBusqueda)
        });
    }

    public async Task<IEnumerable<PacienteAsignadoDto>> ListarPorMedicoAsync(int medicoUsuarioId, PacienteAsignadoFiltroDto filtros)
    {
        return await _ejecutorProcedimientos.ConsultarListaAsync<PacienteAsignadoDto>(OpcionListarPorTecnico,new
        {
            MedicoResponsableUsuarioId = medicoUsuarioId,
            filtros.Activo,
            TextoBusqueda = LimpiarTexto(filtros.TextoBusqueda)
        });
    }

    public async Task<AsignacionResultadoDto?> AsignarAsync(AsignarPacienteSolicitudDto solicitud, int asignadoPorUsuarioId)
    {
        var paciente = await _pacienteServicio.ObtenerPorIdAsync(solicitud.PacienteId);
        var tecnico = await _usuarioServicio.ObtenerPorIdAsync(solicitud.TecnicoUsuarioId);

        if (paciente is null || !paciente.Activo)
        {
            return null;
        }

        if (tecnico is null || !tecnico.Activo || tecnico.CodigoRol != "TECNICO")
        {
            return null;
        }

        return await _ejecutorProcedimientos.EjecutarAsync<AsignacionResultadoDto>(OpcionAsignarPaciente,new
        {
            solicitud.PacienteId,
            solicitud.TecnicoUsuarioId,
            AsignadoPorUsuarioId = asignadoPorUsuarioId,
            Observacion = LimpiarTexto(solicitud.Observacion)
        });
    }

    public async Task<bool> FinalizarAsync(int asignacionPacienteId, FinalizarAsignacionSolicitudDto solicitud)
    {
        if (asignacionPacienteId <= 0)
        {
            return false;
        }

        var resultado = await _ejecutorProcedimientos.EjecutarAsync<AsignacionResultadoDto>(OpcionFinalizarAsignacion,new
        {
            AsignacionPacienteId = asignacionPacienteId,
            Observacion = LimpiarTexto(solicitud.Observacion)
        });

        return resultado is not null;
    }

    private static string? LimpiarTexto(string? texto)
    {
        return string.IsNullOrWhiteSpace(texto) ? null : texto.Trim();
    }
}
