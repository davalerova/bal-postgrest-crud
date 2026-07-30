import ballerina/http;
import ballerina/sql;
import ballerinax/postgresql;
import ballerinax/postgresql.driver as _;

type Empleado record {|
    int id;
    string nombre;
    string cargo;
    decimal salario;
|};

type EmpleadoRequest record {|
    string nombre;
    string cargo;
    decimal salario;
|};

configurable string dbHost = ?;
configurable string dbUsername = ?;
configurable string dbPassword = ?;
configurable string dbName = ?;
configurable int dbPort = ?;
configurable int appPort = ?;

final postgresql:Client dbClient = check new (
    host = dbHost,
    username = dbUsername,
    password = dbPassword,
    database = dbName,
    port = dbPort
);

service / on new http:Listener(appPort) {

    resource function get empleados() returns Empleado[]|http:InternalServerError {
        stream<Empleado, sql:Error?> empleadoStream = dbClient->query(
            `SELECT id, nombre, cargo, salario FROM empleados`
        );

        Empleado[]|error empleados = from Empleado emp in empleadoStream
            select emp;

        if empleados is error {
            return <http:InternalServerError>{
                body: {message: "Error al consultar empleados"}
            };
        }

        return empleados;
    }

    resource function get empleados/[int id]() returns Empleado|http:NotFound|http:InternalServerError {
        Empleado|sql:Error result = dbClient->queryRow(
            `SELECT id, nombre, cargo, salario FROM empleados WHERE id = ${id}`
        );

        if result is sql:NoRowsError {
            return <http:NotFound>{
                body: {message: string `Empleado con id ${id} no encontrado`}
            };
        }

        if result is sql:Error {
            return <http:InternalServerError>{
                body: {message: "Error al consultar el empleado"}
            };
        }

        return result;
    }

    resource function post empleados(EmpleadoRequest payload) returns http:Created|http:InternalServerError {
        Empleado|sql:Error result = dbClient->queryRow(
            `INSERT INTO empleados (nombre, cargo, salario)
             VALUES (${payload.nombre}, ${payload.cargo}, ${payload.salario})
             RETURNING id, nombre, cargo, salario`
        );

        if result is sql:Error {
            return <http:InternalServerError>{
                body: {message: "Error al crear el empleado"}
            };
        }

        return <http:Created>{body: result};
    }

    resource function put empleados/[int id](EmpleadoRequest payload) returns Empleado|http:NotFound|http:InternalServerError {
        Empleado|sql:Error result = dbClient->queryRow(
            `UPDATE empleados
             SET nombre = ${payload.nombre}, cargo = ${payload.cargo}, salario = ${payload.salario}
             WHERE id = ${id}
             RETURNING id, nombre, cargo, salario`
        );

        if result is sql:NoRowsError {
            return <http:NotFound>{
                body: {message: string `Empleado con id ${id} no encontrado`}
            };
        }

        if result is sql:Error {
            return <http:InternalServerError>{
                body: {message: "Error al actualizar el empleado"}
            };
        }

        return result;
    }

    resource function delete empleados/[int id]() returns http:NoContent|http:NotFound|http:InternalServerError {
        sql:ExecutionResult|sql:Error result = dbClient->execute(
            `DELETE FROM empleados WHERE id = ${id}`
        );

        if result is sql:Error {
            return <http:InternalServerError>{
                body: {message: "Error al eliminar el empleado"}
            };
        }

        int? affected = result.affectedRowCount;
        if affected is () || affected == 0 {
            return <http:NotFound>{
                body: {message: string `Empleado con id ${id} no encontrado`}
            };
        }

        return http:NO_CONTENT;
    }
}
