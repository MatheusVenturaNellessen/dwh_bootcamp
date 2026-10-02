/*
=================================================================================
OBJETIVO
    Carregar os dados brutos dos arquivos CSV dos sistemas CRM e ERP para as
	tabelas da camada Bronze.

ETAPAS
    1. Inicia o monitoramento do tempo total da carga.
    2. Para cada tabela CRM e ERP:
       - Remove os dados existentes com TRUNCATE.
       - Carrega os dados do arquivo CSV correspondente via COPY.
       - Registra o tempo de execução da carga.
    3. Exibe o tempo total de processamento da camada Bronze.
    4. Em caso de erro, interrompe a execução e informa a tabela,
       o SQLSTATE e a mensagem do erro.

AVISOS
    - O TRUNCATE remove todos os dados existentes antes de cada carga.
    - Os caminhos dos arquivos CSV são locais e dependem do ambiente.
    - O comando COPY exige que o PostgreSQL (servidor) tenha acesso aos 
	arquivos informados.
=================================================================================
*/

CREATE OR REPLACE PROCEDURE bronze.load_bronze()
LANGUAGE plpgsql
AS $$
DECLARE
	start_time       TIMESTAMP;
	batch_start_time TIMESTAMP;
	end_time         TIMESTAMP;
	batch_end_time   TIMESTAMP;
	current_table    TEXT;
BEGIN
	batch_start_time := CLOCK_TIMESTAMP();

	RAISE NOTICE 'Loading Bronze Layer';

	RAISE NOTICE 'Loading CRM tables';

	-- Table bronze.crm_cust_info	

	start_time := CLOCK_TIMESTAMP();

	current_table := 'bronze.crm_cust_info';

	RAISE NOTICE 'Truncating table: %', current_table;
	
	TRUNCATE bronze.crm_cust_info;
	
	RAISE NOTICE 'Inserting data into table: %', current_table;
	
	COPY bronze.crm_cust_info
	FROM 'C:/Users/2992529/Documents/dev_env/dwh-bootcamp/datasets/source_crm/cust_info.csv'
	WITH (
		FORMAT CSV,
		HEADER,
		DELIMITER ','
	);

	end_time := CLOCK_TIMESTAMP();

	RAISE NOTICE 'Load into table % completed successfully in % second(s)', current_table, EXTRACT(EPOCH FROM (end_time - start_time));

	-- Table bronze.crm_prd_info

	start_time := CLOCK_TIMESTAMP();
	
	current_table := 'bronze.crm_prd_info';

	RAISE NOTICE 'Truncating table: %', current_table;
	
	TRUNCATE bronze.crm_prd_info;
	
	RAISE NOTICE 'Inserting data into table: %', current_table;

	COPY bronze.crm_prd_info
	FROM 'C:/Users/2992529/Documents/dev_env/dwh-bootcamp/datasets/source_crm/prd_info.csv'
	WITH (
		FORMAT CSV,
		HEADER,
		DELIMITER ','
	);

	end_time := CLOCK_TIMESTAMP();

	RAISE NOTICE 'Load into table % completed successfully in % second(s)', current_table, EXTRACT(EPOCH FROM (end_time - start_time));

	-- Table bronze.crm_sales_details

	start_time := CLOCK_TIMESTAMP();
	
	current_table := 'bronze.crm_sales_details';

	RAISE NOTICE 'Truncating table: %', current_table;
	
	TRUNCATE bronze.crm_sales_details;
	
	RAISE NOTICE 'Inserting data into table: %', current_table;

	COPY bronze.crm_sales_details
	FROM 'C:/Users/2992529/Documents/dev_env/dwh-bootcamp/datasets/source_crm/sales_details.csv'
	WITH (
		FORMAT CSV,
		HEADER,
		DELIMITER ','
	);

	end_time := CLOCK_TIMESTAMP();

	RAISE NOTICE 'Load into table % completed successfully in % second(s)', current_table, EXTRACT(EPOCH FROM (end_time - start_time));
	
	RAISE NOTICE 'Loading ERP tables';

	-- Table bronze.erp_cust_az12

	start_time := CLOCK_TIMESTAMP();
	
	current_table := 'bronze.erp_cust_az12';

	RAISE NOTICE 'Truncating table: %', current_table;

	TRUNCATE bronze.erp_cust_az12;
	
	RAISE NOTICE 'Inserting data into table: %', current_table;

	COPY bronze.erp_cust_az12
	FROM 'C:/Users/2992529/Documents/dev_env/dwh-bootcamp/datasets/source_erp/CUST_AZ12.csv'
	WITH (
		FORMAT CSV,
		HEADER,
		DELIMITER ','
	);

	end_time := CLOCK_TIMESTAMP();

	RAISE NOTICE 'Load into table % completed successfully in % second(s)', current_table, EXTRACT(EPOCH FROM (end_time - start_time));

	-- Tabela bronze.erp_loc_a101

	start_time := CLOCK_TIMESTAMP();
	
	current_table := 'bronze.erp_loc_a101';

	RAISE NOTICE 'Truncating table: %', current_table;
		
	TRUNCATE bronze.erp_loc_a101;

	RAISE NOTICE 'Inserting data into table: %', current_table;
	
	COPY bronze.erp_loc_a101
	FROM 'C:/Users/2992529/Documents/dev_env/dwh-bootcamp/datasets/source_erp/LOC_A101.csv'
	WITH (
		FORMAT CSV,
		HEADER,
		DELIMITER ','
	);

	end_time := CLOCK_TIMESTAMP();

	RAISE NOTICE 'Load into table % completed successfully in % second(s)', current_table, EXTRACT(EPOCH FROM (end_time - start_time));

	-- Tabela bronze.erp_px_cat_g1v2

	start_time := CLOCK_TIMESTAMP();
	
	current_table := 'bronze.erp_px_cat_g1v2';
	
	RAISE NOTICE 'Truncating table: %', current_table;

	TRUNCATE bronze.erp_px_cat_g1v2;
	
	RAISE NOTICE 'Inserting data into table: %', current_table;

	COPY bronze.erp_px_cat_g1v2
	FROM 'C:/Users/2992529/Documents/dev_env/dwh-bootcamp/datasets/source_erp/PX_CAT_G1V2.csv'
	WITH (
		FORMAT CSV,
		HEADER,
		DELIMITER ','
	);

	end_time := CLOCK_TIMESTAMP();

	RAISE NOTICE 'Load into table % completed successfully in % second(s)', current_table, EXTRACT(EPOCH FROM (end_time - start_time));

	batch_end_time := CLOCK_TIMESTAMP();

	RAISE NOTICE '==============================================================';
	RAISE NOTICE 'Load Bronze Layer Completed Successfully in % Second(s)', EXTRACT(EPOCH FROM (batch_end_time - batch_start_time));
	RAISE NOTICE '==============================================================';

EXCEPTION
	WHEN OTHERS THEN RAISE EXCEPTION 'Load Bronze Layer Failed | Table: % | SQLSTATE: % | Error: %', current_table, SQLSTATE, SQLERRM;
END;
$$;

CALL bronze.load_bronze();