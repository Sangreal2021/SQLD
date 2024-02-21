-- [SQL 문제풀이]

-- 11. (p.210)
-- LEAD(sal) : sal 칼럼의 다음 행을 보여줌
SELECT	ename,
		sal,
		LEAD(sal) OVER (ORDER BY ename) AS sal1
FROM emp3;


-- 12. (p.211)
SELECT * FROM emp3;

SELECT LEVEL, empno, ename, mgr
FROM emp3
	START WITH job = 'SALESMAN'
	CONNECT BY PRIOR empno = mgr;


-- 13. (p.211)
SELECT	DECODE(b.dname, NULL, '전체합계', b.dname) AS "DNAME",
		DECODE(a.job, NULL, '합계', a.job) AS "JOB",
		SUM(a.sal) AS "SAL(합계)",
		COUNT(a.empno) AS "COUNT(행수)"
FROM emp3 a, dept3 b
WHERE a.DEPTNO = b.DEPTNO
	GROUP BY ROLLUP(b.dname, a.job);


-- 06. (p.227)
--	- LOCAL 키워드 사용 -> Local Index
--	- RANGE 파티션 키(a) 와 인덱스(b)가 다름 -> Non Prefixed Index
--	- 즉, Local Non Prefixed Index


-- 10. (p.230)
-- 모든 관리자보다 월급이 많은 직원 조회
SELECT * FROM emp3;

SELECT a.*
FROM emp3 a, emp3 b
WHERE a.mgr = b.empno AND a.sal >= ANY b.sal;

SELECT a.*
FROM emp3 a JOIN emp3 b ON a.mgr = b.empno
WHERE a.sal >= b.sal;


-- 14. (p.231)
-- emp 테이블에서 MGR 칼럼값이 NULL이면 9999로 출력하는 쿼리문 작성
SELECT NVL(mgr, 9999) FROM emp3;


-- 18. (p.233)
-- 날짜 데이터를 문자로 바꾸고 연도만 출력
SELECT TO_CHAR(sysdate, 'yyyy') FROM dual;


-- 20. (p.233)
-- (1, 2) 와 1을 UNION으로 묶음 -> (1, 2)
SELECT 1 FROM dual
UNION
SELECT 2 FROM dual
UNION
SELECT 1 FROM dual;

-- (1, 2) 와 1을 UNION으로 묶음 -> (1, 2)
SELECT 1 FROM dual
UNION ALL
SELECT 2 FROM dual
UNION
SELECT 1 FROM dual;

-- (1, 2) 와 1을 UNION ALL로 묶음 -> (1, 2, 1)
SELECT 1 FROM dual
UNION
SELECT 2 FROM dual
UNION ALL
SELECT 1 FROM dual;


-- 23. (p.234)
SELECT * FROM emp3
INNER JOIN dept3 ON emp3.DEPTNO = dept3.DEPTNO;


-- 25. (p.235)
SELECT * FROM emp3 a
RIGHT OUTER JOIN dept3 b
	ON a.DEPTNO = b.DEPTNO;


-- 30. (p.236)
-- Ctrl+Shift+E -> 실행계획
-- FULL SCAN 된 것은 LIKE 조건에서 숫자 칼럼과 문자 값 간 형변환이 발생해서
-- empno는 기본키(자동으로 인덱스 생성)
SELECT * FROM emp3 WHERE empno LIKE '100%';


-- 59. (p.253)
SELECT	d.deptno,
		sum(NVL(e.sal,0)) AS total_sal
FROM	emp3 e
JOIN	dept3 d ON e.deptno=e.deptno
GROUP BY d.deptno;


-- 62. (p.255)
SELECT	deptno,
		job,
		sum(sal)
FROM	emp1
GROUP BY CUBE (deptno, job);

SELECT	deptno,
		job,
		sum(sal)
FROM	emp1
GROUP BY GROUPING SETS (deptno, job, (deptno, job));


-- 66. (p.257)
SELECT * FROM emp3;

SELECT * FROM emp3 WHERE (empno, ename) IN ((7369, 'SMITH'), (7499, 'ALLEN'));


-- 86. (p.270)
-- 테이블을 참조하지 않는 인덱스 생성
--	-> IOT(Index-Organized Table) 
--		: 인덱스의 Key가 Fetch하는 추출의 칼럼으로 이루어진 인덱스


-- 91. (p.274)
CREATE TABLE employee(
	eno number(10),
	ename varchar2(20),
	address varchar2(100),
	score number(5),
	dno number(3)
);

CREATE TABLE department(
	dno number(3),
	dname varchar2(20)
);
SELECT * FROM employee;

SELECT * FROM department;

INSERT INTO employee VALUES (10, 'Hong', '서울', 80, 100);
INSERT INTO employee VALUES (20, 'Kim', '대전', 90, 200);
INSERT INTO employee VALUES (30, 'Lee', '강릉', 90, 100);
INSERT INTO employee VALUES (40, 'Kim', '대전', 95, 200);
INSERT INTO employee VALUES (50, 'Hong', '서울', 65, 300);

INSERT INTO department VALUES (100, '영업');
INSERT INTO department VALUES (200, '개발');
INSERT INTO department VALUES (300, '서비스');

-- 문제
SELECT e.dno, d.dname, e.ename, e.score
FROM employee e, department d
WHERE e.dno=d.dno AND
	(e.dno, score) IN (SELECT dno, max(score) FROM employee GROUP BY dno);
-- 서브쿼리
SELECT dno, max(score) FROM employee GROUP BY dno;


-- 98. (p.279)
SELECT	deptno,
		ename,
		sal,
		LAST_VALUE(ename) OVER (PARTITION BY deptno
			ORDER BY sal DESC ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
		) AS "DEPT_A"
FROM 	emp1;

SELECT * FROM emp;


-- 99. (p.279)
--	1) UPDATE 예시
--	- e.empno와 n.empno가 일치하는 조건이 있다면 숫자 1을 반환.
--	- EXISTS는 해당 값이 존재한다면 TRUE를 반환(서브쿼리 결과가 비어있지 않으면 조건 만족)
--	- MILLER를 GREEN으로 대체
UPDATE emp_m e
SET (e.ename, e.job, e.hiredate, e.sal, e.deptno) = 
	(SELECT n.ename, n.job, n.hiredate, n.sal, n.deptno
     FROM new_emp_data n
     WHERE e.empno = n.empno)
WHERE EXISTS (
    SELECT 1 FROM new_emp_data n
    WHERE e.empno = n.empno
);

--	2) INSERT 예시
--	- DANAKA와 BECKHAM 추가
INSERT INTO emp_m (empno, ename, job, mgr, hiredate, sal, comm, deptno)
SELECT n.empno, n.ename, n.job, n.mgr, n.hiredate, n.sal, n.comm, n.deptno
FROM new_emp_data n
WHERE NOT EXISTS (
    SELECT 1 FROM emp_m e
    WHERE e.empno = n.empno
);

SELECT * FROM emp_m;

--	3) MERGE 예시 (UPDATE + INSERT)
DROP TABLE emp_m;
CREATE TABLE emp_m AS SELECT * FROM emp3;

MERGE INTO emp_m e
USING (SELECT empno, ename, job, mgr, hiredate, sal, comm, deptno FROM new_emp_data) n
ON (e.empno = n.empno)
WHEN MATCHED THEN
    UPDATE SET e.ename = n.ename,
               e.job = n.job,
               e.hiredate = n.hiredate,
               e.sal = n.sal,
               e.deptno = n.deptno
WHEN NOT MATCHED THEN
    INSERT (empno, ename, job, mgr, hiredate, sal, comm, deptno)
    VALUES (n.empno, n.ename, n.job, n.mgr, n.hiredate, n.sal, n.comm, n.deptno);
   
SELECT * FROM emp_m;


-- 101. (p.280)
SELECT * FROM (
	SELECT sysdate today FROM dual
	UNION ALL 
	SELECT sysdate-1 today FROM dual
)
ORDER BY today ASC;


-- 106. (p.282)
-- (1)
SELECT rownum, ename FROM emp3;
-- (2)
SELECT empno FROM emp3 WHERE rownum=1;
-- (3)
SELECT ename FROM emp3 WHERE rownum=2; -- X

SELECT * FROM (SELECT rownum top, ename FROM emp3) a
WHERE a.top=2; -- O (인라인 뷰 사용)
-- (4)
SELECT deptno FROM emp3 WHERE rownum<10;


-- 110. (p.284)
--	차수(Degree) : 테이블에서 컬럼(속성)의 수
--	카디널리티(Cardinality) : 한 테이블의 행이 다른 테이블의 몇 개의 행과 관계
--		를 맺을 수 있는지를 나타내는 개념(1:1, 1:N, N:M)


-- 116. (p.287)
SELECT NEXT_DAY(ADD_MONTHS(SYSDATE, 6), '월요일') D_DAY FROM dual;
-- ADD_MONTH(date, integer) : 지정된 날짜에 몇 개월을 더하거나 빼서 새로운 날짜 계산
-- NEXT_DAY(date, 'day_name') : 지정된 날짜 이후의 첫 번째 특정 요일을 검색


-- 120. (p.288)
SELECT * FROM emp3;

SELECT empno, ename, deptno FROM emp3
WHERE EXISTS (SELECT * FROM emp3 WHERE empno=7698) AND deptno=30;


-- 124. (p.290)
SELECT * FROM (SELECT ROWNUM AS list, empno FROM emp3)
WHERE list <= 5;


-- 125. (p.290)
SELECT * FROM dept3;
SELECT * FROM emp3;
INSERT INTO dept3 VALUES (50, 'DEVELOPMENT', 'TOKYO');

-- (1)
SELECT deptno FROM dept3
WHERE deptno NOT IN (SELECT deptno FROM emp3);
-- (2)
SELECT deptno FROM dept3 a
WHERE NOT EXISTS (SELECT * FROM emp3 b WHERE a.deptno=b.deptno);
-- (3) 
SELECT b.deptno FROM emp3 a RIGHT OUTER JOIN dept3 b
	ON a.deptno=b.deptno WHERE empno IS NULL;

-- (4)
-- emp3 테이블에서 어떤 deptno라도 주어진 dept3.deptno와 다른 경우가 있으면 참을 반환
SELECT deptno FROM dept3
WHERE deptno <> ANY (SELECT deptno FROM emp3);


-- 142. (p.298)
SELECT * FROM emp3;

SELECT DECODE(empno, 7369, 'SMITH_OK', 'UNKNOWN') TEST FROM emp3;

SELECT CASE 
		empno WHEN 7369 THEN 'SMITH_OK'
		ELSE 'UNKNOWN'
	END TEST
FROM emp3;


-- 24. (p.314)
--	1) VARCHAR(가변길이 문자형)은 비교시 서로 길이가 다를 경우 서로 다른 내용으로 판단
--	2) CHAR()는 비교시 서로 길이가 다르면 짧은 쪽에 스페이스를 추가하여 같은 값으로 판단
--	3) 문자형과 숫자형을 비교시 문자형을 숫자형으로 묵시적 변환하여 비교
--	4) 연산자 실행순서 : 괄호 -> NOT -> 비교연산자 -> AND -> OR


-- 39. (p.320)
-- PL/SQL의 Cursor 사용 순서
--	OPEN -> FETCH -> CLOSE


-- 09. (p.328)
-- IE 표기법(ERD 표기법 중)
--	- 1 : N 관계에서 N쪽에 새발, 선택 참여에 O, 필수 참여에 | 표시


-- 14. (p.330)
--	1) DDL : CREATE, ALTER, RENAME, DROP, TRUNCATE
--	2) DML : INSERT, UPDATE, DELETE, SELECT
--	3) DCL : GRANT, REVOKE
--	4) TCL : COMMIT, ROLLBACK, SAVEPOINT


-- 20. (p.334)
--	- count(*) 함수는 조건절이 거짓일 때 0을 반환
SELECT NVL(count(*), 9999) FROM dual WHERE 1=0;


-- 22. (p.334)
--	PL/SQL
--		- 절차형 언어
--		- 테이블 생성이 가능함(주로 임시 테이블 용도)
--		- 조건문은 "IF ~ THEN ~ ELSEIF ~ END IF" 와 "CASE ~ WHEN"을 사용함 
--		- 변수에 대입시 ":=" 기호를 사용


-- 27. (p.336)
--	<> ANY 조건은 dept3의 deptno 중에서 emp3의 deptno 중 하나라도 다른 것이 있다면
--	true를 반환
SELECT deptno FROM dept3 WHERE deptno <> ANY (SELECT deptno FROM emp3);
SELECT deptno FROM dept3 WHERE 1=1;

SELECT d.deptno
FROM dept3 d LEFT JOIN emp3 e ON d.deptno = e.deptno
WHERE e.deptno IS NULL;































