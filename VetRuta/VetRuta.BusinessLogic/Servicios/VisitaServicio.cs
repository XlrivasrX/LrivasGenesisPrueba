using VetRuta.BusinessLogic.Interfaces;
using VetRuta.DataAccess.Procedimientos;
using VetRuta.Entities.DTOs.Visitas;

namespace VetRuta.BusinessLogic.Servicios;

public class VisitaServicio : IVisitaServicio
{
    private const int OpcionListarAgenda = 16;
    private const int OpcionObtenerDetalle = 17;
    private const int OpcionObtenerHistorial = 18;
    private const int OpcionListarEvidencias = 19;
    private const int OpcionProgramarVisita = 21;
    private const int OpcionActualizarVisita = 22;
    private const int OpcionCompletarVisita = 23;
    private const int OpcionRegistrarEvidencia = 24;

    private readonly EjecutorProcedimientos _ejecutorProcedimientos;
    private readonly IPacienteServicio _pacienteServicio;
    private readonly IUsuarioServicio _usuarioServicio;
    private readonly ICatalogoServicio _catalogoServicio;
    private readonly IAsignacionServicio _asignacionServicio;

    public VisitaServicio(
        EjecutorProcedimientos ejecutorProcedimientos,
        IPacienteServicio pacienteServicio,
        IUsuarioServicio usuarioServicio,
        ICatalogoServicio catalogoServicio,
        IAsignacionServicio asignacionServicio)
    {
        _ejecutorProcedimientos = ejecutorProcedimientos;
        _pacienteServicio = pacienteServicio;
        _usuarioServicio = usuarioServicio;
        _catalogoServicio = catalogoServicio;
        _asignacionServicio = asignacionServicio;
    }

    public async Task<IEnumerable<AgendaVisitaDto>> ListarAgendaAsync(VisitaFiltroDto filtros)
    {
        return await _ejecutorProcedimientos.ConsultarListaAsync<AgendaVisitaDto>(OpcionListarAgenda,new
        {
            filtros.PacienteId,
            filtros.ServicioId,
            filtros.MedicoResponsableUsuarioId,
            filtros.TecnicoUsuarioId,
            filtros.FechaDesde,
            filtros.FechaHasta,
            TextoBusqueda = LimpiarTexto(filtros.TextoBusqueda)
        });
    }

    public async Task<VisitaDetalleDto?> ObtenerDetalleAsync(int visitaId)
    {
        if (visitaId <= 0)
        {
            return null;
        }

        return await _ejecutorProcedimientos.ConsultarUnoAsync<VisitaDetalleDto>(OpcionObtenerDetalle,new 
        { 
            VisitaId = visitaId 
        });
    }

    public async Task<IEnumerable<HistorialClinicoDto>> ObtenerHistorialAsync(int pacienteId, DateTime? fechaDesde, DateTime? fechaHasta)
    {
        return await _ejecutorProcedimientos.ConsultarListaAsync<HistorialClinicoDto>(OpcionObtenerHistorial,new
        {
            PacienteId = pacienteId,
            FechaDesde = fechaDesde,
            FechaHasta = fechaHasta
        });
    }

    public async Task<IEnumerable<EvidenciaVisitaDto>> ListarEvidenciasAsync(int? registroVisitaId, int? visitaId)
    {
        return await _ejecutorProcedimientos.ConsultarListaAsync<EvidenciaVisitaDto>(OpcionListarEvidencias,new
        {
            RegistroVisitaId = registroVisitaId,
            VisitaId = visitaId
        });
    }

    public async Task<VisitaResultadoDto?> ProgramarAsync(GuardarVisitaSolicitudDto solicitud, int programadaPorUsuarioId)
    {
        if (!await DatosVisitaValidosAsync(solicitud))
        {
            return null;
        }

        return await _ejecutorProcedimientos.EjecutarAsync<VisitaResultadoDto>(OpcionProgramarVisita,CrearParametrosVisita(solicitud, programadaPorUsuarioId));
    }

    public async Task<bool> ActualizarAsync(int visitaId, GuardarVisitaSolicitudDto solicitud)
    {
        var visita = await ObtenerDetalleAsync(visitaId);
        if (visita is null || visita.Estado == "COMPLETADA" || !await DatosVisitaValidosAsync(solicitud))
        {
            return false;
        }

        var resultado = await _ejecutorProcedimientos.EjecutarAsync<VisitaResultadoDto>(OpcionActualizarVisita,new
        {
            VisitaId = visitaId,
            solicitud.PacienteId,
            solicitud.ServicioId,
            solicitud.MedicoResponsableUsuarioId,
            solicitud.TecnicoUsuarioId,
            solicitud.FechaProgramada,
            solicitud.PrecioProgramado,
            ObservacionesProgramacion = LimpiarTexto(solicitud.ObservacionesProgramacion)
        });
        return resultado is not null;
    }

    public async Task<RegistroVisitaResultadoDto?> CompletarAsync(int visitaId, CompletarVisitaSolicitudDto solicitud, int registradoPorUsuarioId)
    {
        var visita = await ObtenerDetalleAsync(visitaId);
        if (visita is null || visita.Estado == "COMPLETADA")
        {
            return null;
        }

        var usuarioAsignado = visita.TecnicoUsuarioId == registradoPorUsuarioId
            || visita.MedicoResponsableUsuarioId == registradoPorUsuarioId;
        if (!usuarioAsignado || solicitud.Latitud is null || solicitud.Longitud is null)
        {
            return null;
        }

        return await _ejecutorProcedimientos.EjecutarAsync<RegistroVisitaResultadoDto>(OpcionCompletarVisita,new
        {
            VisitaId = visitaId,
            solicitud.PesoKg,
            solicitud.AlturaCm,
            solicitud.TemperaturaCelsius,
            CondicionCorporal = LimpiarTexto(solicitud.CondicionCorporal),
            ObservacionesAtencion = LimpiarTexto(solicitud.Observaciones),
            Latitud = solicitud.Latitud.Value,
            Longitud = solicitud.Longitud.Value,
            RegistradoPorUsuarioId = registradoPorUsuarioId
        });
    }

    public async Task<EvidenciaResultadoDto?> RegistrarEvidenciaAsync(RegistrarEvidenciaSolicitudDto solicitud)
    {
        if (solicitud.RegistroVisitaId <= 0)
        {
            return null;
        }

        return await _ejecutorProcedimientos.EjecutarAsync<EvidenciaResultadoDto>(OpcionRegistrarEvidencia,new
        {
            solicitud.RegistroVisitaId,
            solicitud.NombreArchivo,
            solicitud.RutaArchivo,
            solicitud.TipoContenido,
            solicitud.FechaCaptura
        });
    }

    private async Task<bool> DatosVisitaValidosAsync(GuardarVisitaSolicitudDto solicitud)
    {
        if (solicitud.FechaProgramada is null || solicitud.FechaProgramada <= DateTime.Now)
        {
            return false;
        }

        var paciente = await _pacienteServicio.ObtenerPorIdAsync(solicitud.PacienteId);
        var medico = await _usuarioServicio.ObtenerPorIdAsync(solicitud.MedicoResponsableUsuarioId);
        var tecnico = await _usuarioServicio.ObtenerPorIdAsync(solicitud.TecnicoUsuarioId);
        var asignacion = await _asignacionServicio.ObtenerActivaPorPacienteAsync(solicitud.PacienteId);

        if (paciente is null || !paciente.Activo)
        {
            return false;
        }

        if (medico is null || !medico.Activo || medico.CodigoRol != "MEDICO")
        {
            return false;
        }

        if (tecnico is null || !tecnico.Activo || tecnico.CodigoRol != "TECNICO")
        {
            return false;
        }

        if (asignacion is null || asignacion.TecnicoUsuarioId != solicitud.TecnicoUsuarioId)
        {
            return false;
        }

        var servicios = await _catalogoServicio.ListarServiciosAsync(solicitud.ServicioId, true, null);
        return servicios.Any();
    }

    private static object CrearParametrosVisita(GuardarVisitaSolicitudDto solicitud, int programadaPorUsuarioId)
    {
        return new
        {
            solicitud.PacienteId,
            solicitud.ServicioId,
            solicitud.MedicoResponsableUsuarioId,
            solicitud.TecnicoUsuarioId,
            ProgramadaPorUsuarioId = programadaPorUsuarioId,
            solicitud.FechaProgramada,
            solicitud.PrecioProgramado,
            ObservacionesProgramacion = LimpiarTexto(solicitud.ObservacionesProgramacion)
        };
    }

    private static string? LimpiarTexto(string? texto)
    {
        return string.IsNullOrWhiteSpace(texto) ? null : texto.Trim();
    }
}