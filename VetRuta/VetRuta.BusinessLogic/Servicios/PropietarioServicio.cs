using VetRuta.BusinessLogic.Interfaces;
using VetRuta.DataAccess.Procedimientos;
using VetRuta.Entities.DTOs.Comun;
using VetRuta.Entities.DTOs.Propietarios;

namespace VetRuta.BusinessLogic.Servicios;

public class PropietarioServicio : IPropietarioServicio
{
    private const int OpcionListarPropietarios = 10;
    private const int OpcionObtenerPropietario = 11;
    private const int OpcionCrearPropietario = 15;
    private const int OpcionActualizarPropietario = 16;

    private readonly EjecutorProcedimientos _ejecutorProcedimientos;

    public PropietarioServicio(EjecutorProcedimientos ejecutorProcedimientos)
    {
        _ejecutorProcedimientos = ejecutorProcedimientos;
    }

    public async Task<IEnumerable<PropietarioListadoDto>> ListarAsync(PropietarioFiltroDto filtros)
    {
        return await _ejecutorProcedimientos.ConsultarListaAsync<PropietarioListadoDto>(OpcionListarPropietarios,new
        {
            filtros.ZonaId,
            filtros.Activo,
            TextoBusqueda = LimpiarTexto(filtros.TextoBusqueda)
        });
    }

    public async Task<PropietarioDetalleDto?> ObtenerPorIdAsync(int propietarioId)
    {
        if (propietarioId <= 0)
        {
            return null;
        }

        return await _ejecutorProcedimientos.ConsultarUnoAsync<PropietarioDetalleDto>(OpcionObtenerPropietario,new { PropietarioId = propietarioId });
    }

    public async Task<PropietarioCreadoDto?> CrearAsync(GuardarPropietarioSolicitudDto solicitud)
    {
        return await _ejecutorProcedimientos.EjecutarAsync<PropietarioCreadoDto>(OpcionCrearPropietario,CrearParametros(solicitud));
    }

    public async Task<bool> ActualizarAsync(int propietarioId, GuardarPropietarioSolicitudDto solicitud)
    {
        var propietarioExistente = await ObtenerPorIdAsync(propietarioId);

        if (propietarioExistente is null)
        {
            return false;
        }

        var parametros = new
        {
            PropietarioId = propietarioId,
            solicitud.ZonaId,
            Nombres = solicitud.Nombres.Trim(),
            Apellidos = solicitud.Apellidos.Trim(),
            Telefono = solicitud.Telefono.Trim(),
            TelefonoAlternativo = LimpiarTexto(solicitud.TelefonoAlternativo),
            Direccion = solicitud.Direccion.Trim(),
            solicitud.Latitud,
            solicitud.Longitud,
            solicitud.Activo
        };

        var resultado = await _ejecutorProcedimientos.EjecutarAsync<ResultadoOperacionDto>(OpcionActualizarPropietario,parametros);

        return resultado is not null;
    }

    private static object CrearParametros(GuardarPropietarioSolicitudDto solicitud)
    {
        return new
        {
            solicitud.ZonaId,
            Nombres = solicitud.Nombres.Trim(),
            Apellidos = solicitud.Apellidos.Trim(),
            Telefono = solicitud.Telefono.Trim(),
            TelefonoAlternativo = LimpiarTexto(solicitud.TelefonoAlternativo),
            Direccion = solicitud.Direccion.Trim(),
            solicitud.Latitud,
            solicitud.Longitud,
            solicitud.Activo
        };
    }

    private static string? LimpiarTexto(string? texto)
    {
        return string.IsNullOrWhiteSpace(texto) ? null : texto.Trim();
    }
}