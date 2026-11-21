namespace VetRuta.Entities.DTOs.Propietarios;

public class PropietarioListadoDto
{
    public int PropietarioId { get; set; }
    public int? ZonaId { get; set; }
    public string? NombreZona { get; set; }
    public string Nombres { get; set; } = string.Empty;
    public string Apellidos { get; set; } = string.Empty;
    public string Telefono { get; set; } = string.Empty;
    public string? TelefonoAlternativo { get; set; }
    public string Direccion { get; set; } = string.Empty;
    public decimal? Latitud { get; set; }
    public decimal? Longitud { get; set; }
    public bool Activo { get; set; }
    public DateTime FechaCreacion { get; set; }
}