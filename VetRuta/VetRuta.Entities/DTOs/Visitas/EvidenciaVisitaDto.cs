namespace VetRuta.Entities.DTOs.Visitas;

public class EvidenciaVisitaDto
{
    public int EvidenciaVisitaId { get; set; }
    public int RegistroVisitaId { get; set; }
    public int VisitaId { get; set; }
    public string NombreArchivo { get; set; } = string.Empty;
    public string RutaArchivo { get; set; } = string.Empty;
    public string TipoContenido { get; set; } = string.Empty;
    public DateTime? FechaCaptura { get; set; }
    public DateTime FechaCreacion { get; set; }
}