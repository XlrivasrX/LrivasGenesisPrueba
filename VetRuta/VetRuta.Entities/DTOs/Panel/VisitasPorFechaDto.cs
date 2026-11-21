namespace VetRuta.Entities.DTOs.Panel;

public class VisitasPorFechaDto
{
    public DateTime Fecha { get; set; }
    public int CantidadVisitas { get; set; }
    public int Completadas { get; set; }
    public int Programadas { get; set; }
    public decimal TotalProgramado { get; set; }
}