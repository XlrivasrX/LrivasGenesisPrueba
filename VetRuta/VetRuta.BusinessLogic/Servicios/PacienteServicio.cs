using VetRuta.BusinessLogic.Interfaces;
using VetRuta.DataAccess.Procedimientos;
using VetRuta.Entities.DTOs.Comun;
using VetRuta.Entities.DTOs.Pacientes;

namespace VetRuta.BusinessLogic.Servicios;

public class PacienteServicio : IPacienteServicio
{
    private const int OpcionListarPacientes = 12;
    private const int OpcionObtenerPaciente = 13;
    private const int OpcionCrearPaciente = 17;
    private const int OpcionActualizarPaciente = 18;

    private readonly EjecutorProcedimientos _ejecutorProcedimientos;

    public PacienteServicio(EjecutorProcedimientos ejecutorProcedimientos)
    {
        _ejecutorProcedimientos = ejecutorProcedimientos;
    }

    public async Task<IEnumerable<PacienteListadoDto>> ListarAsync(PacienteFiltroDto filtros)
    {
        return await _ejecutorProcedimientos.ConsultarListaAsync<PacienteListadoDto>(OpcionListarPacientes,new
        {
            filtros.PropietarioId,
            filtros.EspecieId,
            filtros.Activo,
            TextoBusqueda = LimpiarTexto(filtros.TextoBusqueda)
        });
    }

    public async Task<PacienteDetalleDto?> ObtenerPorIdAsync(int pacienteId)
    {
        if (pacienteId <= 0)
        {
            return null;
        }

        return await _ejecutorProcedimientos.ConsultarUnoAsync<PacienteDetalleDto>(OpcionObtenerPaciente,new { PacienteId = pacienteId });
    }

    public async Task<PacienteCreadoDto?> CrearAsync(GuardarPacienteSolicitudDto solicitud, int creadoPorUsuarioId)
    {
        return await _ejecutorProcedimientos.EjecutarAsync<PacienteCreadoDto>(OpcionCrearPaciente,new
        {
            solicitud.PropietarioId,
            solicitud.EspecieId,
            solicitud.RazaId,
            NombrePaciente = solicitud.Nombre.Trim(),
            solicitud.FechaNacimientoAproximada,
            RutaFoto = LimpiarTexto(solicitud.RutaFoto),
            Observaciones = LimpiarTexto(solicitud.Observaciones),
            CreadoPorUsuarioId = creadoPorUsuarioId,
            solicitud.Activo
        });
    }

    public async Task<bool> ActualizarAsync(int pacienteId, GuardarPacienteSolicitudDto solicitud)
    {
        var pacienteExistente = await ObtenerPorIdAsync(pacienteId);

        if (pacienteExistente is null)
        {
            return false;
        }

        var resultado = await _ejecutorProcedimientos.EjecutarAsync<ResultadoOperacionDto>(OpcionActualizarPaciente,new
        {
            PacienteId = pacienteId,
            solicitud.PropietarioId,
            solicitud.EspecieId,
            solicitud.RazaId,
            NombrePaciente = solicitud.Nombre.Trim(),
            solicitud.FechaNacimientoAproximada,
            RutaFoto = LimpiarTexto(solicitud.RutaFoto),
            Observaciones = LimpiarTexto(solicitud.Observaciones),
            solicitud.Activo
        });

        return resultado is not null;
    }

    private static string? LimpiarTexto(string? texto)
    {
        return string.IsNullOrWhiteSpace(texto) ? null : texto.Trim();
    }
}
