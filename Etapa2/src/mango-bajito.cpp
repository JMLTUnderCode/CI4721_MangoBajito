#include "mango-bajito.hpp"

// Implementacion de la clase SymbolTable
SymbolTable::SymbolTable() {
	this->current_scope = 0;
	this->next_scope = 1;
	this->scopes.push({this->current_scope, false});
}

void SymbolTable::open_scope() {
	this->current_scope = this->next_scope;
	this->next_scope++;
	this->scopes.push({this->current_scope, false});
}

void SymbolTable::close_scope() {
	this->scopes.top().second = true;
}

bool SymbolTable::insert_symbol(string symbol_name, Attributes &attr) {
	if (contains_key(this->table, symbol_name)) {
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