------------------------------------------------------------------------
--- TABELA ERROR_LOG
------------------------------------------------------------------------
CREATE TABLE error_log (
		log_code				INTEGER
	,	log_mesg				VARCHAR2(2000)
	,	log_date				DATE
	, log_user				VARCHAR2(50)

);
/



------------------------------------------------------------------------
--- MESSAGE ERRORS DICTIONARY
------------------------------------------------------------------------
CREATE TABLE msg_dict (
		log_code				INTEGER
	,	log_mesg				VARCHAR2(2000)

);
/



------------------------------------------------------------------------
--- SPECIFICATION - TYP ABSTRAKCYJNY (ABSTRACT TYPE)
------------------------------------------------------------------------
CREATE OR REPLACE TYPE ABSTRACT AS OBJECT (
  dummy NUMBER(1),              		--- dummy attribute bc Oracle is stupid and will not allow to create type without it

  MEMBER PROCEDURE write_log(		
  	log_code	IN INTEGER
  ,	log_mesg	IN VARCHAR2)
  
  
) NOT INSTANTIABLE NOT FINAL;
/




----- informacja, ostrzeżenie, błąd
----- INFO, WARN, ERR


-- THE PROCEDURE write_log performs 
-- COMMIT IN AUTONOMOUS_TRANSACTION
CREATE OR REPLACE PROCEDURE write_log (		
		log_code	IN INTEGER
	,	log_mesg	IN VARCHAR2) IS
--
PRAGMA AUTONOMOUS_TRANSACTION;
--
BEGIN																-- PT suspends
	INSERT INTO error_log VALUES ( 		-- CT begins
		log_code,
		log_mesg,
		SYSDATE,
		USER	
	);
	COMMIT;														-- CT ends
EXCEPTION
		WHEN OTHERS THEN
			ROLLBACK;
END write_log;											-- PT resumes





------------------------------------------------------------------------
--- DEFINITION - TYP ABSTRAKCYJNY (ABSTRACT TYPE)
------------------------------------------------------------------------
CREATE OR REPLACE TYPE BODY ABSTRACT
IS

	-- THE PROCEDURE write_log performs 
	-- COMMIT IN AUTONOMOUS_TRANSACTION
	MEMBER PROCEDURE write_log (		
			log_code	IN INTEGER
		,	log_mesg	IN VARCHAR2) IS
  --
	PRAGMA AUTONOMOUS_TRANSACTION;
	--
  BEGIN																-- PT suspends
		INSERT INTO error_log VALUES ( 		-- CT begins
			log_code,
			log_mesg,
			SYSDATE,
			USER	
		);
		COMMIT;														-- CT ends
	EXCEPTION
			WHEN OTHERS THEN
				ROLLBACK;
	END write_log;											-- PT resumes

END;
/



------------------------------------------------------------------------
--- SPECIFICATION - MIGAWKA (SNAPSHOT)
------------------------------------------------------------------------
CREATE OR REPLACE TYPE MIGAWKA_TYP UNDER ABSTRACT (
		T_DATESTAMP 		DATE 							--- Data ładowania

) NOT INSTANTIABLE NOT FINAL;
/



------------------------------------------------------------------------
--- SPECIFICATION - KRATOTEKA (RECORD)
------------------------------------------------------------------------
CREATE OR REPLACE TYPE KARTOTEKA_TYP UNDER ABSTRACT (
	  T_STARTDATE 		DATE 							--- Początek obowiązywania wersji
	, T_ENDDATE 			DATE							--- Koniec obowiązywania wersji 
	, T_STATUS 				NUMBER(1)					--- 2-rekord usunięty, 0-rekord dostępny

	, CONSTRUCTOR FUNCTION KARTOTEKA_TYP RETURN SELF AS RESULT

) NOT INSTANTIABLE NOT FINAL;
/



