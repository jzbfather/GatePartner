
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
/


CREATE or REPLACE FUNCTION gatepartner.deposit_email 
(
 p_from in varchar2,
 p_fromname in varchar2,
 p_to in varchar2, 
 p_msgsub in varchar2,
 p_msgtxt in varchar2,
 p_refid in varchar2,
 p_attach in varchar2,
 p_opename in varchar2 default 'mail_html'
) return varchar2 as 


  v$timenow VARCHAR2(50) := to_char ( sysdate , 'DD/MM/YYYY HH24:MI:SS' );

BEGIN 

	INSERT INTO gatepartner.inbox ( SENDER, SENDER_NAME, RECEIVER, RECEIVEDTIME, SUBJECT, MSG, STATUS, MSGTYPE, REFERENCE, ATTACH, OPERATOR )
            VALUES ( p_from, p_fromname, p_to, v$timenow , p_msgsub, p_msgtxt, 'send', 'EMAIL', p_refid, p_attach, p_opename );
  	
	return 'NEW RECORD !'||p_refid; 

EXCEPTION
  WHEN others THEN
    return 'NO RECORD !'||p_refid; 

END;



