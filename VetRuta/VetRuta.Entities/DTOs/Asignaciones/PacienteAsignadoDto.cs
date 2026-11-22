namespace VetRuta.Entities.DTOs.Asignaciones;

public class PacienteAsignadoDto
{
    public int AsignacionPacienteId { get; set; }
    public int TecnicoUsuarioId { get; set; }
    public string NombreTecnico { get; set; } = string.Empty;
    public int AsignadoPorUsuarioId { get; set; }
    public string NombreMedico { get; set; } = string.Empty;
    public DateTime FechaInicio { get; set; }
    public string? Observacion { get; set; }
    public int PacienteId { get; set; }
    public string NombrePaciente { get; set; } = string.Empty;
    public string? RutaFoto { get; set; }
    public bool Activo { get; set; }
    public int EspecieId { get; set; }
    public string NombreEspecie { get; set; } = string.Empty;
    public int RazaId { get; set; }
    public string NombreRaza { get; set; } = string.Empty;
    public int PropietarioId { get; set; }
    public string NombrePropietario { get; set; } = string.Empty;
    public string TelefonoPropietario { get; set; } = string.Empty;
    public string Direccion { get; set; } = string.Empty;
    public decimal? Latitud { get; set; }
    public decimal? Longitud { get; set; }
}
