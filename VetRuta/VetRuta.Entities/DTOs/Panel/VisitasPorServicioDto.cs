namespace VetRuta.Entities.DTOs.Panel;

public class VisitasPorServicioDto
{
    public int ServicioId { get; set; }
    public string Codigo { get; set; } = string.Empty;
    public string NombreServicio { get; set; } = string.Empty;
    public int CantidadVisitas { get; set; }
    public int Completadas { get; set; }
    public int Programadas { get; set; }
    public decimal TotalProgramado { get; set; }
}