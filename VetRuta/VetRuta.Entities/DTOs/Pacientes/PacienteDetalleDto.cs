namespace VetRuta.Entities.DTOs.Pacientes;

public class PacienteDetalleDto
{
    public int PacienteId { get; set; }
    public int PropietarioId { get; set; }
    public string NombrePropietario { get; set; } = string.Empty;
    public string TelefonoPropietario { get; set; } = string.Empty;
    public string? TelefonoAlternativo { get; set; }
    public string Direccion { get; set; } = string.Empty;
    public decimal? Latitud { get; set; }
    public decimal? Longitud { get; set; }
    public int? ZonaId { get; set; }
    public string? NombreZona { get; set; }
    public int EspecieId { get; set; }
    public string NombreEspecie { get; set; } = string.Empty;
    public int RazaId { get; set; }
    public string NombreRaza { get; set; } = string.Empty;
    public string Nombre { get; set; } = string.Empty;
    public DateTime? FechaNacimientoAproximada { get; set; }
    public string? RutaFoto { get; set; }
    public string? Observaciones { get; set; }
    public int CreadoPorUsuarioId { get; set; }
    public bool Activo { get; set; }
    public DateTime FechaCreacion { get; set; }
    public DateTime? FechaActualizacion { get; set; }
}