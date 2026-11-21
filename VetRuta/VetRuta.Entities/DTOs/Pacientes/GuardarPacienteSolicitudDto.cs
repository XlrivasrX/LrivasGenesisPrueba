using System.ComponentModel.DataAnnotations;

namespace VetRuta.Entities.DTOs.Pacientes;

public class GuardarPacienteSolicitudDto
{
    [Range(1, int.MaxValue)]
    public int PropietarioId { get; set; }

    [Range(1, int.MaxValue)]
    public int EspecieId { get; set; }

    [Range(1, int.MaxValue)]
    public int RazaId { get; set; }

    [Required]
    [MaxLength(100)]
    public string Nombre { get; set; } = string.Empty;

    [DataType(DataType.Date)]
    public DateTime? FechaNacimientoAproximada { get; set; }

    [MaxLength(500)]
    public string? RutaFoto { get; set; }

    [MaxLength(1000)]
    public string? Observaciones { get; set; }

    public bool Activo { get; set; } = true;
}
