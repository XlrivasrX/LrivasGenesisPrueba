namespace VetRuta.Entities.DTOs.Auditoria
{
    public class RegistrarAuditoriaSolicitudDto
    {
        public int? UsuarioId { get; set; }
        public string Accion { get; set; } = string.Empty;
        public string Entidad { get; set; } = string.Empty;
        public string? EntidadId { get; set; }
        public string? Detalle { get; set; }
        public string? DireccionIp { get; set; }
    }
}