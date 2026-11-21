namespace VetRuta.Entities.DTOs.Auditoria
{
    public class AuditoriaDto
    {
        public int BitacoraAuditoriaId { get; set; }
        public int? UsuarioId { get; set; }
        public string? NombreUsuario { get; set; }
        public string Accion { get; set; } = string.Empty;
        public string Entidad { get; set; } = string.Empty;
        public string? EntidadId { get; set; }
        public string? Detalle { get; set; }
        public string? DireccionIp { get; set; }
        public DateTime FechaCreacion { get; set; }
    }
}