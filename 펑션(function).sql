set serveroutput on;

create or replace function get_sal
--(���û���)�Ű����� ���� -> in��常 ����
(v_id in employees.employee_id%type)
--(�ʼ�����) return type
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
        DBMS_OUTPUT.PUT_LINE('��� �޿����� �����ϴ�');
    END IF;
END;
/
/*
1. ���ڸ� �Է��� ��� �Էµ� ���ڱ����� ������ �հ踦 ����ϴ� �Լ��� �ۼ��Ͻÿ�.
���� ��)execute dbms_output_line(ydsum(10))
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
2. �����ȣ�� �Է��� ��� ���� ������ �����ϴ� ����� ��µǴ� ydinc �Լ��� �����Ͻÿ�.
- �޿��� 5000 �����̸� 20% �λ�� �޿� ���
- �޿��� 10000 �����̸� 15%�λ�� �޿� ���
- �޿��� 20000 �����̸� 10% �λ�� �޿� ���
- �޿��� 20000 �̻��̸� �޿� �״�� ���
����) select last_name, salary, YDINC(employee_id) from employees;
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
3. �����ȣ�� �Է��ϸ� �ش� ����� ������ ��µǴ� yd_func �Լ��� �����Ͻÿ�
-> ������� : (�޿�+(�޿�*�μ�Ƽ���ۼ�Ʈ))*12
����) select last_name, salary, yd_func(employee_id) from employees;
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
������ ���� ��µǴ� subname �Լ��� �ۼ��Ͻÿ�
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