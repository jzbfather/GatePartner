
CREATE or REPLACE FUNCTION gatepartner.deposit_sms 
(
 p_from in varchar2,
 p_to in varchar2, 
 p_msgtxt in varchar2,
 p_refid in varchar2,
 p_opename in varchar2 
) return varchar2 as 


  v$timenow VARCHAR2(50) := to_char ( sysdate , 'DD/MM/YYYY HH24:MI:SS' );

BEGIN 

	INSERT INTO gatepartner.inbox ( SENDER, RECEIVER, RECEIVEDTIME, MSG, STATUS, MSGTYPE, REFERENCE, OPERATOR )
            VALUES ( p_from, p_to, v$timenow , p_msgtxt, 'send', 'SMS', p_refid, p_opename );
  	
	return 'NEW RECORD !'||p_refid; 

EXCEPTION
  WHEN others THEN
    return 'NO RECORD !'||p_refid; 

END;


