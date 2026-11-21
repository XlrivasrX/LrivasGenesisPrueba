using System.ComponentModel.DataAnnotations;

namespace VetRuta.Entities.DTOs.Visitas;

public class GuardarVisitaSolicitudDto
{
    [Range(1, int.MaxValue)]
    public int PacienteId { get; set; }

    [Range(1, int.MaxValue)]
    public int ServicioId { get; set; }

    [Range(1, int.MaxValue)]
    public int MedicoResponsableUsuarioId { get; set; }

    [Range(1, int.MaxValue)]
    public int TecnicoUsuarioId { get; set; }

    [Required]
    public DateTime? FechaProgramada { get; set; }

    [Range(typeof(decimal), "0", "99999999.99")]
    public decimal PrecioProgramado { get; set; }

    [MaxLength(500)]
    public string? ObservacionesProgramacion { get; set; }
}