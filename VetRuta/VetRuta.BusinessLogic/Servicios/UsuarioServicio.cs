using VetRuta.BusinessLogic.Interfaces;
using VetRuta.DataAccess.Procedimientos;
using VetRuta.Entities.DTOs.Usuarios;
using VetRuta.Entities.DTOs.Comun;

namespace VetRuta.BusinessLogic.Servicios;

public class UsuarioServicio : IUsuarioServicio
{
    private const int OpcionCrearUsuario = 1;
    private const int OpcionListarUsuarios = 2;
    private const int OpcionObtenerUsuario = 3;
    private const int OpcionActualizarUsuario = 2;
    private const int OpcionCambiarEstadoUsuario = 3;
    private const int OpcionRestablecerContrasena = 4;

    private readonly EjecutorProcedimientos _ejecutorProcedimientos;

    public UsuarioServicio(EjecutorProcedimientos ejecutorProcedimientos)
    {
        _ejecutorProcedimientos = ejecutorProcedimientos;
    }

    public async Task<IEnumerable<UsuarioListadoDto>> ListarAsync(UsuarioFiltroDto filtros)
    {
        var textoBusqueda = string.IsNullOrWhiteSpace(
            filtros.TextoBusqueda)
            ? null
            : filtros.TextoBusqueda.Trim();

        return await _ejecutorProcedimientos
            .ConsultarListaAsync<UsuarioListadoDto>(
                OpcionListarUsuarios,
                new
                {
                    filtros.RolId,
                    filtros.Activo,
                    TextoBusqueda = textoBusqueda
                });
    }

    public async Task<UsuarioDetalleDto?> ObtenerPorIdAsync(int usuarioId)
    {
        if (usuarioId <= 0)
        {
            return null;
        }

        return await _ejecutorProcedimientos.ConsultarUnoAsync<UsuarioDetalleDto>(OpcionObtenerUsuario,new { UsuarioId = usuarioId });
    }

    public async Task<UsuarioCreadoDto?> CrearAsync(CrearUsuarioSolicitudDto solicitud)
    {
        var contrasenaHash = BCrypt.Net.BCrypt.HashPassword(solicitud.ContrasenaTemporal, workFactor: 12);

        return await _ejecutorProcedimientos.EjecutarAsync<UsuarioCreadoDto>(
            OpcionCrearUsuario,
            new
            {
                solicitud.RolId,
                NombreUsuario = solicitud.NombreUsuario.Trim(),
                ContrasenaHash = contrasenaHash,
                Nombres = solicitud.Nombres.Trim(),
                Apellidos = solicitud.Apellidos.Trim(),
                Correo = string.IsNullOrWhiteSpace(solicitud.Correo) ? null : solicitud.Correo.Trim(),
                Telefono = string.IsNullOrWhiteSpace(solicitud.Telefono) ? null : solicitud.Telefono.Trim(),
                DebeCambiarContrasena = true
            });
    }

    public async Task<bool> ActualizarAsync(int usuarioId, ActualizarUsuarioSolicitudDto solicitud)
    {
        if (usuarioId <= 0)
        {
            return false;
        }

        var usuarioExistente = await ObtenerPorIdAsync(usuarioId);

        if (usuarioExistente is null)
        {
            return false;
        }

        var resultado = await _ejecutorProcedimientos.EjecutarAsync<ResultadoOperacionDto>(
            OpcionActualizarUsuario,
            new
            {
                UsuarioId = usuarioId,
                solicitud.RolId,
                Nombres = solicitud.Nombres.Trim(),
                Apellidos = solicitud.Apellidos.Trim(),
                Correo = string.IsNullOrWhiteSpace(solicitud.Correo) ? null : solicitud.Correo.Trim(),
                Telefono = string.IsNullOrWhiteSpace(solicitud.Telefono) ? null : solicitud.Telefono.Trim()
            });
        return resultado is not null;
    }

    public async Task<bool> CambiarEstadoAsync(int usuarioId, bool activo)
    {
        if (usuarioId <= 0)
        {
            return false;
        }

        var usuarioExistente = await ObtenerPorIdAsync(usuarioId);

        if (usuarioExistente is null)
        {
            return false;
        }

        var resultado = await _ejecutorProcedimientos.EjecutarAsync<ResultadoOperacionDto>(
            OpcionCambiarEstadoUsuario,
            new
            {
                UsuarioId = usuarioId,
                Activo = activo
            });
        return resultado is not null;
    }

    public async Task<bool> RestablecerContrasenaAsync(int usuarioId, RestablecerContrasenaSolicitudDto solicitud)
    {
        if (usuarioId <= 0)
        {
            return false;
        }

        var usuarioExistente = await ObtenerPorIdAsync(usuarioId);

        if (usuarioExistente is null)
        {
            return false;
        }

        var contrasenaHash = BCrypt.Net.BCrypt.HashPassword(solicitud.NuevaContrasena, workFactor: 12);

        var resultado = await _ejecutorProcedimientos.EjecutarAsync<ResultadoOperacionDto>(
            OpcionRestablecerContrasena,
            new
            {
                UsuarioId = usuarioId,
                ContrasenaHash = contrasenaHash,
                DebeCambiarContrasena = true
            });

        return resultado is not null;
    }
}