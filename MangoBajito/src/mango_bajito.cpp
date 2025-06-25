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
		if (kind == "Numérica" && left_type == right_type && left_type == "higuerote") {
			kind = "Concatenación";	
			if (op == "+") new_node->svalue = left->svalue + right->svalue;
			else {
				error_msg += "Unsupported type for operation: " + type;
				addError(TYPE_ERROR, error_msg);
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
	} 
}

// Construir arbol AST de una Estructura(Arroz Con Mango).
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
	if (!node->tac_data.empty()) cout << ".data:" << endl; 

	for (const auto& tac_data : node->tac_data) {
		cout << tac_data.first << " := " << tac_data.second << endl;
	}

	// Imprimir las declaraciones TAC si hay
	if (!node->tac_declaraciones.empty()){ 
		cout << "\n.declaration:" << endl;
		auto tac_declaraciones = node->tac_declaraciones;
		sort(tac_declaraciones.begin(), tac_declaraciones.end(), [](const pair<int, pair<string, int>>& a, const pair<int, pair<string, int>>& b) {
			return a.first < b.first; // Ordenar por el primer elemento (scope)
		});

		for (const auto& tac_decl : tac_declaraciones) {
			static int last_scope = -1;
			if (tac_decl.first != last_scope) {
				if (last_scope != -1) cout << endl; // Agrega salto de línea antes de cada scope excepto el primero
				cout << "Scope " << tac_decl.first << ": " << endl;
				last_scope = tac_decl.first;
			}
			cout << tac_decl.second.first << ": alloc " << tac_decl.second.second << endl;
		}
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

	return ERROR;
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
				out.push_back(
				"if " + expr->temp + " goto " + expr->trueLabel +
				"\ngoto " + expr->falseLabel
				);
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
	this->count_blocks++;
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
int FlowGraph::length(){
	return this->count_blocks;
}

string extractGotoLabel(const string& line) {
	smatch match;
	regex rgx(R"(goto\s+(L\d+))");
	if (regex_search(line, match, rgx)) {
		return match[1]; // El grupo de captura (L<num>)
	}
	return "";
}

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

	// Iterar sobre las líneas de TAC
	vector<size_t> lider_index; // Conjunto para almacenar los índices de los líderes
	for (size_t i = 0; i < tac.size(); i++) {
		if (i == 0) {
			// La primera línea siempre es un líder
			lider_index.push_back(i);
		} else {
			const string& line = tac[i];
			// También el siguiente bloque es un líder
			if (line.find("goto") != string::npos) {
				if (i + 1 < tac.size()) lider_index.push_back(i + 1);
			}
			// Los labels que cumplen con el patrón son un líder
			if (regex_search(line, b)) lider_index.push_back(i);
		}
	}
	remove_duplicates_keep_order(lider_index);

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
		}
		if (right < left) {
			cout << "[ERROR] right < left, saltando bloque." << endl;
			continue;
		}
		vector<string> code(tac.begin() + left, tac.begin() + right+1);
		string lider_label = "";
		if (regex_search(code[0], b)) lider_label = code[0].substr(0, code[0].size() - 2);
		
		block_name = "B" + to_string(block_count++);
		this->createBlock(block_name, code, lider_label);
	}
	this->createBlock("EXIT");
	this->computeDefAndUseSets();
	BasicBlock* fatherBlock;
	string currentBlockName, currentBlockLabel;
	string label;
	size_t size_tac_code;
	string last_line;
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
			for(auto line : currentBlock->TAC_code){
				label = extractGotoLabel(line);
				if(!label.empty()){
					BasicBlock* nodo = this->getBlockByLabel(label);
					this->addEdge(currentBlockName, nodo->name); // Arista del flujo 'goto Label'
				}

			}
			if (fatherBlock->name != "ENTRY"){
				// Verificar nodo padre si existe condicional "if".
				size_tac_code = fatherBlock->TAC_code.size();
				last_line = fatherBlock->TAC_code[size_tac_code - 1];
				if (last_line.find("if") != string::npos) {
					this->addEdge(fatherBlock->name, currentBlockName);
				} else if (last_line.find("goto") == string::npos){
					this->addEdge(fatherBlock->name, currentBlockName);
				}
			} else {
				this->addEdge(fatherBlock->name, currentBlockName);
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

void FlowGraph::print() {
	const int CELL_SIZE = 10;
	cout << "\033[1;36m\033[5m\n               =======================================================\n";
	cout << "                                  Control Flow Graphs                 \n";
	cout << "               =======================================================\n\033[0m\n";
	cout << "----------------------------------------------------------" << endl;
	// 1. Mostrar información de los nodos
	for (const auto& block : this->blocks) {
		const string& name = block.first;
		BasicBlock* bb = block.second;
		cout << "Name: " << name << endl;
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
	cout << endl << "         * | Matriz de Adyacencia | *" << endl << endl;
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

void FlowGraph::computeDefAndUseSets(){
	// Calcular Def para cada bloque
	set<string> reserved_words = {"if", "goto", "ifnot", "return", "call", "param", "alloc", "print", "read"};
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

void FlowGraph::computeINandOUT_lived_var(){
	// Inicializar Conjuntos IN/OUT
	bool changed = true;
	int count = 0;
	while(changed){
		cout << "\nIteracion: " << count++ << endl;
		changed = false; // Reiniciar el estado de cambio
		set<string> previous_in;
		for(size_t i = this->blocks.size() - 1; i > 0; i--) { // Iterar desde el último bloque hasta el primero
			if(this->blocks[i].first == "EXIT") continue; // Saltar el bloque EXIT
			BasicBlock* block = this->blocks[i].second;
			cout << "Bloque: " << block->name << endl;
			previous_in = block->in;
			// Calcular el conjunto OUT
			set<string> unor_set;
			for(auto& child : block->childs) {
				unor_set.insert(child->in.begin(), child->in.end());
			}
			block->out = unor_set; // Asignar el conjunto OUT al bloque actual
			// Calcular el conjunto IN
			set<string> in_set;
			set<string> diff;
			set_difference(unor_set.begin(), unor_set.end(),
						   block->def.begin(), block->def.end(),
						   inserter(diff, diff.begin()));
			in_set = block->use;
			in_set.insert(diff.begin(), diff.end());
			block->in = in_set;

			cout << "IN: ";
			for (const auto& in : block->in) cout << in << " ";
			cout << "\nOUT: ";
			for (const auto& out : block->out) cout << out << " ";
			cout << endl;

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

void DataFlowProblem::solve_data_flow_problem(FlowGraph& flow_graph){
	
}