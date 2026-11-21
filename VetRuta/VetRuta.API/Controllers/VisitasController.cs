using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using VetRuta.BusinessLogic.Interfaces;
using VetRuta.Entities.DTOs.Visitas;
using VetRuta.API.Modelos;

namespace VetRuta.API.Controllers;

[Authorize]
[ApiController]
[Route("visitas")]
public class VisitasController : ControllerBase
{
    private readonly IVisitaServicio _visitaServicio;

    public VisitasController(IVisitaServicio visitaServicio)
    {
        _visitaServicio = visitaServicio;
    }

    [HttpGet]
    [ProducesResponseType(typeof(IEnumerable<AgendaVisitaDto>), StatusCodes.Status200OK)]
    public async Task<ActionResult<IEnumerable<AgendaVisitaDto>>> ListarAgenda([FromQuery] VisitaFiltroDto filtros)
    {
        var usuarioId = ObtenerUsuarioId();
        if (usuarioId is null)
        {
            return Unauthorized();
        }

        if (User.IsInRole("TECNICO"))
        {
            filtros.TecnicoUsuarioId = usuarioId;
        }
        else if (User.IsInRole("MEDICO"))
        {
            filtros.MedicoResponsableUsuarioId = usuarioId;
        }

        var visitas = await _visitaServicio.ListarAgendaAsync(filtros);
        return Ok(visitas);
    }

    [HttpGet("{visitaId:int}")]
    [ProducesResponseType(typeof(VisitaDetalleDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<ActionResult<VisitaDetalleDto>> ObtenerDetalle(int visitaId)
    {
        var visita = await _visitaServicio.ObtenerDetalleAsync(visitaId);
        if (visita is null)
        {
            return NotFound(new { mensaje = "Visita no encontrada." });
        }

        var usuarioId = ObtenerUsuarioId();
        if (usuarioId is null)
        {
            return Unauthorized();
        }

        if (User.IsInRole("TECNICO") && visita.TecnicoUsuarioId != usuarioId)
        {
            return Forbid();
        }

        if (User.IsInRole("MEDICO") && visita.MedicoResponsableUsuarioId != usuarioId)
        {
            return Forbid();
        }
        return Ok(visita);
    }

    [HttpGet("paciente/{pacienteId:int}/historial")]
    [ProducesResponseType(typeof(IEnumerable<HistorialClinicoDto>), StatusCodes.Status200OK)]
    public async Task<ActionResult<IEnumerable<HistorialClinicoDto>>> ObtenerHistorial(int pacienteId, DateTime? fechaDesde, DateTime? fechaHasta)
    {
        var historial = await _visitaServicio.ObtenerHistorialAsync(pacienteId, fechaDesde, fechaHasta);
        return Ok(historial);
    }

    [HttpGet("{visitaId:int}/evidencias")]
    [ProducesResponseType(typeof(IEnumerable<EvidenciaVisitaDto>), StatusCodes.Status200OK)]
    public async Task<ActionResult<IEnumerable<EvidenciaVisitaDto>>> ListarEvidencias(int visitaId)
    {
        var evidencias = await _visitaServicio.ListarEvidenciasAsync(null, visitaId);
        return Ok(evidencias);
    }

    [Authorize(Roles = "ROOT,DIRECTOR")]
    [HttpPost]
    [ProducesResponseType(typeof(VisitaResultadoDto), StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public async Task<ActionResult<VisitaResultadoDto>> Programar([FromBody] GuardarVisitaSolicitudDto solicitud)
    {
        var usuarioId = ObtenerUsuarioId();
        if (usuarioId is null)
        {
            return Unauthorized();
        }

        var resultado = await _visitaServicio.ProgramarAsync(solicitud, usuarioId.Value);
        if (resultado is null)
        {
            return BadRequest(new
            {
                mensaje = "Los datos de la visita no son válidos. Verifica el paciente, servicio, médico, técnico, asignación y fecha."
            });
        }

        return CreatedAtAction(nameof(ObtenerDetalle), new { visitaId = resultado.VisitaId }, resultado);
    }

    [Authorize(Roles = "ROOT,DIRECTOR")]
    [HttpPut("{visitaId:int}")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Actualizar(int visitaId, [FromBody] GuardarVisitaSolicitudDto solicitud)
    {
        var visita = await _visitaServicio.ObtenerDetalleAsync(visitaId);
        if (visita is null)
        {
            return NotFound(new { mensaje = "Visita no encontrada." });
        }

        if (visita.Estado == "COMPLETADA")
        {
            return BadRequest(new { mensaje = "No se puede modificar una visita completada." });
        }
        var actualizada = await _visitaServicio.ActualizarAsync(visitaId, solicitud);
        if (!actualizada)
        {
            return BadRequest(new { mensaje = "Los datos proporcionados para la visita no son válidos." });
        }
        return Ok(new { mensaje = "Visita actualizada correctamente." });
    }

    [Authorize(Roles = "MEDICO,TECNICO")]
    [HttpPost("{visitaId:int}/completar")]
    [ProducesResponseType(typeof(RegistroVisitaResultadoDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public async Task<ActionResult<RegistroVisitaResultadoDto>> Completar(int visitaId, [FromBody] CompletarVisitaSolicitudDto solicitud)
    {
        var usuarioId = ObtenerUsuarioId();
        if (usuarioId is null)
        {
            return Unauthorized();
        }

        var resultado = await _visitaServicio.CompletarAsync(visitaId, solicitud, usuarioId.Value);
        if (resultado is null)
        {
            return BadRequest(new
            {
                mensaje = "La visita no existe, ya fue completada o no está asignada al usuario actual."
            });
        }
        return Ok(resultado);
    }

    [Authorize(Roles = "MEDICO,TECNICO")]
    [HttpPost("{visitaId:int}/evidencias")]
    [Consumes("multipart/form-data")]
    [RequestSizeLimit(10 * 1024 * 1024)]
    [ProducesResponseType(typeof(EvidenciaResultadoDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<ActionResult<EvidenciaResultadoDto>> AgregarEvidencia(int visitaId, [FromForm] SubirEvidenciaSolicitud solicitud)
    {
        var visita = await _visitaServicio.ObtenerDetalleAsync(visitaId);
        if (visita is null)
        {
            return NotFound(new { mensaje = "Visita no encontrada." });
        }

        if (visita.Estado != "COMPLETADA" || visita.RegistroVisitaId is null)
        {
            return BadRequest(new { mensaje = "La visita debe estar completada antes de agregar evidencias." });
        }

        var usuarioId = ObtenerUsuarioId();
        if (usuarioId is null)
        {
            return Unauthorized();
        }

        if (User.IsInRole("TECNICO") && visita.TecnicoUsuarioId != usuarioId.Value)
        {
            return Forbid();
        }

        if (User.IsInRole("MEDICO") && visita.MedicoResponsableUsuarioId != usuarioId.Value)
        {
            return Forbid();
        }

        var extensionesPermitidas = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase)
        {
            ["image/jpeg"] = ".jpg",
            ["image/png"] = ".png",
            ["image/webp"] = ".webp"
        };

        if (!extensionesPermitidas.TryGetValue(solicitud.Archivo.ContentType, out var extension))
        {
            return BadRequest(new { mensaje = "Solo se permiten imágenes JPG, PNG o WEBP." });
        }

        if (solicitud.Archivo.Length == 0 || solicitud.Archivo.Length > 10 * 1024 * 1024)
        {
            return BadRequest(new { mensaje = "La imagen debe tener un tamaño máximo de 10 MB." });
        }

        var nombreGuardado = $"{Guid.NewGuid():N}{extension}";
        var carpetaEvidencias = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "evidencias");
        var rutaFisica = Path.Combine(carpetaEvidencias, nombreGuardado);
        var rutaPublica = $"/evidencias/{nombreGuardado}";

        Directory.CreateDirectory(carpetaEvidencias);
        try
        {
            await using var flujo = System.IO.File.Create(rutaFisica);
            await solicitud.Archivo.CopyToAsync(flujo);
            var nombreOriginal = Path.GetFileName(solicitud.Archivo.FileName);
            if (nombreOriginal.Length > 255)
            {
                nombreOriginal = nombreOriginal[..255];
            }

            var evidencia = new RegistrarEvidenciaSolicitudDto
            {
                RegistroVisitaId = visita.RegistroVisitaId.Value,
                NombreArchivo = nombreOriginal,
                RutaArchivo = rutaPublica,
                TipoContenido = solicitud.Archivo.ContentType,
                FechaCaptura = solicitud.FechaCaptura
            };

            var resultado = await _visitaServicio.RegistrarEvidenciaAsync(evidencia);
            if (resultado is null)
            {
                System.IO.File.Delete(rutaFisica);
                return BadRequest(new { mensaje = "No fue posible registrar la evidencia." });
            }
            return Ok(resultado);
        }
        catch
        {
            if (System.IO.File.Exists(rutaFisica))
            {
                System.IO.File.Delete(rutaFisica);
            }
            throw;
        }
    }

    private int? ObtenerUsuarioId()
    {
        var usuarioIdTexto = User.FindFirstValue(ClaimTypes.NameIdentifier);
        return int.TryParse(usuarioIdTexto, out var usuarioId) ? usuarioId : null;
    }
}