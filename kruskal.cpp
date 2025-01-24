#include <iostream>

using namespace std;

/*************************************************** Priority Queue ***********************************************************/
struct Edge {
    int src, dest, weight;
};

struct Node {
    Edge edge;
    Node* next;
};

struct PriorityQueue {
    Node* head;
};

void initialize(PriorityQueue& pq) {
    pq.head = nullptr;
}

void insert(PriorityQueue& pq, Edge edge) {
    Node* newNode = new Node();
    newNode->edge = edge;
    newNode->next = nullptr;

    // Insertar en la posición correcta
    if (pq.head == nullptr || pq.head->edge.weight >= edge.weight) {
        newNode->next = pq.head;
        pq.head = newNode;
    } else {
        Node* current = pq.head;
        while (current->next != nullptr && current->next->edge.weight < edge.weight) {
            current = current->next;
        }
        newNode->next = current->next;
        current->next = newNode;
    }
}

Edge extractMin(PriorityQueue& pq) {
    if (pq.head == nullptr) return {-1, -1, -1}; // Error: cola vacía

    Node* temp = pq.head;
    Edge minEdge = pq.head->edge;
    pq.head = pq.head->next;
    delete temp; // Liberar memoria del nodo extraído
    return minEdge;
}

bool isEmpty(PriorityQueue& pq) {
    return pq.head == nullptr;
}

/*************************************************** DSU ***********************************************************/

struct DSU {
    int* parent; // Apuntador al heap para los padres
    int* rank;   // Apuntador al heap para los rangos
    int size;    // Tamaño del DSU
};

void initialize(DSU& dsu, int n) {
    dsu.parent = new int[n];
    dsu.rank = new int[n];
    dsu.size = n;
    for (int i = 0; i < n; i++) {
        dsu.parent[i] = i;
        dsu.rank[i] = 0;
    }
}

int find(DSU& dsu, int x) {
    if (dsu.parent[x] != x)
        dsu.parent[x] = find(dsu, dsu.parent[x]); // Compresión de caminos
    return dsu.parent[x];
}

void unionSets(DSU& dsu, int x, int y) {
    int rootX = find(dsu, x);
    int rootY = find(dsu, y);
    if (rootX != rootY) {
        if (dsu.rank[rootX] > dsu.rank[rootY]) {
            dsu.parent[rootY] = rootX;
        } else if (dsu.rank[rootX] < dsu.rank[rootY]) {
            dsu.parent[rootX] = rootY;
        } else {
            dsu.parent[rootY] = rootX;
            dsu.rank[rootX]++;
        }
    }
}

/*************************************************** Grafo ***********************************************************/
struct Graph {
    Edge* edges;	// Arreglo de aristas. Se utiliza la misma estructura Edge usada en la PriorityQueue.
    int edgeCount;
    int vertexCount;
};

void initialize(Graph& g, int vertices, int edges) {
    g.vertexCount = vertices;
    g.edgeCount = edges;
    g.edges = new Edge[edges];
}

void kruskal(Graph& g) {
    // Inicializar el DSU
    DSU dsu;
    initialize(dsu, g.vertexCount);

    // Inicializar la PriorityQueue
    PriorityQueue pq;
    initialize(pq);

    // Insertar todas las aristas en la PriorityQueue
    for (int i = 0; i < g.edgeCount; i++) {
        insert(pq, g.edges[i]);
    }

    // Variables para el MST
    Edge* mst = new Edge[g.vertexCount - 1];
    int mstSize = 0;
    int totalWeight = 0;

    // Mientras haya aristas en la PriorityQueue y el MST no esté completo
    while (!isEmpty(pq) && mstSize < g.vertexCount - 1) {
        Edge edge = extractMin(pq);

        // Verificar si la arista forma un ciclo
        int rootSrc = find(dsu, edge.src);
        int rootDest = find(dsu, edge.dest);

        if (rootSrc != rootDest) {
            // Agregar la arista al MST
            mst[mstSize++] = edge;
            totalWeight += edge.weight;

            // Unir los conjuntos en el DSU
            unionSets(dsu, rootSrc, rootDest);
        }
    }

    try {
        if (mstSize != g.vertexCount - 1) {
            throw runtime_error("No se pudo encontrar un MST (el grafo no es conexo).");
        }

        // Si no se lanza la excepción, se imprime el MST
        cout << "MST encontrado:\n";
        for (int i = 0; i < mstSize; i++) {
            cout << "Arista: " << mst[i].src << " -> " << mst[i].dest << ", Peso: " << mst[i].weight << "\n";
        }
        cout << "Peso total del MST: " << totalWeight << "\n";
    } catch (const runtime_error& e) {
        // Capturamos la excepción y mostramos el mensaje de error
        cout << e.what() << "\n";
    }

    /* // Imprimir el resultado: Version if/else
    if (mstSize == g.vertexCount - 1) {
        cout << "MST encontrado:\n";
        for (int i = 0; i < mstSize; i++) {
            cout << "Arista: " << mst[i].src << " -> " << mst[i].dest << ", Peso: " << mst[i].weight << "\n";
        }
        cout << "Peso total del MST: " << totalWeight << "\n";
    } else {
        cout << "No se pudo encontrar un MST (el grafo no es conexo).\n";
    } */

    delete[] mst;
}

int main() {
    Graph g;
    initialize(g, 5, 7); // 5 vértices, 7 aristas

    g.edges[0] = {0, 1, 4};
    g.edges[1] = {1, 2, 2};
    g.edges[2] = {0, 2, 4};
    g.edges[3] = {0, 3, 6};
    g.edges[4] = {0, 4, 6};
	g.edges[5] = {2, 3, 8};
    g.edges[6] = {3, 4, 9};

    kruskal(g);
    cout<<endl;

    Graph g2;
    initialize(g2, 6, 4); // 6 vértices, 4 aristas

    g2.edges[0] = {0, 1, 4};
    g2.edges[1] = {1, 2, 6};
    g2.edges[2] = {3, 4, 2};
    g2.edges[3] = {4, 5, 1};

    kruskal(g2);
    
    return 0;
}
