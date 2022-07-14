set serveroutput on;

create or replace function get_sal
--(선택사항)매개변수 선언 -> in모드만 가능
(v_id in employees.employee_id%type)
--(필수사항) return type
return number
is
 v_salary employees.salary%type;
begin
 select salary
 into v_salary
 from employees
 where employee_id = v_id;
 
 return v_salary;
end;
/

variable g_salary number;

execute :g_salary := get_sal(149);

print g_salary;

select get_sal(149) from dual;
--------------------------------------------------------------------------------
create function check_sal
return boolean is
    v_deptid employees.department_id%TYPE;
    v_empno employees.employee_id%TYPE;
    v_sal employees.salary%TYPE;
    v_avg_sal employees.salary%TYPE;
begin
    v_empno := 205;
        select salary,department_id
        into v_sal,v_deptid
        from employees
        where employee_id = v_empno;
    select avg(salary)
    into v_avg_sal 
    from employees
    where department_id = v_deptid;
if v_sal > v_avg_sal then
 return true;
else
    return false;
end if;
 EXCEPTION 
    when no_data_found then
        return null;
    end;
    /
BEGIN
    IF check_sal THEN
        DBMS_OUTPUT.PUT_LINE('평균 급여보다 높습니다');
    END IF;
END;
/
/*
1. 숫자를 입력할 경우 입력된 숫자까지의 정수의 합계를 출력하는 함수를 작성하시오.
실행 예)execute dbms_output_line(ydsum(10))
*/
create or replace function ydsum
(v_num number)
return number
is
    v_sum number := 0;  
begin
    for i in 1..v_num loop
        v_sum := v_sum + i;
    end loop;
    return v_sum;
end;
/

execute dbms_output.put_line(ydsum(10));

select ydsum(10) from dual;

/*
2. 사원번호를 입력할 경우 다음 조건을 만족하는 결과가 출력되는 ydinc 함수를 생성하시오.
- 급여가 5000 이하이면 20% 인상된 급여 출력
- 급여가 10000 이하이면 15%인상된 급여 출력
- 급여가 20000 이하이면 10% 인상된 급여 출력
- 급여가 20000 이상이면 급여 그대로 출력
실행) select last_name, salary, YDINC(employee_id) from employees;
*/
create or replace function ydinc
(v_id in employees.employee_id%type)
return number
is
    v_sal number;
begin
        select salary
        into v_sal
        from employees
        where employee_id = v_id;
        
        if v_sal <= 5000 then
            v_sal := v_sal * 1.2;
        elsif v_sal <= 10000 then
            v_sal := v_sal * 1.15;
        elsif v_sal <= 20000 then
            v_sal := v_sal * 1.1;
            
        else
        v_sal := v_sal;
        end if;
        
    return v_sal;
    
end;
/

execute dbms_output.put_line(ydinc(202));

select last_name, salary, YDINC(employee_id) 
from employees;

/*
3. 사원번호를 입력하면 해당 사원의 연봉이 출력되는 yd_func 함수를 생성하시오
-> 연봉계산 : (급여+(급여*인센티브퍼센트))*12
실행) select last_name, salary, yd_func(employee_id) from employees;
*/
create or replace function yd_func
(v_id in employees.employee_id%type)
return number
is
    v_sal number;
    v_comm number;
begin
        select salary, NVL(commission_pct,0)
        into v_sal,v_comm
        from employees
        where employee_id = v_id;
        
        return (v_sal +(v_sal*v_comm))*12;
end;
/
select last_name, salary, yd_func(employee_id) from employees;
/*
4. select last_name, subname(last_name) from employees;

LAST_NAME   SUBNAME
-------------------
King        K***
Smith       S****
...
예저와 같이 출력되는 subname 함수를 작성하시오
*/
create or replace function subname
(lastname varchar2)
return varchar2
is
    v_lastname varchar2(100);
    v_asta varchar2(100);
    v_len number;
begin
    select last_name into v_lastname from employees where last_name = lastname;
    v_len := length(v_lastname);
    v_asta := rpad(substr(v_lastname,1,1),v_len,'*');
    return v_asta;
end;
/

select last_name, subname(last_name) from employees;