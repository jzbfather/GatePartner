<?php
/**
 *  Main API Page
 */
 
// Sécurité pour les includes
define ('CORECMS', 1 );
// Choose the type of database to be used.
# oracle, mysql, pgsql, mssql and odbc
define ('SGBD', 'oracle' );	
// Fichier principal
if ( is_file ( './core_sys/common.php') ) {	

    include_once ( './core_sys/common.php' ) ; 
	
} else {    
	die ( '<p><strong>Erreur&nbsp;: </strong>Le fichier systeme principal est introuvable.</p>' );
	
}

/**
 *  ////////////////////
 */
include_once ("includes/fct-operation.php");
$gatemsg = new ope_msg();

 //an array to display response
 $response = array();
 
 if($_SERVER['REQUEST_METHOD'] == "POST"){

	$data = json_decode(file_get_contents('php://input'), true);
	
	if ( array_key_exists('psw', $data) && array_key_exists('fm', $data) && array_key_exists('to', $data) && array_key_exists('msg', $data) && array_key_exists('tpe', $data) ) {
		
		switch( $data['tpe'] ) {
		
			case 'sms':
			
			$result = $gatemsg->LoginAuth( $data['psw'] );
			
				if ( $database->NbrRowsSelected ($result) > 0 ) {

					$result_operator = $gatemsg->SelectOperator('sms-Temenos');
					$row = $database->ResultArray( $result_operator );
					$ref = 'TMNS'.time() ;
				
					$msg = $gatemsg->SendSMS ();
				
					oci_bind_by_name($msg, ":a", $data['fm']);
					oci_bind_by_name($msg, ":b", $data['to']);
					oci_bind_by_name($msg, ":c", $data['msg']);
					oci_bind_by_name($msg, ":d", $ref);
					oci_bind_by_name($msg, ":e", $row["cnf_value"]);
			
					oci_bind_by_name($msg, ":f", $res, 80, SQLT_CHR);
					oci_execute($msg);
			
					$response['error'] = False;
					$response['message'] = $res;
				
				}else{
					$response['error'] = True;
					$response['message'] = 'Authentification SMS Failed';
				};	

				break;				
				
			case 'email':	
			
			$result = $gatemsg->LoginAuth( $data['psw'] );
			
			if ( $database->NbrRowsSelected ($result) > 0 ) {
				$result_operator = $gatemsg->SelectOperator('eml-Temenos');
				$row = $database->ResultArray( $result_operator );
				
				$mail_addr = 'eproducts@afrilandfirstbankcd.com';
				$mail_attach = null;
				
				$ref = 'TMNS'.time() ;
				$subject = 'Email-Notification';

				$signature = "<div id=_rc_sig>
								<p><span style=font-family: helvetica; font-size: x-small;>-----------------------------------------------------------------------------------------</span></p>
								<p><em><span style=font-family: helvetica; font-size: x-small;>Direction des Syst&egrave;mes D'information</span></em></p>
								<p><em><span style=font-family: helvetica; font-size: x-small;><b>Afriland First Bank CD</b></span></em></p>
								<p><em><span style=font-family: helvetica; font-size: x-small;>767, Blvd 30 Juin, Kinshasa/Gombe</span></em></p>
								<p><em><span style=font-family: helvetica; font-size: x-small;>www.afrilandfirstbankcd.com﻿</span></em></p>
							  </div>";
				
				$str = ['é', 'è', 'à', 'ê', 'ç'];
				$rplc =['&eacute;','&egrave;','&agrave;','&ecirc;','&Ccedil;'];
				
				$mail_msg = '<p>&nbsp;</p>'.'<p>'.str_replace($str,$rplc,$data["msg"]).'</p>'.$signature;
							
				$email = $gatemsg->SendEMAIL();
				oci_bind_by_name($email, ":a", $mail_addr);
				oci_bind_by_name($email, ":b", $data["fm"]);
				oci_bind_by_name($email, ":c", $data["to"]);
				oci_bind_by_name($email, ":d", $subject);
				oci_bind_by_name($email, ":e", $mail_msg);
				oci_bind_by_name($email, ":f", $ref);
				oci_bind_by_name($email, ":g", $mail_attach);
				oci_bind_by_name($email, ":h", $row["cnf_value"]);
			
				oci_bind_by_name($email, ":i", $res, 80, SQLT_CHR);
				oci_execute($email);

				$response['error'] = False;
				$response['message'] = $res;	
			}else{
				$response['error'] = True;
				$response['message'] = 'Authentification EMAIL Failed';
			};				
				
			break;
			
			default:
		
			$response['error'] = True;
			$response['message'] = "Error calling the API TYPE";
		
		}
		
	}else{
			$response['error'] = True;
			$response['message'] = "Error calling the API, fill all parameters";
	}

 }else{
	$response['error'] = True;
	$response['message'] = "Error when calling the METHOD of the API";
 }

header('Content-type: application/json');
header('Content-Type: text/html; charset=utf-8');

echo json_encode($response);

?>