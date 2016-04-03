CREATE OR REPLACE PROCEDURE load_snapshot(v_source_table VARCHAR2)
AS
	
BEGIN
	--- first use:
	
	create_snapshot_table(v_source_table);
	create_hash_table(v_source_table);
	
	load_snapshot_data(v_source_table, SYSDATE);		-- loading data with given date
	load_hash_data(v_source_table);
	
END load_snapshot;






-- trzeba dodać jako argument datę ładowania
CREATE OR REPLACE PROCEDURE load_snapshot_data(v_source_table VARCHAR2, v_destination_table VARCHAR2)
AS
	v_rows_number NUMBER;
	e_bad_rows_number EXCEPTION;
	
BEGIN	

	EXECUTE IMMEDIATE
		'SELECT COUNT(*) INTO ' || v_rows_number || ' FROM ' || v_source_table;
	
	--INSERT INTO SH_PRODUCTS 
	--("T_DATESTAMP","PRODUCT_ID","ROOM_CLASS","PRODUCT_NAME","DESCRIPTION","PRICE","AVAILABLE") 
	--SELECT SYSDATE, PRODUCTS.* FROM PRODUCTS;
	
	-- EXECUTE IMMEDIATE
	DBMS_OUTPUT.PUT_LINE(
		'INSERT INTO ' 				|| v_destination_table || 
		' ( "T_DATESTAMP", ' 	|| get_all_cols_fnc(v_source_table) || ' ) ' ||
		' SELECT ' 						|| 'SYSDATE' || ',' || v_source_table || '.*' || ' FROM '  || v_source_table);

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

END load_snapshot_data;











CREATE OR REPLACE FUNCTION check_table_equity(v_source_table VARCHAR2, v_destination_table VARCHAR2) RETURN BOOLEAN
AS
	v_source_table_hash 			NUMBER;
	v_destination_table_hash 	NUMBER;

BEGIN	
	
	EXECUTE IMMEDIATE
		'SELECT ORA_HASH(SUM(ORA_HASH(CONCAT(get_all_cols_fnc(' || v_source_table || 
		'))))) FROM ' 	|| v_source_table || 
		' INTO ' 				|| v_source_table_hash;
	
	EXECUTE IMMEDIATE
		'SELECT ORA_HASH(SUM(ORA_HASH(CONCAT(get_all_cols_fnc(' || v_destination_table || 
		'))))) FROM ' 	|| v_destination_table || 
		' INTO ' 				|| v_destination_table_hash;
	
	IF v_source_table_hash = v_destination_table_hash THEN
		RETURN TRUE;			--- tables are equal
	ELSE
		RETURN FALSE;			--- tables are not equal
	END IF;
	
END;
























/*

CREATE OR REPLACE PROCEDURE load_hash_data(v_source_table VARCHAR2)
AS
BEGIN	
END load_hash_data;
*/
