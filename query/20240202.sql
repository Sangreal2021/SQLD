-- 1. Example 테이블 생성 (DEPT, EMP)

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


-- 2. 테이블 연습 준비 (DEPT1, EMP1)
--	(1) 테이블 구조 및 데이터 복사하기
--		CREATE TABLE 신규테이블명 AS SELECT * FROM 복사할테이블명 [WHERE]

--	(2) 테이블 구조만 복사하기
--		CREATE TABLE 신규테이블명 AS SELECT * FROM 복사할테이블명 WHERE 1=2

--	(3) 테이블이 존재할경우, 데이터만 복사하기(구조가 같은경우)
--		INSERT INTO 복사대상테이블명 SELECT * FROM 원본테이블명 [WHERE]

--	(4) 테이블이 존재할경우, 데이터만 복사하기(구조가 다를경우)
--		INSERT INTO 복사대상테이블명 (COL1, COL2) SELECT COL1, COL2 FROM 원본테이블명 [WHERE]

DROP TABLE dept1;
DROP TABLE emp1;

CREATE TABLE dept1 AS SELECT * FROM dept;
CREATE TABLE emp1 AS SELECT * FROM emp;

SELECT * FROM dept1;
SELECT * FROM emp1;

----------------------------------------------------------------------------------------------------

-- 3. SQL 활용(dept3, emp3)

create table dept3(
    deptno number(2,0),
    dname varchar2(14),
    loc varchar2(13),
    constraint pk_dept3 primary key(deptno)
);

create table emp3(
    empno number(4,0),
    ename varchar2(10),
    job varchar2(9),
    mgr number(4,0),
    hiredate date,
    sal number(7,2),
    comm number(7,2),
    deptno number(2,0),
    constraint pk_emp3 primary key (empno),
    constraint fk_deptno3 foreign key (deptno) references dept (deptno)
);

insert into dept3 (deptno, dname, loc) values (10, 'ACCOUNTING', 'NEW YORK');
insert into dept3 (deptno, dname, loc) values (20, 'RESEARCH', 'DALLAS');
insert into dept3 (deptno, dname, loc) values (30, 'SALES', 'CHICAGO');
insert into dept3 (deptno, dname, loc) values (40, 'OPERATIONS', 'BOSTON');



insert into emp3 (empno, ename, job, mgr, hiredate, sal, comm, deptno)
values (7369, 'SMITH', 'CLERK', 7902, to_date('1980-12-17', 'YYYY-MM-DD'), 800, NULL, 20);
insert into emp3 (empno, ename, job, mgr, hiredate, sal, comm, deptno)
values (7499, 'ALLEN', 'SALESMAN', 7698, to_date('1981-02-20', 'YYYY-MM-DD'), 1600, 300, 30);
insert into emp3 (empno, ename, job, mgr, hiredate, sal, comm, deptno)
values (7521, 'WARD', 'SALESMAN', 7698, to_date('1981-02-22', 'YYYY-MM-DD'), 1250, 500, 30);
insert into emp3 (empno, ename, job, mgr, hiredate, sal, comm, deptno)
values (7566, 'JONES', 'MANAGER', 7839, to_date('1981-04-02', 'YYYY-MM-DD'), 2975, NULL, 20);
insert into emp3 (empno, ename, job, mgr, hiredate, sal, comm, deptno)
values (7654, 'MARTIN', 'SALESMAN', 7698, to_date('1981-09-28', 'YYYY-MM-DD'), 1250, 1400, 30);
insert into emp3 (empno, ename, job, mgr, hiredate, sal, comm, deptno)
values (7698, 'BLAKE', 'MANAGER', 7839, to_date('1981-05-01', 'YYYY-MM-DD'), 2850, NULL, 30);
insert into emp3 (empno, ename, job, mgr, hiredate, sal, comm, deptno)
values (7782, 'CLARK', 'MANAGER', 7839, to_date('1981-06-09', 'YYYY-MM-DD'), 2450, NULL, 10);
insert into emp3 (empno, ename, job, mgr, hiredate, sal, comm, deptno)
values (7788, 'SCOTT', 'ANALYST', 7566, to_date('1982-12-09', 'YYYY-MM-DD'), 3000, NULL, 20);
insert into emp3 (empno, ename, job, mgr, hiredate, sal, comm, deptno)
values (7839, 'KING', 'PRESIDENT', NULL, to_date('1981-11-17', 'YYYY-MM-DD'), 5000, NULL, 10);
insert into emp3 (empno, ename, job, mgr, hiredate, sal, comm, deptno)
values (7844, 'TURNER', 'SALESMAN', 7698, to_date('1981-09-08', 'YYYY-MM-DD'), 1500, 0, 30);
insert into emp3 (empno, ename, job, mgr, hiredate, sal, comm, deptno)
values (7876, 'ADAMS', 'CLERK', 7788, to_date('1983-01-12', 'YYYY-MM-DD'), 1100, NULL, 20);
insert into emp3 (empno, ename, job, mgr, hiredate, sal, comm, deptno)
values (7900, 'JAMES', 'CLERK', 7698, to_date('1981-12-03', 'YYYY-MM-DD'), 950, NULL, 30);
insert into emp3 (empno, ename, job, mgr, hiredate, sal, comm, deptno)
values (7902, 'FORD', 'ANALYST', 7566, to_date('1981-12-03', 'YYYY-MM-DD'), 3000, NULL, 20);
insert into emp3 (empno, ename, job, mgr, hiredate, sal, comm, deptno)
values (7934, 'MILLER', 'CLERK', 7782, to_date('1982-01-23', 'YYYY-MM-DD'), 1300, NULL, 10);


SELECT * FROM dept3;
SELECT * FROM emp3;




