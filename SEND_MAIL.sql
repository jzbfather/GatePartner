create or replace function          send_mail 
(
  p_from in varchar2 default null 
, p_fromName in varchar2 default null 
, p_to in varchar2 
, p_subject in varchar2 
, p_html_msg in varchar2 default null 
, p_filename in varchar2 default null 
, p_smtp_host in varchar2 default 'A.B.C.D' 
, p_smtp_port in number default 25 
) return number as 


    v_connection             UTL_SMTP.connection;
    -- mime blocks (the sections of the email body that can become attachments)
    -- must be delimited by a string, this particular string is just an example
    c_mime_boundary CONSTANT VARCHAR2(256) := '-----****RDC****12345';
    
    v_clob                   CLOB := EMPTY_CLOB();
    v_blob                   BLOB := EMPTY_BLOB();
    
    v_len                    INTEGER;
    v_index                  INTEGER;
    l_step        PLS_INTEGER  := 12000;

    p_filetype VARCHAR2(4);
    
    psender VARCHAR2(255) := NULL;
    sender VARCHAR2(255) := NULL;
    
    psender_name VARCHAR2(255) := NULL;
    sender_name VARCHAR2(255) := NULL;
    
    p_return NUMBER := 0;
    
    p_clob BOOLEAN := FALSE ;

begin
    
    SELECT param_value INTO psender FROM GATEPARTNER_CONF where PARAM_NAME = 'mail-sender';
    SELECT param_value INTO psender_name FROM GATEPARTNER_CONF where PARAM_NAME = 'mail-name';
    
    IF ( p_from IS NULL ) THEN
        sender := psender  ;
    ELSE 
        sender := p_from;
    END IF;
    
    IF ( p_fromName IS NULL ) THEN
        sender_name := psender_name  ;
    ELSE 
        sender_name := p_fromName;
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('mail-sender = ' || p_from);
    
    v_connection := UTL_SMTP.open_connection(p_smtp_host);
    
    --- Send HELO to SMTP Server
    UTL_SMTP.HELO( v_connection, p_smtp_host );
    
    --- Set the sender Address
    UTL_SMTP.mail(v_connection, p_from);
    
    --- Set the receiver Address 
    UTL_SMTP.rcpt(v_connection, p_to);
    
    -- Tell to Write Data
    UTL_SMTP.open_data(v_connection);
    
    -- Set the Display Name of sender and E-mail
    UTL_SMTP.write_data(v_connection, 'From:"' ||  sender_name || '" <' || sender || '>' || UTL_TCP.crlf);
    
    -- Set receiver's address
    UTL_SMTP.write_data(v_connection, 'To: ' || p_to || UTL_TCP.crlf);
    
    -- Set the sent Date
    UTL_SMTP.write_data(v_connection, 'Date: ' || TO_CHAR( SYSTIMESTAMP,'DD Mon YYYY HH24:MI:SS TZHTZM' , 'NLS_DATE_LANGUAGE=ENGLISH' ) || UTL_TCP.crlf);
   
    -- Set the subject
    UTL_SMTP.write_data(v_connection, 'Subject: ' || p_subject || UTL_TCP.crlf);
    -- Set Mime Version : 1.0 or 2.0
    UTL_SMTP.write_data(v_connection, 'MIME-Version: 1.0' || UTL_TCP.crlf);
    
    -- Setting Content-type to multipart in order to support either HTML or Plain Text
    UTL_SMTP.write_data(
        v_connection,
        'Content-Type: multipart/mixed; boundary="' || c_mime_boundary || '"' || UTL_TCP.crlf
    );
    
    UTL_SMTP.write_data(v_connection, UTL_TCP.crlf);
    
      -- if Message is a Html text, set Content-type  ====> Content-Type: text/html; charset="iso-8859-1"
   IF p_html_msg IS NOT NULL THEN
        UTL_SMTP.write_data(v_connection, '--' || c_mime_boundary || UTL_TCP.crlf);
        UTL_SMTP.write_data(v_connection, 'Content-Type: text/html; charset="iso-8859-1"' || UTL_TCP.crlf || UTL_TCP.crlf);
        UTL_SMTP.write_data(v_connection, p_html_msg);
        UTL_SMTP.write_data(v_connection, UTL_TCP.crlf || UTL_TCP.crlf);
   END IF;

   -- Put the boudary to specify end of Message
   UTL_SMTP.write_data(v_connection, '--' || c_mime_boundary || UTL_TCP.crlf);
   
   DBMS_OUTPUT.PUT_LINE('Before Checking FileName ' ); 
   -- If there's a file to attach
   IF ( p_filename IS NOT NULL ) THEN 
   
           DBMS_OUTPUT.PUT_LINE('Before Checking Filetype. File Name is : ' || p_filename ); 
            -- Get Attachment File type
            DBMS_OUTPUT.PUT_LINE('Before Substr ' ); 
            SELECT SUBSTR( p_filename ,-4,4 ) INTO p_filetype FROM DUAL ;
            DBMS_OUTPUT.PUT_LINE('After Substr ' ); 
            
            DBMS_OUTPUT.PUT_LINE('Check Filetype : ' || p_filetype );
            
            -- Set the content type of file to attach
            CASE 
                
                WHEN p_filetype IN ( '.csv', '.txt' ) THEN 
                    UTL_SMTP.write_data(v_connection, 'Content-Type: text/plain' || UTL_TCP.crlf);
                    p_clob := TRUE;
                    
                WHEN p_filetype = '.pdf' THEN 
                    UTL_SMTP.write_data(v_connection, 'Content-Type: application/pdf' || UTL_TCP.crlf);
                    UTL_SMTP.write_data(v_connection, 'Content-Transfer-Encoding: base64' || UTL_TCP.crlf);
                    
                WHEN p_filetype IN ( '.xls', 'xlsx' ) THEN 
                    UTL_SMTP.write_data(v_connection, 'Content-Type: application/vnd.ms-excel' || UTL_TCP.crlf);
                    UTL_SMTP.write_data(v_connection, 'Content-Transfer-Encoding: base64' || UTL_TCP.crlf);
                
                WHEN p_filetype IN ( '.doc' , 'docx' ) THEN 
                    UTL_SMTP.write_data(v_connection, 'Content-Type: application/msword' || UTL_TCP.crlf);
                    UTL_SMTP.write_data(v_connection, 'Content-Transfer-Encoding: base64' || UTL_TCP.crlf);
                    
                WHEN p_filetype = '.rtf' THEN 
                    UTL_SMTP.write_data(v_connection, 'Content-Type: application/rtf' || UTL_TCP.crlf);
                    UTL_SMTP.write_data(v_connection, 'Content-Transfer-Encoding: base64' || UTL_TCP.crlf);
                
                WHEN p_filetype IN ( '.jpe' , '.jpg' ) THEN 
                    UTL_SMTP.write_data(v_connection, 'Content-Type: image/jpeg' || UTL_TCP.crlf);
                    UTL_SMTP.write_data(v_connection, 'Content-Transfer-Encoding: base64' || UTL_TCP.crlf);
                    
                WHEN p_filetype = '.png' THEN 
                    UTL_SMTP.write_data(v_connection, 'Content-Type: image/png' || UTL_TCP.crlf);
                    UTL_SMTP.write_data(v_connection, 'Content-Transfer-Encoding: base64' || UTL_TCP.crlf);
                
                WHEN p_filetype = '.gif' THEN 
                    UTL_SMTP.write_data(v_connection, 'Content-Type: image/gif' || UTL_TCP.crlf);
                    UTL_SMTP.write_data(v_connection, 'Content-Transfer-Encoding: base64' || UTL_TCP.crlf);
                
            END CASE;
            
            
            UTL_SMTP.write_data( v_connection,'Content-Disposition: attachment; filename="' || p_filename || '"' || UTL_TCP.crlf );
            UTL_SMTP.write_data(v_connection, UTL_TCP.crlf);
        
            -- Check if file is character or octect 
           CASE  
             
             -- When CSV or Text File
             WHEN p_clob = TRUE  THEN
               v_clob := GETFILE ( p_filename );
               -- Write attachment contents
               v_len := DBMS_LOB.getlength(v_clob);
               v_index := 1;
           
               WHILE v_index <= v_len
                LOOP
                    UTL_SMTP.write_data(v_connection, DBMS_LOB.SUBSTR(v_clob, 32000, v_index));
                    v_index := v_index + 32000;
                END LOOP;
             
            -- When other file type    
            ELSE 
                
                v_blob := GETFILE2(p_filename);
                
                FOR i IN 0 .. TRUNC((DBMS_LOB.getlength(v_blob) - 1 )/l_step) LOOP
                    UTL_SMTP.write_data(v_connection, UTL_RAW.cast_to_varchar2(UTL_ENCODE.base64_encode(DBMS_LOB.substr(v_blob, l_step, i * l_step + 1))));
                END LOOP;
            END CASE;
            
            
            -- End attachment
            UTL_SMTP.write_data(v_connection, UTL_TCP.crlf);
            UTL_SMTP.write_data(v_connection, '--' || c_mime_boundary || '--' || UTL_TCP.crlf);
  
   END IF;
    
    UTL_SMTP.close_data(v_connection);
    UTL_SMTP.quit(v_connection);
    
    p_return := 1;
    
    return p_return;
    EXCEPTION 
    WHEN OTHERS THEN 
        DBMS_OUTPUT.PUT_LINE( DBMS_UTILITY.FORMAT_ERROR_STACK );
        RETURN p_return;
end send_mail;