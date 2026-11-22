using System.ComponentModel.DataAnnotations;

namespace VetRuta.Entities.DTOs.Propietarios;

public class ActualizarUbicacionPropietarioSolicitudDto
{
    [Range(typeof(decimal), "-90", "90")]
    public decimal Latitud { get; set; }

    [Range(typeof(decimal), "-180", "180")]
    public decimal Longitud { get; set; }
}
