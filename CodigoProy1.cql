// Código Proyecto 1 - MG
// Sofía Maldonado García
// Viviana Toledo De La Fuente
// César Adrián Sánchez Santacruz

// Creación de Grafo
LOAD CSV WITH HEADERS FROM 'https://raw.githubusercontent.com/ch0fas/ArchivosMG/refs/heads/main/Data/characters.csv' AS row
CREATE (c:Character)
SET c.name = row.character
SET c.species = row.species;

//Creación de Relaciones - Libro 2
LOAD CSV WITH HEADERS FROM 'https://raw.githubusercontent.com/ch0fas/ArchivosMG/refs/heads/main/Data/02__The_Two_Towers_interactions.csv' AS row
MATCH (src:Character {name:row.source})
MATCH (dst:Character {name:row.target})
MERGE (src)-[:HABLA_L2 {weight:row.value}]->(dst);

//Creación de Relaciones - General
LOAD CSV WITH HEADERS FROM 'https://raw.githubusercontent.com/ch0fas/ArchivosMG/refs/heads/main/Data/all_interactions.csv' AS row
MATCH (src:Character {name:row.source})
MATCH (dst:Character {name:row.target})
MERGE (src)-[:HABLA_G {weight:row.value}]->(dst);



// Análisis Básico 

// 1. 