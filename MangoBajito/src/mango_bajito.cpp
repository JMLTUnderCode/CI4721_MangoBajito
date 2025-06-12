#include "mango_bajito.hpp"

// ======================================================
// =                   Error Handler                    =
// ======================================================

vector<string> sysErrorToString = {
	"ARRAY_LITERAL_SIZE_MISMATCH",
	"SEMANTIC",
	"NON_DEF_VAR",
	"ALREADY_DEF_VAR",
	"NON_DEF_FUNC",
	"ALREADY_DEF_FUNC",
	"NON_DEF_STRUCT",
	"ALREADY_DEF_STRUCT",
	"EMPTY_STRUCT",
	"NON_DEF_UNION",
	"ALREADY_DEF_UNION",
	"EMPTY_UNION",
	"NON_DEF_TYPE",
	"ALREADY_DEF_TYPE",
	"NON_DEF_ATTR",
	"ALREADY_DEF_ATTR",
	"MODIFY_VAR_FOR",
	"TRY_ERROR",
	"NON_VALUE",
	"TYPE_ERROR",
	"MODIFY_CONST",
	"SEGMENTATION_FAULT",
	"FUNC_PARAM_EXCEEDED",
	"FUNC_PARAM_MISSING",
	"ALREADY_DEF_PARAM",
	"EMPTY_ARRAY_CONSTANT",
	"POINTER_ARRAY",
	"INT_INDEX_ARRAY",
	"SIZE_ARRAY_INVALID",
	"INTERNAL",
	"EMPTY"
};

// Función para agregar un error al diccionario
void addError(systemError err, const string& msg) {
	FIRST_ERROR = true; // Indicamos que al menos un error ha ocurrido
	errorDictionary[err].push_back(msg);
}

// Función para imprimir todos los errores
void printErrors() {
	for (const auto& [err, errors] : errorDictionary) {
		if(errors.empty()) continue;
		cout << "Error: " << sysErrorToString[err] << endl;
		for (const auto& error : errors) cout << "  - " << error << endl;
	}
}


// ======================================================
// =                    Symbol Table                    =
// ======================================================

// Implementacion de la clase SymbolTable
SymbolTable::SymbolTable() {
	this->current_scope = 0;
	this->next_scope = 1;
	this->prev_scope = {};
	this->scopes.push_back({this->current_scope, false});

	// Agregamos los simbolos predefinidos
	for (auto& type : predef_types){
		Attributes *attr = new Attributes();
		attr->symbol_name = type;
		attr->category = TYPE;
		this->insert_symbol(type, *attr);
	}

	// Agregamos las funciones predefinidas
	for (auto& func : predef_func){
		Attributes *attr = new Attributes();
		attr->symbol_name = func;
		attr->category = FUNCTION;
		this->insert_symbol(func, *attr);
	}
}

void SymbolTable::open_scope() {
	this->prev_scope.push(this->current_scope);
	this->current_scope = this->next_scope;
	this->next_scope++;
	this->scopes.push_back({this->current_scope, false});
}

void SymbolTable::close_scope() {
	//this->finding_variables_in_scope(this->current_scope);
	this->scopes[this->current_scope].second = true;
	this->current_scope = this->prev_scope.top();
	this->prev_scope.pop();
}

bool SymbolTable::contains_key(string key) {
	return this->table.count(key) > 0;
}

bool SymbolTable::insert_symbol(string symbol_name, Attributes &attr) {
	if (contains_key(symbol_name)) {
		vector<Attributes> &symbols = this->table[symbol_name];
		for (Attributes &symbol : symbols) {
			if (symbol.scope == this->current_scope) {
				return false; // El simbolo ya existe en el scope actual
			}
		}
		symbols.push_back(attr);
		return true;
	}
	vector<Attributes> symbols;
	symbols.push_back(attr);
	this->table[symbol_name] = symbols;
	return true;
}

bool SymbolTable::remove_symbol(string symbol_name) {
	auto symbols = this->table.find(symbol_name);
	if (symbols != this->table.end()) {
		for (auto it = symbols->second.begin(); it != symbols->second.end(); ++it) {
			if (it->scope == this->current_scope) {
				symbols->second.erase(it);
				if (symbols->second.empty()) {
					this->table.erase(symbols); // Eliminar la clave si no hay mas simbolos
				}
				return true;
			}
		}
	}
	return false; // No se encontro el simbolo en el scope actual
}

Attributes* SymbolTable::search_symbol(string symbol_name) {
	Attributes* predef_symbol = nullptr;
	Attributes* best_option = nullptr;
	int scope_value;
	auto symbols = this->table.find(symbol_name);
	if (symbols != this->table.end()) {
		for (Attributes &symbol : symbols->second) {
			if (symbol.symbol_name != symbol_name) continue;
			if (symbol.scope == 0) { predef_symbol = &symbol; break; }
			for(int i = this->scopes.size() - 1; i >= 0; i--){
				if (this->scopes[i].second) continue; // Scope cerrado.
				
				if (symbol.scope == this->scopes[i].first) {
					best_option = &symbol; // El scope mas cercano
					break;
				} else if (best_option != nullptr && this->scopes[i].first == best_option->scope) {
					break; // No se encontrara un scope mas cercano
				}
			}
		}
		
		if (best_option != nullptr){
			return best_option;
		}else if (predef_symbol != nullptr){
			return predef_symbol;
		}else{
			return nullptr;
		}
	}
	return nullptr;
}

void SymbolTable::finding_variables_in_scope(int scope){
	cout << " ---> Start Scope Level: " << scope << " <---" << endl;
	int count = 1;
	for (auto& symbol : table){
		for (Attributes &attr : symbol.second){
			if (attr.scope == scope){
				cout << "       " << count++ << ": " << attr.symbol_name << endl;
			}
		}
	}
	cout << " ---> End Scope Level: " << scope << " <---\n" << endl;
}


// Imprime la tabla de simbolos
void SymbolTable::print_table() {
	string ss;
	cout << "--> Print table? (s/n): "; cin >> ss;
	while(ss != "s" && ss != "n") { cout << "Key Error. Print table? (s/n): "; cin >> ss; }
	if (ss == "n") return;
	
	cout << "\033[1;36m\033[5m\n               =======================================================\n";
	cout << "                             Symbol Table Representation              \n";
	cout << "               =======================================================\n\033[0m\n";
	int count = 1;
	for (auto& symbol : this->table) {
		cout << "\033[1;35m\033[5m    Clave: " << count++ << ": " << symbol.first << "\033[0m" << endl;
		for (Attributes &attr : symbol.second) {
			print_attribute(attr);
		}
	}
}

void SymbolTable::print_attribute(Attributes &attr){
	cout << "    |---> Símbolo: " << attr.symbol_name;
	cout << ", Categoría: (" << attr.category  << ")" << categoryToString(attr.category);
	cout << ", Scope: " << attr.scope;
	if (attr.type) cout << ", Type: "<< attr.type->symbol_name;
	if (!attr.info.empty()) {
		cout <<  ", Informacion: ";
		print_info(attr.info);
	} 
	if (!holds_alternative<nullptr_t>(attr.value)) {
		cout << ", Value: ";
		print_values(attr.value);
	}
	cout << "\n\n";
}	

void SymbolTable::print_info(vector<pair<Information, Attributes*> > informations){
	for (auto &info : informations){
		if (holds_alternative<int>(info.first)) {
			cout << get<int>(info.first) << " ";
		} else if (holds_alternative<string>(info.first)){
			cout << (get<string>(info.first)) << " ";
		} else {
			cout << (get<bool>(info.first) ? "true" : "false") << " ";
		}
	}
}

void SymbolTable::print_values(Values x){
	visit([this](auto&& arg) {
		using T = decay_t<decltype(arg)>;
		if constexpr (is_same_v<T, nullptr_t>) cout << "null";
		else if constexpr (is_same_v<T, char>) cout << arg;
		else if constexpr (is_same_v<T, int>) cout << arg;
		else if constexpr (is_same_v<T, bool>) cout << (arg ? "true" : "false");
		else if constexpr (is_same_v<T, float>) cout << arg;
		else if constexpr (is_same_v<T, double>) cout << arg;
		else if constexpr (is_same_v<T, string>) cout << arg;
		else if constexpr (is_same_v<T, int*>) cout << *arg;
		else if constexpr (is_same_v<T, double*>) cout << *arg;
		else if constexpr (is_same_v<T, string*>) cout << *arg;
		else if constexpr (is_same_v<T, vector<int>>) {
			cout << "[";
			for (const auto& v : arg) cout << v << " ";
			cout << "]";
		}
		else if constexpr (is_same_v<T, vector<float>>) {
			cout << "[";
			for (const auto& v : arg) cout << v << " ";
			cout << "]";
		}
		else if constexpr (is_same_v<T, vector<double>>) {
			cout << "[";
			for (const auto& v : arg) cout << v << " ";
			cout << "]";
		}
		else if constexpr (is_same_v<T, vector<string>>) {
			cout << "[";
			for (const auto& v : arg) cout << v << " ";
			cout << "]";
		}
		else if constexpr (is_same_v<T, vector<RecursiveArray>>) {
			cout << "[";
			for (const auto& v : arg) {
				cout << "{";
				for (const auto& val : v.data) this->print_values(val);
				cout << "} ";
			}
			cout << "]";
		}
	}, x);
}

// ======================================================
// =                Abstract Sintax Tree                =
// ======================================================

// Crear un nodo AST y devolver un puntero inteligente.
// name: nombre del nodo, category: categoría del nodo, type: tipo de dato, kind: tipo de declaración.
// Retorna un puntero al nuevo nodo AST creado.
ASTNode* makeASTNode(const string& name, const string& category, const string& type, const string& kind) {
	return new ASTNode(name, category, type, kind);
}

// Recolecta nodos por una lista de categorías.
// node: nodo raíz a partir del cual buscar, categories: conjunto de categorías a buscar, out: vector donde se almacenan los nodos encontrados.
void collect_nodes_by_categories(ASTNode* node, const set<string>& categories, vector<ASTNode*>& out) {
    if (!node) return;
    if (categories.count(node->category)) out.push_back(node);
    for (auto child : node->children) collect_nodes_by_categories(child, categories, out);
}

// Recolecta todos los nodos de tipo guardia ("o_asi" o "nojoda") en el AST.
// node: nodo raíz a partir del cual buscar, out: vector donde se almacenan los nodos guardia encontrados.
void collect_guardias(ASTNode* node, vector<ASTNode*>& out) {
    if (!node) return;
    // Si el nodo es una guardia, lo agregamos como hijo directo
    if (node->name == "o_asi" || node->name == "nojoda") {
        out.push_back(node);
    } else {
        // Si no, recorremos sus hijos
        for (ASTNode* child : node->children) {
            collect_guardias(child, out);
        }
    }
}

// Verifica si el tipo de dato dado corresponde a un tipo numérico ("mango", "manguita" o "manguangua").
// typeStr: nombre del tipo a verificar.
// Retorna true si es numérico, false en caso contrario.
bool isNumeric(const string& typeStr) {
	return typeStr == "mango" || typeStr == "manguita" || typeStr == "manguangua";
}

// Realiza una operación binaria entre dos nodos AST y retorna el nodo resultado.
// left: nodo izquierdo, op: operador, right: nodo derecho, line_number y column_number: ubicación para reporte de errores.
// Retorna un puntero al nodo AST resultante de la operación.
ASTNode* solver_operation(ASTNode* left, const string& op, ASTNode* right, int line_number, int column_number) {
    ASTNode* new_node = makeASTNode(op, "Operación");
	string type = "Desconocido";
    string kind = "Desconocido";
    
	string error_msg = "Sendo peo en la linea " + to_string(line_number) +
		", columna " + to_string(column_number) + ": ";

    set<string> ops_numericas = {"+", "-", "*", "/", "//", "%", "**"};
	if (ops_numericas.count(op)) kind = "Numérica";

    set<string> ops_booleana = {"igualito", "nie", "mayol", "lidel", "menol", "peluche", "yunta", "o_sea"};
	if (ops_booleana.count(op)) kind = "Booleana";

	string left_type = left ? left->type : "Desconocido";
	string right_type = right ? right->type : "Desconocido";

	if (left && right) {
		type = left_type;

		if (kind == "Numérica" && left_type == right_type) {
			if (type == "mango"){
				if (op == "+") new_node->ivalue = left->ivalue + right->ivalue;
				else if (op == "-") new_node->ivalue = left->ivalue - right->ivalue;
				else if (op == "*") new_node->ivalue = left->ivalue * right->ivalue;
				else if (op == "/") {
					if (right->ivalue != 0) {
						new_node->fvalue = static_cast<float>(left->ivalue) / right->ivalue;
					} else {
						error_msg += "Division by zero in operation.";
						addError(SEGMENTATION_FAULT, error_msg);
					}
					type = "manguita";
				} else if (op == "//") {
					if (right->ivalue != 0) {
						new_node->ivalue = left->ivalue / right->ivalue;
					} else {
						error_msg += "Division by zero in operation.";
						addError(SEGMENTATION_FAULT, error_msg);
					}
				} else if (op == "%") {
					if (right->ivalue != 0) {
						new_node->ivalue = left->ivalue % right->ivalue;
					} else {
						error_msg += "Modulo by zero in operation.";
						addError(TYPE_ERROR, error_msg);
					}
				} else if (op == "**") {
					new_node->dvalue = pow(left->ivalue, right->ivalue);
					type = "manguangua";
				}
			
			} else if (type == "manguita"){
				if (op == "+") new_node->fvalue = left->fvalue + right->fvalue;
				else if (op == "-") new_node->fvalue = left->fvalue - right->fvalue;
				else if (op == "*") new_node->fvalue = left->fvalue * right->fvalue;
				else if (op == "/") {
					if (right->fvalue != 0.0) {
						new_node->fvalue = left->fvalue / right->fvalue;
					} else {
						error_msg += "Division by zero in operation.";
						addError(SEGMENTATION_FAULT, error_msg);
					}
				} else if (op == "//") {
					if (right->fvalue != 0.0) {
						new_node->ivalue = static_cast<int>(left->fvalue / right->fvalue);
					} else {
						error_msg += "Division by zero in operation.";
						addError(SEGMENTATION_FAULT, error_msg);
					}
					type = "mango";
				} else if (op == "%") {
					error_msg += "Modulo operation not supported for float types.";
					addError(TYPE_ERROR, error_msg);
				} else if (op == "**") {
					float base = left->fvalue;
				    float exp = right->fvalue;
				    // Raíz impar de negativo: resultado negativo
					if (base < 0 && fmod(exp, 2.0f) != 0.0f) {
				        new_node->dvalue = -pow(-base, exp);
				    } else {
				        new_node->dvalue = pow(base, exp);
				    }
					type = "manguangua";
				}
			} else if (type == "manguangua"){
				if (op == "+") new_node->dvalue = left->dvalue + right->dvalue;
				else if (op == "-") new_node->dvalue = left->dvalue - right->dvalue;
				else if (op == "*") new_node->dvalue = left->dvalue * right->dvalue;
				else if (op == "/") {
					if (right->dvalue != 0.0) new_node->dvalue = left->dvalue / right->dvalue;
					else {
						error_msg += "Division by zero in operation.";
						addError(SEGMENTATION_FAULT, error_msg);
					}
				} else if (op == "//") {
					if (right->dvalue != 0.0) {
						new_node->ivalue = static_cast<int>(left->dvalue / right->dvalue);
						type = "mango";
					} else {
						error_msg += "Division by zero in operation.";
						addError(SEGMENTATION_FAULT, error_msg);
					}
				} else if (op == "%") {
					error_msg += "Modulo operation not supported for double types.";
					addError(TYPE_ERROR, error_msg);
				} else if (op == "**"){
					double base = left->dvalue;
				    double exp = right->dvalue;
				    // Raíz impar de negativo: resultado negativo
					if (base < 0 && fmod(exp, 2.0) != 0.0f) {
				        new_node->dvalue = -pow(-base, exp);
				    } else {
				        new_node->dvalue = pow(base, exp);
				    }
				}
			} else {
				error_msg += "Unsupported type for operation: " + type;
				addError(TYPE_ERROR, error_msg);
			}

		} else if (kind == "Numérica" && left_type != right_type) {
			error_msg += "Type mismatch in operation: " + left_type + " " + op + " " + right_type;
			addError(TYPE_ERROR, error_msg);

		} else if (kind == "Booleana") {
			if (type == "tas_claro" && left_type == right_type) {
		        if (op == "yunta") { // and
					new_node->bvalue = left->bvalue && right->bvalue;
		        } else if (op == "o_sea") { // or
		            new_node->bvalue = left->bvalue || right->bvalue;
				} else if (op == "igualito") {
					new_node->bvalue = (left->bvalue == right->bvalue);
				} else if (op == "nie") {
					new_node->bvalue = (left->bvalue != right->bvalue);
				} else {
					error_msg += "Operación '" + op + "' no soportada entre tipos: '" + left->type + "' y '" + right->type + "'.";
					addError(TYPE_ERROR, error_msg);
				}

			} else {
				type = "tas_claro"; // Asignar tipo por defecto para operaciones booleanas

				auto isNumeric = [](const string& t) {
				    return t == "mango" || t == "manguita" || t == "manguangua";
				};

				auto get_double = [](ASTNode* n) -> double {
				    if (n->type == "mango") return static_cast<double>(n->ivalue);
				    if (n->type == "manguita") return static_cast<double>(n->fvalue);
				    if (n->type == "manguangua") return n->dvalue;
				    return 0.0;
				};

				auto get_char = [](ASTNode* n) -> char {
				    if (n->type == "negro") return n->cvalue;
				    return '\0';
				};

				auto get_string = [](ASTNode* n) -> string {
				    if (n->type == "higuerote") return n->svalue;
				    return "";
				};

				if (isNumeric(left->type) && isNumeric(right->type)) {
				    double l = get_double(left);
				    double r = get_double(right);
				    if (op == "igualito")      new_node->bvalue = (l == r);
				    else if (op == "nie")      new_node->bvalue = (l != r);
				    else if (op == "mayol")    new_node->bvalue = (l > r);
				    else if (op == "lidel")    new_node->bvalue = (l >= r);
				    else if (op == "menol")    new_node->bvalue = (l < r);
				    else if (op == "peluche")  new_node->bvalue = (l <= r);
				} else if (left->type == "higuerote" && right->type == "higuerote") {
				    string l = get_string(left);
				    string r = get_string(right);
				    if (op == "igualito")      new_node->bvalue = (l == r);
				    else if (op == "nie")      new_node->bvalue = (l != r);
				    else if (op == "mayol")    new_node->bvalue = (l > r);
				    else if (op == "lidel")    new_node->bvalue = (l >= r);
				    else if (op == "menol")    new_node->bvalue = (l < r);
				    else if (op == "peluche")  new_node->bvalue = (l <= r);
				} else if (left->type == "negro" && right->type == "negro") {
				    char l = get_char(left);
				    char r = get_char(right);
				    if (op == "igualito")      new_node->bvalue = (l == r);
				    else if (op == "nie")      new_node->bvalue = (l != r);
				    else if (op == "mayol")    new_node->bvalue = (l > r);
				    else if (op == "lidel")    new_node->bvalue = (l >= r);
				    else if (op == "menol")    new_node->bvalue = (l < r);
				    else if (op == "peluche")  new_node->bvalue = (l <= r);
				} else {
					if (op == "igualito") {
						new_node->bvalue = false;
					} else if (op == "nie") {
						new_node->bvalue = true;
					} else {
						error_msg += "Operación '" + op + "' no soportada entre tipos: '" + left->type + "' y '" + right->type + "'.";
						addError(TYPE_ERROR, error_msg);
					}
				}
			}
		}
		new_node->type = type;
		new_node->kind = kind;
	    if (left) new_node->children.push_back(left);
	    if (right) new_node->children.push_back(right);
	    return new_node;

	} else {
		error_msg += "Non operands finds.";
		addError(INTERNAL, error_msg);
		return nullptr;
	}
}

// Muestra el AST en consola de forma jerárquica.
// node: nodo raíz a mostrar, depth: nivel de profundidad, prefix: prefijo para formato, isLast: indica si es el último hijo.
void showAST(const ASTNode* node, int depth, const string& prefix, bool isLast) {
	if (!node) return;
	
    // Imprimir el prefijo visual
    cout << prefix;
    if (depth > 0) {
        cout << (isLast ? "|--> " : "|--> ");
    }

    // Imprimir la línea del nodo
    cout << node->name;
	if (!node->category.empty()) cout << " | Category: " << node->category;
	if (!node->type.empty())     cout << " | Type: " << node->type;
	if (!node->kind.empty())     cout << " | Kind: " << node->kind;

	if (node->show_value) {
		string type = node->type.empty() ? "Desconocido" : node->type;
		if (type == "mango") cout << " | Value: " << node->ivalue;
		if (type == "manguita") cout << " | Value: " << node->fvalue;
		if (type == "manguangua") cout << " | Value: " << node->dvalue;
		if (type == "negro") cout << " | Value: '" << node->cvalue << "'";
		if (type == "higuerote") cout << " | Value: \"" << node->svalue << "\"";
		if (type == "tas_claro") cout << " | Value: " << node->bvalue ? "Sisa" : "Nolsa";
	}
	
    cout << endl;

    // Construir el prefijo para los hijos
    string childPrefix = prefix;
    if (depth > 0) {
        childPrefix += (isLast ? "     " : "|    ");
    }

    // Imprimir hijos recursivamente
    for (size_t i = 0; i < node->children.size(); ++i) {
        bool lastChild = (i == node->children.size() - 1);
        showAST(node->children[i], depth + 1, childPrefix, lastChild);
    }
}

// Imprime el AST completo en consola.
// node: nodo raíz del AST a imprimir.
void print_AST(const ASTNode* node) {
	if (!node) {
		cout << "AST is empty." << endl;
		return;
	}

	string ss;
	cout << "--> Print AST? (s/n): "; cin >> ss;
	while(ss != "s" && ss != "n") { cout << "Key Error. Print table? (s/n): "; cin >> ss; }
	if (ss == "n") return;

	cout << "\033[1;36m\033[5m\n               =======================================================\n";
	cout << "                                   AST Representation                 \n";
	cout << "               =======================================================\n\033[0m\n";
	showAST(node, 0);
}

string valuesToString(const ASTNode* node) {
	if (!node) return "null";
	
	string type = node->type.empty() ? "Desconocido" : node->type;
	if (type == "mango") return to_string(node->ivalue);
	if (type == "manguita") return to_string(node->fvalue);
	if (type == "manguangua") return to_string(node->dvalue);
	if (type == "negro") return string(1, node->cvalue);
	if (type == "higuerote") return node->svalue;
	if (type == "tas_claro") return node->bvalue ? "Sisa" : "Nolsa";
	return "Desconocido";
}

// ======================================================
// =                Three Address Code                  =
// ======================================================
void show_TAC(const ASTNode* node){
	if (!node) return;
	
	// Imprimir la sección de datos si hay información adicional
	if (!node->tac_data.empty()) cout << ".data:" << endl; 

	for (const auto& tac_data : node->tac_data) {
		cout << tac_data.first << " := \"" << tac_data.second << "\"" << endl;
	}

	// Imprimir las declaraciones TAC si hay
	if (!node->tac_declaraciones.empty()) cout << "\n.declaration:" << endl; 

	for (const auto& tac_decl : node->tac_declaraciones) {
		cout << tac_decl.first << ": alloc " << tac_decl.second << endl;
	}
	
	// Imprimir el codigo principal
	cout << "\n.code:\n";
	for (auto tac : node->tac){
		cout << tac << endl;
	}

}

void print_TAC(const ASTNode* node) {
	if (!node) {
		cout << "TAC is empty." << endl;
		return;
	}

	string ss;
	cout << "--> Print TAC? (s/n): "; cin >> ss;
	while(ss != "s" && ss != "n") { cout << "Key Error. Print TAC? (s/n): "; cin >> ss; }
	if (ss == "n") return;

	cout << "\033[1;36m\033[5m\n               =======================================================\n";
	cout << "                                   TAC Representation                 \n";
	cout << "               =======================================================\n\033[0m\n";

	show_TAC(node);
}

void concat_TAC(ASTNode* node, ASTNode* n1, ASTNode* n2){
	if (n1){
		node->tac.insert(node->tac.end(), n1->tac.begin(), n1->tac.end());
		node->tac_data.insert(node->tac_data.end(), n1->tac_data.begin(), n1->tac_data.end());
		node->tac_declaraciones.insert(node->tac_declaraciones.end(), n1->tac_declaraciones.begin(), n1->tac_declaraciones.end());
	}
	if (n2){
		node->tac.insert(node->tac.end(), n2->tac.begin(), n2->tac.end());
		node->tac_data.insert(node->tac_data.end(), n2->tac_data.begin(), n2->tac_data.end());
		node->tac_declaraciones.insert(node->tac_declaraciones.end(), n2->tac_declaraciones.begin(), n2->tac_declaraciones.end());
	}
}

SizeType strToSizeType(string type){
	if (type == "negro") return NEGRO;
	if (type == "tas_claro") return TAS_CLARO;
	if (type == "mango") return MANGO;
	if (type == "manguita") return MANGUITA;
	if (type == "manguangua") return MANGUANGUA;
	if (type == "higuerote") return HIGUEROTE;
}