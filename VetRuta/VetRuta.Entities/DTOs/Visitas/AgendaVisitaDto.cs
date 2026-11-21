namespace VetRuta.Entities.DTOs.Visitas;

public class AgendaVisitaDto
{
    public int VisitaId { get; set; }
    public DateTime FechaProgramada { get; set; }
    public string Estado { get; set; } = string.Empty;
    public int PacienteId { get; set; }
    public string NombrePaciente { get; set; } = string.Empty;
    public string NombreEspecie { get; set; } = string.Empty;
    public string NombreRaza { get; set; } = string.Empty;
    public int PropietarioId { get; set; }
    public string NombrePropietario { get; set; } = string.Empty;
    public string TelefonoPropietario { get; set; } = string.Empty;
    public string Direccion { get; set; } = string.Empty;
    public decimal? Latitud { get; set; }
    public decimal? Longitud { get; set; }
    public int ServicioId { get; set; }
    public string NombreServicio { get; set; } = string.Empty;
    public decimal PrecioProgramado { get; set; }
    public int MedicoResponsableUsuarioId { get; set; }
    public string NombreMedico { get; set; } = string.Empty;
    public int TecnicoUsuarioId { get; set; }
    public string NombreTecnico { get; set; } = string.Empty;
}