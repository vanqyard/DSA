CREATE OR REPLACE PROCEDURE load_record(v_source_table VARCHAR2, v_destination_table VARCHAR2)
AS
	
	create_record_table(v_source_table, v_destination_table);
	load_record_data(v_source_table, v_destination_table);		-- loading data with given date

	--create_hash_table(v_source_table, v_destination_table);
	--load_hash_data(v_source_table, v_destination_table);



END load_record;




CREATE GLOBAL TEMPORARY TABLE ...
CREATE OR REPLACE PROCEDURE insert_row(v_source_table VARCHAR2)
AS
BEGIN
END;











/*
	-- check_if_destination_table_exists();
	-- check_if_hash_table_exists();
	
	FOR new_record IN 'SELECT * FROM ' || v_source_table || '_TEMPORARY'
	LOOP
		IF check_if_loaded(new_record, TRUNC(v_load_date)) = TRUE THEN
			CONTINUE;
		ELSE
			INSERT
		END IF;
	END LOOP;
	
*/
CREATE OR REPLACE PROCEDURE load_snapshot_data(v_source_table VARCHAR2, v_destination_table VARCHAR2, v_temporary_table VARCHAR2, v_load_date DATE)
AS
	query_str VARCHAR2(1000);
	item_hash NUMBER(20);
	TYPE cur_typ IS REF CURSOR;
  c cur_typ;
    
BEGIN	
	query_str := 'SELECT ORA_HASH( ' || v_source_table || '.* ) ' || FROM || v_temporary_table;
	
	OPEN c FOR query_str
	LOOP
		FETCH c INTO item_hash;
		EXIT WHEN c%NOTFOUND;
		
		IF check_if_loaded(item_hash) = TRUE THEN
		
			-- delete row in v_temporary_table
			--EXECUTE IMMEDIATE
			-- 
			
			-- PAMIĘTAĆ O DZIENNYM WERSJONOWANIU !!!
			
			CONTINUE;
		
		ELSE
			
			-- There has to be function index on each table holding counted ORA_HASH function results !!!
			
			-- - T_ENDDATE DATE (koniec obowiązywania wersji), 
			-- - T_STATUS NUMBER(1) (2-rekord usunięty, 0-rekord dostępny). 
			--
			-- invalidate previous row (do not delete!)
			EXECUTE IMMEDIATE
				'UPDATE ' || v_destination_table  ||
				' SET 	'	|| T_ENDDATE || ' = ' 	|| v_load_date || ' , T_STATUS = 2' || 
				' WHERE ' || ' ORA_HASH ( '				|| get_all_cols_fnc(v_source_table) || ' ) = ' item_hash ;
			
			-- - T_STARTDATE DATE (początek obowiązywania wersji), 
			-- - T_STATUS NUMBER(1) (2-rekord usunięty, 0-rekord dostępny). 
			--
			-- insert new row
			EXECUTE IMMEDIATE
				'INSERT INTO '  	|| v_source_table || '( ' || get_all_cols_fnc(v_source_table) || ', T_STARTDATE, T_ENDDATE, T_STATUS)' ||
			 	' VALUES ' || '('	|| v_source_table || '.*' || ',' || TRUNC(v_load_date) || ', NULL,  0)'



			-- delete row in v_temporary_table
			--EXECUTE IMMEDIATE
			--	'DELETE ' ||
			--	' FROM '	||
			--	' WHERE '	||
			--

		END IF;
		
	END LOOP;
	CLOSE c;



END load_snapshot_data;















CREATE OR REPLACE PROCEDURE create_hash_table(v_source_table VARCHAR2, v_destination_table VARCHAR2)
AS
BEGIN
	--- np. CREATE TABLE hash_products (hash_value	NUMBER(20));
	EXECUTE IMMEDIATE 
		'CREATE TABLE ' || 'hash_' || v_source_table || ' (' || 
						CHR(10) || 'hash_value	NUMBER(20)'  || 
						CHR(10) || ')' ;
	
END create_hash_table;








CREATE OR REPLACE PROCEDURE load_hash_data(v_source_table VARCHAR2, v_hash_table VARCHAR2)
AS
BEGIN	
	EXECUTE IMMEDIATE
		'INSERT INTO ' || v_hash_table || 
		' ( ' 				 || get_all_cols_fnc(v_source_table) 	|| ' ) ' ||
		' SELECT ORA_HASH(SUM(ORA_HASH(' 
									|| v_source_table || '.*' || 
		' ))) FROM '  || v_source_table ;

END load_hash_data;




