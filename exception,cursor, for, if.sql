 set serveroutput on;
 
DECLARE
    type emp_table_type is table of employees%rowtype index by pls_integer;
    my_emp_table emp_table_type;
    max_count number(3) := 104;
begin
    for i in 100..max_count loop
        select * into my_emp_table(i) from employees where employee_id = i;
    end loop;
    for i in my_emp_table.first..my_emp_table.last loop
        DBMS_OUTPUT.PUT_LINE(my_emp_table(i).last_name);
    end loop;
 end;
 /
 
set serveroutput on;
DECLARE
    CURSOR c_emp_cursor is
        select employee_id, last_name
        from employees
        where department_id = 20; -- department_id = 20�� ���� 2���� ���� �ִ�.
    v_empid employees.employee_id%type;
    v_empname employees.last_name%type;
begin
    OPEN c_emp_cursor;
    
    fetch c_emp_cursor into v_empid, v_empname; -- �ʿ��Ѱ��� �� �࿡ ��´�
    DBMS_OUTPUT.PUT_LINE(v_empid||''||v_empname); -- ����� �ϳ��� ���´�.
    
    close c_emp_cursor;
end;
/

-- �Ӽ�: %ISOPEN ����: boolean, Ŀ���� ���������� True
DECLARE
    CURSOR c_emp_cursor is
        select employee_id, last_name
        from employees
        where department_id = 20; -- department_id = 20�� ���� 2���� ���� �ִ�.
    v_empid employees.employee_id%type;
    v_empname employees.last_name%type;
begin
    OPEN c_emp_cursor;
    
    IF NOT c_emp_cursor%ISOPEN THEN
        OPEN c_emp_cursor;
    END IF;
    
    loop
    fetch c_emp_cursor into v_empid, v_empname; -- �ʿ��Ѱ��� �� �࿡ ��´�
    exit when c_emp_cursor%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE(v_empid||''||v_empname); -- ����� �ϳ��� ���´�.
    end loop;
    close c_emp_cursor;
end;
/

create table temp_list(empid, empname)
as
select employee_id, last_name
from employees
where employee_id = 0;

DECLARE
    CURSOR emp_cursor IS
        SELECT employee_id, last_name FROM employees
        WHERE department_id =30;
    emp_record emp_cursor%ROWTYPE;
BEGIN

    OPEN emp_cursor;
    LOOP
    FETCH emp_cursor INTO emp_record;
     EXIT WHEN emp_cursor%NOTFOUND;
        INSERT INTO temp_list (empid, empname)
        values (emp_record.employee_id, emp_record.last_name);
     END LOOP;
COMMIT;
CLOSE emp_cursor;
END;
/
select * from temp_list;

declare
    cursor emp_cursor is
        select last_name, department_id
        from employees;
begin
    for emp_record in emp_cursor loop -- for loop
    --�ڵ����� emo_cursor opne, fetch ����
    if emp_record.department_id = 20 then
        DBMS_OUTPUT.PUT_LINE('Employee'||emp_record.last_name||'works in the Dept');
    end if;
    end loop; --�ڵ����� emp_cursor close 
end;
/

begin
 for emp_record in (select last_name, department_id from employees) loop
  if emp_record.department_id = 20 then
    DBMS_OUTPUT.PUT_LINE('Employee'||emp_record.last_name||'works in the Dept');
  end if;
  end loop;
end;
/

create table test02
as
select employee_id, last_name,hire_date
from employees
where employee_id = 0;

-- 1. �Ի�⵵�� 2000��(����) ���� �Ի��� ���.for loop ���
declare 
    CURSOR emp_cursor is
    select employee_id , last_name, hire_date
    from employees;
 begin
     for emp_record in emp_cursor loop
        if to_char(emp_record.hire_date,'YYYY') <= '2000' THEN
        insert into test01 values emp_record;
        else
        insert into test02 values emp_record;
        end if;
    end loop;
end; 
/


select * from test01;
select * from test02;
-- 1. �Ի�⵵�� 2000�⵵ ���� �Ի��� ���. �⺻ loop ���
-- declare -> open -> fetch -> close ����
declare
    CURSOR emp_cursor is
    select employee_id , last_name, hire_date
    from employees;
    emp_record emp_cursor%rowtype;
begin
    if not emp_cursor%isopen then
    open emp_cursor;
    end if;
    
    loop
        fetch emp_cursor into emp_record;
        exit when emp_cursor%NOTFOUND;
        if to_char(emp_record.hire_date, 'YYYY') <= '2000' then
        insert into test01 values emp_record;
        else
        insert into test02 values emp_record;
        end if;
    end loop;
end;
/

delete from test02;

-- 02
DECLARE
    cursor emp_cursor
    (v_deptno number, v_job varchar2) is
    select employee_id, last_name
    from employees
    where department_id = v_deptno
        and job_id = v_job;
begin
    for emp_record in emp_cursor(90, 'AD_VP') loop
    DBMS_OUTPUT.PUT_LINE(emp_record.employee_id||''||emp_record.last_name);
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('================');
    for emp_record in emp_cursor(60, 'IT_PROG') loop
    DBMS_OUTPUT.PUT_LINE(emp_record.employee_id||''||emp_record.last_name);
    END LOOP;
END;
/

-- 3. �μ���ȣ�� �Է��� ���(&ġȯ���� ���) �ش��ϴ� �μ��� ����̸�, �Ի�����, �μ����� ����Ͻÿ�(�� cursor ���)
declare 
    cursor emp_cursor is
        select e.last_name, e.hire_date, d.department_name
        from employees e inner join departments d
        on e.department_id = d.department_id
        where d.department_id = &deptid;
begin
    for emp_record in emp_cursor loop
        DBMS_OUTPUT.PUT_LINE('����̸� : ' || emp_record.last_name || ' �Ի����� : ' || emp_record.hire_date || ' �μ��� : ' || emp_record.department_name);
    end loop;
end;
/

-- 4. �μ���ȣ�� �Է� (&���)�ϸ� �Ҽӵ� ����� �����ȣ, ����̸�, �μ���ȣ�� ����ϴ� PL/SQL�� �ۼ��Ͻÿ� (��, cursor ���)
declare 
    cursor emp_cursor is
        select employee_id, last_name, department_id
        from employees
        where department_id = &deptid;
begin
    for emp_record in emp_cursor loop
        DBMS_OUTPUT.PUT_LINE('�����ȣ : ' || emp_record.employee_id || ' ����̸� : ' || emp_record.last_name || ' �μ���ȣ : ' || emp_record.department_id);
    end loop;
end;
/

-- 5. �μ���ȣ�� �Է�(&���)�� ��� ����̸�, �޿�, ���� -> (�޿�*12+(�޿�*nvl(Ŀ�̼��ۼ�Ʈ,0)*12))�� ����ϴ� PL/SQL�� �ۼ��Ͻÿ�(��, cursor ���)
declare 
    cursor emp_cursor is
        select last_name, salary, salary*12 + (salary * NVL(commission_pct,0)*12) as annual_sal
        from employees
        where department_id = &deptid;
begin
    for emp_record in emp_cursor loop
        DBMS_OUTPUT.PUT_LINE(' ����̸� : ' || emp_record.last_name || ' �޿� : ' || emp_record.salary || ' ���� : ' || emp_record.annual_sal);
    end loop;
end;
/





declare 
    cursor emp_cursor is
        select *
        from employees
        where department_id = &deptid;
begin
    for emp_record in emp_cursor loop
        DBMS_OUTPUT.PUT_LINE(' ����̸� : ' || emp_record.last_name || ' �޿� : ' || emp_record.salary || ' ���� : ' || (emp_record.salary * 12 + (emp_record.salary*nvl(emp_record.commission_pct, 0)*12)));
    end loop;
end;
/

-- �����̸��� �߻�ȯ���� ��� ����Ŭ���� �����ѰŶ� ����
declare
    v_lname varchar2(15);
begin
    select last_name into v_lname
    from employees
    where first_name='John';
    DBMS_OUTPUT.PUT_LINE('John''s last name is : '||v_lname);
    exception
    when no_data_found then
    DBMS_OUTPUT.PUT_LINE('No DATA : Employee info.');
end;
/

-- �߻�ȯ�游 ����Ŭ�� ���ǵȰ�쿡�� 1.declare�� �����̸��� �����ϰ� ������ ����Ŭ ������ ����
--                              2. Handling
declare
    e_insert_excep exception;
    pragma exception_init(e_insert_excep, -01400);
begin
    insert into departments(department_id, department_name)
    values(280,null);
    
exception
    when e_insert_excep then
        DBMS_OUTPUT.PUT_LINE('INSERT IPERATION FAILED');
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
end;
/

-- �����̸��� �߻�ȯ�浵 ��� ���ǵ��� ���� ��� 1.DECLARE�� �����̸��� ����.
--                                       2.RAISE�� �̿��Ͽ� �߻�ȯ���� ����
--                                       3.Exception���� Handlingó��
DECLARE
    e_invalid_department Exception;
    v_deptno number :=500;
    v_name varchar(20) := 'Testing';
begin
    update departments
    set department_name = v_name
    where department_id = v_deptno;
    
    if SQL%NOTFOUND then --�����۵� ���Ҷ� ����
     raise e_invalid_departemnt;
    end if;
    commit;
exception
    when e_invalid_department then
        DBMS_OUTPUT.PUT_LINE('No search department id.');
end;
/

CREATE TABLE log_table
(code NUMBER(10),
message VARCHAR2(200),
info VARCHAR2(200));

DECLARE
e_toomanyemp EXCEPTION;
v_empsal NUMBER(7);
v_empcomm NUMBER(7);
v_errorcode NUMBER;
v_errortext VARCHAR2(200);
BEGIN
SELECT salary, commission_pct*100000
INTO v_empsal, v_empcomm
FROM employees;
WHERE employee_id = 174;
IF v_empcomm > v_empsal THEN
RAISE e_toomanyemp;
END IF;
EXCEPTION
WHEN e_toomanyemp THEN
INSERT INTO log_table(info)
VALUES ('�� ����� ���ʽ��� '||v_empcomm||'���� ���޿� '||v_empsal||' ���� ����');
WHEN OTHERS THEN
v_errorcode := SQLCODE;
v_errortext := SUBSTR(SQLERRM, 1, 200);
INSERT INTO log_table
VALUES (v_errorcode, v_errortext, 'Oracle error occurred');
END;
/

select * from log_table;

declare
    v_num number := &num; -- ���� �Ѱܹ޴´�
begin
    if v_num <= 0 then --���� ������
        raise_application_error(-20100,'����� �Է¹��� �� �ֽ��ϴ�.');
    end if;
    
    DBMS_OUTPUT.PUT_LINE(v_num);
    
exception
    when no_data_found then
    DBMS_OUTPUT.PUT_LINE('�����Ͱ� �������� �ʽ��ϴ�.');
    when others then
        if sqlcode = -20100 then
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
        else
        DBMS_OUTPUT.PUT_LINE('�ǵ����� ���� ���ܻ����Դϴ�.');
        end if;
end;
/

drop table emp_test;

create table emp_test
as
select employee_id, last_name
from employees
where employee_id < 200;

--emp_test ���̺��� �����ȣ�� ���(&ġȯ���� ���)�Ͽ� ����� �����ϴ� PL/SQL�� �ۼ�
--(��, ����� ���� ���ܻ��� ��� / ��, ����� ������ "�ش����� �����ϴ�."��� �����޽��� �߻�)
declare
    no_emp_data exception;
BEGIN
    DELETE FROM emp_test
    WHERE employee_id = &empid;
    
    if SQL%notfound then
        raise no_emp_data;
    end if; 
exception
when no_emp_data then
    DBMS_OUTPUT.PUT_LINE('�ش��� �����ϴ�.');
END;
/

-- 2. ������̺��� �����ȣ�� �Է¹޾� 10% �λ�� �޿��� �����ϴ� PL/SQL�� �ۼ��Ͻÿ�
-- ��, 2000��(����) ���� �Ի��� ����� �������� �ʰ� "2000�� ���� �Ի��� ����Դϴ�." (<-exception�� ���)��� ��µǵ��� �Ͻÿ�.
declare
    v_empid employees.employee_id%TYPE := &empid;
    v_hire employees.hire_date%TYPE;
    e_hiredate exception;
begin
--�Է¹��� �����ȣ�� �̿��ؼ� �Ի����� ��ȸ
    select hire_date
    into v_hire
    from employees
    where employee_id = v_empid;
    
-- �Ի����� 2000�� ������ ��쿡�� �޿��� 10%�λ�
    if v_hire >= to_date('2000/12/31','yyyy/mm/dd') then
        raise e_hiredate;
    end if;
    
    update employees 
    set salary = salary * 1.1
    where employee_id = v_empid;
exception
when e_hiredate then
    DBMS_OUTPUT.PUT_LINE('2000��� ���� �Ի��� ����Դϴ�.');
end;
/

-- 3-1 ������̺��� �μ���ȣ�� �Է�(&���)�޾� (<-cursor���) 10% �λ�� �޿��� �����ϴ� PL/SQL�� �ۼ�
-- ��, 2000��(����) ���� �Ի��� ����� �������� �ʰ� "2000�� ���� �Ի��� ����� ���ŵ����ʽ��ϴ�." (<-exception�� ���) ��� ��µǵ��� �Ͻÿ�
DECLARE
 CURSOR emp_cursor IS
  SELECT employee_id, hire_date
  FROM employees
  WHERE department_id = &deptid;
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









    
-- 3-2 ������̺��� �μ���ȣ�� �Է�(&���)�޾� (<-cursor���) 10% �λ�� �޿��� �����ϴ� PL/SQL�� �ۼ�
-- ��, �ش� �μ��� ����� ������ "�ش� �μ����� ����� �����ϴ�." (<-exception�� ���) ��� ��µǵ��� �Ͻÿ�

DECLARE
    v_no number := &no;
    no_emp_nodata EXCEPTION;
    no_emp_data EXCEPTION;
    emp_record employees%rowtype;
BEGIN
    select hire_date
    into emp_record.hire_date
    from employees
    where employee_id = v_no;
    if SQL%NOTFOUND then
        RAISE_APPLICATION_ERROR(-20101, '�Է��Ͻ� ��ȣ�� ���� ȸ���Դϴ�');
    else
        update employees 
        set salary = salary*1.1 
        where employee_id = v_no
        AND to_date(hire_date,'RR/MM/DD') < to_date('00/01/01','RR/MM/DD');
        
        if SQL%NOTFOUND then
            RAISE_APPLICATION_ERROR(-20100, '2000�� ���Ŀ� �Ի��� ȸ���Դϴ�');
        end if;
    end if;
  EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('�Է��Ͻ� ��ȣ�� ���� ȸ���Դϴ�.');
        WHEN OTHERS THEN
            IF SQLCODE = -20100 THEN
                DBMS_OUTPUT.PUT_LINE(SQLERRM);
            ELSE
                DBMS_OUTPUT.PUT_LINE('�ǵ����� ���� ���ܻ����Դϴ�.');
            END IF;
END;
/