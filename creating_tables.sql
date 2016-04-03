------------------------------------------------------------------------
--- CHECK_TABLE_EXISTENCE_FNC
---
--- Function check_table_existence_fnc returns TRUE if the table of name 
--- given in argument exists and FALSE if such table does not exist
------------------------------------------------------------------------
FUNCTION check_table_existence_fnc(v_table_name IN VARCHAR2)
	RETURN BOOLEAN 
	IS
	v_table_count NUMBER;

BEGIN
	
	-- Retreive number of tables with 
	-- given name and write the value
	-- to v_table_count variable
	SELECT COUNT(*) 
	INTO v_table_count
	FROM ALL_TABLES 
	WHERE UPPER(table_name) = v_table_name;
	
	IF v_table_count = 1 THEN
		DBMS_OUTPUT.PUT_LINE('Reqired table found !');	
		RETURN TRUE;
	ELSE
		DBMS_OUTPUT.PUT_LINE('Reqired table NOT found !');	
		RETURN FALSE;
	END IF;

END check_table_existence_fnc;



CREATE OR REPLACE PROCEDURE create_snapshot(v_source_table VARCHAR2, v_object_name VARCHAR2)
AS
	v_pk_name 				VARCHAR2(1000);
	v_businness_key 	VARCHAR2(1000);
	v_table_cols 			VARCHAR2(1000);

BEGIN
	
	SELECT 
		REGEXP_REPLACE(
		REGEXP_SUBSTR(
				(SELECT DBMS_METADATA.GET_DDL('TABLE', v_source_table) FROM DUAL)
			, '\((.*?),(\W)*CONSTRAINT', 1, 1, 'nm', 1)
			, '\).*,', '),'
		)
		INTO v_table_cols
    FROM DUAL;

	EXECUTE IMMEDIATE 
		'CREATE TYPE ' || v_object_name || ' UNDER ' || 'MIGAWKA_TYP (' || 
					 CHR(10) || v_table_cols || 
					 CHR(10) || ')' ;

	v_pk_name := 'pk_' || v_destination_table;
	v_businness_key := get_pk_fnc(v_source_table);

  EXECUTE IMMEDIATE 
		'ALTER TABLE  ' || v_destination_table || ' ADD CONSTRAINT ' 
										|| LOWER(v_pk_name) 	 || ' PRIMARY KEY (' 
										|| v_businness_key		 || ' T_DATESTAMP)' ;

END;
/



CREATE OR REPLACE PROCEDURE create_hash_table(v_source_table VARCHAR2)
AS
	
BEGIN
	
	--- CREATE TABLE hash_products (hash_value	NUMBER(20));
	EXECUTE IMMEDIATE 
		'CREATE TABLE ' || 'hash_' || v_source_table || ' (' || 
						CHR(10) || 'hash_value	NUMBER(20)'  || 
						CHR(10) || ')' ;
	
END create_hash_table;



CREATE OR REPLACE FUNCTION get_pk_fnc(v_source_table VARCHAR2) RETURN VARCHAR2
AS
	v_pk_cols VARCHAR2(1000);

	-- Cursor c_primary_key_cols retreives 
	-- names of columns from dictionary that 
	-- are composite key of table. Cursor
	-- reqiuires one argument - name of table.
	CURSOR c_primary_key_cols(v_table_name VARCHAR2) IS
		SELECT cols.column_name col
		FROM all_constraints cons 
		NATURAL JOIN all_cons_columns cols
		WHERE cons.constraint_type = 'P' 
		AND table_name = UPPER(v_table_name);

BEGIN

  -- Concatenating names of primary composite 
  -- key colmns into one varchar separated with comma
	FOR item IN c_primary_key_cols(v_source_table)
	LOOP
		v_pk_cols := v_pk_cols || '"' || item.col || '",';
	END LOOP;

	RETURN v_pk_cols;

END get_pk_fnc;
