namespace VetRuta.Entities.DTOs.Catalogos;

public class EspecieDto
{
    public int EspecieId { get; set; }
    public string Nombre { get; set; } = string.Empty;
    public string? Descripcion { get; set; }
    public bool Activo { get; set; }
}