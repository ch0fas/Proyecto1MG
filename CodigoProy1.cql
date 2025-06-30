// Código Proyecto 1 - MG
// Sofía Maldonado García
// Viviana Toledo De La Fuente
// César Adrián Sánchez Santacruz

// Creación de Grafo
LOAD CSV WITH HEADERS FROM 'https://raw.githubusercontent.com/ch0fas/ArchivosMG/refs/heads/main/Data/characters.csv' AS row
CREATE (c:Character)
SET c.name = row.character,
c.species = row.species,
c.gender = row.gender;

// Corregir nodo de Shadowfax
MATCH (c:Character)
WHERE c.name = 'Shadowfax'
SET c.gender = 'Male';

// Corregir especie
MATCH (c:Character)
WHERE c.species = 'Ainor'
SET c.species = 'Ainur';

//Creación de Relaciones - Libro 2
LOAD CSV WITH HEADERS FROM 'https://raw.githubusercontent.com/ch0fas/ArchivosMG/refs/heads/main/Data/02__The_Two_Towers_interactions.csv' AS row
MATCH (src:Character {name:row.source})
MATCH (dst:Character {name:row.target})
MERGE (src)-[:SPEAKS_L2 {weight:row.value}]->(dst);

//Creación de Relaciones - General
LOAD CSV WITH HEADERS FROM 'https://raw.githubusercontent.com/ch0fas/ArchivosMG/refs/heads/main/Data/all_interactions.csv' AS row
MATCH (src:Character {name:row.source})
MATCH (dst:Character {name:row.target})
MERGE (src)-[:SPEAKS_G {weight:row.value}]->(dst);

//Weight debe ser numérico
MATCH ()-[r:SPEAKS_L2]->()
SET r.weight = toInteger(r.weight);

MATCH ()-[r:SPEAKS_G]->()
SET r.weight = toInteger(r.weight);



// Análisis Básico 

// 1. Graph Schema

CALL db.schema.visualization;

// 2. Character Nodes

MATCH (c:Character)
RETURN COUNT(DISTINCT c) AS Character_Count;

// 3. Relationship Count

MATCH (n) -[r]- (m)
RETURN COUNT(DISTINCT r) AS Interaction_Count;

// 4. Relationship Types

CALL db.relationshipTypes;

// 5. Node Properties

CALL db.schema.nodeTypeProperties;

// 6. Book 2 Characters

MATCH (n) -[r:SPEAKS_L2]-> (m)
RETURN n,r,m;

// 9. Species Characters

MATCH (c:Character)
RETURN c.species AS Species,
COUNT (DISTINCT c) AS Count
ORDER BY Count DESC;

// 10. Gender of Characters

MATCH (c:Character)
RETURN c.gender AS Gender,
COUNT (DISTINCT c) AS Count
ORDER BY Count DESC;

// 11. Species of Characters in Book 2 vs General Saga

MATCH (n) -[r:SPEAKS_L2]- (m)
WITH n,m AS charas
RETURN DISTINCT(charas.species) AS Species_Book2;

// 12. Women in Book 2 vs General Saga

    // Book 2
CALL{
    MATCH (n) -[r:SPEAKS_L2]- (m)
    WITH n,m AS charas
    WHERE charas.gender = 'Female'
    RETURN COUNT(DISTINCT(charas.name)) AS Women_Book2
}
    // General Saga 
CALL{
    MATCH (n) -[r:SPEAKS_G]- (m)
    WITH n,m AS charas
    WHERE charas.gender = 'Female'
    RETURN COUNT(DISTINCT(charas.name)) AS Women_3Books
}
RETURN Women_Book2, Women_3Books;

// 13. Graph to 2 jumps



// 15. Characters in Book 2 vs All Books

    // Book 2
CALL{
    MATCH (n) -[r:SPEAKS_L2]- (m)
    WITH n,m AS charas
    RETURN COUNT(DISTINCT(charas.name)) AS Characters_Book2
}
    // General Saga 
CALL{
    MATCH (n) -[r:SPEAKS_G]- (m)
    WITH n,m AS charas
    RETURN COUNT(DISTINCT(charas.name)) AS Characters_3Books
}
RETURN Characters_Book2, Characters_3Books;

// Subgrafos para algoritmos de centralidad

// Subgrafo Dirigido - Libro 2
CALL gds.graph.project(
    'NaturalL2', 
    'Character', 
    {SPEAKS_L2:
    {orientation: 'NATURAL',
     Properties: 'weight'
    }}
);

//Subgrafo No Dirigido - Libro 2
CALL gds.graph.project(
    'UndirectedL2', 
    'Character', 
    {SPEAKS_L2:
    {orientation: 'UNDIRECTED',
     Properties: 'weight'
    }}
);

//Subgrafo Dirigido - General
CALL gds.graph.project(
    'NaturalG', 
    'Character', 
    {SPEAKS_G:
    {orientation: 'NATURAL',
     Properties: 'weight'
    }}
);

//Subgrafo No Dirigido - General
CALL gds.graph.project(
    'UndirectedG', 
    'Character', 
    {SPEAKS_G:
    {orientation: 'UNDIRECTED',
     Properties: 'weight'
    }}
);

//Subgrafo Inverso - Libro 2
CALL gds.graph.project(
    'ReverseL2', 
    'Character', 
    {SPEAKS_L2:
    {orientation: 'REVERSE',
     Properties: 'weight'
    }}
);


//Subgrafo Inverso - General
CALL gds.graph.project(
    'ReverseG', 
    'Character', 
    {SPEAKS_G:
    {orientation: 'REVERSE',
     Properties: 'weight'
    }}
);

// Análisis de Centralidad

// 1
// PageRank L2
CALL gds.pageRank.write(
        'NaturalL2',
        {
                writeProperty: 'PageRankL2',
                maxIterations: 20,
                dampingFactor: 0.85
        }

)
YIELD nodePropertiesWritten, ranIterations

//PageRank General
CALL gds.pageRank.write(
        'NaturalG',
        {
                writeProperty: 'PageRankG',
                maxIterations: 20,
                dampingFactor: 0.85
        }

)
YIELD nodePropertiesWritten, ranIterations

MATCH (c:Character)
RETURN c.name AS Character, c.PageRankG AS PR_G, c.PageRankL2 AS PR_L2
ORDER BY PR_G DESC
LIMIT 5;

// 2
MATCH (c:Character)
RETURN c.name AS Character, c.PageRankL2 AS PR_L2
ORDER BY PR_L2 DESC
LIMIT 10;

// 3
// BC General
CALL gds.betweenness.write(
        'NaturalG',
        {
                writeProperty: 'bc_G'
        }
)
YIELD centralityDistribution, nodePropertiesWritten

MATCH (c:Character)
RETURN c.species AS Especie, COUNT(c) AS Members, avg(c.bc_G) AS BC_G
ORDER BY BC_G DESC;

// 4
MATCH (c:Character {gender:'Female'})
RETURN c.name AS Name, c.PageRankG AS PageRank
ORDER BY PageRank DESC
LIMIT 5;

// 5
//Añadir atributo closeness centrality
call gds.closeness.write(
        'NaturalL2',
        {
                writeProperty: 'closeness_L2'
        }
)
YIELD centralityDistribution, nodePropertiesWritten;

MATCH (c:Character)
RETURN c.species AS Especie, avg(c.closeness_L2) AS Closeness
ORDER BY Closeness DESC;

// 6. Closeness Centrality

MATCH (c:Character)
RETURN c.name AS Character,
c.closeness_L2 AS Closeness
ORDER BY Closeness DESC
LIMIT 1;

// 7. Closeness Centrality in Women

    // Añadir atributo Closeness General
call gds.closeness.write(
        'NaturalG',
        {
                writeProperty: 'closeness_G'
        }
)
YIELD centralityDistribution, nodePropertiesWritten;

MATCH (c:Character)
WHERE c.gender = 'Female'
RETURN c.name AS Character,
c.closeness_G AS Closeness
ORDER BY Closeness DESC
LIMIT 1;

// 8. Betweenness Comparison in Book 2 and Trilogy
// Atributo betweenness
CALL gds.betweenness.write(
        'NaturalL2',
        {
                writeProperty: 'bc_L2'
        }
)
YIELD centralityDistribution, nodePropertiesWritten

CALL gds.betweenness.write(
        'NaturalG',
        {
                writeProperty: 'bc_G'
        }
)
YIELD centralityDistribution, nodePropertiesWritten

MATCH (c:Character)
RETURN c.name AS Character, c.bc_L2 AS BC_L2
ORDER BY BC_L2 DESC
LIMIT 5;

// 9. Top Betweenness in Fellowship of the Ring 

//10
// Atributo degree
CALL gds.degree.write('UndirectedG', {writeProperty:'degree_G'})
YIELD centralityDistribution, nodePropertiesWritten;

CALL gds.degree.write('UndirectedL2', {writeProperty:'degree_L2'})
YIELD centralityDistribution, nodePropertiesWritten;

MATCH (c:Character)
WHERE c.gender = 'Female'
RETURN c.name AS Character, c.degree_G AS Degree, 
ROUND(c.closeness_G,4) AS Closeness,
ROUND(c.PageRankG,4) AS PageRank, 
ROUND(c.bc_G,4) AS Betweenness
ORDER BY Degree DESC
LIMIT 1;

// 11
// Atributo InDegree
CALL gds.degree.write('ReverseG', {writeProperty:'in_degree_G'})
YIELD centralityDistribution, nodePropertiesWritten

CALL gds.degree.write('ReverseL2', {writeProperty:'in_degree_L2'})
YIELD centralityDistribution, nodePropertiesWritten

MATCH (c:Character)
RETURN c.name AS Character, c.in_degree_G AS InDegree
ORDER BY InDegree ASC;

MATCH (c:Character {in_degree_G:0})
RETURN COUNT(DISTINCT c)

// 12. Top 5 Out Degree in General vs L2
    // OutDegree Attribute
CALL gds.degree.write('NaturalG', {writeProperty:'out_degree_G'})
YIELD centralityDistribution, nodePropertiesWritten;

CALL gds.degree.write('NaturalL2', {writeProperty:'out_degree_L2'})
YIELD centralityDistribution, nodePropertiesWritten;

    // Top 5 Characters
MATCH (c:Character)
RETURN c.name AS Character,
c.out_degree_G AS Out_Degree_Trilogy
ORDER BY Out_Degree_Trilogy DESC
LIMIT 5;

MATCH (c:Character)
RETURN c.name AS Character,
c.out_degree_L2 AS Out_Degree_Book2
ORDER BY Out_Degree_Book2 DESC
LIMIT 5;

// 13. Top 3 Species using max Degree in General vs Book 2
MATCH (c:Character)
RETURN c.species AS Species, 
COUNT(c) AS Members, 
AVG(c.degree_G) AS Degree_General
ORDER BY Degree_General DESC
LIMIT 3;

MATCH (c:Character)
RETURN c.species AS Species, 
COUNT(c) AS Members, 
AVG(c.degree_L2) AS Degree_Book2
ORDER BY Degree_Book2 DESC
LIMIT 3;

// 14. Top 3 Species using min Degree in General vs Book 2
MATCH (c:Character)
RETURN c.species AS Species, 
COUNT(c) AS Members, 
AVG(c.degree_G) AS Degree_General
ORDER BY Degree_General ASC
LIMIT 3;

MATCH (c:Character)
WITH c.species AS Species,
COUNT(c) AS Members,
AVG(c.degree_L2) AS Degree_Book2
WHERE Degree_Book2 <> 0                         // for the species that dont appear in Book 2
RETURN Species, Members, Degree_Book2
ORDER BY Degree_Book2 ASC
LIMIT 3;

// 15. Analysis of the Character with the Top Degree

MATCH (c:Character)
RETURN c.name AS Character, c.degree_G AS Degree, 
ROUND(c.closeness_G,4) AS Closeness,
ROUND(c.PageRankG,4) AS PageRank, 
ROUND(c.bc_G,4) AS Betweenness
ORDER BY Degree DESC
LIMIT 1;



// Análisis de Comunidad

// 1
// Atributo WCC
call gds.wcc.write('UndirectedL2', {writeProperty: 'wcc_L2'})
YIELD componentCount, componentDistribution

call gds.wcc.write('UndirectedG', {writeProperty: 'wcc_G'})
YIELD componentCount, componentDistribution

MATCH (c:Character)
RETURN c.species AS Especie, COUNT(DISTINCT c) AS Number, avg(c.wcc_L2) AS WCC
ORDER BY WCC DESC;

// 2
MATCH (c:Character)
RETURN c.species AS Especie, COUNT(DISTINCT c) AS Number, avg(c.wcc_G) AS WCC
ORDER BY WCC DESC;

// 3
// Atributo TC
CALL gds.triangleCount.write('UndirectedL2', {
  writeProperty: 'tc_L2'
})
YIELD globalTriangleCount, nodeCount

CALL gds.triangleCount.write('UndirectedG', {
  writeProperty: 'tc_G'
})
YIELD globalTriangleCount, nodeCount

MATCH (c:Character)
RETURN c.name AS Character, c.tc_L2 AS TriangleCount
ORDER BY TriangleCount DESC
LIMIT 10;

// 4
MATCH (c:Character)
RETURN c.name AS Character, c.tc_G AS TriangleCount
ORDER BY TriangleCount DESC
LIMIT 10;

// 5
// Atributo Louvain
call gds.louvain.write('UndirectedL2',{writeProperty: 'louvain_L2'})
YIELD communityCount, modularity, modularities

call gds.louvain.write('UndirectedG',{writeProperty: 'louvain_G'})
YIELD communityCount, modularity, modularities

MATCH (c:Character)
RETURN c.species AS Especie, COUNT(DISTINCT c) AS Number, avg(c.louvain_G) AS Louvain
ORDER BY Louvain DESC;