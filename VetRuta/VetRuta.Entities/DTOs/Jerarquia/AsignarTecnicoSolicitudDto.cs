using System.ComponentModel.DataAnnotations;

namespace VetRuta.Entities.DTOs.Jerarquia;

public class AsignarTecnicoSolicitudDto
{
    [Range(1, int.MaxValue)]
    public int MedicoUsuarioId { get; set; }

    [Range(1, int.MaxValue)]
    public int TecnicoUsuarioId { get; set; }

    [MaxLength(250)]
    public string? Observacion { get; set; }
}