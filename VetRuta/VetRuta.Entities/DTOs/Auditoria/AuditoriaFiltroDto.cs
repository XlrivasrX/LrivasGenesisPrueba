namespace VetRuta.Entities.DTOs.Auditoria
{
    public class AuditoriaFiltroDto
    {
        public int? UsuarioId { get; set; }
        public string? Accion { get; set; }
        public string? Entidad { get; set; }
        public DateTime? FechaDesde { get; set; }
        public DateTime? FechaHasta { get; set; }
        public string? TextoBusqueda { get; set; }
    }
}