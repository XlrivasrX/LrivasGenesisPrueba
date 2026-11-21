namespace VetRuta.Entities.DTOs.Panel;

public class ResumenPanelDto
{
    public int PropietariosActivos { get; set; }
    public int PacientesActivos { get; set; }
    public int VisitasProgramadas { get; set; }
    public int VisitasCompletadas { get; set; }
    public int VisitasDeHoy { get; set; }
}