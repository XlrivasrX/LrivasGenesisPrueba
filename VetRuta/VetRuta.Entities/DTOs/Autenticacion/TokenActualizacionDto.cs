namespace VetRuta.Entities.DTOs.Autenticacion;

public class TokenActualizacionDto
{
    public int TokenActualizacionId { get; set; }
    public int UsuarioId { get; set; }
    public string TokenHash { get; set; } = string.Empty;
    public DateTime FechaExpiracion { get; set; }
    public string? Dispositivo { get; set; }
    public string? DireccionIp { get; set; }
    public DateTime FechaCreacion { get; set; }
    public string NombreUsuario { get; set; } = string.Empty;
    public string Nombres { get; set; } = string.Empty;
    public string Apellidos { get; set; } = string.Empty;
    public int RolId { get; set; }
}