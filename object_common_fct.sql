create or replace PACKAGE jzb_common IS 
  TYPE TypeTabArray IS TABLE OF VARCHAR2(3200) INDEX BY VARCHAR2(50);
  
  -- Convert timestand to date 
  FUNCTION convert_ts_to_date( p_ts IN NUMBER )
    RETURN  DATE;
  
  FUNCTION convert_date_to_ts( PDate in date )
    RETURN  NUMBER;
  
  PROCEDURE PrintTabArray (nmtab TypeTabArray);
  
END;
/

create or replace PACKAGE BODY jzb_common IS 
  
  -- Convert timestand to date 
  FUNCTION convert_ts_to_date( p_ts IN NUMBER ) RETURN DATE IS
      l_date DATE;
  BEGIN
      l_date := date '1970-01-01' + p_ts/60/60/24;
      RETURN l_date;
  END;
  
  FUNCTION convert_date_to_ts( PDate in date ) RETURN number is    
    l_unix_ts number;
    
  BEGIN
    
       l_unix_ts := ( PDate - date '1970-01-01' ) * 60 * 60 * 24;
       return l_unix_ts;
  END;
  
  PROCEDURE PrintTabArray (nmtab TypeTabArray) IS
    
  BEGIN
    
    FOR i IN 1..nmtab.count LOOP
      dbms_output.put_line(nmtab(i));
    END LOOP;
  END;
  
  
END;
