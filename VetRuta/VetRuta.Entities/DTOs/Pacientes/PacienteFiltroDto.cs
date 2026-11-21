namespace VetRuta.Entities.DTOs.Pacientes;

public class PacienteFiltroDto
{
    public int? PropietarioId { get; set; }
    public int? EspecieId { get; set; }
    public bool? Activo { get; set; }
    public string? TextoBusqueda { get; set; }
}
