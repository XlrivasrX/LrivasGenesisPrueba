using System.ComponentModel.DataAnnotations;

namespace VetRuta.Entities.DTOs.Visitas;

public class CompletarVisitaSolicitudDto
{
    [Range(typeof(decimal), "0.01", "999999.99")]
    public decimal? PesoKg { get; set; }

    [Range(typeof(decimal), "0.01", "999999.99")]
    public decimal? AlturaCm { get; set; }

    [Range(typeof(decimal), "0", "100")]
    public decimal? TemperaturaCelsius { get; set; }

    [MaxLength(100)]
    public string? CondicionCorporal { get; set; }

    [MaxLength(1000)]
    public string? Observaciones { get; set; }

    [Required]
    [Range(typeof(decimal), "-90", "90")]
    public decimal? Latitud { get; set; }

    [Required]
    [Range(typeof(decimal), "-180", "180")]
    public decimal? Longitud { get; set; }
}