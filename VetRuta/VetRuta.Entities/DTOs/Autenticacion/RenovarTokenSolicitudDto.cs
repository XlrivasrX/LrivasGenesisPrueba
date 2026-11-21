using System.ComponentModel.DataAnnotations;

namespace VetRuta.Entities.DTOs.Autenticacion;

public class RenovarTokenSolicitudDto
{
    [Required]
    public string TokenActualizacion { get; set; } = string.Empty;
}