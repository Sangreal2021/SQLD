SELECT * FROM dept;
SELECT * FROM emp;

CREATE TABLE dept1(
	deptno varchar2(4) PRIMARY KEY,
	deptname varchar2(20)
);

CREATE TABLE emp1(
	empno number(10),
	ename varchar2(20),
	sal number(10,2) DEFAULT 0,
	deptno varchar2(4) NOT NULL,
	createdate DATE DEFAULT sysdate,
	CONSTRAINT emp_pk PRIMARY KEY(empno),
	CONSTRAINT dept_fk FOREIGN KEY (deptno)
		REFERENCES dept1 (deptno)
);

SELECT * FROM dept1;
SELECT * FROM emp1;

DROP TABLE emp1;
DROP TABLE dept1;

SELECT sysdate FROM dual;


-- 뷰(view) 생성과 삭제
-- 뷰의 장단점
-- 	(1) 장점
--		- 보안 기능
--		- 데이터 관리가 간단
--		- select 문이 간단해짐
--	(2) 단점
--		- 독자적 인덱스를 만들 수 없음
--		- 삽입, 수정, 삭제 연산이 제약
--		- 데이터 구조를 변경X
CREATE VIEW T_EMP AS SELECT * FROM emp;
SELECT * FROM t_emp;

DROP VIEW t_emp;


-- distinct : 중복 데이터 삭제
SELECT deptno FROM emp ORDER BY deptno;
SELECT DISTINCT deptno FROM emp ORDER BY deptno;


SELECT * FROM emp;

SELECT * FROM emp
WHERE empno >= 7501 AND sal >= 1000;

-- example 생성
DROP TABLE emp;
DROP TABLE dept;

create table dept(
    deptno number(2,0),
    dname varchar2(14),
    loc varchar2(13),
    constraint pk_dept primary key(deptno)
);

create table emp(
    empno number(4,0),
    ename varchar2(10),
    job varchar2(9),
    mgr number(4,0),
    hiredate date,
    sal number(7,2),
    comm number(7,2),
    deptno number(2,0),
    constraint pk_emp primary key (empno),
    constraint fk_deptno foreign key (deptno) references dept (deptno)
);

insert into dept (deptno, dname, loc) values (10, 'ACCOUNTING', 'NEW YORK');
insert into dept (deptno, dname, loc) values (20, 'RESEARCH', 'DALLAS');
insert into dept (deptno, dname, loc) values (30, 'SALES', 'CHICAGO');
insert into dept (deptno, dname, loc) values (40, 'OPERATIONS', 'BOSTON');
INSERT INTO dept (deptno, dname, loc) VALUES (50, 'DEVELOPEMENT', 'SEOUL');
INSERT INTO dept (deptno, dname, loc) VALUES (60, 'UNKNOWN', 'TOKYO');
INSERT INTO dept (deptno, dname, loc) VALUES (70, NULL, 'OSAKA');

insert into emp (empno, ename, job, mgr, hiredate, sal, comm, deptno)
values (1001, 'SMITH', 'CLERK', 7902, to_date('1980-12-17', 'YYYY-MM-DD'), 800, NULL, 20);
insert into emp (empno, ename, job, mgr, hiredate, sal, comm, deptno)
values (1002, 'ALLEN', 'SALESMAN', 7698, to_date('1981-02-20', 'YYYY-MM-DD'), 1600, 300, 30);
insert into emp (empno, ename, job, mgr, hiredate, sal, comm, deptno)
values (1003, 'WARD', 'SALESMAN', 7698, to_date('1981-02-22', 'YYYY-MM-DD'), 1250, 500, 30);
insert into emp (empno, ename, job, mgr, hiredate, sal, comm, deptno)
values (1004, 'JONES', 'MANAGER', 7839, to_date('1981-04-02', 'YYYY-MM-DD'), 2975, NULL, 20);
insert into emp (empno, ename, job, mgr, hiredate, sal, comm, deptno)
values (1005, 'MARTIN', 'SALESMAN', 7698, to_date('1981-09-28', 'YYYY-MM-DD'), 1250, 1400, 30);
insert into emp (empno, ename, job, mgr, hiredate, sal, comm, deptno)
values (1006, 'BLAKE', 'MANAGER', 7839, to_date('1981-05-01', 'YYYY-MM-DD'), 2850, NULL, 30);
insert into emp (empno, ename, job, mgr, hiredate, sal, comm, deptno)
values (1007, 'CLARK', 'MANAGER', 7839, to_date('1981-06-09', 'YYYY-MM-DD'), 2450, NULL, 10);
insert into emp (empno, ename, job, mgr, hiredate, sal, comm, deptno)
values (1008, 'SCOTT', 'ANALYST', 7566, to_date('1982-12-09', 'YYYY-MM-DD'), 3000, NULL, 20);
insert into emp (empno, ename, job, mgr, hiredate, sal, comm, deptno)
values (1000, 'KING', 'PRESIDENT', NULL, to_date('1981-11-17', 'YYYY-MM-DD'), 5000, NULL, 10);
insert into emp (empno, ename, job, mgr, hiredate, sal, comm, deptno)
values (1009, 'TURNER', 'SALESMAN', 7698, to_date('1981-09-08', 'YYYY-MM-DD'), 1500, 0, 30);
insert into emp (empno, ename, job, mgr, hiredate, sal, comm, deptno)
values (1010, 'ADAMS', 'CLERK', 7788, to_date('1983-01-12', 'YYYY-MM-DD'), 1100, NULL, 20);
insert into emp (empno, ename, job, mgr, hiredate, sal, comm, deptno)
values (1011, 'JAMES', 'CLERK', 7698, to_date('1981-12-03', 'YYYY-MM-DD'), 950, NULL, 30);
insert into emp (empno, ename, job, mgr, hiredate, sal, comm, deptno)
values (1012, 'FORD', 'ANALYST', 7566, to_date('1981-12-03', 'YYYY-MM-DD'), 3000, NULL, 20);
insert into emp (empno, ename, job, mgr, hiredate, sal, comm, deptno)
values (1013, 'MILLER', 'CLERK', 7782, to_date('1982-01-23', 'YYYY-MM-DD'), 1300, NULL, 10);
insert into emp (empno, ename, job, mgr, hiredate, sal, comm, deptno)
values (1014, 'DANAKA', 'SALESMAN', 7082, to_date('1989-12-23', 'YYYY-MM-DD'), 2000, NULL, 70);


SELECT * FROM dept;
SELECT * FROM emp;













