namespace VetRuta.Entities.DTOs.Panel;

public class VisitasPorTecnicoDto
{
    public int TecnicoUsuarioId { get; set; }
    public string NombreTecnico { get; set; } = string.Empty;
    public int CantidadVisitas { get; set; }
    public int Completadas { get; set; }
    public int Programadas { get; set; }
}