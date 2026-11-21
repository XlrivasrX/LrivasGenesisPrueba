using System.Security.Claims;
using VetRuta.BusinessLogic.Interfaces;
using VetRuta.Entities.DTOs.Auditoria;

namespace VetRuta.API.Middleware;

public class AuditoriaMiddleware
{
    private readonly RequestDelegate _siguiente;
    private readonly ILogger<AuditoriaMiddleware> _logger;

    public AuditoriaMiddleware(RequestDelegate siguiente, ILogger<AuditoriaMiddleware> logger)
    {
        _siguiente = siguiente;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext contexto, IAuditoriaServicio auditoriaServicio)
    {
        await _siguiente(contexto);
        if (!DebeRegistrar(contexto))
        {
            return;
        }

        try
        {
            var usuarioIdTexto = contexto.User.FindFirstValue(ClaimTypes.NameIdentifier);
            int.TryParse(usuarioIdTexto, out var usuarioId);

            var accion = contexto.Request.RouteValues["action"]?.ToString() ?? contexto.Request.Method;
            var entidad = contexto.Request.RouteValues["controller"]?.ToString() ?? "Desconocida";
            var entidadId = contexto.Request.RouteValues.FirstOrDefault(valor => valor.Key.EndsWith("Id", StringComparison.OrdinalIgnoreCase)).Value?.ToString();

            await auditoriaServicio.RegistrarAsync(new RegistrarAuditoriaSolicitudDto
            {
                UsuarioId = usuarioId,
                Accion = accion,
                Entidad = entidad,
                EntidadId = entidadId,
                Detalle = $"Solicitud {contexto.Request.Method} {contexto.Request.Path} finalizada con código {contexto.Response.StatusCode}.",
                DireccionIp = contexto.Connection.RemoteIpAddress?.ToString()
            });
        }
        catch (Exception excepcion)
        {
            _logger.LogError(excepcion, "No fue posible registrar la solicitud en la bitácora de auditoría.");
        }
    }

    private static bool DebeRegistrar(HttpContext contexto)
    {
        var metodoModificaDatos = HttpMethods.IsPost(contexto.Request.Method)
            || HttpMethods.IsPut(contexto.Request.Method)
            || HttpMethods.IsPatch(contexto.Request.Method)
            || HttpMethods.IsDelete(contexto.Request.Method);

        var respuestaExitosa = contexto.Response.StatusCode >= 200 && contexto.Response.StatusCode < 300;
        return contexto.User.Identity?.IsAuthenticated == true && metodoModificaDatos && respuestaExitosa;
    }
}