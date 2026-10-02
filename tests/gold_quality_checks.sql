/*
=================================================================================
OBJETIVO
    Validar a qualidade, integração e integridade dos dados disponibilizados
    na camada Gold.

ETAPAS
    1. Valida a integração dos dados utilizados na dimensão de clientes.
    2. Verifica duplicidades e consistência dos dados de gênero.
    3. Valida a integração e possíveis duplicidades na dimensão de produtos.
    4. Verifica a integração das vendas com as dimensões de clientes e produtos.
    5. Valida a integridade referencial entre a tabela fato e suas dimensões.

AVISO
    Este script é destinado apenas à validação e diagnóstico dos dados.
    As consultas não alteram os dados armazenados ou as views da camada Gold.
=================================================================================
*/

-- Tabela gold.dim_customers

-- Verificar a integração entre as tabelas de cliente
SELECT	  cci.cst_id,
		  cci.cst_key,
		  cci.cst_firstname,
		  cci.cst_lastname,
		  cci.cst_marital_status,
		  cci.cst_gndr,
		  cci.cst_create_date,
		  eca.bdate,
		  eca.gen,
		  ela.cntry
FROM	  silver.crm_cust_info cci
LEFT JOIN silver.erp_cust_az12 eca
ON	      cci.cst_key = eca.cid
LEFT JOIN silver.erp_loc_a101 ela 
ON	      cci.cst_key = ela.cid;

-- Verificar registros duplicados após integração
SELECT	 cst_id,
		 COUNT(*)
FROM	(
	SELECT	  cci.cst_id,
			  cci.cst_key,
			  cci.cst_firstname,
			  cci.cst_lastname,
			  cci.cst_marital_status,
			  cci.cst_gndr,
			  cci.cst_create_date,
			  eca.bdate,
			  eca.gen,
			  ela.cntry
	FROM	  silver.crm_cust_info cci
	LEFT JOIN silver.erp_cust_az12 eca
	ON	      cci.cst_key = eca.cid
	LEFT JOIN silver.erp_loc_a101 ela 
	ON	      cci.cst_key = ela.cid
)t
GROUP BY cst_id
HAVING 	 COUNT(*) > 1;

-- Verificar divergências dos campos de gênero
SELECT DISTINCT cci.cst_gndr,
			    eca.gen
FROM	  		silver.crm_cust_info cci
LEFT JOIN 		silver.erp_cust_az12 eca
ON	      		cci.cst_key = eca.cid
LEFT JOIN 		silver.erp_loc_a101 ela 
ON	      		cci.cst_key = ela.cid;

-- Verificar qualidade de gold.dim_customer
SELECT DISTINCT gender FROM gold.dim_customers;

-- Tabela gold.dim_products

-- Verificar a integração entre as tabelas de produto
SELECT	  ROW_NUMBER() OVER(ORDER BY cpi.prd_start_dt, cpi.prd_id) AS product_key,
		  cpi.prd_id                                               AS product_id,
		  cpi.prd_key                                              AS product_number,
		  cpi.prd_nm                                               AS product_name,
		  cpi.prd_line                                             AS product_line,
		  cpi.cat_id                                               AS category_id,
		  epcgv.cat                                                AS category,
		  epcgv.subcat                                             AS subcategory,
		  epcgv.maintenance,
		  cpi.prd_cost                                             AS cost,
		  cpi.prd_start_dt                                         AS start_date
FROM 	  silver.crm_prd_info cpi
LEFT JOIN silver.erp_px_cat_g1v2 epcgv
ON		  cpi.cat_id = epcgv.id
WHERE	  cpi.prd_end_dt IS NULL
ORDER BY  cpi.prd_start_dt, cpi.prd_id;

-- Verificar registros duplicados após integração
SELECT	 t.prd_key,
		 COUNT(*)
FROM (
	SELECT 	ROW_NUMBER() OVER(ORDER BY cpi.prd_start_dt, cpi.prd_id) AS product_key,
			cpi.prd_id,
			cpi.prd_key,
			cpi.prd_nm,
			cpi.cat_id,
			epcgv.cat,
			epcgv.subcat,
			epcgv.maintenance,
			cpi.prd_cost,
			cpi.prd_start_dt
	FROM 	silver.crm_prd_info cpi
	LEFT JOIN silver.erp_px_cat_g1v2 epcgv
	ON cpi.cat_id = epcgv.id
	WHERE 	cpi.prd_end_dt IS NULL
	ORDER BY cpi.prd_start_dt, cpi.prd_id
)t
GROUP BY t.prd_key
HAVING	 COUNT(*) > 1;

-- Tabela gold.fact_sales

-- Verificar a integração entre as tabelas de vendas
SELECT	  csd.sls_ord_num  AS order_number,
		  dp.product_key,
		  dc.customer_key,
		  csd.sls_order_dt AS order_date,
		  csd.sls_ship_dt  AS shipping_date,
		  csd.sls_due_dt   AS due_date,
		  csd.sls_sales    AS sales_amount,
		  csd.sls_quantity AS quantity,
		  csd.sls_price    AS price
FROM	  silver.crm_sales_details csd
LEFT JOIN gold.dim_customers dc
ON		  csd.sls_cust_id = dc.customer_id
LEFT JOIN gold.dim_products dp
ON 		  csd.sls_prd_key = dp.product_number
ORDER BY  csd.sls_order_dt, csd.sls_ship_dt, csd.sls_due_dt;

-- Verificar integridade referêncial entre a tabela fato e as tabelas dimensão
SELECT	  *
FROM	  gold.fact_sales fs
LEFT JOIN gold.dim_products dp
ON 		  fs.product_key = dp.product_key
WHERE 	  dp.product_key IS NULL;

SELECT	  *
FROM	  gold.fact_sales fs
LEFT JOIN gold.dim_customers dc
ON 		  fs.customer_key = dc.customer_key
WHERE 	  dc.customer_key IS NULL;