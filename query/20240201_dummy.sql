
DROP TABLE dept3;
DROP TABLE emp3;

-- 더미 데이터 생성
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



insert into emp (empno, ename, job, mgr, hiredate, sal, comm, deptno)
values (7369, 'SMITH', 'CLERK', 7902, to_date('1980-12-17', 'YYYY-MM-DD'), 800, NULL, 20);
insert into emp (empno, ename, job, mgr, hiredate, sal, comm, deptno)
values (7499, 'ALLEN', 'SALESMAN', 7698, to_date('1981-02-20', 'YYYY-MM-DD'), 1600, 300, 30);
insert into emp (empno, ename, job, mgr, hiredate, sal, comm, deptno)
values (7521, 'WARD', 'SALESMAN', 7698, to_date('1981-02-22', 'YYYY-MM-DD'), 1250, 500, 30);
insert into emp (empno, ename, job, mgr, hiredate, sal, comm, deptno)
values (7566, 'JONES', 'MANAGER', 7839, to_date('1981-04-02', 'YYYY-MM-DD'), 2975, NULL, 20);
insert into emp (empno, ename, job, mgr, hiredate, sal, comm, deptno)
values (7654, 'MARTIN', 'SALESMAN', 7698, to_date('1981-09-28', 'YYYY-MM-DD'), 1250, 1400, 30);
insert into emp (empno, ename, job, mgr, hiredate, sal, comm, deptno)
values (7698, 'BLAKE', 'MANAGER', 7839, to_date('1981-05-01', 'YYYY-MM-DD'), 2850, NULL, 30);
insert into emp (empno, ename, job, mgr, hiredate, sal, comm, deptno)
values (7782, 'CLARK', 'MANAGER', 7839, to_date('1981-06-09', 'YYYY-MM-DD'), 2450, NULL, 10);
insert into emp (empno, ename, job, mgr, hiredate, sal, comm, deptno)
values (7788, 'SCOTT', 'ANALYST', 7566, to_date('1982-12-09', 'YYYY-MM-DD'), 3000, NULL, 20);
insert into emp (empno, ename, job, mgr, hiredate, sal, comm, deptno)
values (7839, 'KING', 'PRESIDENT', NULL, to_date('1981-11-17', 'YYYY-MM-DD'), 5000, NULL, 10);
insert into emp (empno, ename, job, mgr, hiredate, sal, comm, deptno)
values (7844, 'TURNER', 'SALESMAN', 7698, to_date('1981-09-08', 'YYYY-MM-DD'), 1500, 0, 30);
insert into emp (empno, ename, job, mgr, hiredate, sal, comm, deptno)
values (7876, 'ADAMS', 'CLERK', 7788, to_date('1983-01-12', 'YYYY-MM-DD'), 1100, NULL, 20);
insert into emp (empno, ename, job, mgr, hiredate, sal, comm, deptno)
values (7900, 'JAMES', 'CLERK', 7698, to_date('1981-12-03', 'YYYY-MM-DD'), 950, NULL, 30);
insert into emp (empno, ename, job, mgr, hiredate, sal, comm, deptno)
values (7902, 'FORD', 'ANALYST', 7566, to_date('1981-12-03', 'YYYY-MM-DD'), 3000, NULL, 20);
insert into emp (empno, ename, job, mgr, hiredate, sal, comm, deptno)
values (7934, 'MILLER', 'CLERK', 7782, to_date('1982-01-23', 'YYYY-MM-DD'), 1300, NULL, 10);










