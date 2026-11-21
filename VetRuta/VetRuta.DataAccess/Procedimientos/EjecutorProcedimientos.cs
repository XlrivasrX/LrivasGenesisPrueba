using Dapper;
using System.Data;
using VetRuta.DataAccess.Conexion;

namespace VetRuta.DataAccess.Procedimientos;

public class EjecutorProcedimientos
{
    private const string ProcedimientoConsultas = "dbo.SP_VetRuta_Consultas";
    private const string ProcedimientoOperaciones = "dbo.SP_VetRuta_Inserts_Updates";
    private readonly ConexionBaseDatos _conexionBaseDatos;

    public EjecutorProcedimientos(ConexionBaseDatos conexionBaseDatos)
    {
        _conexionBaseDatos = conexionBaseDatos;
    }

    public async Task<IEnumerable<T>> ConsultarListaAsync<T>(
        int opcion,
        object? parametros = null)
    {
        var parametrosDapper = CrearParametros(opcion, parametros);

        await using var conexion = _conexionBaseDatos.CrearConexion();
        await conexion.OpenAsync();

        return await conexion.QueryAsync<T>(
            ProcedimientoConsultas,
            parametrosDapper,
            commandType: CommandType.StoredProcedure);
    }

    public async Task<T?> ConsultarUnoAsync<T>(
        int opcion,
        object? parametros = null)
    {
        var parametrosDapper = CrearParametros(opcion, parametros);

        await using var conexion = _conexionBaseDatos.CrearConexion();
        await conexion.OpenAsync();

        return await conexion.QuerySingleOrDefaultAsync<T>(
            ProcedimientoConsultas,
            parametrosDapper,
            commandType: CommandType.StoredProcedure);
    }

    public async Task<T?> EjecutarAsync<T>(
        int opcion,
        object? parametros = null)
    {
        var parametrosDapper = CrearParametros(opcion, parametros);

        await using var conexion = _conexionBaseDatos.CrearConexion();
        await conexion.OpenAsync();

        return await conexion.QuerySingleOrDefaultAsync<T>(
            ProcedimientoOperaciones,
            parametrosDapper,
            commandType: CommandType.StoredProcedure);
    }

    private static DynamicParameters CrearParametros(
        int opcion,
        object? parametros)
    {
        var parametrosDapper = parametros is null
            ? new DynamicParameters()
            : new DynamicParameters(parametros);

        parametrosDapper.Add("@Opcion", opcion);

        return parametrosDapper;
    }
}