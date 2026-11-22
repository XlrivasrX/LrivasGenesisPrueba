namespace VetRuta.Entities.DTOs.Panel;

public class MascotasAtendidasDto
{
    public int EspecieId { get; set; }
    public string NombreEspecie { get; set; } = string.Empty;
    public int CantidadMascotas { get; set; }
}