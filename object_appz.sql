create or replace PROCEDURE POSTMAN 
AS 

r INT :=0;
t INT := 0;

func VARCHAR2(50);
plsql_block VARCHAR2(500);


config_list intranet.jzb_common_utility.TypeTabArray;

CURSOR ini_param IS select cnf_name,cnf_value from config;

BEGIN

  -- ************************************** --
  -- initialize parameter                   --
  -- ************************************** --
  
  FOR modinfo IN ini_param LOOP      
      config_list( modinfo.cnf_name ) := modinfo.cnf_value ;
    
  END LOOP;


  -- ************************************** --
  -- SMS management                         --
  -- ************************************** --
  

  FOR pu1 IN ( SELECT id, receiver, msg, operator FROM gatepartner.inbox WHERE msgtype = 'SMS'
             AND status= 'send' AND ROWNUM <= config_list('sms-batch') )

  LOOP

        func := pu1.operator;
        
        plsql_block := 'BEGIN  :v := ' || func || '(:v1, :v2); END;';
        
        EXECUTE IMMEDIATE plsql_block USING OUT r, IN pu1.receiver, pu1.msg;
        
        
		-- response good or bad
        IF r = 1 THEN

			UPDATE gatepartner.inbox SET status = 'sent', senttime= TO_CHAR ( SYSDATE, 'DD/MM/YYYY HH24:MI:SS' )
			WHERE id = pu1.id;
			COMMIT;
		ELSE 

			UPDATE gatepartner.inbox SET status = 'notsent', senttime= TO_CHAR ( SYSDATE, 'DD/MM/YYYY HH24:MI:SS' )
			WHERE id = pu1.id;
			COMMIT;            
            
		END IF;


  END LOOP;



  -- ************************************** --
  -- E-mail management                      --
  -- ************************************** --




END;
