using VetRuta.Entities.DTOs.Usuarios;

namespace VetRuta.BusinessLogic.Interfaces;

public interface IUsuarioServicio
{
    Task<IEnumerable<UsuarioListadoDto>> ListarAsync(UsuarioFiltroDto filtros);

    Task<UsuarioDetalleDto?> ObtenerPorIdAsync(int usuarioId);

    Task<UsuarioCreadoDto?> CrearAsync(CrearUsuarioSolicitudDto solicitud);

    Task<bool> ActualizarAsync(int usuarioId, ActualizarUsuarioSolicitudDto solicitud);

    Task<bool> CambiarEstadoAsync(int usuarioId, bool activo);

    Task<bool> RestablecerContrasenaAsync(int usuarioId, RestablecerContrasenaSolicitudDto solicitud);
}