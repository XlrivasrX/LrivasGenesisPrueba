using VetRuta.Entities.DTOs.Autenticacion;

namespace VetRuta.BusinessLogic.Interfaces;
public interface IAutenticacionServicio
{
    Task<LoginRespuestaDto?> IniciarSesionAsync(
        LoginSolicitudDto solicitud,
        string? direccionIp,
        string? dispositivo);

    Task<LoginRespuestaDto?> RenovarTokenAsync(
    RenovarTokenSolicitudDto solicitud,
    string? direccionIp,
    string? dispositivo);

    Task<bool> CerrarSesionAsync(CerrarSesionSolicitudDto solicitud);

    Task<bool> CambiarContrasenaAsync(string nombreUsuario,CambiarContrasenaSolicitudDto solicitud);
}