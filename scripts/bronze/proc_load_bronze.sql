/*
=========================================================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
=========================================================================================================
Purpose:
    This stored procedure loads data into the 'bronze' schema from external CSV files. 
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the `BULK INSERT` command to load data from csv Files to bronze tables.

Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC bronze.load_bronze;

Important:
    - The path used in this scripts are for MAC users (Using Docker for SQL Server)
    - So try to move all the files to the docker container and then use this file path for BULK INSERT.
=========================================================================================================
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @start_batch_time DATETIME, @end_batch_time DATETIME;
    BEGIN TRY
        SET @start_batch_time = GETDATE();
        PRINT '=================================================';
        PRINT 'LOADING THE BRONZE LAYER';
        PRINT '=================================================';

        PRINT '-------------------------------------------------';
        PRINT 'Loading the CRM Tables:';
        PRINT '-------------------------------------------------';

        SET @start_time = GETDATE();
        PRINT '>> Truncating the table: bronze.crm_cust_info';
        TRUNCATE TABLE bronze.crm_cust_info;

        PRINT '>> Inserting the data into the table: bronze.crm_cust_info';
        BULK INSERT bronze.crm_cust_info
        FROM '/var/opt/mssql/data/cust_info.csv'  -- Docker Container Path for the files
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
        PRINT '>>>--------------------------------------------------------------';


        SET @start_time = GETDATE();
        PRINT '>> Truncating the table: bronze.crm_prd_info';
        TRUNCATE TABLE bronze.crm_prd_info;
        PRINT '>> Inserting the data into the table: bronze.crm_prd_info';
        BULK INSERT bronze.crm_prd_info
        FROM '/var/opt/mssql/data/prd_info.csv'  -- Docker Container Path for the files
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
        PRINT '>>>--------------------------------------------------------------';

        SET @start_time = GETDATE();
        PRINT '>> Truncating the table: bronze.crm_sales_details';
        TRUNCATE TABLE bronze.crm_sales_details;
        PRINT '>> Inserting the data into the table: bronze.crm_sales_details';
        BULK INSERT bronze.crm_sales_details
        FROM '/var/opt/mssql/data/sales_details.csv'  -- Docker Container Path for the files
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
        PRINT '>>>--------------------------------------------------------------';


        PRINT '-------------------------------------------------';
        PRINT 'Loading the ERP Tables:';
        PRINT '-------------------------------------------------';

        SET @start_time = GETDATE();
        PRINT '>> Truncating the table: bronze.erp_cust_az12 ';
        TRUNCATE TABLE bronze.erp_cust_az12;
        PRINT '>> Inserting the data into the table: bronze.erp_cust_az12 ';
        BULK INSERT bronze.erp_cust_az12
        FROM '/var/opt/mssql/data/CUST_AZ12.csv'  -- Docker Container Path for the files
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
        PRINT '>>>--------------------------------------------------------------';

        SET @start_time = GETDATE();
        PRINT '>> Truncating the table: bronze.erp_loc_a101 ';
        TRUNCATE TABLE bronze.erp_loc_a101;
        PRINT '>> Inserting the data into the table: bronze.erp_loc_a101';
        BULK INSERT bronze.erp_loc_a101
        FROM '/var/opt/mssql/data/LOC_A101.csv'  -- Docker Container Path for the files
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
        PRINT '>>>--------------------------------------------------------------';

        SET @start_time = GETDATE()
        PRINT '>> Truncating the table: bronze.erp_px_cat_g1v2';
        TRUNCATE TABLE bronze.erp_px_cat_g1v2;
        PRINT '>> Inserting the data into the table: bronze.erp_px_cat_g1v2';
        BULK INSERT bronze.erp_px_cat_g1v2
        FROM '/var/opt/mssql/data/PX_CAT_G1V2.csv'  -- Docker Container Path for the files
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
        PRINT '>>>--------------------------------------------------------------';
        SET @end_batch_time = GETDATE();
        PRINT '=================================================';
        PRINT 'Loading Bronze Layer Completed in ' + CAST(DATEDIFF(second,@start_batch_time,@end_batch_time) AS NVARCHAR) + ' seconds!!!!'
        PRINT '=================================================';

    END TRY
    BEGIN CATCH
        PRINT '===============================================';
        PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER';
        PRINT 'Error Message:' + ERROR_MESSAGE();
        PRINT 'Error Message:' + CAST( ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error Message:' + CAST( ERROR_STATE() AS NVARCHAR);
        PRINT '===============================================';
    END CATCH

END
-- USE 'EXEC bronze.load_bronze' (to run the Stored Procedure.)
