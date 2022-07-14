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
        where department_id = 20; -- department_id = 20는 현재 2개의 행이 있다.
    v_empid employees.employee_id%type;
    v_empname employees.last_name%type;
begin
    OPEN c_emp_cursor;
    
    fetch c_emp_cursor into v_empid, v_empname; -- 필요한값을 한 행에 담는다
    DBMS_OUTPUT.PUT_LINE(v_empid||''||v_empname); -- 출력은 하나만 나온다.
    
    close c_emp_cursor;
end;
/

-- 속성: %ISOPEN 유형: boolean, 커서가 열려있으면 True
DECLARE
    CURSOR c_emp_cursor is
        select employee_id, last_name
        from employees
        where department_id = 20; -- department_id = 20는 현재 2개의 행이 있다.
    v_empid employees.employee_id%type;
    v_empname employees.last_name%type;
begin
    OPEN c_emp_cursor;
    
    IF NOT c_emp_cursor%ISOPEN THEN
        OPEN c_emp_cursor;
    END IF;
    
    loop
    fetch c_emp_cursor into v_empid, v_empname; -- 필요한값을 한 행에 담는다
    exit when c_emp_cursor%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE(v_empid||''||v_empname); -- 출력은 하나만 나온다.
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
    --자동으로 emo_cursor opne, fetch 실행
    if emp_record.department_id = 20 then
        DBMS_OUTPUT.PUT_LINE('Employee'||emp_record.last_name||'works in the Dept');
    end if;
    end loop; --자동으로 emp_cursor close 
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

-- 1. 입사년도가 2000년(포함) 이전 입사한 사원.for loop 사용
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
-- 1. 입사년도가 2000년도 이후 입사한 사원. 기본 loop 사용
-- declare -> open -> fetch -> close 순서
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

-- 3. 부서번호를 입력할 경우(&치환변수 사용) 해당하는 부서의 사원이름, 입사일자, 부서명을 출력하시오(단 cursor 사용)
declare 
    cursor emp_cursor is
        select e.last_name, e.hire_date, d.department_name
        from employees e inner join departments d
        on e.department_id = d.department_id
        where d.department_id = &deptid;
begin
    for emp_record in emp_cursor loop
        DBMS_OUTPUT.PUT_LINE('사원이름 : ' || emp_record.last_name || ' 입사일자 : ' || emp_record.hire_date || ' 부서명 : ' || emp_record.department_name);
    end loop;
end;
/

-- 4. 부서번호를 입력 (&사용)하면 소속된 사원의 사원번호, 사원이름, 부서번호를 출력하는 PL/SQL을 작성하시오 (단, cursor 사용)
declare 
    cursor emp_cursor is
        select employee_id, last_name, department_id
        from employees
        where department_id = &deptid;
begin
    for emp_record in emp_cursor loop
        DBMS_OUTPUT.PUT_LINE('사원번호 : ' || emp_record.employee_id || ' 사원이름 : ' || emp_record.last_name || ' 부서번호 : ' || emp_record.department_id);
    end loop;
end;
/

-- 5. 부서번호를 입력(&사용)할 경우 사원이름, 급여, 연봉 -> (급여*12+(급여*nvl(커미션퍼센트,0)*12))을 출력하는 PL/SQL을 작성하시오(단, cursor 사용)
declare 
    cursor emp_cursor is
        select last_name, salary, salary*12 + (salary * NVL(commission_pct,0)*12) as annual_sal
        from employees
        where department_id = &deptid;
begin
    for emp_record in emp_cursor loop
        DBMS_OUTPUT.PUT_LINE(' 사원이름 : ' || emp_record.last_name || ' 급여 : ' || emp_record.salary || ' 연봉 : ' || emp_record.annual_sal);
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
        DBMS_OUTPUT.PUT_LINE(' 사원이름 : ' || emp_record.last_name || ' 급여 : ' || emp_record.salary || ' 연봉 : ' || (emp_record.salary * 12 + (emp_record.salary*nvl(emp_record.commission_pct, 0)*12)));
    end loop;
end;
/

-- 예외이름과 발생환경을 모두 오라클에서 정의한거랑 연동
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

-- 발생환경만 오라클에 정의된경우에는 1.declare에 예외이름을 정의하고 기존의 오라클 오류와 연결
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

-- 예외이름도 발생환경도 모두 정의되지 않은 경우 1.DECLARE에 예외이름을 정의.
--                                       2.RAISE를 이용하여 발생환경을 정의
--                                       3.Exception절에 Handling처리
DECLARE
    e_invalid_department Exception;
    v_deptno number :=500;
    v_name varchar(20) := 'Testing';
begin
    update departments
    set department_name = v_name
    where department_id = v_deptno;
    
    if SQL%NOTFOUND then --정상작동 안할때 예외
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
VALUES ('이 사원은 보너스가 '||v_empcomm||'으로 월급여 '||v_empsal||' 보다 많다');
WHEN OTHERS THEN
v_errorcode := SQLCODE;
v_errortext := SUBSTR(SQLERRM, 1, 200);
INSERT INTO log_table
VALUES (v_errorcode, v_errortext, 'Oracle error occurred');
END;
/

select * from log_table;

declare
    v_num number := &num; -- 값을 넘겨받는다
begin
    if v_num <= 0 then --값이 음수면
        raise_application_error(-20100,'양수만 입력받을 수 있습니다.');
    end if;
    
    DBMS_OUTPUT.PUT_LINE(v_num);
    
exception
    when no_data_found then
    DBMS_OUTPUT.PUT_LINE('데이터가 존재하지 않습니다.');
    when others then
        if sqlcode = -20100 then
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
        else
        DBMS_OUTPUT.PUT_LINE('의도하지 않은 예외사항입니다.');
        end if;
end;
/

drop table emp_test;

create table emp_test
as
select employee_id, last_name
from employees
where employee_id < 200;

--emp_test 테이블에서 사원번호를 사용(&치환변수 사용)하여 사원을 삭제하는 PL/SQL을 작성
--(단, 사용자 정의 예외사항 사용 / 단, 사원이 없으면 "해당사원이 없습니다."라는 오류메시지 발생)
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
    DBMS_OUTPUT.PUT_LINE('해당사원 없습니다.');
END;
/

-- 2. 사원테이블에서 사원번호를 입력받아 10% 인상된 급여로 수정하는 PL/SQL을 작성하시오
-- 단, 2000년(포함) 이후 입사한 사원은 갱신하지 않고 "2000년 이후 입사한 사원입니다." (<-exception절 사용)라고 출력되도록 하시오.
declare
    v_empid employees.employee_id%TYPE := &empid;
    v_hire employees.hire_date%TYPE;
    e_hiredate exception;
begin
--입력받은 사원번호를 이용해서 입사일을 조회
    select hire_date
    into v_hire
    from employees
    where employee_id = v_empid;
    
-- 입사일이 2000년 이전일 경우에만 급여를 10%인상
    if v_hire >= to_date('2000/12/31','yyyy/mm/dd') then
        raise e_hiredate;
    end if;
    
    update employees 
    set salary = salary * 1.1
    where employee_id = v_empid;
exception
when e_hiredate then
    DBMS_OUTPUT.PUT_LINE('2000년대 이후 입사한 사원입니다.');
end;
/

-- 3-1 사원테이블에서 부서번호를 입력(&사용)받아 (<-cursor사용) 10% 인상된 급여로 수정하는 PL/SQL을 작성
-- 단, 2000년(포함) 이후 입사한 사원은 갱신하지 않고 "2000년 이후 입사한 사원은 갱신되지않습니다." (<-exception절 사용) 라고 출력되도록 하시오
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









    
-- 3-2 사원테이블에서 부서번호를 입력(&사용)받아 (<-cursor사용) 10% 인상된 급여로 수정하는 PL/SQL을 작성
-- 단, 해당 부서에 사원이 없으면 "해당 부서에는 사원이 없습니다." (<-exception절 사용) 라고 출력되도록 하시오

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
        RAISE_APPLICATION_ERROR(-20101, '입력하신 번호는 없는 회원입니다');
    else
        update employees 
        set salary = salary*1.1 
        where employee_id = v_no
        AND to_date(hire_date,'RR/MM/DD') < to_date('00/01/01','RR/MM/DD');
        
        if SQL%NOTFOUND then
            RAISE_APPLICATION_ERROR(-20100, '2000년 이후에 입사한 회원입니다');
        end if;
    end if;
  EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('입력하신 번호는 없는 회원입니다.');
        WHEN OTHERS THEN
            IF SQLCODE = -20100 THEN
                DBMS_OUTPUT.PUT_LINE(SQLERRM);
            ELSE
                DBMS_OUTPUT.PUT_LINE('의도하지 않은 예외사항입니다.');
            END IF;
END;
/