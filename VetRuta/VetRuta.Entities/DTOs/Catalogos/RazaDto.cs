namespace VetRuta.Entities.DTOs.Catalogos;

public class RazaDto
{
    public int RazaId { get; set; }
    public int EspecieId { get; set; }
    public string NombreEspecie { get; set; } = string.Empty;
    public string Nombre { get; set; } = string.Empty;
    public string? Descripcion { get; set; }
    public bool Activo { get; set; }
}