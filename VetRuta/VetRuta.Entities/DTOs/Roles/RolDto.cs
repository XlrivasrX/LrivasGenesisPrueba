namespace VetRuta.Entities.DTOs.Roles;

public class RolDto
{
    public int RolId { get; set; }
    public string Codigo { get; set; } = string.Empty;
    public string Nombre { get; set; } = string.Empty;
    public string? Descripcion { get; set; }
}
