namespace VetRuta.Entities.DTOs.Visitas;

public class HistorialClinicoDto
{
    public int RegistroVisitaId { get; set; }
    public int VisitaId { get; set; }
    public int PacienteId { get; set; }
    public string NombrePaciente { get; set; } = string.Empty;
    public DateTime FechaProgramada { get; set; }
    public DateTime FechaRegistro { get; set; }
    public int ServicioId { get; set; }
    public string NombreServicio { get; set; } = string.Empty;
    public decimal PrecioProgramado { get; set; }
    public int MedicoResponsableUsuarioId { get; set; }
    public string NombreMedico { get; set; } = string.Empty;
    public int TecnicoUsuarioId { get; set; }
    public string NombreTecnico { get; set; } = string.Empty;
    public decimal? PesoKg { get; set; }
    public decimal? AlturaCm { get; set; }
    public decimal? TemperaturaCelsius { get; set; }
    public string? CondicionCorporal { get; set; }
    public string? Observaciones { get; set; }
    public decimal Latitud { get; set; }
    public decimal Longitud { get; set; }
    public int RegistradoPorUsuarioId { get; set; }
    public string RegistradoPor { get; set; } = string.Empty;
    public int CantidadEvidencias { get; set; }
}