using System.ComponentModel.DataAnnotations;

namespace VetRuta.API.Modelos;

public class SubirEvidenciaSolicitud
{
    [Required]
    public IFormFile Archivo { get; set; } = null!;

    public DateTime? FechaCaptura { get; set; }
}