/*
=========================================================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
=========================================================================================================
Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to 
    populate the 'silver' schema tables from the 'bronze' schema.
	Actions Performed:
		- Truncates Silver tables.
		- Inserts transformed and cleansed data from Bronze into Silver tables.

Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC silver.load_silver;

Important:
    - The path used in this scripts are for MAC users (Using Docker for SQL Server)
=========================================================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @start_batch_time DATETIME, @end_batch_time DATETIME;
    BEGIN TRY
        SET @start_batch_time = GETDATE();
        PRINT '=================================================';
        PRINT 'LOADING THE SILVER LAYER';
        PRINT '=================================================';

        PRINT '-------------------------------------------------';
        PRINT 'Transforming & Loading the CRM Tables:';
        PRINT '-------------------------------------------------';

        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: silver.crm_cust_info'
        TRUNCATE TABLE silver.crm_cust_info;
        PRINT '>> Inserting Cleaned Data: silver.crm_cust_info'
        INSERT INTO silver.crm_cust_info(
            cst_id,
            cst_key,
            cst_firstname,
            cst_lastname,
            cst_marital_status,
            cst_gndr,
            cst_create_date
        )
        SELECT 
        cst_id,
        cst_key,
        TRIM(cst_firstname) AS cst_firstname,
        TRIM(cst_lastname) AS cst_lastname,
        CASE UPPER(TRIM(cst_marital_status)) 
            WHEN 'S' THEN 'Single'
            WHEN 'M' THEN 'Married'
            ELSE 'n/a'
        END cst_marital_status,
        CASE UPPER(TRIM(cst_gndr))
            WHEN 'F' THEN 'Female'
            WHEN 'M' THEN 'Male'
            ELSE 'n/a'
        END cst_gndr,
        cst_create_date
        FROM(SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
        FROM bronze.crm_cust_info
        WHERE cst_id IS NOT NULL
        )t WHERE flag_last = 1;
        SET @end_time = GETDATE();
        PRINT '>> Transform & Load Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
        PRINT '>>>--------------------------------------------------------------';

        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: silver.crm_prd_info'
        TRUNCATE TABLE silver.crm_prd_info;
        PRINT '>> Inserting Cleaned Data: silver.crm_prd_info'
        INSERT INTO silver.crm_prd_info(
            prd_id,
            cat_id,
            prd_key,
            prd_nm,
            prd_cost,
            prd_line,
            prd_start_dt,
            prd_end_dt
        )
        SELECT 
        prd_id,
        REPLACE(SUBSTRING(prd_key,1,5),'-','_') AS cat_id,
        SUBSTRING(prd_key,7,LEN(prd_key)) AS prd_key,
        prd_nm,
        ISNULL(prd_cost,0) AS prd_cost,
        CASE UPPER(TRIM(prd_line)) 
            WHEN 'M' THEN 'Mountain'
            WHEN 'R' THEN 'Road'
            WHEN 'S' THEN 'Other Sales'
            WHEN 'T' THEN 'Touring'
            ELSE 'n/a'
        END AS prd_line,
        CAST(prd_start_dt AS DATE) AS prd_start_dt,
        CAST(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS DATE) AS prd_end_dt
        FROM bronze.crm_prd_info;
        SET @end_time = GETDATE();
        PRINT '>> Transform & Load Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
        PRINT '>>>--------------------------------------------------------------';

        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: silver.crm_sales_details'
        TRUNCATE TABLE silver.crm_sales_details;
        PRINT '>> Inserting Cleaned Data: silver.crm_sales_details'
        INSERT INTO silver.crm_sales_details(
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            sls_order_dt,
            sls_ship_dt,
            sls_due_dt,
            sls_sales,
            sls_quantity,
            sls_price
        )
        SELECT 
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
            ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
        END AS sls_order_dt,
        CASE WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
            ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
        END AS sls_ship_dt,
        CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
            ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
        END AS sls_due_dt,
        CASE WHEN sls_sales IS NULL OR sls_sales <=0 OR sls_sales != sls_quantity * ABS(sls_price)
            THEN sls_quantity * ABS(sls_price)
            ELSE sls_sales
        END AS sls_sales,
        sls_quantity,
        CASE WHEN sls_price IS NULL OR sls_price <= 0 
            THEN sls_sales/sls_quantity
            ELSE sls_price
        END AS sls_price
        FROM bronze.crm_sales_details;
        SET @end_time = GETDATE();
        PRINT '>> Transform & Load Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
        PRINT '>>>--------------------------------------------------------------';


        PRINT '-------------------------------------------------';
        PRINT 'Loading the ERP Tables:';
        PRINT '-------------------------------------------------';

        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: silver.erp_cust_az12'
        TRUNCATE TABLE silver.erp_cust_az12;
        PRINT '>> Inserting Cleaned Data: silver.erp_cust_az12'
        INSERT INTO silver.erp_cust_az12(
            cid,
            bdate,
            gen
        )
        SELECT 
        CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4,LEN(cid))
            ELSE cid
        END AS cid,
        CASE WHEN bdate > GETDATE() THEN NULL
            ELSE bdate
        END AS bdate,
        CASE 
            WHEN UPPER(TRIM(REPLACE(REPLACE(gen, CHAR(10), ''), CHAR(13), ''))) IN ('FEMALE', 'F') THEN 'Female'
            WHEN UPPER(TRIM(REPLACE(REPLACE(gen, CHAR(10), ''), CHAR(13), ''))) IN ('MALE', 'M') THEN 'Male'
            ELSE 'n/a'
        END AS gen
        FROM bronze.erp_cust_az12;
        SET @end_time = GETDATE();
        PRINT '>> Transform & Load Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
        PRINT '>>>--------------------------------------------------------------';

        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: silver.erp_loc_a101'
        TRUNCATE TABLE silver.erp_loc_a101;
        PRINT '>> Inserting Cleaned Data: silver.erp_loc_a101'
        INSERT INTO silver.erp_loc_a101(
            cid,
            cntry
        )
        SELECT
        REPLACE(cid,'-','') AS cid,
        CASE 
            WHEN UPPER(TRIM(REPLACE(REPLACE(cntry, CHAR(10), ''), CHAR(13), ''))) IN ('USA', 'US', 'UNITED STATES') 
            THEN 'United States of America'
            WHEN UPPER(TRIM(REPLACE(REPLACE(cntry, CHAR(10), ''), CHAR(13), ''))) = 'UNITED KINGDOM' 
            THEN 'United Kingdom'
            WHEN UPPER(TRIM(REPLACE(REPLACE(cntry, CHAR(10), ''), CHAR(13), ''))) = 'CANADA' 
            THEN 'Canada'
            WHEN UPPER(TRIM(REPLACE(REPLACE(cntry, CHAR(10), ''), CHAR(13), ''))) IN ('GERMANY', 'DE') 
            THEN 'Germany'
            WHEN UPPER(TRIM(REPLACE(REPLACE(cntry, CHAR(10), ''), CHAR(13), ''))) = 'AUSTRALIA' 
            THEN 'Australia'
            WHEN UPPER(TRIM(REPLACE(REPLACE(cntry, CHAR(10), ''), CHAR(13), ''))) = 'FRANCE' 
            THEN 'France'
            ELSE 'n/a'
        END AS cntry
        FROM bronze.erp_loc_a101;
        SET @end_time = GETDATE();
        PRINT '>> Transform & Load Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
        PRINT '>>>--------------------------------------------------------------';

        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: silver.erp_px_cat_g1v2'
        TRUNCATE TABLE silver.erp_px_cat_g1v2;
        PRINT '>> Inserting Cleaned Data: silver.erp_px_cat_g1v2'
        INSERT INTO silver.erp_px_cat_g1v2(
            id,
            cat,
            subcat,
            maintenance
        )
        SELECT 
        TRIM(id) AS id,
        TRIM(cat) AS cat,
        TRIM(subcat) AS subcat,
        CASE WHEN UPPER(TRIM(REPLACE(REPLACE(maintenance, CHAR(10), ''), CHAR(13), ''))) = 'YES' 
            THEN 'Yes'
            ELSE 'No'
        END AS maintenance
        FROM bronze.erp_px_cat_g1v2; 
        SET @end_time = GETDATE();
        PRINT '>> Transform & Load Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
        PRINT '>>>--------------------------------------------------------------';
    
    END TRY
    BEGIN CATCH
        PRINT '===============================================';
        PRINT 'ERROR OCCURED DURING LOADING & TRANSFORMING SILVER LAYER';
        PRINT 'Error Message:' + ERROR_MESSAGE();
        PRINT 'Error Message:' + CAST( ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error Message:' + CAST( ERROR_STATE() AS NVARCHAR);
        PRINT '===============================================';
    END CATCH
END 

-- USE 'EXEC siver.load_silver' (to run the Stored Procedure.)
