namespace VetRuta.Entities.DTOs.Visitas;

public class VisitaDetalleDto
{
    public int VisitaId { get; set; }
    public DateTime FechaProgramada { get; set; }
    public string Estado { get; set; } = string.Empty;
    public int PacienteId { get; set; }
    public string NombrePaciente { get; set; } = string.Empty;
    public string? RutaFoto { get; set; }
    public DateTime? FechaNacimientoAproximada { get; set; }
    public string? ObservacionesPaciente { get; set; }
    public int EspecieId { get; set; }
    public string NombreEspecie { get; set; } = string.Empty;
    public int RazaId { get; set; }
    public string NombreRaza { get; set; } = string.Empty;
    public int PropietarioId { get; set; }
    public string NombrePropietario { get; set; } = string.Empty;
    public string TelefonoPropietario { get; set; } = string.Empty;
    public string? TelefonoAlternativo { get; set; }
    public string Direccion { get; set; } = string.Empty;
    public decimal? LatitudPropietario { get; set; }
    public decimal? LongitudPropietario { get; set; }
    public int ServicioId { get; set; }
    public string NombreServicio { get; set; } = string.Empty;
    public decimal PrecioProgramado { get; set; }
    public string? ObservacionesProgramacion { get; set; }
    public int MedicoResponsableUsuarioId { get; set; }
    public string NombreMedico { get; set; } = string.Empty;
    public int TecnicoUsuarioId { get; set; }
    public string NombreTecnico { get; set; } = string.Empty;
    public int ProgramadaPorUsuarioId { get; set; }
    public string ProgramadaPor { get; set; } = string.Empty;
    public DateTime FechaCreacion { get; set; }
    public int? RegistroVisitaId { get; set; }
    public decimal? PesoKg { get; set; }
    public decimal? AlturaCm { get; set; }
    public decimal? TemperaturaCelsius { get; set; }
    public string? CondicionCorporal { get; set; }
    public string? ObservacionesAtencion { get; set; }
    public decimal? LatitudAtencion { get; set; }
    public decimal? LongitudAtencion { get; set; }
    public int? RegistradoPorUsuarioId { get; set; }
    public DateTime? FechaRegistro { get; set; }
}