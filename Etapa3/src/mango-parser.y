%{
#include <iostream>
#include <cstdlib>
#include "mango-bajito.hpp"
#include <cstring>
#include <memory>
#include "ast.hpp" 

using namespace std;

typedef struct YYLTYPE {
    int first_line;
    int first_column;
    //int last_line;
    //int last_column;
} YYLTYPE;

void yyerror(const char *s);
int yylex();
extern int yylineno;
extern YYLTYPE yylloc;
extern std::stack<std::shared_ptr<ASTNode>> ancestros;

// Función para iniciar un nodo
void iniciarNodo(ASTNode::NodeType tipo) {
    auto nuevoNodo = std::make_shared<ASTNode>(tipo);
    ancestros.push(nuevoNodo);
    std::cout << "Nodo insertado en la pila. Tipo: " << static_cast<int>(tipo) << std::endl;
}

// Función para cerrar un nodo
void cerrarNodo() {
    if (!ancestros.empty()) {
        auto nodoActual = ancestros.top();
        ancestros.pop();
        if (!ancestros.empty()) {
            ancestros.top()->addChild(nodoActual);
        }
        std::cout << "Nodo eliminado de la pila." << std::endl;
    } else {
        std::cerr << "Error: No hay nodos en la pila para cerrar." << std::endl;
    }
}


SymbolTable symbolTable = SymbolTable();
errorType ERROR_TYPE = SEMANTIC_TYPE; // Permite manejar un error particular de tipo errorType
string current_struct_name = "";
string current_function_name = "";
string current_array_name = "";
%}

%code requires {
	struct ExpresionAttribute {
		enum Type { INT, FLOAT, DOUBLE, BOOL, STRING, POINTER, ID} type;
		union {
			int ival;
			float fval;
			double dval;
			char* sval;
		};
	};
}

%union {
	ExpresionAttribute att_val; // Usa el struct definido
    int ival;
    float fval;
    double dval;
    char* sval;
}

%token <sval> T_MANGO       // Token para int
%token <sval> T_MANGUITA    // Token para float
%token <sval> T_MANGUANGUA  // Token para double
%token <sval> T_NEGRO       // Token para caracter
%token <sval> T_HIGUEROTE   // Token para string

%token T_SE_PRENDE T_ASIGNACION T_DOSPUNTOS T_PUNTOCOMA T_COMA
%token T_SIESASI T_OASI T_NOJODA
%token T_REPITEBURDA T_ENTRE T_HASTA T_CONFLOW
%token T_ECHALEBOLAS
%token T_ROTALO T_KIETO
%token T_CULITO T_JEVA
%token T_TASCLARO T_SISA T_NOLSA T_ARROZCONMANGO T_COLIAO T_PUNTO
%token T_AHITA T_AKITOY T_CEROKM T_BORRADOL T_PELABOLA T_FLECHA
%token T_UNCONO
%token T_ECHARCUENTO T_LANZA T_LANZATE
%token T_RESCATA T_HABLAME
%token T_T_MEANDO T_FUERADELPEROL T_COMO
%token T_OPSUMA T_OPRESTA T_OPINCREMENTO T_OPDECREMENTO T_OPASIGRESTA T_OPASIGSUMA T_OPASIGMULT
%token T_OPMULT T_OPDIVDECIMAL T_OPDIVENTERA T_OPMOD T_OPEXP
%token T_OPIGUAL T_OPDIFERENTE T_OPMAYORIGUAL T_OPMAYOR T_OPMENORIGUAL T_OPMENOR
%token T_YUNTA T_OSEA T_NELSON
%token <sval> T_IDENTIFICADOR 
%token <att_val> T_VALUE
%token T_IZQPAREN T_DERPAREN T_IZQLLAVE T_DERLLAVE T_IZQCORCHE T_DERCORCHE
%token T_CASTEO

// Declaracion de tipos de retorno para las producciones 
%type <sval> tipo_declaracion declaracion_aputador tipo_valor tipos asignacion firma_funcion operadores_asignacion
%type <att_val> expresion

// Declaracion de precedencia y asociatividad de Operadores
// Asignacion
%right T_ASIGNACION 

// Logicos y comparativos
%left T_OSEA
%left T_YUNTA
%nonassoc T_OPIGUAL T_OPDIFERENTE T_OPMAYOR T_OPMENOR T_OPMAYORIGUAL T_OPMENORIGUAL

// Aritmeticos
%left T_OPSUMA T_OPRESTA 
%left T_OPMULT T_OPDIVENTERA T_OPDIVDECIMAL T_OPMOD
%right T_OPEXP
%nonassoc T_IZQPAREN T_DERPAREN

// Operaciones unarias
%left T_OPINCREMENTO T_OPDECREMENTO
%right T_SIGNO_MENOS T_NELSON
%left T_FLECHA

%right T_CASTEO  // Precedencia más alta para el casting

%start programa
%%

abrir_scope:
    { symbolTable.open_scope(); }
    ;

cerrar_scope:
    { symbolTable.close_scope(); }
    ;

programa:
    { iniciarNodo(ASTNode::NodeType::program_inst_main); }
    abrir_scope 
    { iniciarNodo(ASTNode::NodeType::instuctions); }
    instrucciones 
    { cerrarNodo(); }
    main cerrar_scope
    | { iniciarNodo(ASTNode::NodeType::program_main); }
    abrir_scope main cerrar_scope
    ;

main:
    T_SE_PRENDE abrir_scope {iniciarNodo(ASTNode::NodeType::s_main);}T_IZQPAREN T_DERPAREN T_IZQLLAVE {iniciarNodo(ASTNode::NodeType::instuctions);} instruccionesopt {cerrarNodo();} T_DERLLAVE T_PUNTOCOMA cerrar_scope {cerrarNodo();} { 
		symbolTable.print_table(); 
		cout << "Programa válido: "; 
	} 
    ;

instrucciones:
    instruccion T_PUNTOCOMA
    | instrucciones instruccion T_PUNTOCOMA
    ;

instruccionesopt:
    instrucciones |
    ;

instruccion:
      declaracion     // ✓
    | asignacion      // ✓
    | condicion       // ✓
    | bucle     // ✓
    | entrada_salida  // ✓
    | funcion         // ✓
    | manejo_error    // ✓
    | struct
    | variante
    | {iniciarNodo(ASTNode::NodeType::s_break);} T_KIETO {cerrarNodo();}    // ✓
    | {iniciarNodo(ASTNode::NodeType::s_continue);} T_ROTALO {cerrarNodo();} // ✓
    | T_IDENTIFICADOR T_OPDECREMENTO {iniciarNodo(ASTNode::NodeType::s_decremento); ancestros.top()->informacion.identificador = $1; cerrarNodo();} // ✓
    | T_IDENTIFICADOR T_OPINCREMENTO {iniciarNodo(ASTNode::NodeType::s_incremento); ancestros.top()->informacion.identificador = $1; cerrarNodo();} // ✓
    | {iniciarNodo(ASTNode::NodeType::s_return);} T_LANZATE expresion {cerrarNodo();} // ✓
    | T_BORRADOL T_IDENTIFICADOR {iniciarNodo(ASTNode::NodeType::s_delete); ancestros.top()->informacion.identificador = $2; cerrarNodo();}
    | T_BORRADOL T_IDENTIFICADOR T_PUNTO T_IDENTIFICADOR {  // ✓
        iniciarNodo(ASTNode::NodeType::s_delete);
        ancestros.top()->informacion.identificador = $4;
        ancestros.top()->informacion.es_atributo = "true";
        cerrarNodo();
    }
    ;

declaracion:
    tipo_declaracion T_IDENTIFICADOR T_DOSPUNTOS tipos {

        iniciarNodo(ASTNode::NodeType::Undefined);

        if (symbolTable.search_symbol($4) == nullptr){
			ERROR_TYPE = NON_DEF_TYPE;
            yyerror($4);
            exit(1);
        };

		Attributes *attributes = new Attributes();
        attributes->symbol_name = $2;
        attributes->scope = symbolTable.current_scope;
        attributes->info.push_back({"-", nullptr});
        attributes->type = symbolTable.search_symbol($4);

        if (strcmp($1, "POINTER_V") == 0){
            attributes->category = POINTER_V;
            ancestros.top()->informacion.es_apuntador = "true";
            ancestros.top()->type = ASTNode::NodeType::s_decl_culito;

        } else if (strcmp($1, "POINTER_C") == 0){
            attributes->category = POINTER_C;
            ancestros.top()->informacion.es_apuntador = "true";
            ancestros.top()->type = ASTNode::NodeType::s_decl_jeva;
        } else if (strcmp($1, "VARIABLE") == 0){
            attributes->category = VARIABLE;
            ancestros.top()->type = ASTNode::NodeType::s_decl_culito;
        } else if (strcmp($1, "CONSTANTE") == 0){
            attributes->category = CONSTANT;
            ancestros.top()->type = ASTNode::NodeType::s_decl_jeva;
        };

        ancestros.top()->informacion.tipo = strdup($4);
        ancestros.top()->informacion.identificador = strdup($2);

        if (!symbolTable.insert_symbol($2, *attributes)){
			ERROR_TYPE = ALREADY_DEF_VAR;
            yyerror($2);
            exit(1);
        };

        cerrarNodo();
    }

    | tipo_declaracion T_IDENTIFICADOR T_DOSPUNTOS tipos T_ASIGNACION {
        iniciarNodo(ASTNode::NodeType::s_asign);
        ancestros.top()->informacion.tipo_asignacion = strdup("=");

        iniciarNodo(ASTNode::NodeType::Undefined);
        if (strcmp($1, "POINTER_V") == 0){
            ancestros.top()->informacion.es_apuntador = "true";
            ancestros.top()->type = ASTNode::NodeType::s_decl_culito;
        } else if (strcmp($1, "POINTER_C") == 0){
            ancestros.top()->informacion.es_apuntador = "true";
            ancestros.top()->type = ASTNode::NodeType::s_decl_jeva;
        } else if (strcmp($1, "VARIABLE") == 0){
            ancestros.top()->type = ASTNode::NodeType::s_decl_culito;
        } else if (strcmp($1, "CONSTANTE") == 0){
            ancestros.top()->type = ASTNode::NodeType::s_decl_jeva;
        };
        ancestros.top()->informacion.tipo = strdup($4);
        ancestros.top()->informacion.identificador = strdup($2);

        cerrarNodo();
    }  expresion {
        cerrarNodo();
        if (symbolTable.search_symbol($4) == nullptr){
			ERROR_TYPE = NON_DEF_TYPE;
            yyerror($4);
            exit(1);
        };

		Attributes *attributes = new Attributes();
        attributes->symbol_name = $2;
        attributes->scope = symbolTable.current_scope;
        attributes->info.push_back({"-", nullptr});
        attributes->type = symbolTable.search_symbol($4);

        if (strcmp($1, "POINTER_V") == 0){
            attributes->category = POINTER_V;
        } else if (strcmp($1, "POINTER_C") == 0){
            attributes->category = POINTER_C;
        } else if (strcmp($1, "VARIABLE") == 0){
            attributes->category = VARIABLE;
        } else if (strcmp($1, "CONSTANTE") == 0){
            attributes->category = CONSTANT;
        };
                
	    switch($7.type) {
	        case ExpresionAttribute::INT:
	            cout << "ASIGNANDO ENTERO: valor = " << $7.ival << endl;
	            attributes->value = $7.ival;
	            break;
	        
	        case ExpresionAttribute::FLOAT:
	            //cout << "ASIGNANDO FLOAT: valor = " << $7.fval << endl;
	            attributes->value = $7.fval;
	            break;
	        
			case ExpresionAttribute::DOUBLE:
	            //cout << "ASIGNANDO DOUBLE: valor = " << $7.dval << endl;
	            attributes->value = $7.dval;
	            break;

	        case ExpresionAttribute::BOOL:
	            //cout << "ASIGNANDO BOOL: valor = " << (strcmp($7.sval, "Sisa") == 0 ? "true" : "false") << endl;
	            attributes->value = strcmp($7.sval, "Sisa") == 0 ? true : false;
	            break;
	        
	        case ExpresionAttribute::STRING:
	            //cout << "ASIGNANDO STRING: valor = \"" << $7.sval << "\"" << endl;
	            attributes->value = string($7.sval);
	            break;
	        
	        case ExpresionAttribute::POINTER:
	            //cout << "ASIGNANDO PUNTERO: valor = nullptr" << endl;
	            attributes->value = nullptr;
	            break;
	        
	        default:
	            cout << "TIPO DESCONOCIDO: Asignando nullptr a: " << $2 << endl;
	            attributes->value = nullptr;
	    }

        if (!symbolTable.insert_symbol($2, *attributes)){
			ERROR_TYPE = ALREADY_DEF_VAR;
            yyerror($2);
            exit(1);
        };
    }
	| declaracion_funcion
    ;

declaracion_aputador:
    { $$ = strdup(""); }
    | T_AHITA   { $$ = strdup("POINTER"); }
    ;

tipo_declaracion:
    declaracion_aputador T_CULITO { $$ =  strcmp($1, "POINTER") == 0 ? strdup("POINTER_V") : strdup("VARIABLE"); }
    | declaracion_aputador T_JEVA { $$ =  strcmp($1, "POINTER") == 0 ? strdup("POINTER_C") : strdup("CONSTANTE"); }
    ;

tipos:
    tipo_valor {$$ = strdup($1);}
    | tipos T_IZQCORCHE expresion T_DERCORCHE { $$ = strdup("array$"); }
    ;

tipo_valor:
    T_MANGO { $$ = strdup("mango"); }
    | T_MANGUITA { $$ = strdup("manguita"); }
    | T_MANGUANGUA { $$ = strdup("manguangua"); }
    | T_NEGRO { $$ = strdup("negro"); }
    | T_HIGUEROTE { $$ = strdup("higuerote"); }
    | T_TASCLARO { $$ = strdup("tas_claro"); }
    ;

operadores_asignacion:
    T_ASIGNACION {$$ = "=";}
    | T_OPASIGSUMA {$$ = "+=";}
    | T_OPASIGRESTA {$$ = "-=";}
    | T_OPASIGMULT {$$ = "*=";}
    ;

asignacion:
     T_IDENTIFICADOR operadores_asignacion  {iniciarNodo(ASTNode::NodeType::s_asign); ancestros.top()->informacion.tipo_asignacion = strdup($2);} expresion { 
         
        cerrarNodo();


        Attributes *attr_var = symbolTable.search_symbol($1);
        if (attr_var == nullptr){
			ERROR_TYPE = NON_DEF_VAR;
            yyerror($1);
            exit(1);
        };
                
        string info_var = get<string>(attr_var->info[0].first);
        if (strcmp(info_var.c_str(), "CICLO FOR") == 0){
			ERROR_TYPE = VAR_FOR;
            yyerror("No se puede modificar una variable de un ciclo determinado");
            exit(1);
        }

        if (strcmp(info_var.c_str(), "MANEJO ERROR") == 0){
			ERROR_TYPE = VAR_TRY;
            yyerror("No se puede modificar una variable de un meando/fuera_del_perol");
            exit(1);
        }

		current_array_name = string($1); // En caso de asignacion de arreglos.

	    switch($4.type) {
	        case ExpresionAttribute::INT:
	            attr_var->value = $4.ival;
	            break;
	        case ExpresionAttribute::FLOAT:
	            attr_var->value = $4.fval;
	            break;
	        case ExpresionAttribute::BOOL:
	            attr_var->value = (bool)$4.ival; // Asumiendo que se almacena en ival
	            break;
	        case ExpresionAttribute::STRING:
                attr_var->value = string($4.sval); // Convierte a std::string
	            break;
	        case ExpresionAttribute::POINTER:
	            // Manejar punteros según sea necesario
	            attr_var->value = nullptr; // O el valor adecuado
	            break;
	        default:
                cout << $4.sval << endl;
                Attributes *attr = symbolTable.search_symbol($4.sval);
                if(attr != nullptr){
                    if(attr->category == VARIABLE || attr->category == CONSTANT){
                        attr_var->value = attr->value;
                    } 
                } else {
                    attr_var->value = nullptr;
                }
                break;
	            
	    }
    }
    | T_IDENTIFICADOR T_PUNTO T_IDENTIFICADOR operadores_asignacion expresion
    ;

valores_booleanos:
    T_SISA 
    | T_NOLSA
    ;

expresion_apuntador:
    T_AKITOY T_IDENTIFICADOR
    | T_AKITOY T_IDENTIFICADOR T_PUNTO T_IDENTIFICADOR
    ;

expresion_nuevo:
    T_CEROKM tipos
    | expresion_nuevo T_IZQPAREN expresion T_DERPAREN
    ;

expresion:
    T_IDENTIFICADOR {$$.sval = $1; $$.type = ExpresionAttribute::ID;}
    | T_VALUE {
		if(current_array_name != ""){

		}

        switch($1.type) {
	        case ExpresionAttribute::INT:
	            $$.ival = $1.ival;
	            break;
	        case ExpresionAttribute::FLOAT:
	            $$.fval = $1.fval;
	            break;
	        case ExpresionAttribute::BOOL:
	            $$.ival = (bool)$1.ival; // Asumiendo que se almacena en ival
	            break;
	        case ExpresionAttribute::STRING:
                $$.sval = $1.sval; // Convierte a std::string
	            break;
            case ExpresionAttribute::DOUBLE:
                $$.dval = $1.dval;
	        default:
                break;
        }
    }
    | T_PELABOLA
    | T_IZQPAREN expresion T_DERPAREN
    | valores_booleanos 
    | expresion_apuntador 
    | expresion_nuevo
    | arreglo
    | T_NELSON expresion
	| T_OPRESTA expresion %prec T_SIGNO_MENOS {$$ = $2;}
    | expresion T_FLECHA expresion
    | expresion T_OPSUMA expresion {
        if($1.type == ExpresionAttribute::INT && $3.type == ExpresionAttribute::INT){
            $$.type = ExpresionAttribute::INT;
            $$.ival = $1.ival + $3.ival;
        }

        if($1.type == ExpresionAttribute::FLOAT && $3.type == ExpresionAttribute::INT){
            $$.type = ExpresionAttribute::FLOAT;
            $$.fval = (float)($1.fval + $3.ival);
        }

        if($1.type == ExpresionAttribute::INT && $3.type == ExpresionAttribute::FLOAT){
            $$.type = ExpresionAttribute::FLOAT;
            $$.fval = (float)($1.ival + $3.fval);
        }

        if($1.type == ExpresionAttribute::ID && $3.type == ExpresionAttribute::ID){
            Attributes *var1 = symbolTable.search_symbol($1.sval);
            Attributes *var2 = symbolTable.search_symbol($3.sval);

            $$.type = ExpresionAttribute::INT;
            $$.ival = get<int>(var1->value) + get<int>(var2->value);
        }
        
    }
    | expresion T_OPRESTA expresion
    | expresion T_OPMULT expresion
    | expresion T_OPDIVDECIMAL expresion
    | expresion T_OPDIVENTERA expresion
    | expresion T_OPMOD expresion
    | expresion T_OPEXP expresion
    | expresion T_OPIGUAL expresion
    | expresion T_OPDIFERENTE expresion
    | expresion T_OPMAYOR expresion
    | expresion T_OPMAYORIGUAL expresion
    | expresion T_OPMENOR expresion
    | expresion T_OPMENORIGUAL expresion
    | expresion T_OSEA expresion
    | expresion T_YUNTA expresion
    | expresion T_OPDECREMENTO
    | expresion T_OPINCREMENTO
    | entrada_salida
    | funcion
    | casting
    ;

condicion:
    {iniciarNodo(ASTNode::NodeType::s_if);} T_SIESASI T_IZQPAREN expresion T_DERPAREN abrir_scope T_IZQLLAVE {iniciarNodo(ASTNode::NodeType::instuctions);} instrucciones {cerrarNodo();} T_DERLLAVE cerrar_scope alternativa {cerrarNodo();} 
    ;

alternativa:
    | {iniciarNodo(ASTNode::NodeType::s_if_else);} T_OASI T_IZQPAREN expresion T_DERPAREN abrir_scope T_IZQLLAVE {iniciarNodo(ASTNode::NodeType::instuctions);} instrucciones {cerrarNodo();} T_DERLLAVE cerrar_scope {cerrarNodo();} alternativa
    | {iniciarNodo(ASTNode::NodeType::s_else);} T_NOJODA abrir_scope T_IZQLLAVE {iniciarNodo(ASTNode::NodeType::instuctions);} instrucciones {cerrarNodo();} T_DERLLAVE cerrar_scope {cerrarNodo();}
    ;

bucle:
    indeterminado 
    | {iniciarNodo(ASTNode::NodeType::s_for);} determinado {cerrarNodo();}
    ;

indeterminado:
    {iniciarNodo(ASTNode::NodeType::s_while);} T_ECHALEBOLAS T_IZQPAREN expresion T_DERPAREN abrir_scope T_IZQLLAVE {iniciarNodo(ASTNode::NodeType::instuctions);} instrucciones {cerrarNodo();} T_DERLLAVE cerrar_scope {cerrarNodo();}
    ;
var_ciclo_determinado:
    {iniciarNodo(ASTNode::NodeType::rango_for);} T_IDENTIFICADOR T_ENTRE expresion T_HASTA expresion {cerrarNodo();} {
        if (symbolTable.search_symbol($2) != nullptr){
			ERROR_TYPE = ALREADY_DEF_VAR;
            yyerror($2);
            exit(1);
        };

        Attributes *attributes = new Attributes();
        attributes->symbol_name = $2;
        attributes->scope = symbolTable.current_scope;
        attributes->info.push_back({"CICLO FOR", nullptr});
        attributes->type = symbolTable.search_symbol("mango");
        attributes->category = VARIABLE;

        switch($4.type) {
            case ExpresionAttribute::INT:
                attributes->value = $4.ival;
                break;
            case ExpresionAttribute::FLOAT:
                attributes->value = $4.fval;
                break;
            case ExpresionAttribute::BOOL:
                attributes->value = (bool)$4.ival; // Asumiendo que se almacena en ival
                break;
            case ExpresionAttribute::STRING:
                attributes->value = string($4.sval); // Convierte a std::string
                break;
            case ExpresionAttribute::POINTER:
                // Manejar punteros según sea necesario
                attributes->value = nullptr; // O el valor adecuado
                break;
            default:
                attributes->value = nullptr;
        }

        if (!symbolTable.insert_symbol($2, *attributes)){
			ERROR_TYPE = ALREADY_DEF_VAR;
            yyerror($2);
            exit(1);
        };
    }
    ;
determinado:
    T_REPITEBURDA abrir_scope var_ciclo_determinado T_IZQLLAVE {iniciarNodo(ASTNode::NodeType::instuctions);} instrucciones {cerrarNodo();} T_DERLLAVE cerrar_scope
    | T_REPITEBURDA abrir_scope var_ciclo_determinado T_CONFLOW T_VALUE T_IZQLLAVE {iniciarNodo(ASTNode::NodeType::flow_for); cerrarNodo(); iniciarNodo(ASTNode::NodeType::instuctions);} instrucciones {cerrarNodo();} T_DERLLAVE cerrar_scope
    ;

entrada_salida:
    {iniciarNodo(ASTNode::NodeType::s_print);} T_RESCATA T_IZQPAREN {iniciarNodo(ASTNode::NodeType::s_sequence);} secuencia {cerrarNodo();} T_DERPAREN {cerrarNodo();}
    | {iniciarNodo(ASTNode::NodeType::s_input);} T_HABLAME T_IZQPAREN expresion T_DERPAREN {cerrarNodo();}
    ;

secuencia:
    | secuencia T_COMA expresion 
    | expresion 
    ;

secuencia_declaraciones:
    | secuencia_declaraciones T_PUNTOCOMA T_IDENTIFICADOR T_DOSPUNTOS tipos{
		if (current_struct_name == "") {
			ERROR_TYPE = DEBUGGING_TYPE;
            yyerror("No hay estructura actual");
            exit(1);
        }
        
		Attributes* struct_attr = symbolTable.search_symbol(current_struct_name);
        if (struct_attr == nullptr) {
			ERROR_TYPE = NON_DEF_STRUCT;
            yyerror(current_struct_name.c_str());
            exit(1);
        }
        
        Attributes *attr = new Attributes();
        attr->symbol_name = $3;
        attr->scope = symbolTable.current_scope;
        attr->category = STRUCT_ATTRIBUTE;
        attr->type = symbolTable.search_symbol($5);
        attr->value = nullptr;
        
        if (!symbolTable.insert_symbol($3, *attr)) {
			ERROR_TYPE = ALREADY_DEF_ATTR;
            yyerror($3);
            exit(1);
        }
        
        struct_attr->info.push_back({string($3), attr});
        //cout << "  Agregando atributo: \"" << $3 << "\" a estructura: " << current_struct_name << endl;
    }
    | T_IDENTIFICADOR T_DOSPUNTOS tipos {
        if (current_struct_name == "") {
			ERROR_TYPE = DEBUGGING_TYPE;
            yyerror("No hay estructura actual");
            exit(1);
        }

        Attributes* struct_attr = symbolTable.search_symbol(current_struct_name);
        if (struct_attr == nullptr) {
			ERROR_TYPE = NON_DEF_STRUCT;
            yyerror(current_struct_name.c_str());
            exit(1);
        }
        
        Attributes *attr = new Attributes();
        attr->symbol_name = $1;
        attr->scope = symbolTable.current_scope;
        attr->category = STRUCT_ATTRIBUTE;
        attr->type = symbolTable.search_symbol($3);
        attr->value = nullptr;

        if (!symbolTable.insert_symbol($1, *attr)) {
			ERROR_TYPE = ALREADY_DEF_ATTR;
            yyerror($1);
            exit(1);
        }
		
        struct_attr->info.push_back({string($1), attr});
        //cout << "  Agregando atributo: \"" << $1 << "\" a estructura: " << current_struct_name << endl;
    }
    ;

variante: 
    T_COLIAO T_IDENTIFICADOR {
		Attributes *attributes = new Attributes();
        attributes->symbol_name = $2;
        attributes->scope = symbolTable.current_scope;
        attributes->category = UNION;
        attributes->info.push_back({"UNION", nullptr});
        attributes->value = nullptr;

		current_struct_name = string($2);

		if (!symbolTable.insert_symbol($2, *attributes)){
			ERROR_TYPE = ALREADY_DEF_UNION;
            yyerror($2);
            exit(1);
        };
        
        //cout << "Definiendo variante: " << $2 << endl;

	} abrir_scope T_IZQLLAVE secuencia_declaraciones T_PUNTOCOMA T_DERLLAVE {
		current_struct_name = "";
	} cerrar_scope
    ;

struct: 
    T_ARROZCONMANGO T_IDENTIFICADOR {
        Attributes *attributes = new Attributes();
        attributes->symbol_name = $2;
        attributes->scope = symbolTable.current_scope;
        attributes->category = STRUCT;
        attributes->info.push_back({"ESTRUCTURA", nullptr});
        attributes->value = nullptr;
        
        current_struct_name = string($2);
        
        if (!symbolTable.insert_symbol($2, *attributes)){
			ERROR_TYPE = ALREADY_DEF_STRUCT;
            yyerror($2);
            exit(1);
        };
        
        //cout << "Definiendo estructura: " << $2 << endl;
    } abrir_scope T_IZQLLAVE secuencia_declaraciones T_PUNTOCOMA T_DERLLAVE {
        current_struct_name = "";
    } cerrar_scope
    ;

firma_funcion: 
    T_ECHARCUENTO T_IDENTIFICADOR {

        Attributes *attributes = new Attributes();
        attributes->symbol_name = $2;
        attributes->scope = symbolTable.current_scope;
        //attributes->info.clear();
        attributes->info.push_back({"FUNCION", nullptr});
        attributes->type = symbolTable.search_symbol("funcion$");
        attributes->category = FUNCTION;
        attributes->value = nullptr;

        if (!symbolTable.insert_symbol($2, *attributes)){
			ERROR_TYPE = ALREADY_DEF_FUNC;
            yyerror($2);
            exit(1);
        };

        current_function_name = string($2);
    }
    ;

tipo_funcion:
    tipos 
    | T_UNCONO
    ;

secuencia_parametros:
    | secuencia_parametros T_COMA parametro 
	| parametro
    ;

parametro:
    T_AKITOY T_IDENTIFICADOR T_DOSPUNTOS tipos{
		if (current_function_name == "") {
			ERROR_TYPE = DEBUGGING_TYPE;
            yyerror("No hay funcion actual");
            exit(1);
        }
        
		Attributes* funct_attr = symbolTable.search_symbol(current_function_name);
        if (funct_attr == nullptr) {
			ERROR_TYPE = NON_DEF_FUNC;
            yyerror(current_function_name.c_str());
            exit(1);
        }

        Attributes *attributes = new Attributes();
        attributes->symbol_name = $2;
        attributes->scope = symbolTable.current_scope;
        attributes->info.push_back({"PARAMETRO", nullptr});
        attributes->type = symbolTable.search_symbol($4);
        attributes->category = POINTER_V;
        attributes->value = nullptr;

        if (!symbolTable.insert_symbol($2, *attributes)){
			ERROR_TYPE = ALREADY_DEF_VAR;
            yyerror($2);
            exit(1);
        };

		funct_attr->info.push_back({string($2), attributes});
    }
    | T_IDENTIFICADOR T_DOSPUNTOS tipos {
		if (current_function_name == "") {
			ERROR_TYPE = DEBUGGING_TYPE;
            yyerror("No hay funcion actual");
            exit(1);
        }
        
		Attributes* funct_attr = symbolTable.search_symbol(current_function_name);
        if (funct_attr == nullptr) {
			ERROR_TYPE = NON_DEF_FUNC;
            yyerror(current_function_name.c_str());
            exit(1);
        }
		
        Attributes *attributes = new Attributes();
        attributes->symbol_name = $1;
        attributes->scope = symbolTable.current_scope;
        //attributes->info.clear();
        attributes->info.push_back({"PARAMETRO", nullptr});
        attributes->type = symbolTable.search_symbol($3);
        attributes->category = VARIABLE;
        attributes->value = nullptr;

        if (!symbolTable.insert_symbol($1, *attributes)){
			ERROR_TYPE = ALREADY_DEF_VAR;
            yyerror($1);
            exit(1);
        };

		funct_attr->info.push_back({string($1), attributes});
    }
    ;

declaracion_funcion:
    firma_funcion abrir_scope T_IZQPAREN secuencia_parametros T_DERPAREN T_LANZA tipo_funcion {
		current_function_name = "";
	} T_IZQLLAVE instruccionesopt T_DERLLAVE cerrar_scope
    ;

funcion:
	T_IDENTIFICADOR  {iniciarNodo(ASTNode::NodeType::s_func_call); ancestros.top()->informacion.identificador = $1;} T_IZQPAREN {iniciarNodo(ASTNode::NodeType::s_sequence);} secuencia T_DERPAREN {cerrarNodo(); cerrarNodo();}

arreglo:
    T_IZQCORCHE secuencia T_DERCORCHE {
		current_array_name = "";
	}
    ;

var_manejo_error:
    T_COMO abrir_scope T_IDENTIFICADOR {
        iniciarNodo(ASTNode::NodeType::s_try_catch_variable);
        ancestros.top()->informacion.identificador = $3;
        cerrarNodo();

        if (symbolTable.search_symbol($3) != nullptr){
            ERROR_TYPE = ALREADY_DEF_VAR;
            yyerror($3);
            exit(1);
        };

        Attributes *attributes = new Attributes();
        attributes->symbol_name = $3;
        attributes->scope = symbolTable.current_scope;
        attributes->info.push_back({"MANEJO ERROR", nullptr});
        attributes->type = symbolTable.search_symbol("error$");
        attributes->category = VARIABLE;

        if (!symbolTable.insert_symbol($3, *attributes)){
            ERROR_TYPE = ALREADY_DEF_VAR;
            yyerror($3);
            exit(1);
        };
    }
    ;

manejador:
    | T_FUERADELPEROL abrir_scope T_IZQLLAVE {iniciarNodo(ASTNode::NodeType::instuctions);} instrucciones {cerrarNodo();}T_DERLLAVE cerrar_scope
    | T_FUERADELPEROL var_manejo_error T_IZQLLAVE {iniciarNodo(ASTNode::NodeType::instuctions);} instrucciones {cerrarNodo();} T_DERLLAVE cerrar_scope
    ;

manejo_error:
    T_T_MEANDO abrir_scope {iniciarNodo(ASTNode::NodeType::s_try);} T_IZQLLAVE {iniciarNodo(ASTNode::NodeType::instuctions);} instrucciones {cerrarNodo();} T_DERLLAVE cerrar_scope {iniciarNodo(ASTNode::NodeType::s_try_catch);}  manejador{cerrarNodo(); cerrarNodo();}
    ;

casting:
	T_CASTEO expresion
	;

%%

void yyerror(const char *var) {
    static bool first_error = true;

	if (ERROR_TYPE == SEMANTIC_TYPE) {
		extern char* yytext;
		cerr << "\nError sintáctico en línea " << yylineno << ", columna " << yylloc.first_column << ": '" << yytext << "'\n\n";
	} else {
		cout << "\nError en línea " << yylineno << ", columna " << yylloc.first_column << ": ";
		switch (ERROR_TYPE) {
	        case NON_DEF_VAR:
	            cout << "Variable \"" << var << "\" no definida.";
	            break;
	        case ALREADY_DEF_VAR:
	            cout << "Variable \"" << var << "\" ya fue definida.";
	            break;
	        case NON_DEF_FUNC:
				cout << "Funcion \"" << var << "\" no definida.";
	            break;
	        case ALREADY_DEF_FUNC:
	            cout << "Funcion \"" << var << "\" ya fue definida.";
	            break;
	        case NON_DEF_STRUCT:
	            cout << "Estructura \"" << var << "\" no definida.";
	            break;
	        case ALREADY_DEF_STRUCT:
	            cout << "Estructura \"" << var << "\" ya fue definida.";
	            break;
	        case NON_DEF_UNION:
	            cout << "Variante \"" << var << "\" no definida.";
	            break;
	        case ALREADY_DEF_UNION:
	            cout << "Variante \"" << var << "\" ya fue definida.";
	            break;
	        case ALREADY_DEF_ATTR:
	            cout << "Atributo \"" << var << "\" ya fue definido.";
	            break;
	        case NON_DEF_TYPE:
	            cout << "Tipo \"" << var << "\"" << " no definido.";
	            break;
	        case VAR_FOR:
				cout << "Variable \"" << var << "\" es de ciclo repite_burda. No se admite cambiar su valor.";
	            break;
	        case VAR_TRY:
				cout << "Variable \"" << var << "\" es de estructura fuera_del_perol. No se admite cambiar su valor.";
	            break;
	        case DEBUGGING_TYPE:
				cout << var;
	            break;
	        default:
	            break;
	    }
		cout << "\n\n";
	}
}