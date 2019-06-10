create or replace function          date_to_ts( PDate in date ) return number is

   l_unix_ts number;

begin

   l_unix_ts := ( to_date (  to_char ( PDate , 'DD/MM/YYYY' ) ) - date '1970-01-01' ) * 60 * 60 * 24;
   return l_unix_ts;

end;


create or replace FUNCTION ts_to_date( p_ts IN NUMBER )
  RETURN DATE
IS
  l_date DATE;
BEGIN
  l_date := date '1970-01-01' + p_ts/60/60/24;
  RETURN l_date;
END;


create or replace function          ping_dblink (dbl varchar2) return varchar2 is 

BEGIN 
  execute immediate 'SELECT count(*) from dual@'||dbl; 
  return 'UP'; 
EXCEPTION
  WHEN others THEN
    return 'DOWN'; 
END;


create or replace FUNCTION GetFile( FileName IN VARCHAR2) RETURN CLOB IS

    v_bfile   BFILE; 
    v_clob    CLOB; 
    destOffset INTEGER := 1; 
    srcOffset INTEGER := 1; 
    lang_context INTEGER := DBMS_LOB.default_lang_ctx;
    warning INTEGER;
    FolderName VARCHAR2(50);

BEGIN 

    SELECT param_value INTO FolderName from INTRANET.GATEPARTNER_CONF where PARAM_NAME='dir_work';
    
    DBMS_OUTPUT.PUT_LINE('FolderName = ' || FolderName );
    DBMS_OUTPUT.PUT_LINE('FileName = ' || FileName );
    

    v_bfile := BFILENAME ( FolderName , FileName ); 

    -- Open Binary File --
    DBMS_LOB.OPEN (v_bfile); 

    -- Create Temporary File --
    DBMS_LOB.CREATETEMPORARY(v_clob, TRUE, DBMS_LOB.SESSION);

    --- From CLOB, Create BLOB
    DBMS_LOB.LOADCLOBFROMFILE(
        dest_lob => v_clob, 
        src_bfile => v_bfile, 
        amount => DBMS_LOB.GETLENGTH(v_bfile), 
        dest_offset => destOffset, 
        src_offset => srcOffset,
        bfile_csid => DBMS_LOB.default_csid,
        lang_context => lang_context,
        warning => warning); 

    -- Close Binary File --
    DBMS_LOB.CLOSE(v_bfile); 

    -- Return the file to attach
    RETURN v_clob; 

END GetFile;




create or replace FUNCTION          IS_DATE 
(
  input in varchar2 
) RETURN BOOLEAN AS 

v$date DATE;

BEGIN
  
  SELECT TO_DATE ( input, 'DD/MM/YYYY' ) INTO v$date
  FROM DUAL ;
  
  RETURN TRUE;
  
EXCEPTION
  WHEN OTHERS THEN
    RETURN FALSE; 
  
END  IS_DATE;



create or replace FUNCTION IS_NUMBER( str IN VARCHAR2 ) 
RETURN INT IS
DUMMY number;
	BEGIN
		
		dummy := TO_NUMBER(str);
		RETURN 1;
		
	EXCEPTION 
  WHEN INVALID_NUMBER THEN
    SYS.DBMS_OUTPUT.PUT_LINE( 'Erreur INVALID_NUMBER. SQLERRM : ' || SQLERRM || '. SQL CODE : ' || SQLCODE);
		RETURN 0;
  WHEN VALUE_ERROR THEN
		SYS.DBMS_OUTPUT.PUT_LINE( 'Erreur VALUE_ERROR. SQLERRM : ' || SQLERRM || '. SQL CODE : ' || SQLCODE);
    RETURN 0;
  WHEN OTHERS THEN 
  SYS.DBMS_OUTPUT.PUT_LINE( 'Erreur OTHERS. SQLERRM : ' || SQLERRM || '. SQL CODE : ' || SQLCODE);
    RETURN 0;
		
	END;
	
	