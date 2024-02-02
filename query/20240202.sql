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

















