using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using VetRuta.API.Modelos;
using VetRuta.BusinessLogic.Interfaces;
using VetRuta.Entities.DTOs.Pacientes;

namespace VetRuta.API.Controllers;

[Authorize(Roles = "DIRECTOR,MEDICO,TECNICO")]
[ApiController]
[Route("pacientes")]
public class PacientesController : ControllerBase
{
    private readonly IPacienteServicio _pacienteServicio;
    private readonly IAsignacionServicio _asignacionServicio;

    public PacientesController(
        IPacienteServicio pacienteServicio,
        IAsignacionServicio asignacionServicio)
    {
        _pacienteServicio = pacienteServicio;
        _asignacionServicio = asignacionServicio;
    }

    [Authorize(Roles = "DIRECTOR")]
    [HttpGet]
    [ProducesResponseType(typeof(IEnumerable<PacienteListadoDto>), StatusCodes.Status200OK)]
    public async Task<ActionResult<IEnumerable<PacienteListadoDto>>> Listar([FromQuery] PacienteFiltroDto filtros)
    {
        var pacientes = await _pacienteServicio.ListarAsync(filtros);
        return Ok(pacientes);
    }

    [HttpGet("{pacienteId:int}")]
    [ProducesResponseType(typeof(PacienteDetalleDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<ActionResult<PacienteDetalleDto>> ObtenerPorId(int pacienteId)
    {
        var paciente = await _pacienteServicio.ObtenerPorIdAsync(pacienteId);
        if (paciente is null)
        {
            return NotFound(new { mensaje = "Paciente no encontrado." });
        }

        if (!await PuedeAccederPacienteAsync(pacienteId))
        {
            return Forbid();
        }

        return Ok(paciente);
    }

    [Authorize(Roles = "MEDICO")]
    [HttpPost]
    [ProducesResponseType(typeof(PacienteCreadoDto), StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<ActionResult<PacienteCreadoDto>> Crear([FromBody] GuardarPacienteSolicitudDto solicitud)
    {
        var usuarioIdTexto = User.FindFirstValue(ClaimTypes.NameIdentifier);

        if (!int.TryParse(usuarioIdTexto, out var usuarioId))
        {
            return Unauthorized();
        }

        var pacienteCreado = await _pacienteServicio.CrearAsync(solicitud, usuarioId);
        if (pacienteCreado is null)
        {
            return BadRequest(new { mensaje = "No fue posible crear el paciente." });
        }
        return CreatedAtAction(nameof(ObtenerPorId), new { pacienteId = pacienteCreado.PacienteId }, pacienteCreado);
    }

    [Authorize(Roles = "MEDICO")]
    [HttpPut("{pacienteId:int}")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Actualizar(int pacienteId, [FromBody] GuardarPacienteSolicitudDto solicitud)
    {
        var paciente = await _pacienteServicio.ObtenerPorIdAsync(pacienteId);
        if (paciente is null)
        {
            return NotFound(new { mensaje = "Paciente no encontrado." });
        }

        if (!await PuedeAccederPacienteAsync(pacienteId))
        {
            return Forbid();
        }

        var pacienteActualizado = await _pacienteServicio.ActualizarAsync(pacienteId, solicitud);
        if (!pacienteActualizado)
        {
            return NotFound(new { mensaje = "Paciente no encontrado." });
        }
        return Ok(new { mensaje = "Paciente actualizado correctamente." });
    }

    [HttpGet("{pacienteId:int}/foto")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> ObtenerFoto(int pacienteId)
    {
        var paciente = await _pacienteServicio.ObtenerPorIdAsync(pacienteId);
        if (paciente is null || string.IsNullOrWhiteSpace(paciente.RutaFoto))
        {
            return NotFound(new { mensaje = "El paciente no tiene fotografía." });
        }

        if (!await PuedeAccederPacienteAsync(pacienteId))
        {
            return Forbid();
        }

        var nombreGuardado = Path.GetFileName(paciente.RutaFoto);
        var rutaFisica = Path.Combine(
            Directory.GetCurrentDirectory(),
            "wwwroot",
            "fotos-pacientes",
            nombreGuardado);

        if (!System.IO.File.Exists(rutaFisica))
        {
            return NotFound(new { mensaje = "La fotografía no existe." });
        }

        return PhysicalFile(
            rutaFisica,
            ObtenerTipoContenido(nombreGuardado),
            enableRangeProcessing: false);
    }

    [Authorize(Roles = "MEDICO")]
    [HttpPost("{pacienteId:int}/foto")]
    [Consumes("multipart/form-data")]
    [RequestSizeLimit(10 * 1024 * 1024)]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GuardarFoto(
        int pacienteId,
        [FromForm] SubirFotoPacienteSolicitud solicitud)
    {
        var paciente = await _pacienteServicio.ObtenerPorIdAsync(pacienteId);
        if (paciente is null)
        {
            return NotFound(new { mensaje = "Paciente no encontrado." });
        }

        if (!await PuedeAccederPacienteAsync(pacienteId))
        {
            return Forbid();
        }

        var extensionesPermitidas = new Dictionary<string, string>(
            StringComparer.OrdinalIgnoreCase)
        {
            ["image/jpeg"] = ".jpg",
            ["image/png"] = ".png",
            ["image/webp"] = ".webp"
        };

        if (!extensionesPermitidas.TryGetValue(
                solicitud.Archivo.ContentType,
                out var extension))
        {
            return BadRequest(new
            {
                mensaje = "Solo se permiten imágenes JPG, PNG o WEBP."
            });
        }

        if (solicitud.Archivo.Length == 0
            || solicitud.Archivo.Length > 10 * 1024 * 1024)
        {
            return BadRequest(new
            {
                mensaje = "La imagen debe tener un tamaño máximo de 10 MB."
            });
        }

        var nombreGuardado = $"{Guid.NewGuid():N}{extension}";
        var carpetaFotos = Path.Combine(
            Directory.GetCurrentDirectory(),
            "wwwroot",
            "fotos-pacientes");
        var rutaFisica = Path.Combine(carpetaFotos, nombreGuardado);
        var rutaPublica = $"/fotos-pacientes/{nombreGuardado}";

        Directory.CreateDirectory(carpetaFotos);

        try
        {
            await using (var flujo = System.IO.File.Create(rutaFisica))
            {
                await solicitud.Archivo.CopyToAsync(flujo);
            }

            var actualizada = await _pacienteServicio.ActualizarAsync(
                pacienteId,
                new GuardarPacienteSolicitudDto
                {
                    PropietarioId = paciente.PropietarioId,
                    EspecieId = paciente.EspecieId,
                    RazaId = paciente.RazaId,
                    Nombre = paciente.Nombre,
                    FechaNacimientoAproximada =
                        paciente.FechaNacimientoAproximada,
                    RutaFoto = rutaPublica,
                    Observaciones = paciente.Observaciones,
                    Activo = paciente.Activo
                });

            if (!actualizada)
            {
                System.IO.File.Delete(rutaFisica);
                return BadRequest(new
                {
                    mensaje = "No fue posible guardar la fotografía."
                });
            }

            EliminarFotoAnterior(paciente.RutaFoto, rutaFisica);
            return Ok(new { rutaFoto = rutaPublica });
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

    private async Task<bool> PuedeAccederPacienteAsync(int pacienteId)
    {
        if (User.IsInRole("DIRECTOR"))
        {
            return true;
        }

        var usuarioIdTexto = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!int.TryParse(usuarioIdTexto, out var usuarioId))
        {
            return false;
        }

        var asignacion = await _asignacionServicio
            .ObtenerActivaPorPacienteAsync(pacienteId);

        return asignacion is not null
            && ((User.IsInRole("MEDICO")
                    && asignacion.AsignadoPorUsuarioId == usuarioId)
                || (User.IsInRole("TECNICO")
                    && asignacion.TecnicoUsuarioId == usuarioId));
    }

    private static string ObtenerTipoContenido(string nombreArchivo)
    {
        return Path.GetExtension(nombreArchivo).ToLowerInvariant() switch
        {
            ".png" => "image/png",
            ".webp" => "image/webp",
            _ => "image/jpeg"
        };
    }

    private static void EliminarFotoAnterior(
        string? rutaAnterior,
        string rutaNueva)
    {
        if (string.IsNullOrWhiteSpace(rutaAnterior)
            || !rutaAnterior.StartsWith(
                "/fotos-pacientes/",
                StringComparison.OrdinalIgnoreCase))
        {
            return;
        }

        var rutaFisicaAnterior = Path.Combine(
            Directory.GetCurrentDirectory(),
            "wwwroot",
            "fotos-pacientes",
            Path.GetFileName(rutaAnterior));

        try
        {
            if (!string.Equals(
                    rutaFisicaAnterior,
                    rutaNueva,
                    StringComparison.OrdinalIgnoreCase)
                && System.IO.File.Exists(rutaFisicaAnterior))
            {
                System.IO.File.Delete(rutaFisicaAnterior);
            }
        }
        catch (IOException)
        {
            // La fotografía nueva ya quedó asociada; la limpieza puede reintentarse.
        }
        catch (UnauthorizedAccessException)
        {
            // La fotografía nueva ya quedó asociada; la limpieza puede reintentarse.
        }
    }
}
