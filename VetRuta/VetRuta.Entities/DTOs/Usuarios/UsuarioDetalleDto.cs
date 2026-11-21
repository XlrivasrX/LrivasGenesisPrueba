namespace VetRuta.Entities.DTOs.Usuarios;

public class UsuarioDetalleDto
{
    public int UsuarioId { get; set; }
    public int RolId { get; set; }
    public string NombreUsuario { get; set; } = string.Empty;
    public string Nombres { get; set; } = string.Empty;
    public string Apellidos { get; set; } = string.Empty;
    public string? Correo { get; set; }
    public string? Telefono { get; set; }
    public bool Activo { get; set; }
    public bool DebeCambiarContrasena { get; set; }
    public DateTime? FechaUltimoAcceso { get; set; }
    public DateTime FechaCreacion { get; set; }
    public DateTime? FechaActualizacion { get; set; }
    public string CodigoRol { get; set; } = string.Empty;
    public string NombreRol { get; set; } = string.Empty;
}