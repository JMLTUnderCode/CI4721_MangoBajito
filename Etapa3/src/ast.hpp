#ifndef AST_HPP
#define AST_HPP

#include <vector>
#include <memory>
#include <iostream>
#include <string>
#include <map>

struct info
{
	std::string es_apuntador = "";
	std::string tipo_asignacion = "";
	std::string identificador = "";
	std::string tipo = "";
	std::string es_atributo = "";
	std::string valor = "";
};

class ASTNode
{
public:
	enum class NodeType
	{
		Undefined,
		program_inst_main,
		program_main,
		s_main,
		instuctions,
		s_decl_struct,
		s_decl_culito,
		s_decl_jeva,
		s_if,
		s_if_else,
		s_else,
		s_asign,
		s_exp,
		s_sequence,
		s_print,
		s_input,
		s_func_call,
		s_try,
		s_try_catch,
		s_try_catch_variable,
		s_while,
		s_for,
		rango_for,
		flow_for,
		s_break,
		s_continue,
		s_incremento,
		s_decremento,
		s_return,
		s_delete,
		variable,
		valor,
		e_null,
		s_struct,
		decl_sequence,
		s_variante,
		// Agrega más tipos de nodos según sea necesario
	};

	ASTNode(NodeType type) : type(type) {}

	std::string getType() const
	{
		switch (type)
		{
		case NodeType::Undefined:
			return "Undefined";
		case NodeType::program_inst_main:
			return "program_inst_main";
		case NodeType::program_main:
			return "program_main";
		case NodeType::instuctions:
			return "instuctions";
		case NodeType::s_decl_culito:
			return "s_decl_culito";
		case NodeType::s_decl_jeva:
			return "s_decl_jeva";
		case NodeType::s_if:
			return "s_if";
		case NodeType::s_if_else:
			return "s_if_else";
		case NodeType::s_else:
			return "s_else";
		case NodeType::s_asign:
			return "s_asign";
		case NodeType::s_main:
			return "s_main";
		case NodeType::s_sequence:
			return "s_sequence";
		case NodeType::s_print:
			return "s_print";
		case NodeType::s_input:
			return "s_input";
		case NodeType::s_func_call:
			return "s_func_call";
		case NodeType::s_try:
			return "s_try";
		case NodeType::s_try_catch:
			return "s_try_catch";
		case NodeType::s_try_catch_variable:
			return "s_try_catch_variable";
		case NodeType::s_exp:
			return "s_exp";
		case NodeType::s_while:
			return "s_while";
		case NodeType::s_for:
			return "s_for";
		case NodeType::rango_for:
			return "rango_for";
		case NodeType::flow_for:
			return "flow_for";
		case NodeType::s_break:
			return "s_break";
		case NodeType::s_continue:
			return "s_continue";
		case NodeType::s_incremento:
			return "s_incremento";
		case NodeType::s_decremento:
			return "s_decremento";
		case NodeType::s_return:
			return "s_return";
		case NodeType::s_delete:
			return "s_delete";
		case NodeType::variable:
			return "variable";
		case NodeType::valor:
			return "valor";
		case NodeType::s_struct:
			return "s_struct";
		case NodeType::decl_sequence:
			return "decl_sequence";
		case NodeType::s_decl_struct:
			return "s_decl_struct";
		case NodeType::s_variante:
			return "s_variante";
		case NodeType::e_null:
			return "null";
		// Agrega más casos según sea necesario
		default:
			return "Pendiente, pon nombre!!!";
		}
	}
	const std::vector<std::shared_ptr<ASTNode>> &getChildren() const { return children; }

	void addChild(std::shared_ptr<ASTNode> child)
	{
		children.push_back(child);
	}

	NodeType type;
	std::vector<std::shared_ptr<ASTNode>> children;
	info informacion;
};

inline void printAST(const std::shared_ptr<ASTNode> &node, int depth = 0)
{
	if (!node)
		return;

	// Indent based on depth
	for (int i = 0; i < depth; ++i)
		std::cout << "  ";

	// Print the node type
	std::cout << "Node Type: " << node->getType() << std::endl;
	// Use a map to iterate over the attributes of the 'informacion' struct
	std::map<std::string, std::string> attributes = {
		{"es_apuntador", node->informacion.es_apuntador},
		{"tipo_asignacion", node->informacion.tipo_asignacion},
		{"identificador", node->informacion.identificador},
		{"tipo", node->informacion.tipo},
		{"es_atributo", node->informacion.es_atributo},
		{"valor", node->informacion.valor}};

	for (const auto &attribute : attributes)
	{
		if (!attribute.second.empty())
		{
			// Indent based on depth + 1
			for (int i = 0; i < depth + 1; ++i)
				std::cout << "  ";
			std::cout << attribute.first << ": " << attribute.second << std::endl;
		}
	}
	// Indent based on depth + 1
	if (!node->getChildren().empty()){
		for (int i = 0; i < depth + 1; ++i)
			std::cout << "  ";
		std::cout<< "Hijos:" <<std::endl;
	}
	// Recursively print children
	for (const auto &child : node->getChildren())
	{
		printAST(child, depth + 2);
	}
}
#endif // AST_HPP