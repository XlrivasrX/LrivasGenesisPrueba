namespace VetRuta.API.Middleware;

public class ManejadorExcepcionesMiddleware
{
    private readonly RequestDelegate _siguiente;
    private readonly ILogger<ManejadorExcepcionesMiddleware> _logger;

    public ManejadorExcepcionesMiddleware(RequestDelegate siguiente, ILogger<ManejadorExcepcionesMiddleware> logger)
    {
        _siguiente = siguiente;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext contexto)
    {
        try
        {
            await _siguiente(contexto);
        }
        catch (Exception excepcion)
        {
            _logger.LogError(excepcion, "Ocurrió un error no controlado al procesar la solicitud.");

            if (contexto.Response.HasStarted)
            {
                throw;
            }

            contexto.Response.Clear();
            contexto.Response.StatusCode = StatusCodes.Status500InternalServerError;
            contexto.Response.ContentType = "application/json";

            await contexto.Response.WriteAsJsonAsync(new
            {
                codigo = StatusCodes.Status500InternalServerError,
                mensaje = "Ocurrió un error interno. Inténtalo nuevamente."
            });
        }
    }
}