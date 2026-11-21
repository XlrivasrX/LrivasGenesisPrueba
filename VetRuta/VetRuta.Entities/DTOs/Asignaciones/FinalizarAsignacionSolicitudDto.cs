using System.ComponentModel.DataAnnotations;

namespace VetRuta.Entities.DTOs.Asignaciones;

public class FinalizarAsignacionSolicitudDto
{
    [MaxLength(250)]
    public string? Observacion { get; set; }
}