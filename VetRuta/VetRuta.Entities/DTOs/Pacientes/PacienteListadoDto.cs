namespace VetRuta.Entities.DTOs.Pacientes;

public class PacienteListadoDto
{
    public int PacienteId { get; set; }
    public string Nombre { get; set; } = string.Empty;
    public DateTime? FechaNacimientoAproximada { get; set; }
    public string? RutaFoto { get; set; }
    public bool Activo { get; set; }
    public int PropietarioId { get; set; }
    public string NombrePropietario { get; set; } = string.Empty;
    public string TelefonoPropietario { get; set; } = string.Empty;
    public int EspecieId { get; set; }
    public string NombreEspecie { get; set; } = string.Empty;
    public int RazaId { get; set; }
    public string NombreRaza { get; set; } = string.Empty;
    public DateTime FechaCreacion { get; set; }
}