#ifndef TAC_HPP
#define TAC_HPP

#include <string>
#include <vector>
#include <sstream>

using namespace std;
/**
 * @class TACInstruction
 * @brief Clase que representa una instrucción de código intermedio en tres direcciones (TAC).
 * @param op Operación a realizar (por ejemplo, "ADD", "SUB", "GOTO").
 * @param arg1 Primer operando o argumento de la operación.
 * @param arg2 Segundo operando o argumento de la operación.
 * @param result Variable resultado o temporal donde se almacenará el resultado de la operación.
 * @param label Nombre de la etiqueta (si aplica).
 * @details Esta clase se utiliza para representar instrucciones de código intermedio en un formato
 *          de tres direcciones. Cada instrucción puede tener una operación, dos operandos y un resultado.
 *          También puede incluir etiquetas para saltos condicionales o incondicionales.
 * @note - Las operaciones pueden incluir asignaciones, saltos, comparaciones y operaciones aritméticas.
 * @note - El formato de salida de la instrucción se puede obtener utilizando el método toString().
 * @note - Las etiquetas se generan automáticamente y son únicas para cada instrucción.
 * 
*/
class TACInstruction {
public:
    string op;      // Operación ("+", "-", "GOTO", "LABEL", etc.)
    string arg1;    // Primer operando o destino de salto/etiqueta
    string arg2;    // Segundo operando
    string result;  // Variable resultado o temporal
    string label;   // Nombre de la etiqueta (si aplica)

    TACInstruction(string op,
                   string arg1 = "",
                   string arg2 = "",
                   string result = "",
                   string label = "")
        : op(op), arg1(arg1), arg2(arg2), result(result), label(label) {}

    string toString() const {
        string tac_code = "";
        if (op == "LABEL") {
            tac_code += label + ":";
        } else if (op == "GOTO") {
            tac_code += "goto " + arg1;
        } else if (op == "IFGOTO") {
            tac_code += "if " + arg1 + " goto " + arg2;
        } else if (op == "ASSIGN") {
            tac_code += result + " := " + arg1;
        } else if (op == "NEG") {
            tac_code += result + " := !" + arg1;
        } else if (op == "IF_FALSE") {
            tac_code += "ifFalse " + arg1 + " goto " + arg2;
        } else if (op == "PARAM") {
            tac_code += "param " + arg1;
        } else if (op == "CALL" && result != "") {
            tac_code += result + " := call " + arg1 + ", " + arg2;
        } else if (op == "CALL"){
            tac_code += "call " + arg1 + ", " + arg2;
        } else if (op == "RETURN") {
            tac_code += "return " + arg1;
        } else if (op == "PRINT") {
            tac_code += "print " + arg1;
        } else if (op == "READ") {
            tac_code += "read " + result;
        } else {
            // Operaciones aritméticas y otras de 3 direcciones
            tac_code += result + " := " + arg1 + " " + op + " " + arg2;
        }
        return tac_code;
    }
};
/** 
 * @class LabelGenerator
 * @brief Clase que genera etiquetas y temporales únicos para instrucciones TAC.
 * @param counter_label Contador de etiquetas.
 * @param counter_temp Contador de temporales.
 * @details Esta clase se utiliza para generar etiquetas y temporales únicos para instrucciones de código
 *          intermedio en tres direcciones (TAC). Mantiene contadores para etiquetas y temporales, y
 *          proporciona métodos para crear nuevos identificadores únicos.
 * @note - Las etiquetas se generan con un prefijo opcional (por defecto "L").
 * @note - Los temporales se generan con un prefijo opcional (por defecto "t").
 * @note - Los métodos getLabelCount() y getTempCount() devuelven el conteo actual de etiquetas y temporales.
 * @note - Los métodos resetLabel() y resetTemp() permiten restablecer los contadores de etiquetas y temporales.
 * @note - El método reset() restablece ambos contadores a cero.
*/
class LabelGenerator {
    int counter_label; // Contador de etiquetas
	int counter_temp;       // Contador de etiquetas temporales
public:
    LabelGenerator() : counter_label(0), counter_temp(0) {}

    string newLabel(const string& base = "L") {
        return base + to_string(counter_label++);
    }

	string newTemp(const string& base = "t") {
		return base + to_string(counter_temp++);
	}

	void reset() {
		counter_label = 0;
		counter_temp = 0;
	}

	void resetLabel() {
		counter_label = 0;
	}

	void resetTemp() {
		counter_temp = 0;
	}

	int getLabelCount() const {
		return counter_label;
	}

	int getTempCount() const {
		return counter_temp;
	}
};

/**
 * @struct tac_if
 * @brief Estructura que representa una condición if en TAC.
 * @param if_label Etiqueta para el inicio del bloque if.
 * @param else_label Etiqueta para el bloque else (si aplica).
 * @param end_label Etiqueta para el final del bloque if/else.
 * @details Esta estructura se utiliza para almacenar las etiquetas asociadas a una condición if en TAC.
 *          Permite gestionar el flujo de control en instrucciones condicionales.
 */
struct tac_if{
	string if_label;
	string else_label;
	string end_label;

	tac_if(string if_label = "", string else_label = "", string end_label = "")
		: if_label(if_label), else_label(else_label), end_label(end_label) {}
};

/**
 * @struct tac_while
 * @brief Estructura que representa un bucle while en TAC.
 * @param init_label Etiqueta para la inicialización del bucle while.
 * @param loop_label Etiqueta para el inicio del bloque de instruccion del bucle while.
 * @param end_label Etiqueta para el final del bucle while.
 * @details Esta estructura se utiliza para almacenar las etiquetas asociadas a un bucle while en TAC.
 *          Permite gestionar el flujo de control en instrucciones de bucle.
 */
struct tac_while{
    string init_label;
    string loop_label;
    string end_label;

    tac_while(string init_label = "", string loop_label = "", string end_label = "")
        : init_label(init_label), loop_label(loop_label), end_label(end_label) {}
};
/**
 * @struct tac_for
 * @brief Estructura que representa un bucle for en TAC.
 * @param cond_label Etiqueta para la condición del bucle for.
 * @param init_label Etiqueta para la inicialización del bucle for.
 * @param var Variable de control del bucle for.
 * @param val_limit Límite de valor para la variable de control del bucle for.
 * @param loop_label Etiqueta para el inicio del bloque de instruccion del bucle for.
 * @param end_label Etiqueta para el final del bucle for.
 * @details Esta estructura se utiliza para almacenar las etiquetas y variables asociadas a un bucle for en TAC.
 *          Permite gestionar el flujo de control en instrucciones de bucle for.
 */
struct tac_for{
    string cond_label;
    string init_label;
    string var;
    string val_limit;
    string loop_label;
    string end_label;

    tac_for(string cond_label = "", string init_label = "", string var="", string val_limit="", string loop_label = "", string end_label = "")
        : cond_label(cond_label), init_label(init_label), var(var), val_limit(val_limit), loop_label(loop_label), end_label(end_label) {}
};

/**
 * @struct tac_func
 * @brief Estructura que representa el tac de llamada y definiciones de funciones
 * @param func_name Nombre de la funcion (representado como una etiqueta).
 * @param func_type Tipo de retorno de la funcion.
 * @param end_label Etiqueta de finalizacion de la funcion.
 * @param params Cantidad de parametros pasados a la funcion.
 * @details Esta estructura se utiliza para almacenar las etiquetas e informacion asociadas a una funcion en TAC
 *          Permite gestionar el flujo de control en instrucciones de las funciones
 */
struct tac_func{
    string func_name; // Nombre de la función
    string func_type; // Etiqueta de retorno de la función
    string end_label; // Etiqueta de finalización de la función
    int params; // Parámetros de la función

    tac_func(string func_name = "", string func_type = "", string end_label = "", int params = 0)
        : func_name(func_name), func_type(func_type), end_label(end_label), params(params) {}
};

struct tac_params{
    vector<string> params; // Lista de parámetros

    tac_params() = default;
    tac_params(const vector<string>& params) : params(params) {};
};
#endif // TAC_HPP