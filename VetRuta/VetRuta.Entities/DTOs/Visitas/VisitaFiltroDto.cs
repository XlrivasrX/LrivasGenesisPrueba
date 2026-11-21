namespace VetRuta.Entities.DTOs.Visitas;

public class VisitaFiltroDto
{
    public int? PacienteId { get; set; }
    public int? ServicioId { get; set; }
    public int? MedicoResponsableUsuarioId { get; set; }
    public int? TecnicoUsuarioId { get; set; }
    public DateTime? FechaDesde { get; set; }
    public DateTime? FechaHasta { get; set; }
    public string? TextoBusqueda { get; set; }
}