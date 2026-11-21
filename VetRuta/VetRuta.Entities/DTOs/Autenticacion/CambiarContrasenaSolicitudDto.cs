using System.ComponentModel.DataAnnotations;

namespace VetRuta.Entities.DTOs.Autenticacion;

public class CambiarContrasenaSolicitudDto
{
    [Required]
    public string ContrasenaActual { get; set; } = string.Empty;

    [Required]
    [MinLength(8)]
    public string NuevaContrasena { get; set; } = string.Empty;

    [Required]
    [Compare(nameof(NuevaContrasena))]
    public string ConfirmarContrasena { get; set; } = string.Empty;
}