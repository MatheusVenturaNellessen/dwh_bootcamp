/*
=================================================================================
OBJETIVO
    Criar as views da camada Gold para disponibilizar dados consolidados e 
	estruturados para análise e consumo de negócio.

ETAPAS
    1. Cria dim_customers integrando dados de clientes do CRM e ERP.
    2. Cria dim_products integrando produtos e categorias, mantendo apenas
       os registros atualmente ativos.
    3. Cria fact_sales relacionando as vendas às dimensões de clientes
       e produtos por meio de suas chaves.
    4. Organiza os dados em um modelo dimensional composto por dimensões
       de clientes e produtos e uma tabela fato de vendas.

AVISO
    As estruturas da camada Gold são views e dependem dos dados disponíveis
    e tratados nas tabelas da camada Silver.
=================================================================================
*/

-- Tabela gold.dim_customers
CREATE OR REPLACE VIEW gold.dim_customers
AS SELECT	ROW_NUMBER() OVER(ORDER BY cci.cst_id) AS customer_key,
		  	cci.cst_id                             AS customer_id,
		  	cci.cst_key                            AS customer_number,
		 	cci.cst_firstname                      AS first_name,
		  	cci.cst_lastname                       AS last_name,
		 	 CASE
		 	 	WHEN cci.cst_gndr <> 'n/a' THEN cci.cst_gndr
		 	 	ELSE COALESCE(eca.gen, 'n/a')
		 	 END                                    AS gender,
		 	 cci.cst_marital_status                 AS marital_status,
  		 	 ela.cntry                              AS country,
		 	 eca.bdate                              AS birthdate,
		 	 cci.cst_create_date                    AS create_date
FROM	 	 silver.crm_cust_info cci
LEFT JOIN	 silver.erp_cust_az12 eca
ON	     	 cci.cst_key = eca.cid
LEFT JOIN	 silver.erp_loc_a101 ela 
ON	     	 cci.cst_key = ela.cid
ORDER BY 	 cci.cst_id;

-- Tabela gold.dim_prodicts
CREATE OR REPLACE VIEW gold.dim_products
AS SELECT	ROW_NUMBER() OVER(ORDER BY cpi.prd_start_dt, cpi.prd_id) AS product_key,
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
FROM 	  	silver.crm_prd_info cpi
LEFT JOIN 	silver.erp_px_cat_g1v2 epcgv
ON		  	cpi.cat_id = epcgv.id
WHERE	  	cpi.prd_end_dt IS NULL
ORDER BY  	cpi.prd_start_dt, cpi.prd_id;

-- Tabela gold.fact_sales
CREATE OR REPLACE VIEW gold.fact_sales
AS SELECT	csd.sls_ord_num  AS order_number,
		  	dp.product_key,
		  	dc.customer_key,
		  	csd.sls_order_dt AS order_date,
		  	csd.sls_ship_dt  AS shipping_date,
		  	csd.sls_due_dt   AS due_date,
		  	csd.sls_sales    AS sales_amount,
		  	csd.sls_quantity AS quantity,
		  	csd.sls_price    AS price
FROM	 	 silver.crm_sales_details csd
LEFT JOIN 	gold.dim_customers dc
ON		  	csd.sls_cust_id = dc.customer_id
LEFT JOIN 	gold.dim_products dp
ON 		  	csd.sls_prd_key = dp.product_number
ORDER BY  	csd.sls_order_dt, csd.sls_ship_dt, csd.sls_due_dt;

