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

// Subgrafos para algoritmos de comunidad

// Subgrafo Dirigido - Libro 2

//Subgrafo No Dirigido - Libro 2

//Subgrafo Dirigido - General

//Subgrafo No Dirigido - General



// Análisis de Centralidad


// Análisis de Comunidad