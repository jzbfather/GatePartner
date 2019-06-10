create or replace FUNCTION                            sms_test ( p_number IN VARCHAR2, p_message IN VARCHAR2, r_value OUT INT  )

RETURN INT IS

  req   UTL_HTTP.REQ; -- HTTP REQUEST
  resp  UTL_HTTP.RESP; -- HTTP RESPONSE
  
  v_msg VARCHAR2(255); 
  v_entire_msg VARCHAR2(32767);  -- URL to post to
  vResponseText VARCHAR2(255); 
  
  v_url VARCHAR2(32767);
  v_param_length NUMBER := length(v_url);
  
BEGIN
 
  r_value := 0;
  
  -- Replace here space in the msg by %20 in order to send
  SELECT PARAM_VALUE INTO v_url   FROM INTRANET.GATEPARTNER_CONF where PARAM_NAME = 'sms-gateway1';
  
   v_url := REPLACE( v_url , '%1' , p_number );
   v_url := REPLACE( v_url , '%2' , p_message );
  
  v_url := REPLACE( v_url ,' ','%20');
  
  
  DBMS_OUTPUT.PUT_LINE( 'Valeur de v_url := ' || v_url);
  
  req := UTL_HTTP.begin_request(url => v_url, method => 'GET');
  
  resp := UTL_HTTP.get_response(r => req);

  DBMS_OUTPUT.PUT_LINE('Valeur de response code : ' || v_entire_msg);
  
  BEGIN
  
     LOOP
       UTL_HTTP.read_text(r => resp,data => v_msg);
       v_entire_msg := v_entire_msg||v_msg;
     END LOOP;
     
  EXCEPTION
     
     WHEN  UTL_HTTP.END_OF_BODY
     THEN  NULL;
     
  END;
  
  DBMS_OUTPUT.PUT_LINE('Valeur de v_entire_msg' || v_entire_msg);
  
  r_value := 1;
 
  UTL_HTTP.end_response(r => resp);
 
  
  
  RETURN r_value;
 
EXCEPTION
  
  WHEN  others
  THEN   DBMS_OUTPUT.PUT_LINE( 'Erreur := ' || SQLERRM  );
  RETURN r_value;
  
END;