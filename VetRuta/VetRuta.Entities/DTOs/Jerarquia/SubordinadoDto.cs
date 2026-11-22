namespace VetRuta.Entities.DTOs.Jerarquia;

public class SubordinadoDto
{
    public int AsignacionJerarquiaId { get; set; }
    public int UsuarioSuperiorId { get; set; }
    public int UsuarioSubordinadoId { get; set; }
    public string NombreUsuario { get; set; } = string.Empty;
    public string Nombres { get; set; } = string.Empty;
    public string Apellidos { get; set; } = string.Empty;
    public string? Correo { get; set; }
    public string? Telefono { get; set; }
    public bool Activo { get; set; }
    public int RolId { get; set; }
    public string CodigoRol { get; set; } = string.Empty;
    public string NombreRol { get; set; } = string.Empty;
    public DateTime FechaInicio { get; set; }

    public string NombreCompleto =>
        $"{Nombres} {Apellidos}".Trim();
}