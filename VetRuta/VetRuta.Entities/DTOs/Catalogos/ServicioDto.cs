namespace VetRuta.Entities.DTOs.Catalogos;

public class ServicioDto
{
    public int ServicioId { get; set; }
    public string Codigo { get; set; } = string.Empty;
    public string Nombre { get; set; } = string.Empty;
    public string? Descripcion { get; set; }
    public decimal Precio { get; set; }
    public int? DuracionEstimadaMinutos { get; set; }
    public bool Activo { get; set; }
}