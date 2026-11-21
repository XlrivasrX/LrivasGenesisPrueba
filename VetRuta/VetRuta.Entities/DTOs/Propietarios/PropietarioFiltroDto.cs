namespace VetRuta.Entities.DTOs.Propietarios;

public class PropietarioFiltroDto
{
    public int? ZonaId { get; set; }
    public bool? Activo { get; set; }
    public string? TextoBusqueda { get; set; }
}