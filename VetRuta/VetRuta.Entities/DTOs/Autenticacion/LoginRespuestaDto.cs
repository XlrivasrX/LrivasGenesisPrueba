namespace VetRuta.Entities.DTOs.Autenticacion;

public class LoginRespuestaDto
{
    public string Token { get; set; } = string.Empty;
    public string TokenActualizacion { get; set; } = string.Empty;
    public DateTime FechaExpiracion { get; set; }
    public UsuarioSesionDto Usuario { get; set; } = new();
}