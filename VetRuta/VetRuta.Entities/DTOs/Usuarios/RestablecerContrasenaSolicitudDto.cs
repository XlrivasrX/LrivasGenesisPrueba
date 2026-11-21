using System.ComponentModel.DataAnnotations;

namespace VetRuta.Entities.DTOs.Usuarios;

public class RestablecerContrasenaSolicitudDto
{
    [Required]
    [MinLength(8)]
    public string NuevaContrasena { get; set; } = string.Empty;

    [Required]
    [Compare(nameof(NuevaContrasena))]
    public string ConfirmarContrasena { get; set; } = string.Empty;
}