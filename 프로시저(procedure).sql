set serveroutput on;
create procedure raise_salary
-- 프로시저 매개변수 : 변수명, mode(모드에는 in, out, in out이 존재), type을 선언
(v_id in employees.employee_id%type)
is -- 프로시저에서는 declare를 대처하는걸로 is를 사용한다.
--선언부분
    v_result number;
begin
    update employees
    set salary = salary * 1.1
    where employee_id = v_id;
    
    v_result := SQL%ROWCOUNT;
    
    DBMS_OUTPUT.PUT_LINE(v_result||'건이 실행되었습니다.');
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
    raise e_dept_no_data; --if문으로 코드추가
 end if;
 
 close emp_cursor;
EXCEPTION
 WHEN e_hire_date THEN
  DBMS_OUTPUT.PUT_LINE('2000년 이후 입사자입니다.');
  when e_dept_no_data then
  DBMS_OUTPUT.PUT_LINE('해당부서에 사원이 없습니다..');
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
1. 주민등록번호를 입력하면 다음과 같이 출력되도록 yedam_ju 프로시저를 작성하시오.
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
--에디션
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
2. 사원번호를 입력할 경우 삭제하는 test_pro 프로시저를 생성하시오
단, 해당사원이 없는 경우 "해당사원이 없습니다." 출력
예) EXECUTE TEST_PRO(176)
*/
create or replace procedure test_pro
(v_id in employees.employee_id%type)
is
begin
    delete
    from employees
    where employee_id = v_id;
    
    if sql%rowcount = 0 then
        dbms_output.put_line('해당사원이 없습니다.');
    end if;
end;
/
EXECUTE test_pro(176);

--에디션
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
    dbms_output.put_line(' 없는 부서');        
end;
/
execute test_pro(10);

/*
3. 다음과 같이 PL/SQL 블록을 실행할 경우
사원번호를 입력할 경우 사원의 이름(last_name)의 첫번째 글자를 제외하고는
'*'가 출력되도록 yedam_emp 프로시저를 생성하시오
실행) execute yedam_emp(176)
실행결과) taylor -> T***** <- 이름 크기만큼 별표(*)
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
1. 부서번호를 입력할 경우 해당부서에 근무하는 사원의 사원번호, 사원이름(last_name)을 출력하는 get_emp프로시저를 생성하시오
(cursor 사용해야함)
단, 사원이 없을 경우 "해당 부서에는 사원이 없습니다." 라고 출력(exception 사용)
실행) EXECUTE get_emp(30)
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
  
         dbms_output.put_line('사원 번호 : ' || emp_record.employee_id || ' 사원 이름 : ' || emp_record.last_name);
    end loop;

   if emp_cursor%rowcount = 0 then
        raise e_no_data;
     end if;  
exception
when e_no_data then
  DBMS_OUTPUT.PUT_LINE('해당 부서에는 사원이 없습니다.');
end;
/
execute get_emp(10);

-- 에디션
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
  DBMS_OUTPUT.PUT_LINE('사원번호 :'||emp_record.employee_id||', 사원이름: '||emp_record.last_name);
  
 END LOOP;
 IF emp_cursor%ROWCOUNT = 0 THEN
  RAISE e_emp_no_data;
 END IF;
 CLOSE emp_cursor;
EXCEPTION
 WHEN e_emp_no_data THEN
  DBMS_OUTPUT.PUT_LINE('해당부서에는 사원이 없습니다.');
END;
/


/*
2. 직원들의 사번, 급여 증가치만 입력하면 employees 테이블에 쉽게 사원의 급여를 
갱신할 수 있는 y_update 프로시저를 작성하세요
만약 입력한 사원이 없는 경우에는 'No search employee!!'라는 메시지를 출력하세요(예외처리)
실행) execute y_update(200,10)
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