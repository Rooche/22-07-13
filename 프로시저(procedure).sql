set serveroutput on;
create procedure raise_salary
-- ���ν��� �Ű����� : ������, mode(��忡�� in, out, in out�� ����), type�� ����
(v_id in employees.employee_id%type)
is -- ���ν��������� declare�� ��ó�ϴ°ɷ� is�� ����Ѵ�.
--����κ�
    v_result number;
begin
    update employees
    set salary = salary * 1.1
    where employee_id = v_id;
    
    v_result := SQL%ROWCOUNT;
    
    DBMS_OUTPUT.PUT_LINE(v_result||'���� ����Ǿ����ϴ�.');
end;
/
execute raise_salary(7369);
-------------------------------------------------------------------------
create procedure calculator
(v_num in number)
is
    v_sum number :=0;
begin
    for i in 1..v_num loop
    v_sum := v_sum+i;
    end loop;
    DBMS_OUTPUT.PUT_LINE(v_sum);
end;
/
execute calculator(10);
-------------------------------------------------------------------------
create or replace procedure raise_salary
is
 CURSOR emp_cursor IS
  SELECT employee_id, hire_date
  FROM employees
  WHERE department_id = 30;
 emp_record emp_cursor%ROWTYPE;
 e_hire_date EXCEPTION;
 e_dept_no_data exception;
BEGIN
 OPEN emp_cursor;
 
 LOOP
  FETCH emp_cursor INTO emp_record;
  EXIT WHEN emp_cursor%NOTFOUND;
  
  IF emp_record.hire_date >= TO_DATE('2000/01/01','YYYY/MM/DD')THEN
   RAISE e_hire_date;
  END IF;
 
  UPDATE employees
  SET salary = salary * 1.1
  WHERE employee_id = emp_record.employee_id;
 END LOOP;
 
 if emp_cursor%rowcount = 0then
    raise e_dept_no_data; --if������ �ڵ��߰�
 end if;
 
 close emp_cursor;
EXCEPTION
 WHEN e_hire_date THEN
  DBMS_OUTPUT.PUT_LINE('2000�� ���� �Ի����Դϴ�.');
  when e_dept_no_data then
  DBMS_OUTPUT.PUT_LINE('�ش�μ��� ����� �����ϴ�..');
END;
/

execute raise_salary;
-------------------------------------------------------------------------
create or replace procedure query_emp
( v_id in employees.employee_id%type,
  v_name out employees.last_name%type,
  v_salary out employees.salary%type,
  v_comm out employees.commission_pct%type
)
is
begin
    select last_name, salary, commission_pct
    into v_name, v_salary, v_comm
    from employees
    where employee_id = v_id;
end;
/

variable g_name varchar2(15);
VARIABLE g_salary NUMBER;
VARIABLE g_comm NUMBER;

execute query_emp(149, :g_name, :g_salary, :g_comm);

print g_name;
print g_salary;
print g_comm;

select * from employees where commission_pct is not null;
-------------------------------------------------------------------------
 create or replace procedure calculator
 (v_num in number, 
 v_sum out number)
 is
--  v_temp number := 0;
begin
  v_sum :=0;
    for i in 1..v_num loop
    v_sum := v_sum + i;
--    v_temp := v_temp + i;
     end loop;
--     v_sum := v_temp;
end;
/

variable g_sum number;
 
 execute calculator(10,:g_sum);

print g_sum;
-------------------------------------------------------------------------
create or replace procedure format_phone
(v_phone_no in out varchar2)
is
begin
 v_phone_no :='('||substr(v_phone_no, 1, 3)||')'||substr(v_phone_no,4,3)||'-'||substr(v_phone_no,7);
 end;
 /

declare
 phone_no varchar2(100) := '0539403574';
begin
 format_phone(phone_no);
 DBMS_OUTPUT.PUT_LINE(phone_no);
end;
/
-------------------------------------------------------------------------
create or replace procedure raise_salary
( v_id in employees.employee_id%type)
is
begin
    update employees
    set salary = salary * 1.1
    where employee_id = v_id;
end;
/

create or replace procedure process_emps
is
    cursor emp_cursor is
    select employee_id
    from employees;
begin
for emp_record in emp_cursor loop
raise_salary(emp_record.employee_id);
end loop;
end;
/

execute process_emps;

drop procedure calculator;
-------------------------------------------------------------------------
/*
1. �ֹε�Ϲ�ȣ�� �Է��ϸ� ������ ���� ��µǵ��� yedam_ju ���ν����� �ۼ��Ͻÿ�.
EXECUTE yedam_ju(9501011667777)
-> 950101-1******
*/
create or replace procedure yedam_ju
(v_ju_no in out varchar2)
is
begin
 v_ju_no :=  substr(v_ju_no, 1,6)||'-'||substr(v_ju_no,7,1) || '******';
end;
/

declare
 g_ju VARCHAR2(100) := &num;
 begin
    yedam_ju(g_ju);
    DBMS_OUTPUT.PUT_LINE(g_ju);
end;
/
--�����
CREATE OR REPLACE PROCEDURE yedam_ju
(v_ssn IN VARCHAR2)
IS
 v_text VARCHAR2(100) := '';
BEGIN
 v_text := SUBSTR(v_ssn,1,6)||'-'||RPAD(SUBSTR(v_ssn,7,1),7,'*');
 DBMS_OUTPUT.PUT_LINE(v_text);
END;
/

EXECUTE yedam_ju()

/*
2. �����ȣ�� �Է��� ��� �����ϴ� test_pro ���ν����� �����Ͻÿ�
��, �ش����� ���� ��� "�ش����� �����ϴ�." ���
��) EXECUTE TEST_PRO(176)
*/
create or replace procedure test_pro
(v_id in employees.employee_id%type)
is
begin
    delete
    from employees
    where employee_id = v_id;
    
    if sql%rowcount = 0 then
        dbms_output.put_line('�ش����� �����ϴ�.');
    end if;
end;
/
EXECUTE test_pro(176);

--�����
create or replace procedure test_pro
(emp_id employees.employee_id%TYPE)
is
e_no_data exception;
 begin
    delete from employees
    where employee_id = emp_id;
    
    if sql%notfound   then
        raise e_no_data;
     end if;    
exception     
    when e_no_data then
    dbms_output.put_line(' ���� �μ�');        
end;
/
execute test_pro(10);

/*
3. ������ ���� PL/SQL ����� ������ ���
�����ȣ�� �Է��� ��� ����� �̸�(last_name)�� ù��° ���ڸ� �����ϰ��
'*'�� ��µǵ��� yedam_emp ���ν����� �����Ͻÿ�
����) execute yedam_emp(176)
������) taylor -> T***** <- �̸� ũ�⸸ŭ ��ǥ(*)
*/
create or replace procedure yedam_emp
(v_id in employees.employee_id%type)
is
 v_name employees.last_name%type;
begin
    select last_name
    into v_name
    from employees
    where employee_id = v_id;
    
    DBMS_OUTPUT.PUT_LINE(v_name ||'->'||RPAD(substr(v_name,1,1),length(v_name),'*'));
end;
/

execute yedam_emp(200);
-------------------------------------------------------------------------
-------------------------------------------------------------------------
/*
1. �μ���ȣ�� �Է��� ��� �ش�μ��� �ٹ��ϴ� ����� �����ȣ, ����̸�(last_name)�� ����ϴ� get_emp���ν����� �����Ͻÿ�
(cursor ����ؾ���)
��, ����� ���� ��� "�ش� �μ����� ����� �����ϴ�." ��� ���(exception ���)
����) EXECUTE get_emp(30)
*/
create or replace procedure get_emp
(v_id in employees.department_id%type)
is
 cursor emp_cursor is
    select employee_id, last_name
    from employees
    where department_id = v_id;
    e_no_data exception;
    emp_record emp_cursor%ROWTYPE;
begin
open emp_cursor;
loop
  FETCH emp_cursor INTO emp_record;
  EXIT WHEN emp_cursor%NOTFOUND;
  
         dbms_output.put_line('��� ��ȣ : ' || emp_record.employee_id || ' ��� �̸� : ' || emp_record.last_name);
    end loop;

   if emp_cursor%rowcount = 0 then
        raise e_no_data;
     end if;  
exception
when e_no_data then
  DBMS_OUTPUT.PUT_LINE('�ش� �μ����� ����� �����ϴ�.');
end;
/
execute get_emp(10);

-- �����
CREATE OR REPLACE PROCEDURE get_emp
(v_id IN departments.department_id%TYPE)
IS
 CURSOR emp_cursor IS
  SELECT employee_id, last_name
  FROM employees
  WHERE department_id = v_id;
 emp_record emp_cursor%ROWTYPE;
 e_emp_no_data EXCEPTION;
BEGIN
 IF NOT emp_cursor%ISOPEN THEN
  OPEN emp_cursor;
 END IF;
 
 LOOP
  FETCH emp_cursor INTO emp_record;
  EXIT WHEN emp_cursor%NOTFOUND;
  DBMS_OUTPUT.PUT_LINE('�����ȣ :'||emp_record.employee_id||', ����̸�: '||emp_record.last_name);
  
 END LOOP;
 IF emp_cursor%ROWCOUNT = 0 THEN
  RAISE e_emp_no_data;
 END IF;
 CLOSE emp_cursor;
EXCEPTION
 WHEN e_emp_no_data THEN
  DBMS_OUTPUT.PUT_LINE('�ش�μ����� ����� �����ϴ�.');
END;
/


/*
2. �������� ���, �޿� ����ġ�� �Է��ϸ� employees ���̺� ���� ����� �޿��� 
������ �� �ִ� y_update ���ν����� �ۼ��ϼ���
���� �Է��� ����� ���� ��쿡�� 'No search employee!!'��� �޽����� ����ϼ���(����ó��)
����) execute y_update(200,10)
*/
create or replace procedure y_update
(v_id in employees.employee_id%type,
 v_ratio in number)
 is
  e_emp_no_data exception;
begin
 update employees
 set salary = salary *(1+(v_ratio/100))
 where employee_id = v_id;
 
 if sql%notfound then
  raise e_emp_no_data;
 end if;
exception
 when e_emp_no_data then
  DBMS_OUTPUT.PUT_LINE('No search employee!!');
end;
/

execute y_update(1000,10);