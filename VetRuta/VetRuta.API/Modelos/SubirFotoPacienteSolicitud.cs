using System.ComponentModel.DataAnnotations;

namespace VetRuta.API.Modelos;

public class SubirFotoPacienteSolicitud
{
    [Required]
    public IFormFile Archivo { get; set; } = null!;
}
