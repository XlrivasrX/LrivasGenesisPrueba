namespace VetRuta.Entities.DTOs.Asignaciones;

public class AsignacionActivaDto
{
    public int AsignacionPacienteId { get; set; }
    public int PacienteId { get; set; }
    public string NombrePaciente { get; set; } = string.Empty;
    public int TecnicoUsuarioId { get; set; }
    public string NombreTecnico { get; set; } = string.Empty;
    public string? TelefonoTecnico { get; set; }
    public int AsignadoPorUsuarioId { get; set; }
    public string AsignadoPor { get; set; } = string.Empty;
    public DateTime FechaInicio { get; set; }
    public string? Observacion { get; set; }
    public DateTime FechaCreacion { get; set; }
}