namespace VetRuta.Entities.DTOs.Autenticacion;

public class UsuarioSesionDto
{
    public int UsuarioId { get; set; }
    public string NombreUsuario { get; set; } = string.Empty;
    public string Nombres { get; set; } = string.Empty;
    public string Apellidos { get; set; } = string.Empty;
    public int RolId { get; set; }
    public string CodigoRol { get; set; } = string.Empty;
    public string NombreRol { get; set; } = string.Empty;
    public bool DebeCambiarContrasena { get; set; }
}