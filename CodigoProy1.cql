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

CALL 

// Subgrafos para algoritmos de comunidad

// Subgrafo Dirigido - Libro 2

//Subgrafo No Dirigido - Libro 2

//Subgrafo Dirigido - General

//Subgrafo No Dirigido - General



// Análisis de Centralidad


// Análisis de Comunidad