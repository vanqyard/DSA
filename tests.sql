
Testing:

SET SERVEROUTPUT ON
DECLARE 
  x VARCHAR2(1000);
BEGIN
  x := get_pk_fnc('PRODUCTS');
  DBMS_OUTPUT.PUT_LINE(x);
END;






CREATE OR REPLACE PROCEDURE create_snapshot(v_source_table VARCHAR2, v_destination_table VARCHAR2)
AS
	v_pk_name 			VARCHAR2(1000);
	v_businness_key VARCHAR2(1000);

BEGIN

	v_pk_name := 'pk_' || v_destination_table;
	v_businness_key := get_pk_fnc(v_source_table);

	DBMS_OUTPUT.PUT_LINE('CREATE TABLE ' || v_destination_table || ' AS SELECT * FROM ' || v_source_table || ' WHERE 1 = 0');
  DBMS_OUTPUT.PUT_LINE('ALTER TABLE ' 	|| v_destination_table || ' ADD (T_DATESTAMP DATE)');
  DBMS_OUTPUT.PUT_LINE('ALTER TABLE ' 	|| v_destination_table || ' ADD CONSTRAINT ' 
																		|| LOWER(v_pk_name) 					 || ' PRIMARY KEY (' 
																		|| v_businness_key		 || ' "T_DATESTAMP")');

END;
/












CREATE OR REPLACE PROCEDURE create_snapshot(v_source_table VARCHAR2, v_destination_table VARCHAR2)
AS
	v_pk_name 			VARCHAR2(1000);
	v_businness_key VARCHAR2(1000);

BEGIN
	v_pk_name := 'pk_' || v_destination_table;
	v_businness_key := get_pk_fnc(v_source_table);

	DBMS_OUTPUT.PUT_LINE('CREATE TABLE ' || v_destination_table || ' OF TYPE ' || 'MIGAWKA_TYP');
  DBMS_OUTPUT.PUT_LINE('ALTER TABLE  ' || v_destination_table || ' ADD CONSTRAINT ' 
																		|| LOWER(v_pk_name) 	 || ' PRIMARY KEY (' 
																		|| v_businness_key		 || ' T_DATESTAMP)' );

END;
/





(?<=\)).*,

	"PRODUCT_ID" NUMBER(10,0) NOT NULL ENABLE, 
	"ROOM_CLASS" NUMBER(2,0), 
	"PRODUCT_NAME" VARCHAR2(64) NOT NULL ENABLE, 
	"DESCRIPTION" VARCHAR2(1024), 
	"PRICE" NUMBER(10,2), 
	"AVAILABLE" VARCHAR2(1)







SET SERVEROUTPUT ON
BEGIN
  create_snapshot('PRODUCTS', 'SH_PROCUCTS');

END;
