using System.ComponentModel.DataAnnotations;

namespace VetRuta.Entities.DTOs.Autenticacion;

public class LoginSolicitudDto
{
    [Required(ErrorMessage = "El nombre de usuario es obligatorio.")]
    public string NombreUsuario { get; set; } = string.Empty;

    [Required(ErrorMessage = "La contraseña es obligatoria.")]
    public string Contrasena { get; set; } = string.Empty;
}