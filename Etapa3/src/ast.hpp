#ifndef AST_HPP
#define AST_HPP

#include <vector>
#include <memory>
#include <iostream>
#include <string>


struct info
{
	std::string es_apuntador = "";
	std::string tipo_asignacion = "";
	std::string identificador = "";
	std::string tipo = "";
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
		s_decl_culito,
		s_decl_jeva,
		s_if,
		s_if_else,
		s_else,
		s_asign,
		s_exp,
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
		// Agrega más casos según sea necesario
		default:
			return "Unknown";
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

	// Recursively print children
	for (const auto &child : node->getChildren())
	{
		printAST(child, depth + 1);
	}
}
#endif // AST_HPP