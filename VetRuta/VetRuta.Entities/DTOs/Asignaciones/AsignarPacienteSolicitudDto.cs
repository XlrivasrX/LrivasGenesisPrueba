using System.ComponentModel.DataAnnotations;

namespace VetRuta.Entities.DTOs.Asignaciones;

public class AsignarPacienteSolicitudDto
{
    [Range(1, int.MaxValue)]
    public int PacienteId { get; set; }

    [Range(1, int.MaxValue)]
    public int TecnicoUsuarioId { get; set; }

    [MaxLength(250)]
    public string? Observacion { get; set; }
}