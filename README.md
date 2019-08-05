# GatePartner - v 1.619

GatePartner is an application that allows you to send and receive hundreds of your SMS or E-mail. Flexible, it's functionalities integrates perfectly with your applications of type Java, PHP, Python, etc ...


Developments
===========
tested, and developed on Oracle 10.0.xx or higher
If you have made changes to the core you think might benefit others please let us know about them.

Functionalities
==============
- Message Sending
- Message priorities
- Receiving Messages
- Email sending


## Installation

Execute all the following file :

* object_create.sql `about storage information`.
* object_main_fct.sql `All function to be use`.
* object_common_fct.sql `Package of all common utility function, type of variable, ...`.
* object_appz.sql `This is a application`.

## Usage

Verify the grant :

    grant execute, select, read  ... to schema

Send a SMS :

    configure the fonction operator to send your sms 
    INSERT INTO gatepartner.config (CNF_NAME, CNF_VALUE) VALUES ('francecom', 'schema.function')

    GRANT EXECUTE ON schema.function TO gatepartner 

    Function to deliver sms by your application 
    gatepartner.deposit_sms(
	'Ecommerce', -- Persone who sending
	'+243000003269', -- Personne who will be recivied
	'Bonjour, Nous somme heureux.', -- Message to be recevied
	'30074015', -- Reference of message
	'francecom' -- operator who received the message to send 
	);








 


    object_create.sql 'storage information'
    object_create.sql 'storage information'

