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

BEGIN	
	
	--INSERT INTO SH_PRODUCTS 
	--("T_DATESTAMP","PRODUCT_ID","ROOM_CLASS","PRODUCT_NAME","DESCRIPTION","PRICE","AVAILABLE") 
	--SELECT SYSDATE, PRODUCTS.* FROM PRODUCTS;
	
	-- IMMEDIATE
	DBMS_OUTPUT.PUT_LINE(
		'INSERT INTO ' 				|| v_destination_table || 
		' ( "T_DATESTAMP", ' 	|| get_all_cols_fnc(v_source_table) || ' ) ' ||
		' AS SELECT ' 				|| 'SYSDATE' || ',' || v_source_table || '.*' || ' FROM '  || v_source_table);

END load_snapshot_data;







































CREATE OR REPLACE PROCEDURE load_hash_data(v_source_table VARCHAR2)
AS
BEGIN	
END load_hash_data;
