using System.ComponentModel.DataAnnotations;

namespace VetRuta.Entities.DTOs.Propietarios;

public class GuardarPropietarioSolicitudDto
{
    public int? ZonaId { get; set; }

    [Required]
    [MaxLength(100)]
    public string Nombres { get; set; } = string.Empty;

    [Required]
    [MaxLength(100)]
    public string Apellidos { get; set; } = string.Empty;

    [Required]
    [MaxLength(25)]
    public string Telefono { get; set; } = string.Empty;

    [MaxLength(25)]
    public string? TelefonoAlternativo { get; set; }

    [Required]
    [MaxLength(500)]
    public string Direccion { get; set; } = string.Empty;

    [Range(typeof(decimal), "-90", "90")]
    public decimal? Latitud { get; set; }

    [Range(typeof(decimal), "-180", "180")]
    public decimal? Longitud { get; set; }

    public bool Activo { get; set; } = true;
}