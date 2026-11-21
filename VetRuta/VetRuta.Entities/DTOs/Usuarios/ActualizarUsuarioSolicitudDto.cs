using System.ComponentModel.DataAnnotations;

namespace VetRuta.Entities.DTOs.Usuarios;

public class ActualizarUsuarioSolicitudDto
{
    [Range(1, int.MaxValue)]
    public int RolId { get; set; }

    [Required]
    [MaxLength(100)]
    public string Nombres { get; set; } = string.Empty;

    [Required]
    [MaxLength(100)]
    public string Apellidos { get; set; } = string.Empty;

    [EmailAddress]
    [MaxLength(254)]
    public string? Correo { get; set; }

    [MaxLength(25)]
    public string? Telefono { get; set; }
}