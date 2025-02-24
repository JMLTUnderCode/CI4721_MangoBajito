#include "mango-bajito.hpp"

// Implementacion de la clase SymbolTable
SymbolTable::SymbolTable() {
	this->current_scope = 0;
	this->next_scope = 1;
	this->scopes.push({this->current_scope, false});

	// Agregamos los simbolos predefinidos
	for (int i = 0; i < 7; i++){
		Attributes attr = {this->predef_types[i], TYPE, 0, nullptr};
		if (this->insert_symbol(predef_types[i], attr)) {
            cout << "Insertado tipo predefinido: " << predef_types[i] << endl;
        } else {
            cout << "Error al insertar tipo predefinido: " << predef_types[i] << endl;
        }
	}

	// Agregamos las funciones predefinidas
	for (int i = 0; i < 3; i++){
		Attributes attr = {this->predef_func[i], FUNCTION, 0, nullptr};
		if (this->insert_symbol(predef_func[i], attr)) {
            cout << "Insertada función predefinida: " << predef_func[i] << endl;
        } else {
            cout << "Error al insertar función predefinida: " << predef_func[i] << endl;
        }
	}

}

void SymbolTable::open_scope() {
	this->current_scope = this->next_scope;
	this->next_scope++;
	this->scopes.push({this->current_scope, false});
}

void SymbolTable::close_scope() {
	this->scopes.top().second = true;
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
	stack<pair<int, bool> > scopes_aux = this->scopes;
	int scope_value;

	auto symbols = this->table.find(symbol_name);
	if (symbols != this->table.end()) {
		for (Attributes &symbol : symbols->second) {
			if (symbol.symbol_name != symbol_name) continue;
			if (symbol.scope == 0) { predef_symbol = &symbol; break; }
			
			while (!scopes_aux.empty()) {
				scope_value = scopes_aux.top().first;
				
				if (symbol.scope == scope_value) {
					best_option = &symbol;		// El scope mas cercano
					break;
				} else if (best_option != nullptr && scope_value == best_option->scope) {
					break;						// No se encontrara un scope mas cercano
				}

				if (scopes_aux.top().second) break;	  // No puede ver al padre
				
				scopes_aux.pop();
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

}

void SymbolTable::print_table() {
    cout << "Tabla de Simbolos:" << endl;
    for (auto& symbol : this->table) {
        cout << "Clave: " << symbol.first << endl;
        for (Attributes &attr : symbol.second) {
            cout << "  Símbolo: " << attr.symbol_name 
                 << ", Categoría: " << attr.category 
                 << ", Scope: " << attr.scope << endl;
        }
    }
}