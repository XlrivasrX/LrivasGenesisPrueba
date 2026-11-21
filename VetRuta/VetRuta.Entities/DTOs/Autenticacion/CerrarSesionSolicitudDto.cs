using System.ComponentModel.DataAnnotations;

namespace VetRuta.Entities.DTOs.Autenticacion;

public class CerrarSesionSolicitudDto
{
    [Required]
    public string TokenActualizacion { get; set; } = string.Empty;
}