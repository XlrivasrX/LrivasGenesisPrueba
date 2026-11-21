using System.ComponentModel.DataAnnotations;

namespace VetRuta.Entities.DTOs.Visitas;

public class RegistrarEvidenciaSolicitudDto
{
    [Range(1, int.MaxValue)]
    public int RegistroVisitaId { get; set; }

    [Required]
    [MaxLength(255)]
    public string NombreArchivo { get; set; } = string.Empty;

    [Required]
    [MaxLength(500)]
    public string RutaArchivo { get; set; } = string.Empty;

    [Required]
    [MaxLength(100)]
    public string TipoContenido { get; set; } = string.Empty;

    public DateTime? FechaCaptura { get; set; }
}