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
	"WRONG_RANGE",
	"TRY_ERROR",
	"NON_VALUE",
	"TYPE_ERROR",
	"INVALID_OPERATION",
	"MODIFY_CONST",
	"SEGMENTATION_FAULT",
	"FUNC_PARAM_EXCEEDED",
	"FUNC_PARAM_MISSING",
	"FUNC_RETURN_VALUE",
	"FUNC_NO_RETURN",
	"ALREADY_DEF_PARAM",
	"EMPTY_ARRAY_CONSTANT",
	"POINTER_ARRAY",
	"INT_INDEX_ARRAY",
	"SIZE_ARRAY_INVALID",
	"INVALID_ACCESS",
	"CASTING_TYPE",
	"CASTING_ERROR",
	"OVERFULL",
	"INTERNAL"
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
	cout << "--> Print Symbol Table? (s/n): "; cin >> ss;
	while(ss != "s" && ss != "n") { cout << "Key Error. Print Symbol Table? (s/n): "; cin >> ss; }
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
	cout << ", Declaración: (" << attr.declare << ")" << declareToString(attr.declare);
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
		else if constexpr (is_same_v<T, char>) cout << (arg == '\0' ? "''" : "'" + string(1, arg) + "'");
		else if constexpr (is_same_v<T, int>) cout << arg;
		else if constexpr (is_same_v<T, bool>) cout << (arg ? "true" : "false");
		else if constexpr (is_same_v<T, float>) cout << arg;
		else if constexpr (is_same_v<T, double>) cout << arg;
		else if constexpr (is_same_v<T, string>) cout << (arg == "" ? "\"\"" : "\"" + arg + "\"");
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
	for (auto child : node->children) {
		if (child->category != "Estructura") collect_nodes_by_categories(child, categories, out);
		else out.push_back(child);
	}
}

// Recolecta nodos por una lista de categorías.
// node: nodo raíz a partir del cual buscar, out: vector donde se almacenan los nodos encontrados.
void collect_arguments(ASTNode* node, vector<ASTNode*>& out) {
	if (!node) return;
	if (node->children.empty()) {
		out.push_back(node);
		return;
	}
	for (auto child : node->children) {
		if (child->name != "Secuencia") out.push_back(child);
		else collect_arguments(child, out);
	}
}

// Recolecta todos los nodos de tipo guardia ("o_asi" o "nojoda") en el AST.
// node: nodo raíz a partir del cual buscar, out: vector donde se almacenan los nodos guardia encontrados.
void collect_guards(ASTNode* node, vector<ASTNode*>& out) {
	if (!node) return;
	// Si el nodo es una guardia, lo agregamos como hijo directo
	if (node->name == "o_asi" || node->name == "nojoda") {
		out.push_back(node);
	} else {
		// Si no, recorremos sus hijos
		for (ASTNode* child : node->children) {
			collect_guards(child, out);
		}
	}
}

// Recolecta todos los nodos de tipo Lanzate.
void collect_returns(ASTNode* node, vector<ASTNode*>& out){
	if (!node) return;
	// Si el nodo es una guardia, lo agregamos como hijo directo
	if (node->name == "lanzate") {
		out.push_back(node);
	} else {
		// Si no, recorremos sus hijos
		for (ASTNode* child : node->children) {
			collect_returns(child, out);
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

	if (!left || !right) {
		error_msg += "Non operands finds.";
		addError(INTERNAL, error_msg);
		return nullptr;
	} else {
		type = left_type;
		if (left_type == "un_coño" || right_type == "un_coño") {
			error_msg += "Cómo comparo 'un_coño' con otra vaina más? Definitivamente la droga pega.";
			addError(INVALID_OPERATION, error_msg);
		} else if (kind == "Numérica" && left_type == right_type && left_type == "higuerote") {
			kind = "Concatenación";
			if (op == "+") new_node->svalue = left->svalue + right->svalue;
			else {
				error_msg += "Estas operando \"" + op + "\"" + " entre '" + left_type + "' y '" + right_type + "', que vaina es loca?";
				addError(INVALID_OPERATION, error_msg);
			}
		} else if (kind == "Numérica" && left_type == right_type) {
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
					double res = pow(left->ivalue, right->ivalue);
					if (res >= INT_MIN && res <= INT_MAX && floor(res) == res) {
						new_node->ivalue = static_cast<int>(res);
						type = "mango";
					} else if (res >= -FLT_MAX && res <= FLT_MAX) {
						new_node->fvalue = static_cast<float>(res);
						type = "manguita";
					} else {
						new_node->dvalue = res;
						type = "manguangua";
					}
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
					double res;
					if (base < 0 && fmod(exp, 2.0f) != 0.0f) res = -pow(-base, exp);
					else res = pow(base, exp);

					// Prioridad: manguita → manguangua
					if (res >= -FLT_MAX && res <= FLT_MAX) {
						new_node->fvalue = static_cast<float>(res);
						type = "manguita";
					} else {
						new_node->dvalue = res;
						type = "manguangua";
					}
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
				} else if (op == "**") {
					double base = left->dvalue;
					double exp = right->dvalue;
					double res;
					if (base < 0 && fmod(exp, 2.0) != 0.0f) res = -pow(-base, exp);
					else res = pow(base, exp);

					// Siempre manguangua
					new_node->dvalue = res;
					type = "manguangua";
				}
			} else {
				error_msg += "Estas operando \"" + op + "\"" + " entre '" + left_type + "' y '" + right_type + "', que vaina es loca?";
				addError(INVALID_OPERATION, error_msg);
			}

		} else if (kind == "Numérica" && left_type != right_type) {
			error_msg += "Estas operando \"" + op + "\"" + " entre '" + left_type + "' y '" + right_type + "', que vaina es loca?";
			addError(INVALID_OPERATION, error_msg);

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
					error_msg += "Estas operando \"" + op + "\"" + " entre '" + left_type + "' y '" + right_type + "', que vaina es loca?";
					addError(INVALID_OPERATION, error_msg);
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

				if (isNumeric(left_type) && isNumeric(right_type)) {
					double l = get_double(left);
					double r = get_double(right);
					if (op == "igualito")      new_node->bvalue = (l == r);
					else if (op == "nie")      new_node->bvalue = (l != r);
					else if (op == "mayol")    new_node->bvalue = (l > r);
					else if (op == "lidel")    new_node->bvalue = (l >= r);
					else if (op == "menol")    new_node->bvalue = (l < r);
					else if (op == "peluche")  new_node->bvalue = (l <= r);
				} else if (left_type == "higuerote" && right_type == "higuerote") {
					string l = get_string(left);
					string r = get_string(right);
					if (op == "igualito")      new_node->bvalue = (l == r);
					else if (op == "nie")      new_node->bvalue = (l != r);
					else if (op == "mayol")    new_node->bvalue = (l > r);
					else if (op == "lidel")    new_node->bvalue = (l >= r);
					else if (op == "menol")    new_node->bvalue = (l < r);
					else if (op == "peluche")  new_node->bvalue = (l <= r);
				} else if (left_type == "negro" && right_type == "negro") {
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
						error_msg += "Estas operando \"" + op + "\"" + " entre '" + left_type + "' y '" + right_type + "', que vaina es loca?";
						addError(INVALID_OPERATION, error_msg);
					}
				}
			}
		}
		new_node->type = type;
		new_node->kind = kind;
		if (left) new_node->children.push_back(left);
		if (right) new_node->children.push_back(right);
		return new_node;
	} 
}

// Construye arbol AST de una Estructura(Arroz Con Mango).
void buildAST_by_struct(ASTNode* node, vector<pair<Information, Attributes*>> info, SymbolTable& symbolTable) {
	if (info.empty()) return;
	
	// Vector para almacenar los hijos (atributos o subestructuras)
	vector<ASTNode*> children;
	for (size_t i = 0; i < info.size(); i++) {
		Attributes* attr = symbolTable.search_symbol(get<string>(info[i].first));
		if (attr == nullptr) continue; // Si el atributo es nulo, saltar.
		
		//ASTNode* secuence_node = makeASTNode("Secuencia", "Expresión", "", ",");
		ASTNode* child = makeASTNode(attr->symbol_name, "Atributo_Estructura");

		if (attr->category == STRUCT) {
			child->category = "Estructura";
			buildAST_by_struct(child, attr->info, symbolTable);
		} else {
			string type = attr->type ? attr->type->symbol_name : "Desconocido";
			child->type = type;
			child->show_value = !holds_alternative<nullptr_t>(attr->value);
			if (type == "mango") {
				if (child->show_value) child->ivalue = get<int>(attr->value);
				else child->ivalue = 0; // Valor nulo para int
			} else if (type == "manguita") {
				if (child->show_value) child->fvalue = get<float>(attr->value);
				else child->fvalue = 0.0f; // Valor nulo para float
			} else if (type == "manguangua") {
				if (child->show_value) child->dvalue = get<double>(attr->value);
				else child->dvalue = 0.0; // Valor nulo para double
			} else if (type == "negro") {
				if (child->show_value) child->cvalue = get<char>(attr->value);
				else child->cvalue = '\0'; // Valor nulo para char
			} else if (type == "higuerote") {
				if (child->show_value) child->svalue = get<string>(attr->value);
				else child->svalue = ""; // Valor nulo para string
			} else if (type == "tas_claro") {
				if (child->show_value) child->bvalue = get<bool>(attr->value);
				else child->bvalue = false; // Valor nulo para bool
			}
		}
		children.push_back(child);
	}
	// Ahora construimos la secuencia anidada
	ASTNode* secuencia = nullptr;
	if (!children.empty()) {
		secuencia = children[0];
		for (size_t i = 1; i < children.size(); ++i) {
			ASTNode* nuevo = makeASTNode("Secuencia", "Expresión", "", ",");
			nuevo->children.push_back(secuencia);
			nuevo->children.push_back(children[i]);
			secuencia = nuevo;
		}
		node->children.push_back(secuencia);
	}
}

// Construye arbol AST de un Arreglo.
void buildAST_by_array(ASTNode* node, vector<pair<Information, Attributes*>> info, SymbolTable& symbolTable) {
	if (info.empty()) return;
	
	// Vector para almacenar los hijos (subarreglos)
	vector<ASTNode*> children;
	for (size_t i = 0; i < info.size(); i++) {
		Attributes* attr = symbolTable.search_symbol(get<string>(info[i].first));
		if (attr == nullptr) continue; // Si el atributo es nulo, saltar.
		
		//ASTNode* secuence_node = makeASTNode("Secuencia", "Expresión", "", ",");
		ASTNode* child = makeASTNode(attr->symbol_name, "Elemento_Array");

		if (attr->category == ARRAY) {
			child->category = "Array";
			buildAST_by_array(child, attr->info, symbolTable);
		} else {
			string type = attr->type ? attr->type->symbol_name : "Desconocido";
			child->type = type;
			child->show_value = !holds_alternative<nullptr_t>(attr->value);
			if (type == "mango") {
				if (child->show_value) child->ivalue = get<int>(attr->value);
				else child->ivalue = 0; // Valor nulo para int
			} else if (type == "manguita") {
				if (child->show_value) child->fvalue = get<float>(attr->value);
				else child->fvalue = 0.0f; // Valor nulo para float
			} else if (type == "manguangua") {
				if (child->show_value) child->dvalue = get<double>(attr->value);
				else child->dvalue = 0.0; // Valor nulo para double
			} else if (type == "negro") {
				if (child->show_value) child->cvalue = get<char>(attr->value);
				else child->cvalue = '\0'; // Valor nulo para char
			} else if (type == "higuerote") {
				if (child->show_value) child->svalue = get<string>(attr->value);
				else child->svalue = ""; // Valor nulo para string
			} else if (type == "tas_claro") {
				if (child->show_value) child->bvalue = get<bool>(attr->value);
				else child->bvalue = false; // Valor nulo para bool
			}
		}
		children.push_back(child);
	}
	// Ahora construimos la secuencia anidada
	ASTNode* secuencia = nullptr;
	if (!children.empty()) {
		secuencia = children[0];
		for (size_t i = 1; i < children.size(); ++i) {
			ASTNode* nuevo = makeASTNode("Secuencia", "Expresión", "", ",");
			nuevo->children.push_back(secuencia);
			nuevo->children.push_back(children[i]);
			secuencia = nuevo;
		}
		node->children.push_back(secuencia);
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
		if (type == "negro" && node->cvalue != '\0') cout << " | Value: '" << node->cvalue << "'";
		if (type == "negro" && node->cvalue == '\0') cout << " | Value: ''";
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
	while(ss != "s" && ss != "n") { cout << "Key Error. Print AST? (s/n): "; cin >> ss; }
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
	if (type == "negro") return "'"s + node->cvalue + "'";
	if (type == "higuerote") return "\"" + node->svalue + "\"";
	if (type == "tas_claro") return node->bvalue ? "Sisa" : "Nolsa";
	return "Desconocido";
}

// ======================================================
// =                Three Address Code                  =
// ======================================================
void show_TAC(const ASTNode* node){
	if (!node) return;
	
	// Imprimir la sección de datos si hay información adicional
	if (!node->tac_data.empty()) cout << "\033[1;36m\033[5m\n.data:\033[0m\n";

	for (const auto& tac_data : node->tac_data) {
		cout << tac_data.first << " := " << tac_data.second << endl;
	}

	// Imprimir las declaraciones TAC si hay
	if (!node->tac_declaraciones.empty()){ 
		cout << "\033[1;36m\033[5m\n.declaration:\033[0m\n";
		auto tac_declaraciones = node->tac_declaraciones;
		sort(tac_declaraciones.begin(), tac_declaraciones.end(), [](const pair<int, pair<string, int>>& a, const pair<int, pair<string, int>>& b) {
			return a.first < b.first; // Ordenar por el primer elemento (scope)
		});

		for (const auto& tac_decl : tac_declaraciones) {
			static int last_scope = -1;
			if (tac_decl.first != last_scope) {
				if (last_scope != -1) cout << endl; // Agrega salto de línea antes de cada scope excepto el primero
				cout << "\033[1;33m\033[5mScope " << tac_decl.first << ":\033[0m" << endl;
				last_scope = tac_decl.first;
			}
			cout << tac_decl.second.first << ": alloc " << tac_decl.second.second << endl;
		}
	} 
	
	// Imprimir el codigo principal
	cout << "\033[1;36m\033[5m\n.code:\033[0m\n";
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

	return ERROR;
}

void collect_dimensions(Attributes* array, vector<int> &all_dimensions){
	all_dimensions.push_back(get<int>(array->value));
	if(array->info.size() > 0 && array->info[0].second->category == ARRAY){
		collect_dimensions(array->info[0].second, all_dimensions);
	}
}

void write_TAC_array(ASTNode* padre, const string& name, ASTNode* lista_dimensiones, const vector<int>& dimensions, const string& type, string op_tac, ASTNode* expr, function<string()> newLabelFunc){
	// Verificar si todos los índices son literales
	bool all_indexes_are_literals = true;
	for (auto& child : lista_dimensiones->children) {
		if (child->name != "Literal") {
			all_indexes_are_literals = false;
			break;
		}
	}

	int size_element = strToSizeType(type);	// w
	int access = 1;
	int dimensions_size = dimensions.size();
	string actual_temp_access = "";
	string last_temp_access = "";
	// iterar por lo accesos de los indices
	if(!all_indexes_are_literals) { 
		for(auto& child : lista_dimensiones->children) {	// i_k
			// cacular los n_k
			for (int i = dimensions_size - 1; i > 0; i--) {
				access *= dimensions[i]; // Π n_k
			}
			if(child->name == "Literal"){ // caso literales
				access *= child->ivalue * size_element; // i_k * w
				actual_temp_access = to_string(access);
			}else{ // caso variables
				actual_temp_access = newLabelFunc();
				access *= size_element; // Π n_k * w
				padre->tac.push_back(actual_temp_access + " := " + child->temp + " * " + to_string(access));
			}

			if (!last_temp_access.empty() && !actual_temp_access.empty()){
				string temp = newLabelFunc();
				padre->tac.push_back(temp + " := " + last_temp_access + " + " + actual_temp_access);
				actual_temp_access = temp;
			}
			last_temp_access = actual_temp_access;
			dimensions_size--;
			access = 1;
		}
		if(op_tac == "" && expr == nullptr) {
			string temp = newLabelFunc();
			padre->tac.push_back(temp + " := " + name + "[" + last_temp_access + "]");
			padre->temp = temp;
		} else if (op_tac == " := "){
			concat_TAC(padre, expr);
			padre->tac.push_back(name + "[" + last_temp_access + "]" + " := " + expr->temp);
		} else {
			concat_TAC(padre, expr);
			string temp_addr = newLabelFunc(),
					temp = newLabelFunc();
			padre->tac.push_back(temp_addr + " := " + name + "[" + last_temp_access + "]");
			padre->tac.push_back(temp + " := " + temp_addr + op_tac + expr->temp);
			padre->tac.push_back(name + "[" + last_temp_access + "]" + " := " + temp);
		}
	} else {
		int total_access = 0;
		for (auto& child : lista_dimensiones->children) { // i_k
			// cacular los n_k
			for (int i = dimensions_size - 1; i > 0; i--) {
				access *= dimensions[i]; // Π n_k
			}
			access *= child->ivalue * size_element; // i_k * w
			total_access += access;
			dimensions_size--;
			access = 1;
		}
		if(op_tac == "" && expr == nullptr) {
			string temp = newLabelFunc();
			padre->tac.push_back(temp + " := " + name + "[" + to_string(total_access) + "]");
			padre->temp = temp;
		} else if (op_tac == " := "){
			concat_TAC(padre, expr);
			padre->tac.push_back(name + "[" + to_string(total_access) + "]" + " := " + expr->temp);
		} else {
			concat_TAC(padre, expr);
			string temp_addr = newLabelFunc(),
					temp = newLabelFunc();
			padre->tac.push_back(temp_addr + " := " + name + "[" + to_string(total_access) + "]");
			padre->tac.push_back(temp + " := " + temp_addr + op_tac + expr->temp);
			padre->tac.push_back(name + "[" + to_string(total_access) + "]" + " := " + temp);
		}
	}
}

int sumOfSizeTypes(vector<pair<Information, Attributes*>> info){
	int result = 0;
	for (auto node : info){
		result += strToSizeType(node.second->type->symbol_name);
	}
	return result;
}

SizeType maxOfSizeType(vector<pair<Information, Attributes*>> info){
	SizeType max_result = strToSizeType(info[0].second->type->symbol_name);
	for (auto node : info){
		max_result = max(max_result, strToSizeType(node.second->type->symbol_name));
	}
	return max_result;
}

int accumulateSizeType(vector<pair<Information, Attributes*>> info, string var){
	if (info.empty()) return 0;
	int accumulate = 0;

	for (int i = 0; i < info.size(); i++) {
		if (info[i].second->symbol_name == var) break;
		if (info[i].second->category == STRUCT || info[i].second->category == UNION)
			accumulate += accumulateSizeType(info[i].second->info, var);
		else
			accumulate += strToSizeType(info[i].second->type->symbol_name);
	}

	return accumulate;
}

string convertBoolOperation(string op) {
	if (op == "igualito") return "==";
	if (op == "nie") return "!=";
	if (op == "mayol") return ">";
	if (op == "lidel") return ">=";
	if (op == "menol") return "<";
	if (op == "peluche") return "<=";
	if (op == "yunta") return "&&";
	if (op == "o_sea") return "||";
	return op; // Retorna el operador original si no es uno de los booleanos
}

void generateJumpingCode(ASTNode* guardia, vector<string>& out, function<string()> newLabelFunc) {	
	if (!guardia) {
		return;
	}

	for(auto expr : guardia->children){
		if (expr->name == "yunta"){
			expr->children[0]->falseLabel = expr->falseLabel != "fall" ? expr->falseLabel : newLabelFunc();
			expr->children[0]->trueLabel = "fall";

			expr->children[1]->trueLabel = expr->trueLabel;
			expr->children[1]->falseLabel = expr->falseLabel;

			generateJumpingCode(expr, out, newLabelFunc);

			
			if (expr->falseLabel == "fall") out.push_back(expr->children[0]->falseLabel + ": ");
		
		}else if (expr->name == "o_sea"){
			expr->children[0]->trueLabel = expr->trueLabel != "fall" ? expr->trueLabel : newLabelFunc();
			expr->children[0]->falseLabel = "fall";

			expr->children[1]->trueLabel = expr->trueLabel;
			expr->children[1]->falseLabel = expr->falseLabel;

			generateJumpingCode(expr, out, newLabelFunc);

			if (expr->trueLabel == "fall") out.push_back(expr->children[0]->trueLabel + ": ");
		}else if (expr->name == "nelson"){
			expr->children[0]->falseLabel = expr->trueLabel;
			expr->children[0]->trueLabel = expr->falseLabel;
			generateJumpingCode(expr, out, newLabelFunc); 
		}else if (expr->name == "Literal" && expr->kind == "Sisa"){
			if(expr->trueLabel != "fall") out.push_back("goto " + expr->trueLabel);
		}else if (expr->name == "Literal" && expr->kind == "Nolsa"){
			if(expr->falseLabel != "fall") out.push_back("goto " + expr->falseLabel);
		}else{
			out.insert(out.end(), expr->tac.begin(), expr->tac.end());

			if (expr->trueLabel != "fall" && expr->falseLabel != "fall"){
				out.push_back("if " + expr->temp + " goto " + expr->trueLabel);
				out.push_back("goto " + expr->falseLabel);
			} else if (expr->trueLabel != "fall"){
				out.push_back(
				"if " + expr->temp + " goto " + expr->trueLabel
				);
			} else if (expr->falseLabel != "fall"){
				out.push_back(
				"ifnot " + expr->temp + " goto " + expr->falseLabel
				);
			}
		}
	}
}
// ======================================================
// =                    Flow Graph                      =
// ======================================================

FlowGraph::FlowGraph(){
	this->createBlock("ENTRY");
}

// Obtiene un bloque por etiqueta. Retorna nullptr si no existe.
BasicBlock* FlowGraph::getBlockByName(const string& name) {
	for(auto& block : this->blocks){
		if(block.first == name) return block.second;
	}
	return nullptr;
}

BasicBlock* FlowGraph::getBlockByLabel(const string& label){
	for(auto& block : this->blocks){
		if(block.second->lider_label == label) return block.second;
	}
	return nullptr;
}

// Crea un bloque con la etiqueta dada. Retorna true si lo creó, false si ya existía.
bool FlowGraph::createBlock(const string& name, vector<string> code, const string& label) {
	BasicBlock* block = this->getBlockByName(name);
	if (block) return false;
	blocks.emplace_back(name, new BasicBlock(name, code, label));
	return true;
}

// Agrega una arista dirigida de 'from' a 'to'
void FlowGraph::addEdge(const string& from, const string& to) {
	BasicBlock* b_from = this->getBlockByName(from);
	BasicBlock* b_to = this->getBlockByName(to);
	if (b_from && b_to) {
		b_from->childs.push_back(b_to);
		b_to->fathers.push_back(b_from);
	}
}

// Devuelve la cantidad de bloques en el grafo.
int FlowGraph::len(){
	return this->blocks.size();
}

// Extrae la etiqueta de un salto goto de una línea de TAC.
string extractGotoLabel(const string& line) {
	smatch match;
	regex rgx(R"(goto\s+(L\d+))");
	if (regex_search(line, match, rgx)) {
		return match[1]; // El grupo de captura (L<num>)
	}
	return "";
}

// Extrae el nombre de una función llamada en una línea de TAC.
string extractCallLabel(const string& line) {
	size_t pos = line.find("call ");
	if (pos != string::npos && pos + 5 < line.size()) {
		char next_char = line[pos + 5];
		if (next_char != ':') { // Si no es una etiqueta
			string func_name = line.substr(pos + 5); // Extrae desde después de "call "
			size_t comma_pos = func_name.find(",");
			
			// Solo hasta la coma si existe
			if (comma_pos != string::npos) {
				func_name = func_name.substr(0, comma_pos); 
			}
			
			// Quita espacios
			func_name.erase(remove(func_name.begin(), func_name.end(), ' '), func_name.end());
			
			return func_name; // Retorna el nombre de la función llamada
		}
	}
	return ""; // Retorna vacío si no es una llamada válida
}

// Elimina duplicados de un vector manteniendo el orden original.
template<typename T>
void remove_duplicates_keep_order(vector<T>& vec) {
	set<T> seen;
	vector<T> result;
	for (const auto& v : vec) {
		if (seen.insert(v).second) { // insert retorna pair<iterator,bool>
			result.push_back(v);
		}
	}
	vec = move(result);
}

// Genera el grafo de flujo a partir del TAC
void FlowGraph::generateFlowGraph(vector<string>& tac) {
	int block_count = 1;
	regex b(R"(^\s*L[0-9]+:)");
	regex c(R"(^\s*[a-zA-Z_][a-zA-Z0-9_]*:)");
	
	// Iterar sobre las líneas de TAC
	vector<size_t> lider_index; // Conjunto para almacenar los índices de los líderes
	for (size_t i = 0; i < tac.size(); i++) {
		if (i == 0) { // La primera línea siempre es un líder
			lider_index.push_back(i);
		} else {
			const string& line = tac[i];
			// Instruccion posterior a goto es un lider.
			if (line.find("goto") != string::npos) {
				if (i + 1 < tac.size()) lider_index.push_back(i + 1);
			}
			// Las etiquetas de salto son lideres.
			if (regex_search(line, b)) lider_index.push_back(i);
			else if (regex_search(line, c)) { // Si es un label de funcion, también es un líder
				if (i + 1 < tac.size() && tac[i + 1] == "begin_func:") {
					lider_index.push_back(i);
				}
			}
			if (line == "end_func:") { // Fin de una función, siguiente línea es un líder
				if (i + 1 < tac.size()) lider_index.push_back(i + 1);
			}

			// Instruccion siguiente a una call de funcion es lider.
			if (line.find("call ") != string::npos) {
				size_t pos = line.find("call ");
				if (pos != string::npos && pos + 5 < line.size()) {
					char next_char = line[pos + 5];
					if (next_char != ':') {
						if (i + 1 < tac.size()) lider_index.push_back(i + 1);
					}
				}
			}
		}
	}
	remove_duplicates_keep_order(lider_index);

	map<string, string> returns_func; // Mapa para almacenar las funciones y sus bloques de retorno
	stack<string> func_stack; // Pila para manejar el contexto de funciones

	// Creacion de Bloques basicos
	size_t size_lider = lider_index.size();
	string block_name = "";
	for (size_t i = 0; i < size_lider; i++) {
		size_t left, right;
		if (i + 1 < size_lider) { 
			left = lider_index[i]; right = lider_index[i+1];
			right--;
		} else {
			left = lider_index[i]; right = lider_index[i];
			if (right+1 < tac.size()) right = tac.size() - 1; // Último bloque hasta el final del TAC
		}
		if (right < left) {
			cout << "[ERROR] right < left, saltando bloque." << endl;
			continue;
		}
		vector<string> code(tac.begin() + left, tac.begin() + right+1);
		string lider_label = "";
		if (regex_search(code[0], b)) lider_label = code[0].substr(0, code[0].size() - 2);
		else if (regex_search(code[0], c)) {
			lider_label = code[0].substr(0, code[0].size() - 1);
			func_stack.push(lider_label); // Agregar a la pila de funciones
		}

		block_name = "B" + to_string(block_count++);
		this->createBlock(block_name, code, lider_label);

		if (code.back() == "end_func:") {
			if (!func_stack.empty()) {
				lider_label = func_stack.top(); // Obtener el nombre de la función
				func_stack.pop(); // Sacar de la pila
				returns_func[lider_label] = block_name; // Guardar el bloque de retorno
			}
		}
	}
	this->createBlock("EXIT");

	this->computeDefAndUseSets();
	
	// Creacion de aristas entre Bloques Basicos
	BasicBlock* fatherBlock;
	string currentBlockName, currentBlockLabel;
	string label;
	size_t size_tac_code;
	string last_line;
	set<string> sys_func = {"concat", "print", "read"};
	for(auto block : this->blocks){
		currentBlockName = block.first;
		currentBlockLabel = block.second->lider_label;
		BasicBlock* currentBlock = block.second;
		if(currentBlockName == "ENTRY"){
			fatherBlock = currentBlock;
		}else if (currentBlockName == "EXIT"){
			// Conectar el último bloque con EXIT
			this->addEdge(fatherBlock->name, "EXIT");
		}else{
			// Repaso por lineas de TAC
			for(auto line : currentBlock->TAC_code){
				// Inclusion de conexion entre bloques por etiquetas de salto.
				label = extractGotoLabel(line);
				if(!label.empty()){
					BasicBlock* nodo = this->getBlockByLabel(label);
					this->addEdge(currentBlockName, nodo->name); // Arista del flujo 'goto Label'
				}
				// Inclusion de conexion por llamadas de funciones.
				string func_name = extractCallLabel(line);
				if (func_name != "") {
					// Verificar llamadas a funciones del sistema.
					if (sys_func.find(func_name) == sys_func.end()) {
						BasicBlock* func_block = this->getBlockByLabel(func_name);
						if (func_block) {
							this->addEdge(currentBlockName, func_block->name);
						}
					}
				}
			}

			if (fatherBlock->name == "ENTRY"){
				this->addEdge(fatherBlock->name, currentBlockName);
			} else {
				// Verificar ultima linea de nodo padre, si existe condicional "if".
				size_tac_code = fatherBlock->TAC_code.size();
				last_line = fatherBlock->TAC_code[size_tac_code - 1];
				if (last_line.find("if") != string::npos) {
					this->addEdge(fatherBlock->name, currentBlockName);
				// Verificar si no hay goto en la ultima linea del padre.
				} else if (last_line.find("goto") == string::npos){
					this->addEdge(fatherBlock->name, currentBlockName);
				}

				// Verificar si hay una llamada a una función en la última línea del padre.
				// En ese caso, seria conectar el bloque retorno con el bloque actual.
				string func_name = extractCallLabel(last_line);
				if (func_name != "") {
					if (sys_func.find(func_name) == sys_func.end()) {
						auto it = returns_func.find(func_name);
						if (it != returns_func.end()) {
							string return_block = it->second;
							this->addEdge(return_block, currentBlockName);
						}
					}
				}
			}
			fatherBlock = currentBlock;
		}
	}
}

// Centra un string en un campo de ancho fijo
string center(const string& s, int width) {
	int len = s.length();
	if (len >= width) return s.substr(0, width);
	int left = (width - len) / 2;
	int right = width - len - left;
	return string(left, ' ') + s + string(right, ' ');
}

// Imprime el grafo de flujo de control en consola.
void FlowGraph::print() {
	const int CELL_SIZE = 7;
	string ss;
	cout << "--> Print Control Flow Graphs? (s/n): "; cin >> ss;
	while(ss != "s" && ss != "n") { cout << "Key Error. Print Control Flow Graphs? (s/n): "; cin >> ss; }
	if (ss == "n") return;
	cout << "\033[1;36m\033[5m\n               =======================================================\n";
	cout << "                                  Control Flow Graphs                 \n";
	cout << "               =======================================================\n\033[0m\n";
	cout << "----------------------------------------------------------" << endl;
	// 1. Mostrar información de los nodos
	for (const auto& block : this->blocks) {
		const string& name = block.first;
		BasicBlock* bb = block.second;
		cout << "\033[1;33m\033[5mName: " << name << ":\033[0m" << endl;
		if (name != "ENTRY" && name != "EXIT") {
			cout << "Lider Label: " << bb->lider_label << endl;
			cout << "Code:" << endl;
			for (const auto& line : bb->TAC_code) cout << "     | " << line << endl;
		}
		if (!bb->childs.empty()){
			cout << "Childs: ";
			for (auto child : bb->childs) cout << child->name << " ";
			cout << endl;
		}
		if (!bb->fathers.empty()){
			cout << "Fathers: ";
			for (auto father : bb->fathers) cout << father->name << " ";
			cout << endl;
		}
		if(!bb->def.empty()){
			cout << "Def: ";
			for (const auto& def : bb->def) cout << def << " ";
			cout << endl;
		}
		if(!bb->use.empty()){
			cout << "Use: ";
			for (const auto& use : bb->use) cout << use << " ";
			cout << endl;
		}
		if (!bb->in.empty()) {
			cout << "In: ";
			for (const auto& in : bb->in) cout << in << " ";
			cout << endl;
		}
		if (!bb->out.empty()) {
			cout << "Out: ";
			for (const auto& out : bb->out) cout << out << " ";
			cout << endl;
		}
		cout << "----------------------------------------------------------" << endl;
	}

	// 2. Construir lista de nombres de bloques (en orden)
	vector<string> block_names;
	for (const auto& block : this->blocks) {
		block_names.push_back(block.first);
	}

	// 3. Imprimir encabezado de la matriz
	cout << endl << center("* | Matriz de Adyacencia | *", (CELL_SIZE) + block_names.size() * (CELL_SIZE - 1) + block_names.size() + 1) << endl;
	cout << center("-", CELL_SIZE);
	for (const auto& col : block_names) cout << "|" << center(col, CELL_SIZE - 1);
	cout << "|" << endl;
	cout << string((CELL_SIZE) + block_names.size() * (CELL_SIZE - 1) + block_names.size() + 1, '-') << endl;

	// 4. Imprimir filas de la matriz
	for (const auto& row_name : block_names) {
		cout << center(row_name, CELL_SIZE);
		for (const auto& col_name : block_names) {
			BasicBlock* row_block = this->getBlockByName(row_name);
			BasicBlock* col_block = this->getBlockByName(col_name);
			bool found = false;
			if (row_block && col_block && row_block != col_block) {
				for (auto child : row_block->childs) {
					if (child == col_block) { found = true; break; }
				}
			}
			string cell;
			if (found) cell = "o";
			else cell = "";
			cout << "|" << center(cell, CELL_SIZE - 1);
		}
		cout << "|" << endl;
		cout << string((CELL_SIZE) + block_names.size() * (CELL_SIZE - 1) + block_names.size() + 1, '-') << endl;
	}
}

// Calcula los conjuntos Def y Use para cada bloque del grafo de flujo.
void FlowGraph::computeDefAndUseSets(){
	// Calcular Def para cada bloque
	set<string> reserved_words = {"if", "goto", "ifnot", "begin_func", "end_func", "return", "call", "param", "alloc", "print", "read", "concat"};
	regex b(R"(^\s*L[0-9]+)");
	regex def_regex(R"(\b([a-zA-Z_][a-zA-Z0-9_]*)\s*:=)");
	regex use_regex(R"(\b([a-zA-Z_][a-zA-Z0-9_]*)\b)");
	int count;
	for (auto& block : this->blocks) {
		map<string, vector<pair<string, int> >> def_and_used_map;
		set<string> recursive_vars;
		BasicBlock* bb = block.second;
		count = 0;
		for (const auto& l : bb->TAC_code) {
			count++;
			// Primero, encontrar todas las variables definidas en el bloque
			smatch match;
			if (regex_search(l, match, def_regex)) {
				def_and_used_map[match[1]].emplace_back("def", count);

				vector<string> split_code;
				istringstream iss(l);
				string token;
				while (iss >> token) {
					split_code.push_back(token);
				}
				if(split_code.size() > 2){
					auto it = find(split_code.begin() + 2, split_code.end(), match[1]);
					if (it != split_code.end()) {
						recursive_vars.insert(match[1]);
					}
				}
			}

			// Ahora, encontrar todas las variables usadas en el bloque
			auto words_begin = sregex_iterator(l.begin(), l.end(), use_regex);
			auto words_end = sregex_iterator();
			for (sregex_iterator it = words_begin; it != words_end; ++it) {
				string var_name = (*it)[1];
				if (reserved_words.find(var_name) != reserved_words.end()) continue; // Ignorar palabras reservadas
				if (regex_search(var_name, b)) continue; // Ignorar etiquetas de bloque
				if(l.find(":=") != string::npos && it == words_begin) continue;
				def_and_used_map[var_name].emplace_back("used", count);
			}
			
			// Def = variables definidas en el bloque, pero que no son recursivas
			for (const auto& var : def_and_used_map) {
				string key = var.first; vector<pair<string, int>> value = var.second;
				bool is_recursive = recursive_vars.find(key) != recursive_vars.end();
				size_t size_vector = value.size();
				bool is_defined = false, is_used = false;
				int currentLine = 1;
				for (auto info : value){
					if (info.first == "def" && is_used && !is_defined) break;
					if (info.first == "used" && is_defined && !is_used && info.second != currentLine) {bb->def.insert(key); break;}
					if (info.first == "def") {is_defined = true; currentLine = info.second;}
					if (info.first == "used") {is_used = true; currentLine = info.second;}
				}
				is_defined = false; is_used = false;
				for (auto info : value){
					if (info.first == "def") {is_defined = true; break;}
					else is_used = true;
				}
				if(!is_defined && is_used) bb->use.insert(key);
			}
		}
	}
}

// Calcula los conjuntos IN y OUT para cada bloque del grafo de flujo.
void FlowGraph::computeINandOUT_lived_var(){
	// Inicializar Conjuntos IN/OUT
	bool changed = true;
	int count = 0;
	while(changed){
		changed = false; // Reiniciar el estado de cambio
		set<string> previous_in;
		for(int i = this->len() - 1; i > -1; i--) { // Iterar desde el último bloque hasta el primero
			if(this->blocks[i].first == "EXIT") continue; // Saltar el bloque EXIT
			BasicBlock* block = this->blocks[i].second;
			previous_in = block->in;
			
			// Calcular el conjunto OUT
			set<string> union_p_outs;
			for(auto& child : block->childs) {
				union_p_outs.insert(child->in.begin(), child->in.end());
			}
			block->out = union_p_outs; // Asignar el conjunto OUT al bloque actual
			
			// Calcular el conjunto IN
			set<string> in_set;
			set<string> diff;
			set_difference(union_p_outs.begin(), union_p_outs.end(),
						   block->def.begin(), block->def.end(),
						   inserter(diff, diff.begin()));
			in_set = block->use;
			in_set.insert(diff.begin(), diff.end());
			block->in = in_set;

			// Verificar si hubo cambios
			if (previous_in != block->in) {
				changed = true; // Hubo cambios, continuar iterando
			}
		}
	}
}

// ======================================================
// =               Data Flow Problem                    =
// ======================================================

void SolverFlowGraphProblem::set_direction(Direction dir) {
	this->direction = dir;
}

void SolverFlowGraphProblem::solver_data_flow_problem(FlowGraph& flow_graph){
	Direction current_dir = this->direction;
	int count_blocks = flow_graph.len();
	int iter;

	bool changed = true;
	while(changed){
		changed = false; // Reiniciar el estado de cambio
		
		iter = current_dir == FORWARD ? 0 : count_blocks - 1;
		while (true) {
			// Condicion de terminacion de iteracion de bloques.
			if (current_dir == FORWARD && iter >= count_blocks) break;
			else if (current_dir == BACKWARD && iter < 0) break;

			BasicBlock* block = flow_graph.blocks[iter].second;

			// Algoritmo: Caso BACKWARD
			if (current_dir == BACKWARD) {
				if (block->name != "EXIT") {
					set<string> previous_in = block->in;
					
					// Calcular el conjunto OUT
					set<string> union_p_outs;
					for(auto& child : block->childs) {
						union_p_outs.insert(child->in.begin(), child->in.end());
					}
					block->out = union_p_outs;
					
					// Calcular el conjunto IN
					set<string> in_set;
					set<string> diff;
					set_difference(union_p_outs.begin(), union_p_outs.end(),
								   block->def.begin(), block->def.end(),
								   inserter(diff, diff.begin()));
					in_set = block->use;
					in_set.insert(diff.begin(), diff.end());
					block->in = in_set;

					// Verificar si hubo cambios
					if (previous_in != block->in) changed = true;
				}
			}
			// Algoritmo: Caso FORWARD
			
			if (current_dir == FORWARD) {
				if (block->name != "ENTRY"){
					set<string> previous_out = block->out;

					// IMPLEMENTAR LOGICA DEL CASO
				}
			}

			// Incremento de iteradores
			if (current_dir == FORWARD) iter++;
			else if (current_dir == BACKWARD) iter--;
		}
	}
}

// ======================================================
// =                 Assembly Code                      =
// ======================================================

// Busca el tipo de una variable en las declaraciones TAC del nodo AST.
string search_type(ASTNode* node, string var) {
	for (const auto& tac_decl : node->tac_declaraciones) {
		if (tac_decl.second.first == var) {
			if (tac_decl.second.second == 1) return "tas_claro";
			else if (tac_decl.second.second == 2) return "negro";
			else if (tac_decl.second.second == 4) return "mango";
			else if (tac_decl.second.second == 8) return "manguita";
			else if (tac_decl.second.second == 16) return "manguangua";
			else if (tac_decl.second.second == 32) return "higuerote";
		}
	}
	return "";
}

// Cola circular para temporales internos de MIPS
class MipsTempQueue {
	queue<string> temps;
	set<string> reserved; // temporales usados por TAC
public:
	MipsTempQueue() = default;

	// Inicializa la cola con los temporales disponibles, excluyendo los usados por TAC
	void init(const set<string>& tac_temps) {
		reserved = tac_temps;
		vector<string> all = {"$t0", "$t1", "$t2", "$t3", "$t4", "$t5", "$t6", "$t7", "$t8", "$t9"};
		for (const auto& t : all) {
			if (reserved.find(t) == reserved.end()) {
				temps.push(t);
			}
		}
	}

	// Obtiene el siguiente temporal disponible y lo vuelve a poner al final de la cola
	string next() {
		if (temps.empty()) return "$t9"; // fallback
		string t = temps.front();
		temps.pop();
		temps.push(t);
		return t;
	}
};

set<string> collect_TAC_temporals(const vector<string>& tac) {
	set<string> temps;
	regex temp_regex(R"(\bt(\d+)\b)");
	for (const auto& line : tac) {
		auto words_begin = sregex_iterator(line.begin(), line.end(), temp_regex);
		auto words_end = sregex_iterator();
		for (auto it = words_begin; it != words_end; ++it) {
			temps.insert("$" + it->str());
		}
	}
	return temps;
}

// Traduce una instrucción TAC a MIPS Assembly (por línea)
vector<string> translate_TAC_to_MIPS(vector<pair<string, BasicBlock*> > blocks, ASTNode* node) {
	// 1. Recolecta temporales TAC y prepara la cola de temporales internos MIPS
	set<string> tac_temps = collect_TAC_temporals(node->tac);
	MipsTempQueue mipsTemps;
	mipsTemps.init(tac_temps);

	vector<string> mips;
	vector<string> params;
	smatch m;

	for (size_t b = 0; b < blocks.size(); ++b) {
		const string& block_name = blocks[b].first;
		BasicBlock* bb = blocks[b].second;
		if (block_name == "ENTRY" || block_name == "EXIT") continue;

		const vector<string>& tac_lines = bb->TAC_code;
		for (size_t i = 0; i < tac_lines.size(); ++i) {
			string line = tac_lines[i];
			line.erase(0, line.find_first_not_of(" \t"));
			line.erase(line.find_last_not_of(" \t") + 1);

			// Acumula parámetros
			if (regex_match(line, regex(R"(^param\s+(.+)$)"))) {
				string param = line.substr(6);
				params.push_back(param);
				continue;
			}

			// call print, N
			if (regex_match(line, regex(R"(^call print, (\d+)$)"))) {
				for (const string& param : params) {
					string reg = "$a0";
					string param_trim = param;
					param_trim.erase(0, param_trim.find_first_not_of(" \t"));
					param_trim.erase(param_trim.find_last_not_of(" \t") + 1);

					if (regex_match(param_trim, regex(R"(^\(string\)([a-zA-Z_][a-zA-Z0-9_]*)$)"))) {
						string var = param_trim.substr(8);
						mips.push_back("    lw $a0, " + var);
						mips.push_back("    li $v0, 1");
						mips.push_back("    syscall");
					} else if (param_trim[0] == '&') {
						mips.push_back("    la " + reg + ", " + param_trim.substr(1));
						mips.push_back("    li $v0, 4");
						mips.push_back("    syscall");
					} else if (regex_match(param_trim, regex(R"(^t\d+$)"))) {
						mips.push_back("    move " + reg + ", $" + param_trim);
						mips.push_back("    li $v0, 4");
						mips.push_back("    syscall");
					} else {
						mips.push_back("    la " + reg + ", " + param_trim);
						mips.push_back("    li $v0, 4");
						mips.push_back("    syscall");
					}
				}
				params.clear();
				continue;
			}

			// call read, 1 (generalizado usando SymbolTable y bloques)
			if (regex_match(line, regex(R"(^t(\d+)\s*:=\s*call read, 1$)"))) {
				if (!params.empty()) {
					string param = params.front();
					string reg = "$a0";
					string param_trim = param;
					param_trim.erase(0, param_trim.find_first_not_of(" \t"));
					param_trim.erase(param_trim.find_last_not_of(" \t") + 1);

					if (param_trim[0] == '&') {
						mips.push_back("    la " + reg + ", " + param_trim.substr(1));
					} else if (regex_match(param_trim, regex(R"(^t\d+$)"))) {
						mips.push_back("    move " + reg + ", $" + param_trim);
					} else {
						mips.push_back("    la " + reg + ", " + param_trim);
					}
					mips.push_back("    li $v0, 4");
					mips.push_back("    syscall");
					params.clear();
				}
				string tnum = regex_replace(line, regex(R"(^t(\d+)\s*:=\s*call read, 1$)"), "$1");

				// Busca la asignación siguiente en el bloque actual o el siguiente
				string var_dest;
				string pat_assign = "^([a-zA-Z_][a-zA-Z0-9_]*)\\s*:=\\s*(\\([a-zA-Z_][a-zA-Z0-9_]*\\))?t" + tnum + "$";
				smatch m2;
				for (size_t j = i + 1; j < tac_lines.size(); ++j) {
					if (regex_match(tac_lines[j], m2, regex(pat_assign))) {
						var_dest = m2[1];
						break;
					}
				}
				if (var_dest.empty() && b + 1 < blocks.size()) {
					const vector<string>& next_block_lines = blocks[b + 1].second->TAC_code;
					for (const string& next_line : next_block_lines) {
						if (regex_match(next_line, m2, regex(pat_assign))) {
							var_dest = m2[1];
							break;
						}
					}
				}

				if (!var_dest.empty()) {
					string type = search_type(node, var_dest);
					if (type == "higuerote") {
						mips.push_back("    la $a0, " + var_dest);
						mips.push_back("    li $a1, 32");
						mips.push_back("    li $v0, 8");
						mips.push_back("    syscall");
						mips.push_back("    move $t" + tnum + ", $a0");
					} else if (type == "mango" || type == "tas_claro" || type == "negro") {
						mips.push_back("    li $v0, 5");
						mips.push_back("    syscall");
						mips.push_back("    move $t" + tnum + ", $v0");
					} else if (type == "manguita") {
						mips.push_back("    li $v0, 6");
						mips.push_back("    syscall");
						mips.push_back("    mov.s $f0, $f0");
					} else if (type == "manguangua") {
						mips.push_back("    li $v0, 7");
						mips.push_back("    syscall");
						mips.push_back("    mov.d $f0, $f0");
					} else {
						mips.push_back("    # [TODO] Lectura de tipo compuesto o no soportado: " + type);
					}
				} else {
					mips.push_back("    # [TODO] No se encontró variable destino.");
				}
				continue;
			}

			// Asignar temporal a variable (con o sin cast): var := tX o var := (cast)tX
			if (regex_match(line, m, regex(R"(^([a-zA-Z_][a-zA-Z0-9_]*)\s*:=\s*(?:\([a-zA-Z_][a-zA-Z0-9_]*\))?t(\d+)$)"))) {
				string var = m[1];
				string tnum = m[2];
				string type = search_type(node, var);
				if (type == "higuerote") {
					string tmp1 = mipsTemps.next();
					string tmp2 = mipsTemps.next();
					string tmp3 = mipsTemps.next();
					mips.push_back("    move " + tmp1 + ", $t" + tnum);
					mips.push_back("    la " + tmp2 + ", " + var);
					mips.push_back("copy_" + var + ":");
					mips.push_back("    lb " + tmp3 + ", 0(" + tmp1 + ")");
					mips.push_back("    sb " + tmp3 + ", 0(" + tmp2 + ")");
					mips.push_back("    addiu " + tmp1 + ", " + tmp1 + ", 1");
					mips.push_back("    addiu " + tmp2 + ", " + tmp2 + ", 1");
					mips.push_back("    bnez " + tmp3 + ", copy_" + var);
				} else {
					mips.push_back("    sw $t" + tnum + ", " + var);
				}
				continue;
			}

			// nombre := 0 (asignación constante)
			if (regex_match(line, m, regex(R"(^([a-zA-Z_][a-zA-Z0-9_]*)\s*:=\s*(\d+)$)"))) {
				string var = m[1];
				string val = m[2];
				string tmp = mipsTemps.next();
				mips.push_back("    li " + tmp + ", " + val);
				mips.push_back("    sw " + tmp + ", " + var);
				continue;
			}

			// Suma con constante: x := x + c
			if (regex_match(line, m, regex(R"(^([a-zA-Z_][a-zA-Z0-9_]*)\s*:=\s*([a-zA-Z_][a-zA-Z0-9_]*)\s*\+\s*(\d+)$)"))) {
				string left = m[1], op1 = m[2], val = m[3];
				bool left_is_temp = regex_match(left, regex(R"(^t\d+$)"));
				bool op1_is_temp = regex_match(op1, regex(R"(^t\d+$)"));
				string tmp0 = mipsTemps.next();
				string tmp1 = mipsTemps.next();
				string tmp2 = mipsTemps.next();

				if (op1_is_temp) mips.push_back("    move " + tmp0 + ", $" + op1);
				else mips.push_back("    lw " + tmp0 + ", " + op1);
				mips.push_back("    li " + tmp1 + ", " + val);
				mips.push_back("    add " + tmp2 + ", " + tmp0 + ", " + tmp1);

				if (left_is_temp) mips.push_back("    move $" + left + ", " + tmp2);
				else mips.push_back("    sw " + tmp2 + ", " + left);
				continue;
			}

			// Suma: suma := suma + n
			if (regex_match(line, m, regex(R"(^([a-zA-Z_][a-zA-Z0-9_]*)\s*:=\s*([a-zA-Z_][a-zA-Z0-9_]*)\s*\+\s*([a-zA-Z_][a-zA-Z0-9_]*)$)"))) {
				string left = m[1], op1 = m[2], op2 = m[3];
				bool left_is_temp = regex_match(left, regex(R"(^t\d+$)"));
				bool op1_is_temp = regex_match(op1, regex(R"(^t\d+$)"));
				bool op2_is_temp = regex_match(op2, regex(R"(^t\d+$)"));
				string tmp0 = mipsTemps.next();
				string tmp1 = mipsTemps.next();
				string tmp2 = mipsTemps.next();

				if (op1_is_temp) mips.push_back("    move " + tmp0 + ", $" + op1);
				else mips.push_back("    lw " + tmp0 + ", " + op1);
				if (op2_is_temp) mips.push_back("    move " + tmp1 + ", $" + op2);
				else mips.push_back("    lw " + tmp1 + ", " + op2);

				mips.push_back("    add " + tmp2 + ", " + tmp0 + ", " + tmp1);

				if (left_is_temp) mips.push_back("    move $" + left + ", " + tmp2);
				else mips.push_back("    sw " + tmp2 + ", " + left);
				continue;
			}
			
			// Asignación simple: x := y
			string pat_assign_simple = "^([a-zA-Z_][a-zA-Z0-9_]*)\\s*:=\\s*([a-zA-Z_][a-zA-Z0-9_]*)$";
			if (regex_match(line, m, regex(pat_assign_simple))) {
				string left = m[1], right = m[2];
				bool left_is_temp = regex_match(left, regex(R"(^t\d+$)"));
				bool right_is_temp = regex_match(right, regex(R"(^t\d+$)"));
				string tmp = mipsTemps.next();
				if (right_is_temp) {
					mips.push_back("    move " + tmp + ", $" + right);
				} else {
					mips.push_back("    lw " + tmp + ", " + right);
				}
				if (left_is_temp) {
					mips.push_back("    move $" + left + ", " + tmp);
				} else {
					mips.push_back("    sw " + tmp + ", " + left);
				}
				continue;
			}

			// Etiquetas
			if (regex_match(line, regex(R"(^L\d+:$)"))) {
				mips.push_back(line);
				continue;
			}

			// Goto
			if (regex_match(line, m, regex(R"(^goto\s+(L\d+)$)"))) {
				mips.push_back("    j " + string(m[1]));
				continue;
			}

			// Ifnot cond goto Lx
			if (regex_match(line, m, regex(R"(^ifnot\s+(.+)\s+goto\s+(L\d+)$)"))) {
				string cond = m[1];
				string label = m[2];
				smatch cmp;
				if (regex_match(cond, cmp, regex(R"((\w+)\s*([=!<>]+)\s*(\w+))"))) {
					string left = cmp[1], op = cmp[2], right = cmp[3];
					bool left_is_temp = regex_match(left, regex(R"(^t\d+$)"));
					bool right_is_temp = regex_match(right, regex(R"(^t\d+$)"));
					bool right_is_const = regex_match(right, regex(R"(^\d+$)"));
					string tmp0 = mipsTemps.next();
					string tmp1 = mipsTemps.next();
					// Carga left
					if (left_is_temp) mips.push_back("    move " + tmp0 + ", $" + left);
					else mips.push_back("    lw " + tmp0 + ", " + left);
					// Carga right
					if (right_is_temp) mips.push_back("    move " + tmp1 + ", $" + right);
					else if (right_is_const) mips.push_back("    li " + tmp1 + ", " + right);
					else mips.push_back("    lw " + tmp1 + ", " + right);
					// Condición
					if (op == "==") mips.push_back("    bne " + tmp0 + ", " + tmp1 + ", " + label);
					else if (op == "!=") mips.push_back("    beq " + tmp0 + ", " + tmp1 + ", " + label);
					else if (op == "<") mips.push_back("    bge " + tmp0 + ", " + tmp1 + ", " + label);
					else if (op == "<=") mips.push_back("    bgt " + tmp0 + ", " + tmp1 + ", " + label);
					else if (op == ">") mips.push_back("    ble " + tmp0 + ", " + tmp1 + ", " + label);
					else if (op == ">=") mips.push_back("    blt " + tmp0 + ", " + tmp1 + ", " + label);
				}
				continue;
			}

			// If cond goto Lx
			if (regex_match(line, m, regex(R"(^if\s+(.+)\s+goto\s+(L\d+)$)"))) {
				string cond = m[1];
				string label = m[2];
				smatch cmp;
				if (regex_match(cond, cmp, regex(R"((\w+)\s*([=!<>]+)\s*(\w+))"))) {
					string left = cmp[1], op = cmp[2], right = cmp[3];
					bool left_is_temp = regex_match(left, regex(R"(^t\d+$)"));
					bool right_is_temp = regex_match(right, regex(R"(^t\d+$)"));
					bool right_is_const = regex_match(right, regex(R"(^\d+$)"));
					string tmp0 = mipsTemps.next();
					string tmp1 = mipsTemps.next();
					// Carga left
					if (left_is_temp) mips.push_back("    move " + tmp0 + ", $" + left);
					else mips.push_back("    lw " + tmp0 + ", " + left);
					// Carga right
					if (right_is_temp) mips.push_back("    move " + tmp1 + ", $" + right);
					else if (right_is_const) mips.push_back("    li " + tmp1 + ", " + right);
					else mips.push_back("    lw " + tmp1 + ", " + right);
					// Condición
					if (op == "==") mips.push_back("    beq " + tmp0 + ", " + tmp1 + ", " + label);
					else if (op == "!=") mips.push_back("    bne " + tmp0 + ", " + tmp1 + ", " + label);
					else if (op == "<") mips.push_back("    blt " + tmp0 + ", " + tmp1 + ", " + label);
					else if (op == "<=") mips.push_back("    ble " + tmp0 + ", " + tmp1 + ", " + label);
					else if (op == ">") mips.push_back("    bgt " + tmp0 + ", " + tmp1 + ", " + label);
					else if (op == ">=") mips.push_back("    bge " + tmp0 + ", " + tmp1 + ", " + label);
				}
				continue;
			}

			// Concatenación: tX := call concat, N
			if (regex_match(line, m, regex(R"(^t(\d+)\s*:=\s*call concat, \d+$)"))) {
				string tnum = m[1];
				mips.push_back("    la $t" + tnum + ", buffer # [TODO] concat no implementado");
				continue;
			}

			// Otros casos: dejar como comentario
			mips.push_back("    # " + line);
		}
	}
	return mips;
}

// Genera el código ensamblador a partir del TAC y los bloques de flujo
void generateAssemblyCode(ASTNode* node, vector<pair<string, BasicBlock*> > blocks) {
	if (!node) {
		cout << "TAC is empty." << endl;
		return;
	}

	string ss;
	cout << "--> Generate Assemble Code? (s/n): "; cin >> ss;
	while (ss != "s" && ss != "n") { cout << "Key Error. Generate Assemble Code? (s/n): "; cin >> ss; }
	if (ss == "n") return;

	vector<string> asm_code;
	asm_code.push_back(".data");
	asm_code.push_back(".align 2");
	// 1. Sección de datos (strings, etc.)
	for (const auto& tac_data : node->tac_data) {
		asm_code.push_back(tac_data.first + ": .asciiz " + tac_data.second);
	}

	// 2. Sección de declaraciones (espacio para variables)
	set<string> declared;
	for (const auto& tac_decl : node->tac_declaraciones) {
		const string& var = tac_decl.second.first;
		if (declared.count(var)) continue;
		declared.insert(var);
		asm_code.push_back(var + ": .word 0");
	}
	asm_code.push_back("buffer: .space 64");
	asm_code.push_back("");
	asm_code.push_back(".text");
	asm_code.push_back("main:");

	// 3. Sección de código (por bloques)
	vector<string> mips_block = translate_TAC_to_MIPS(blocks, node);
	asm_code.insert(asm_code.end(), mips_block.begin(), mips_block.end());

	// 4. Escribir el código ensamblador a un archivo
	ofstream fout("output.asm");
	for (const auto& line : asm_code) {
		fout << line << endl;
	}
	fout.close();

	cout << "\033[1;32m[OK]\033[0m Código ensamblador generado en output.asm" << endl;
}