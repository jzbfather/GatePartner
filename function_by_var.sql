

DECLARE
  func VARCHAR2(20);

  value1 NUMBER := 10;
  value2 NUMBER := 20;
  plsql_block VARCHAR2(500);
  out_value NUMBER;  
BEGIN
  func := 'add';

  plsql_block := 'BEGIN  :v := ' || func || '(:v1,:v2); END;';      

  EXECUTE IMMEDIATE plsql_block USING OUT out_value, IN value1, value2;

END;
