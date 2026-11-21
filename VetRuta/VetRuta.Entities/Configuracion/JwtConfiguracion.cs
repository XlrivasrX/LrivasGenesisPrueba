namespace VetRuta.Entities.Configuracion;

public class JwtConfiguracion
{
    public const string Seccion = "Jwt";

    public string Clave { get; set; } = string.Empty;
    public string Emisor { get; set; } = string.Empty;
    public string Audiencia { get; set; } = string.Empty;
    public int MinutosExpiracion { get; set; }
    public int DiasExpiracionTokenActualizacion { get; set; }
}
