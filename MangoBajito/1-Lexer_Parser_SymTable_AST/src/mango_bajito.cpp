#include "mango_bajito.hpp"

vector<string> sysErrorToString = {
	"ARRAY_LITERAL_SIZE_MISMATCH",
	"SEMANTIC",
	"NON_DEF_VAR",
	"ALREADY_DEF_VAR",
	"NON_DEF_FUNC",
	"ALREADY_DEF_FUNC",
	"NON_DEF_STRUCT",
	"ALREADY_DEF_STRUCT",
	"NON_DEF_UNION",
	"ALREADY_DEF_UNION",
	"NON_DEF_TYPE",
	"ALREADY_DEF_TYPE",
	"NON_DEF_ATTR",
	"ALREADY_DEF_ATTR",
	"VAR_FOR",
	"VAR_TRY",
	"NON_VALUE",
	"TYPE_ERROR",
	"MODIFY_CONST",
	"SEGMENTATION_FAULT",
	"FUNC_PARAM_EXCEEDED",
	"FUNC_PARAM_MISSING",
	"ALREADY_DEF_PARAM",
	"EMPTY_ARRAY_CONSTANT",
	"POINTER_ARRAY",
	"INT_SIZE_ARRAY",
	"INT_INDEX_ARRAY",
	"SIZE_ARRAY_INVALID",
	"INTERNAL",
	"EMPTY"
};

// Función para agregar un error al diccionario
void addError(systemError err, const string& msg) {
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

// Función para imprimir la información de los atributos
void print_info(vector<pair<Information, Attributes*> > informations){
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

void print_values(Values x){
	visit([](auto&& arg) {
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
				for (const auto& val : v.data) print_values(val);
				cout << "} ";
			}
			cout << "]";
		}
	}, x);
}

// ======================================================
// =                    Symbol Table                    =
// ======================================================

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

// funcion auxiliar para verificar si una key esta en un map
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

Attributes* SymbolTable::search_symbol(string symbol_name) {
	Attributes *predef_symbol, *best_option = nullptr;
	//vector<pair<int, bool> > scopes_aux = this->scopes;
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

void SymbolTable::print_attribute(Attributes &attr){
	cout << "       Símbolo: " << attr.symbol_name 
		<< ", Categoría: " << attr.category 
		<< ", Scope: " << attr.scope 
		<< ", Type: "<< (attr.type != nullptr ? attr.type->symbol_name : "")
		<<  ", Informacion: "; print_info(attr.info); 
		cout << ", Value: "; print_values(attr.value); cout << "\n\n";
}

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
		cout << "    Clave: " << count++ << ": " << symbol.first << endl;
		for (Attributes &attr : symbol.second) {
			print_attribute(attr);
		}
	}
}

// ======================================================
// =                Abstract Sintax Tree                =
// ======================================================

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
	if (!node->value.empty())    cout << " | Value: " << node->value;

	// Imprimir parámetros si es función
	if (!node->params.empty()) {
		cout << " | Params (" << node->param_count << "): ";
		for (const auto& param : node->params) {
			cout << "[" << param.type << " " << param.name << "] ";
		}
	}

	// Imprimir atributos si es struct/union/variant
	if (!node->attributes.empty()) {
		cout << " | Attributes: ";
		for (const auto& attr : node->attributes) {
			cout << "[" << attr.type << " " << attr.name << "] ";
		}
	}

	// Imprimir elementos si es un array
	if (!node->elements.empty()) {
	    cout << " | Elements: [";
	    for (size_t i = 0; i < node->elements.size(); ++i) {
	        if (!node->elements[i].name.empty()) cout << node->elements[i].name;
	        else { cout << node->elements[i].value; }
	        if (i + 1 < node->elements.size()) cout << ", ";
	    }
	    cout << "]";
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
