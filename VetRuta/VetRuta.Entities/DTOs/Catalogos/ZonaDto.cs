namespace VetRuta.Entities.DTOs.Catalogos;

public class ZonaDto
{
    public int ZonaId { get; set; }
    public string Codigo { get; set; } = string.Empty;
    public string Nombre { get; set; } = string.Empty;
    public string? Descripcion { get; set; }
    public bool Activo { get; set; }
}