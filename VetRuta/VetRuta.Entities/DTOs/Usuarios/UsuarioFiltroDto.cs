namespace VetRuta.Entities.DTOs.Usuarios;

public class UsuarioFiltroDto
{
    public int? RolId { get; set; }
    public bool? Activo { get; set; }
    public string? TextoBusqueda { get; set; }
}