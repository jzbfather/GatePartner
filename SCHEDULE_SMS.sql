create or replace PROCEDURE                                                                         SCHEDULE_SMS 
AS 
r INT :=0;
t INT := 0;
count_sms INT;
count_mail INT;
server_address VARCHAR2(255);
server_port NUMBER;

BEGIN

SELECT param_value INTO count_sms from GATEPARTNER_CONF where PARAM_NAME='sms-number';
SELECT param_value INTO count_mail from GATEPARTNER_CONF where PARAM_NAME='mail-number';
SELECT param_value INTO server_address from GATEPARTNER_CONF where PARAM_NAME='server-addr';
SELECT TO_NUMBER ( param_value ) INTO server_port from GATEPARTNER_CONF where PARAM_NAME='server-port';


------------------------------------------------------------------------------
----------------------------- Send SMS ---------------------------------------
------------------------------------------------------------------------------
FOR pu1 IN ( SELECT id, TRIM ( REPLACE ( receiver, '+', '' ) ) receiver, msg
				FROM INTRANET.gatepartner_inbox 
				WHERE status= 'send' AND msgtype = 'SMS'
                AND ROWNUM <= count_sms )

	LOOP

		r := SMS_TEST( 
						 P_NUMBER => pu1.receiver,
						 P_MESSAGE => pu1.msg, 
						 R_VALUE => t);

	--DBMS_OUTPUT.PUT_LINE( 'Valeur de r := ' || r);
    --DBMS_OUTPUT.PUT_LINE( 'Valeur de pu1.receiver := ' || pu1.receiver);
    --DBMS_OUTPUT.PUT_LINE( 'Valeur de pu1.msg := ' || pu1.msg );
    --DBMS_OUTPUT.PUT_LINE( 'Valeur de pu1.id := ' || pu1.id );

		IF r=1 THEN

			UPDATE gatepartner_inbox SET status = 'sent', senttime= TO_CHAR ( SYSDATE, 'DD/MM/YYYY HH24:MI:SS' ), operator = 'SATELCOM'
			WHERE id = pu1.id;

			COMMIT;

			--DBMS_OUTPUT.PUT_LINE( 'Valeur de r est 1. Fin de fonction ');

		ELSE 

			DBMS_OUTPUT.PUT_LINE( 'Valeur de r est 0. Fin de fonction ');

		END IF;


	END LOOP;


------------------------------------------------------------------------------
----------------------------- Send E-MAIL ---------------------------------------
------------------------------------------------------------------------------

FOR pu1 IN ( SELECT id, sender, from_name, receiver, msg, attach, subject
				FROM INTRANET.gatepartner_inbox 
				WHERE status= 'send' AND msgtype = 'EMAIL'
                AND ROWNUM <= count_mail )
LOOP 

 r := SEND_MAIL( p_from => pu1.sender , p_fromName => pu1.from_name , p_to => pu1.receiver,  p_subject =>  pu1.subject , p_html_msg => pu1.msg , p_filename => pu1.attach , p_smtp_host => server_address , p_smtp_port => server_port );
 
 IF ( r = 1 ) THEN
 
  UPDATE gatepartner_inbox SET status = 'sent', senttime= TO_CHAR ( SYSDATE, 'DD/MM/YYYY HH24:MI:SS' )
	WHERE id = pu1.id;
 
 END IF;

END LOOP;


END;