/*
=================================================================================
OBJETIVO
    Inicializar a estrutura base do Data Warehouse.

ETAPAS
    1. Remove o banco "data_warehouse", caso já exista.
    2. Cria o banco "data_warehouse".
    3. Cria os schemas:
       - bronze: dados brutos/originais.
       - silver: dados tratados e padronizados.
       - gold: dados finais, prontos para consumo.

AVISO
    A execução remove completamente o banco "data_warehouse" existente,
    incluindo todos os seus objetos e dados.
	Utilize com cautela.
=================================================================================
*/

DROP DATABASE IF EXISTS data_warehouse;

CREATE DATABASE data_warehouse;

-- USE data_warehouse;

CREATE SCHEMA bronze;

CREATE SCHEMA silver;

CREATE SCHEMA gold;