namespace VetRuta.Entities.DTOs.Panel;

public class PacientesPorEspecieDto
{
    public int EspecieId { get; set; }
    public string NombreEspecie { get; set; } = string.Empty;
    public int CantidadPacientes { get; set; }
}
