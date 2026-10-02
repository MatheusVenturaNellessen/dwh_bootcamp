/*
=================================================================================
OBJETIVO
    Criar as tabelas da camada Bronze para armazenar os dados brutos
    provenientes dos sistemas CRM e ERP.

ETAPAS
    1. Remove as tabelas Bronze existentes, caso existam.
    2. Cria as tabelas de origem CRM:
       - crm_cust_info: informações de clientes.
       - crm_prd_info: informações de produtos.
       - crm_sales_details: detalhes de vendas.
    3. Cria as tabelas de origem ERP:
       - erp_loc_a101: informações de localização de clientes.
       - erp_px_cat_g1v2: categorias e subcategorias de produtos.
       - erp_cust_az12: informações complementares de clientes.

AVISO
    A execução remove as tabelas existentes e todos os dados armazenados nelas.
    Execute antes da carga da camada Bronze e utilize com cautela.
=================================================================================
*/

-- Tabela bronze.crm_cust_info
DROP TABLE IF EXISTS bronze.crm_cust_info;
CREATE TABLE bronze.crm_cust_info (
	cst_id             INT,
	cst_key            VARCHAR(50),
	cst_firstname      VARCHAR(50),
	cst_lastname       VARCHAR(50),
	cst_marital_status VARCHAR(50),
	cst_gndr           VARCHAR(50),
	cst_create_date    DATE
);

-- Tabela bronze.crm_prd_info
DROP TABLE IF EXISTS bronze.crm_prd_info;
CREATE TABLE bronze.crm_prd_info (
	prd_id       INT,
	prd_key      VARCHAR(50),
	prd_nm       VARCHAR(50),
	prd_cost     INT,
	prd_line     VARCHAR(50),
	prd_start_dt DATE,
	prd_end_dt   DATE
);

-- Tabela bronze.crm_sales_details
DROP TABLE IF EXISTS bronze.crm_sales_details;
CREATE TABLE bronze.crm_sales_details (
	sls_ord_num  VARCHAR(50),
	sls_prd_key  VARCHAR(50),
	sls_cust_id  INT,
	sls_order_dt INT,
	sls_ship_dt  INT,
	sls_due_dt   INT,
	sls_sales    INT,
	sls_quantity INT,
	sls_price    INT
);

-- Tabela bronze.erp_loc_a101
DROP TABLE IF EXISTS bronze.erp_loc_a101;
CREATE TABLE bronze.erp_loc_a101 (
	cid   VARCHAR(50),
	cntry VARCHAR(50)
);

-- Tabela bronze.erp_px_cat_g1v2
DROP TABLE IF EXISTS bronze.erp_px_cat_g1v2;
CREATE TABLE bronze.erp_px_cat_g1v2 (
	id          VARCHAR(50),
	cat         VARCHAR(50),
	subcat      VARCHAR(50),
	maintenance VARCHAR(50)
);

-- Tabela bronze.erp_cust_az12
DROP TABLE IF EXISTS bronze.erp_cust_az12;
CREATE TABLE bronze.erp_cust_az12 (
	cid   VARCHAR(50),
	bdate DATE,
	gen   VARCHAR(50)
);