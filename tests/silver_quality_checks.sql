/*
=================================================================================
OBJETIVO
    Validar a qualidade e consistência dos dados da camada Bronze antes de sua
	 transformação e carga na camada Silver.

ETAPAS
    1. Verifica chaves duplicadas, nulas e relacionamentos entre tabelas.
    2. Identifica espaços indesejados e valores não padronizados.
    3. Valida a integridade de campos numéricos e datas.
    4. Verifica regras de negócio relacionadas a vendas.
    5. Analisa a consistência entre dados provenientes dos sistemas CRM e ERP.
    6. Identifica inconsistências que devem ser tratadas na camada Silver.

AVISO
    Este script é destinado apenas à validação e diagnóstico dos dados.
    As consultas não alteram os dados armazenados nas tabelas.
=================================================================================
*/

-- Tabela bronze.crm_cst_info

-- Verificar valores duplicados ou nulos na chave primária
SELECT	 cst_id,
		 COUNT(*)
FROM	 bronze.crm_cust_info
GROUP BY cst_id
HAVING 	 COUNT(*) > 1
	OR	 cst_id IS NULL;

SELECT 	 cst_key,
		 COUNT(*)
FROM	 bronze.crm_cust_info
GROUP BY cst_key
HAVING 	 COUNT(*) > 1
	OR	 cst_key IS NULL;

-- Verificar espaços indesejados nos campos de texto
SELECT	cst_firstname
FROM 	bronze.crm_cust_info
WHERE 	cst_firstname <> TRIM(cst_firstname);

SELECT	cst_lastname
FROM 	bronze.crm_cust_info
WHERE 	cst_lastname <> TRIM(cst_lastname);

SELECT	cst_marital_status
FROM 	bronze.crm_cust_info
WHERE 	cst_marital_status <> TRIM(cst_marital_status);

SELECT	cst_gndr
FROM 	bronze.crm_cust_info
WHERE 	cst_gndr <> TRIM(cst_gndr);

-- Verificar padronização e consistência dos dados
SELECT 	DISTINCT cst_gndr
FROM 	bronze.crm_cust_info;

SELECT 	DISTINCT cst_marital_status
FROM 	bronze.crm_cust_info;

-- Tabela bronze.crm_prd_info

-- Verificar valores duplicados ou nulos na chave primária
SELECT	 prd_id,
		 COUNT(*)
FROM 	 bronze.crm_prd_info
GROUP BY prd_id
HAVING 	 COUNT(*) > 1
	OR 	 prd_id IS NULL;

-- Extrair de bronze.crm_prd_info.prd_key o ID da categoria e a Chave do Produto
SELECT	prd_key,
		REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
		SUBSTRING(prd_key, 7, LENGTH(prd_key))      AS prd_key
FROM 	bronze.crm_prd_info;

-- Verificar espaços indesejados nos campos de texto
SELECT 	prd_nm
FROM	bronze.crm_prd_info
WHERE	prd_nm <> TRIM(prd_nm);

SELECT	prd_line
FROM 	bronze.crm_prd_info
WHERE	prd_line <> TRIM(prd_line);

-- Verificar integridade dos campos numéricos
SELECT	prd_cost
FROM 	bronze.crm_prd_info
WHERE	prd_cost IS NULL
	OR	prd_cost < 0;

-- Verificar padronização e consistência dos dados
SELECT 	DISTINCT prd_line
FROM 	bronze.crm_prd_info;

-- Verificar integridade dos campos de data
SELECT	prd_start_dt,
		prd_end_dt
FROM 	bronze.crm_prd_info
WHERE 	prd_end_dt < prd_start_dt;

-- Tabela bronze.crm_sales_details

-- Verificar espaços indesejados nos campos de texto
SELECT 	sls_ord_num
FROM 	bronze.crm_sales_details
WHERE 	sls_ord_num <> TRIM(sls_ord_num);

-- Verificar relacionamento entre as tabelas
SELECT 	*
FROM 	bronze.crm_sales_details
WHERE	sls_prd_key NOT IN (SELECT prd_key FROM silver.crm_prd_info);

SELECT	*
FROM 	bronze.crm_sales_details
WHERE 	sls_cust_id NOT IN (SELECT cst_id FROM silver.crm_cust_info);

-- Verificar integridade dos campos de data
SELECT	sls_order_dt
FROM 	bronze.crm_sales_details
WHERE 	sls_order_dt <= 0
	OR 	LENGTH(CAST(sls_order_dt AS TEXT)) <> 8
	OR 	sls_order_dt > 20500101
	OR 	sls_order_dt < 19700101;

SELECT 	sls_ship_dt
FROM 	bronze.crm_sales_details
WHERE 	sls_ship_dt <= 0
	OR	LENGTH(CAST(sls_ship_dt AS TEXT)) <> 8
	OR 	sls_ship_dt > 20500101
	OR 	sls_ship_dt < 19700101;

SELECT	sls_due_dt
FROM	bronze.crm_sales_details
WHERE	sls_due_dt <= 0
	OR	LENGTH(CAST(sls_due_dt AS TEXT)) <> 8
	OR 	sls_due_dt > 20500101
	OR	sls_due_dt < 19700101;

SELECT 	*
FROM	bronze.crm_sales_details
WHERE 	sls_order_dt > sls_ship_dt 
	OR 	sls_order_dt > sls_due_dt;

-- Verificar a seguinte consitência nos dados: sls_sales = sls_quantity * sls_price
SELECT	 sls_sales,
		 sls_quantity,
		 sls_price
FROM	 bronze.crm_sales_details
WHERE 	 sls_sales <> sls_quantity * sls_price
   	OR 	 sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
	OR	 sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
ORDER BY 1, 2, 3;

-- Tabela bronze.erp_cust_az12

-- Verificar relacionamento entre as tabelas
SELECT	*
FROM	silver.crm_cust_info
WHERE 	cst_key NOT IN (
	SELECT
	CASE
		WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LENGTH(cid))
		ELSE cid
	END AS cid
FROM	bronze.erp_cust_az12);

-- Verificar integridade dos campos de data
SELECT	 *
FROM	 bronze.erp_cust_az12
WHERE	 bdate < '1926-01-01'
	OR 	 bdate > CURRENT_DATE
ORDER BY bdate;

-- Verificar padronização e consistência dos dados
SELECT 	DISTINCT gen
FROM 	bronze.erp_cust_az12;

-- Tabela bronze.erp_loc_a101

-- Verificar relacionamento entre as tabelas
SELECT  cid
FROM	bronze.erp_loc_a101
WHERE 	REPLACE(cid, '-', '') NOT IN (
	SELECT cst_key FROM silver.crm_cust_info);

-- Verificar padronização e consistência dos dados
SELECT 	 DISTINCT cntry
FROM	 bronze.erp_loc_a101
ORDER BY 1;

-- Tabela bronze.erp_px_cat_g1v2

-- Verificar relacionamento entre as tabelas
SELECT	*
FROM	bronze.erp_px_cat_g1v2
WHERE	id NOT IN (SELECT cat_id FROM silver.crm_prd_info);

SELECT	*
FROM 	silver.crm_prd_info
WHERE	cat_id NOT IN (SELECT id FROM bronze.erp_px_cat_g1v2);

SELECT	*
FROM	bronze.erp_px_cat_g1v2 
WHERE 	id LIKE 'CO_P%';

SELECT	*
FROM	silver.crm_prd_info
WHERE 	cat_id LIKE 'CO_P%';

WITH cte AS (
	SELECT	CASE 
				WHEN id = 'CO_PD' THEN 'CO_PE'
				ELSE id
			END AS id,
			cat,
			subcat,
			maintenance
	FROM	bronze.erp_px_cat_g1v2
)
SELECT 	*
FROM 	cte
WHERE 	id NOT IN (SELECT cat_id FROM silver.crm_prd_info);

-- Verificar espaços indesejados nos campos de texto
SELECT	*
FROM	bronze.erp_px_cat_g1v2
WHERE	cat <> TRIM(cat)
	OR	subcat <> TRIM(subcat)
	OR	maintenance <> TRIM(maintenance);

-- Verificar padronização e consistência dos dados
SELECT	DISTINCT cat
FROM	bronze.erp_px_cat_g1v2;

SELECT	DISTINCT cat,
				 subcat
FROM	bronze.erp_px_cat_g1v2
ORDER BY 1, 2;

SELECT	DISTINCT maintenance
FROM	bronze.erp_px_cat_g1v2;