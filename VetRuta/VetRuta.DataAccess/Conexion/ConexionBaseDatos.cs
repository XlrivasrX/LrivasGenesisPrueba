using Microsoft.Data.SqlClient;

namespace VetRuta.DataAccess.Conexion
{
    public class ConexionBaseDatos
    {
        private readonly string _cadenaConexion;
        public ConexionBaseDatos(string cadenaConexion)
        {
            if (string.IsNullOrWhiteSpace(cadenaConexion))
            {
                throw new ArgumentException(
                    "La cadena de conexión no puede estar vacía.",
                    nameof(cadenaConexion));
            }
            _cadenaConexion = cadenaConexion;
        }
        public SqlConnection CrearConexion()
        {
            return new SqlConnection(_cadenaConexion);
        }
    }
}
