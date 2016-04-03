CREATE OR REPLACE PROCEDURE load_snapshot(v_source_table VARCHAR2)
AS
	
BEGIN

	--- first use:
	
	create_snapshot(v_source_table);
	create_hash_table(v_source_table);
	
	load_snapshot_data(v_source_table, SYSDATE);		-- loading data with given date
	load_hash_data(v_source_table);
	
END load_snapshot;



CREATE OR REPLACE PROCEDURE load_snapshot_data(v_source_table VARCHAR2)
AS
	
END load_snapshot_data;



CREATE OR REPLACE PROCEDURE load_hash_data(v_source_table VARCHAR2)
AS
	
END load_hash_data;
