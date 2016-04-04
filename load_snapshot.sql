CREATE OR REPLACE PROCEDURE load_snapshot(v_source_table VARCHAR2, v_destination_table VARCHAR2)
AS
	
BEGIN
	--- first use:
	
	create_snapshot_table(v_source_table, v_destination_table);
	load_snapshot_data(v_source_table, v_destination_table);		-- loading data with given date
	
END load_snapshot;




/*
	IF ora_hash(v_source_table) = ora_hash(v_destination_table) THEN
		-- Tables are equal, no need for update.
		-- Updating only T_DATESTAMP value
	ELSE
		-- Delete whole previous content of snapshot
		-- Load content based on source table
	END IF;
	
*/
-- trzeba dodać jako argument datę ładowania
CREATE OR REPLACE PROCEDURE load_snapshot_data(v_source_table VARCHAR2, v_destination_table VARCHAR2)
AS
	v_rows_number NUMBER;
	e_bad_rows_number EXCEPTION;
	
BEGIN	

	IF check_table_equity(v_source_table, v_destination_table) = TRUE THEN
		write_log(3003, 'INFO: The snapshot of table ' || v_source_table || ' is up to date. No need for update.');
		
	ELSE

		EXECUTE IMMEDIATE
			'DELETE * FROM ' || v_source_table

		EXECUTE IMMEDIATE
			'SELECT COUNT(*) INTO ' || v_rows_number || ' FROM ' || v_source_table;
		
		--INSERT INTO SH_PRODUCTS 
		--("T_DATESTAMP","PRODUCT_ID","ROOM_CLASS","PRODUCT_NAME","DESCRIPTION","PRICE","AVAILABLE") 
		--SELECT SYSDATE, PRODUCTS.* FROM PRODUCTS;
		
		EXECUTE IMMEDIATE
			'INSERT INTO ' 				|| v_destination_table || 
			' ( "T_DATESTAMP", ' 	|| get_all_cols_fnc(v_source_table) || ' ) ' ||
			' SELECT ' 						|| 'SYSDATE' || ',' || v_source_table || '.*' || ' FROM '  || v_source_table ;

		IF v_rows_number = SQL%ROWCOUNT THEN
			write_log(3000, 'INFO: The table has been successfully loaded with: ' || SQL%ROWCOUNT || ' rows.');
		ELSE
			RAISE e_bad_rows_number;
		END IF;
		
		EXCEPTION
			WHEN e_bad_rows_number THEN
				write_log(3001, 'ERR: Corrupted data insert - ' || v_rows_number || ' rows to insert, but ' || SQL%ROWCOUNT || ' inserted.');
			WHEN OTHERS THEN
				write_log(3002, 'ERR: Unknown error.');

	END IF;

END load_snapshot_data;









CREATE OR REPLACE FUNCTION check_table_equity(v_source_table VARCHAR2, v_destination_table VARCHAR2) RETURN BOOLEAN
AS
	v_source_table_hash 			NUMBER;
	v_destination_table_hash 	NUMBER;
	v_source_columns					VARCHAR2(1000);
  v_destination_columns			VARCHAR2(1000);
  
BEGIN	

	SELECT 
	REGEXP_REPLACE(
	REGEXP_REPLACE(
		get_all_cols_fnc(v_source_table)
		, ','
		, '||'
	) 
		, '"T_DATESTAMP",'
		, ''
	)
	INTO v_source_columns
	FROM DUAL;
	
  SELECT 
  REGEXP_REPLACE(
  REGEXP_REPLACE(
		get_all_cols_fnc(v_destination_table)
		, ','
		, '||'
	) 
		, '"T_DATESTAMP",'
		, ''
	)
	INTO v_destination_columns
	FROM DUAL;
  
	EXECUTE IMMEDIATE
		'SELECT ORA_HASH(SUM(ORA_HASH(' || v_source_columns || ')))' ||
    ' FROM ' 	|| v_source_table
		INTO v_source_table_hash;
	
	EXECUTE IMMEDIATE
		'SELECT ORA_HASH(SUM(ORA_HASH(' || v_destination_columns || '))) ' ||
    ' FROM ' 	|| v_destination_table 
		INTO v_destination_table_hash ;
	
	IF v_source_table_hash = v_destination_table_hash THEN
		RETURN TRUE;			--- tables are equal
	ELSE
		RETURN FALSE;			--- tables are not equal
	END IF;
	
END;
