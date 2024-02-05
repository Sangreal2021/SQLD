-- 1. View

CREATE VIEW T_EMP AS SELECT * FROM emp;

SELECT * FROM T_EMP;

DROP VIEW T_EMP;


-- 2. 테이블 연습 준비
--테이블 구조 및 데이터 복사하기
--CREATE TABLE 신규테이블명 AS SELECT * FROM 복사할테이블명 [WHERE]

--테이블 구조만 복사하기
--CREATE TABLE 신규테이블명 AS SELECT * FROM 복사할테이블명 WHERE 1=2

--테이블이 존재할경우, 데이터만 복사하기(구조가 같은경우)
--INSERT INTO 복사대상테이블명 SELECT * FROM 원본테이블명 [WHERE]

--테이블이 존재할경우, 데이터만 복사하기(구조가 다를경우)
--INSERT INTO 복사대상테이블명 (COL1, COL2) SELECT COL1, COL2 FROM 원본테이블명 [WHERE]

DROP TABLE dept1;
DROP TABLE emp1;

CREATE TABLE dept1 AS SELECT * FROM dept;
CREATE TABLE emp1 AS SELECT * FROM emp;

SELECT * FROM dept1;
SELECT * FROM emp1;


-- 3. 최대 저장할 수 있는 공간
-- 	(1) DELETE vs TRUNCATE
--		- DELETE : 테이블 용량은 감소하지 않음
--		- TRUNCATE : 테이블의 용량 초기화

SELECT TABLE_NAME, MAX_EXTENTS
FROM USER_TABLES;


-- 4. Distinct, Alias
-- 	(1) Distinct : 중복된 데이트를 한 번만 조회
--	(2) Alias : 별칭
SELECT deptno FROM emp ORDER BY DEPTNO;

SELECT DISTINCT deptno FROM emp ORDER BY DEPTNO;

SELECT ename AS "이름" FROM emp a WHERE a.EMPNO = 1000;


-- 5. where 문
SELECT * FROM emp1;

SELECT * FROM emp WHERE empno >= 1000 AND sal >= 1500;

SELECT * FROM emp WHERE ename LIKE '%N';

SELECT * FROM EMP WHERE sal BETWEEN 1000 AND 2000;

-- BETWEEN a AND b : a 이상, b 이하
-- NOT BETWEEN a AND b : a 미만, b 초과
-- IN (a, b) : a 또는 b
SELECT * FROM emp WHERE job IN ('CLERK', 'MANAGER');

SELECT * FROM EMP WHERE (job, ename) IN (('CLERK','SMITH'), ('MANAGER','BLAKE'));


-- 6. NULL 관련 함수
-- 	(1) NVL 함수 : NVL(MGR, 0) - MGR 칼럼이 NULL이면 0으로 바꿈
--	(2) NVL2 함수 : NVL2(MGR, 1, 0) - MGR 칼럼이 NULL이 아니면 1, NULL이면 0 반환
--	(3) NULLIF 함수 : NULLIF(exp1, exp2) - exp1과 exp2가 같으면 NULL, 다르면 exp1 반환
--	(4) COALESCE : COALESCE(exp1, exp2, ...) - exp1이 NULL이 아니면 exp1의 값을,
--			그렇지 않으면 그 뒤의 값의 NULL 여부를 판단하여 값을 반환
SELECT * FROM EMP WHERE MGR IS NULL ;
SELECT * FROM EMP WHERE MGR IS NOT NULL ;

SELECT * FROM emp1;
SELECT * FROM dept1;
DROP TABLE DEPT1;
--INSERT INTO dept1 (DEPTNO, DNAME, LOC) VALUES (5, 'DEVELOPEMENT', 'SEOUL');
--UPDATE DEPT1 SET DEPTNO = 50 WHERE deptno = 5;
--DELETE FROM dept1 WHERE deptno = 60;
--INSERT INTO dept1 (DEPTNO, DNAME, LOC) VALUES (60, 'UNKNOWN', 'TOKYO');
--INSERT INTO DEPT1 (DEPTNO, LOC) VALUES (70, 'OSAKA');
--INSERT INTO emp1 (empno, ename, job, mgr, HIREDATE, sal, deptno)
--	VALUES (
--		1014,
--		'DANAKA',
--		'SALESMAN',
--		7190,
--		TO_TIMESTAMP('1989-12-22 00:00:00.000', 'YYYY-MM-DD HH24:MI:SS.FF'),
--		2000,
--		70
--);

-- ※ 날짜 관련
--	(1) TO_DATE('1989-12-22', 'YYYY-MM-DD')
--	(2) TO_TIMESTAMP('1989-12-22 00:00:00.000', 'YYYY-MM-DD HH24:MI:SS.FF')
--	(3) SYSDATE : 초 단위까지
--	(4) CURRENT_TIMESTAMP : 밀리초 단위까지


-- 1) NVL(MGR, 0) : MGR 컬럼이 NULL이면 0으로 바꿈
SELECT NVL(MGR, 0) FROM EMP WHERE EMPNO = 1001;
SELECT NVL(MGR, 0) FROM EMP WHERE EMPNO = 1000;

-- 2) NVL2(MGR, 1, 0) : MGR 컬럼이 NULL이 아니면 1을, NULL이면 0을 반환
SELECT NVL2(MGR, 1, 0) FROM EMP WHERE EMPNO = 1001;
SELECT NVL2(MGR, 1, 0) FROM EMP WHERE EMPNO = 1000;

-- 3) NULLIF(exp1, exp2) : exp1 = exp2이면 NULL을 exp1 != exp2이면 exp1을 반환
-- 이 함수는 데이터 변환 또는 데이터 정제 과정에서 유용하게 사용됩니다.
-- 예를 들어, 특정 조건에서 값이 유효하지 않거나 기대하지 않는 경우에 NULL 값을 할당하여 이후 처리에서 제외시킬 수 있음.
SELECT * FROM dept1;
SELECT * FROM emp1;

SELECT EMPNO,
       ENAME,
       JOB,
       NULLIF(COMM, 0) AS COMM
FROM EMP1;

SELECT DEPTNO,
       NULLIF(DNAME, 'UNKNOWN') AS DNAME,
       LOC
FROM DEPT1;

-- 4) COALESCE(exp1, exp2, exp3, ...)
-- 입력된 인자 목록 중에서 첫 번째 NULL이 아닌 값을 반환합니다.
-- COALESCE 함수가 리스트의 모든 값을 순차적으로 검사하고, 모든 값이 NULL이면 리스트의 마지막 값을 반환한다는 것을 의미.
--	인자 전부 NULL이면 NULL 값을 반환
-- 이 함수는 데이터 처리 시 기본값을 제공하거나, 여러 컬럼 중 유효한 값을 선택해야 할 때 유용하게 사용.
SELECT * FROM dept1;
SELECT * FROM emp1;

-- 	EMP 테이블에서 사원의 커미션(COMM)과 급여(SAL) 사용하기:
-- 		급여는 존재하지만 COMM은 존재하지 않을 수 있으므로..
-- 	사원의 커미션(COMM)이 NULL인 경우, 다음 인자인 '0'을 반환해서 급여(SAL)를 더해 총 수입을 계산하는 예시
SELECT EMPNO,
       ENAME,
       JOB,
       SAL,
       COMM,
       COALESCE(COMM, 0) + SAL AS TOTAL_INCOME
FROM EMP1;

-- DEPT 테이블과 EMP 테이블을 조인(LEFT JOIN)하여 부서명이 없는 경우 대체값 사용하기:
-- 	사원이 속한 부서의 이름(DNAME)을 표시하되, 어떤 이유로 부서 이름이 NULL로 되어 있는 경우
-- 	'No Department'라는 기본값을 제공하는 예시
-- 아래의 쿼리에서는 EMP1 테이블을 "왼쪽" 테이블로, DEPT1 테이블을 "오른쪽" 테이블로 사용하여 LEFT JOIN을 수행함.
-- 여기서 EMP1 테이블은 사원 정보를, DEPT1 테이블은 부서 정보를 담고 있습니다.
-- EMP1 테이블의 모든 행은 결과에 포함됩니다. 즉, 모든 사원 정보가 쿼리 결과에 나타납니다.
-- EMP1 테이블의 각 행에 대해, DEPTNO 컬럼을 사용하여 DEPT1 테이블의 DEPTNO 컬럼과 매칭을 시도합니다.
SELECT E1.empno,
       E1.deptno,
       E1.ename,
       E1.job,
       COALESCE(D1.dname, 'No Department') AS DEPARTMENT
FROM EMP1 E1 LEFT JOIN DEPT1 D1 ON E1.deptno = D1.deptno;


-- 7. GROUP BY
--	: 소규모 행을 그룹화하여 합계, 평균, 최대값, 초소값 등을 계산
SELECT * FROM EMP1;
SELECT * FROM DEPT1;

SELECT	deptno,
		SUM(SAL)
FROM emp1 GROUP BY deptno ORDER BY SUM(sal) DESC;

-- 8. HAVING문
--	: GROUP BY에 조건절을 사용하기 위한 조건문
SELECT	deptno, 
		SUM(sal)
FROM EMP GROUP BY deptno
HAVING SUM(sal) > 5000;


-- 9. 집계 함수
--	(1) COUNT() : 행 수를 조회
--	(2)	SUM() : 합계를 계산
--	(3)	AVG() : 평균을 계산
--	(4)	MAX(), MIN() : 최대값과 최소값을 계산
--	(5)	STDDEV() : 표준편차를 계산
--	(6)	VARIAN() : 분산을 계산

-- (1) COUNT()
--	- COUNT(*) : NULL 값 포함 모든 행 수
--	- COUNT(칼럼명) : NULL 값 제외 행 수
SELECT * FROM emp1;

SELECT count(*) FROM emp1;
SELECT count(MGR) FROM emp1;

-- 부서별, 관리자별 급여평균 계산
SELECT	deptno,
		ROUND(avg(sal), 2) AS "avg"
FROM	emp1
GROUP BY deptno ORDER BY avg(sal) asc;

SELECT	mgr,
		ROUND(avg(sal), 2) AS "avg"
FROM	emp1
GROUP BY mgr ORDER BY avg(sal) asc;

SELECT	deptno, mgr, avg(sal)
FROM	emp1
GROUP BY deptno, mgr ORDER BY avg(sal) ASC;

-- 직업별 급여합계 중 급여(sal)합계가 5000 이상인 직업(job)
SELECT	job, sum(sal)
FROM	emp1
GROUP BY job HAVING sum(sal) >= 5000 ORDER BY sum(sal) desc;

-- 사원번호 1000 ~ 1005 번의 부서별 급여합계
SELECT	deptno, sum(sal)
FROM	emp1
WHERE	empno BETWEEN 1000 AND 1005
GROUP BY deptno;


-- 10. 명시적 형변환과 암시적 형변환
--	- 명시적 형변환 : SQL 개발자가 형변환 함수를 사용해서 형변환을 수행하는 것.
-- 	- 암시작 형변환 : sQL 개발자가 형변환을 수행하지 않았을 경우 DB 관리 시스템이
--		내부적으로 형변환을 수행.
-- 형변환 함수
-- 	(1) TO_NUMBER(문자열) : 문자열을 숫자로 변환
--	(2) TO_CHAR(숫자 혹은 날짜.[FORMAT]) : 숫자 혹은 날짜를 지정된 FORMAT의 문자로 변환
--	(3) TO_DATE(문자열, FORMAT) : 문자열을 지정된 FORMAT의 날짜형으로 변환


-- 11. 내장형 함수
--	(1) 문자열 함수
--		- ASCII(문자) : 문자 혹은 숫자를 ASCII 코드값으로 변환
--		- CHAR(ASCII 코드값) : ASCII 코드값을 문자롤 변환
--		- SUBSTR(문자열, m, n) : 문자열에서 m번째 위치부터 n개를 뽑아서 출력(인덱스 규칙X)
--		- CONCAT(문자열1, 문자열2) : 문자열1번과 문자열2번을 결합
--			Oracle은 '||', MS-SQL은 '+' 를 사용할 수 있음
--		- LOWER(문자열) : 영문자를 소문자로 변환
--		- UPPER(문자열) : 영문자를 대문자로 변환
--		- LENGTH(문자열) or LEN(문자열) : 공백을 포함, 문자열의 길이를 알려줌
--		- LTRIM(문자열, 지정문자) : 왼쪽에서 지정된 문자를 삭제(지정된 문자 생략시 공백을 삭제)
--		- RTRIM(문자열) : 오른쪽에서 지정된 문자를 삭제(지정된 문자 생략시 공백을 삭제)
--		- TRIM(문자열) : 왼쪽 및 오른쪽에서 지정된 문자를 삭제(지정된 문자 생략시 공백을 삭제)
SELECT	ASCII('a'),
		SUBSTR('ABC', 2, 2),
		CONCAT('Java', 'Script'),
		LENGTH ('A BC'),
		LTRIM(' ABC'),
		LENGTH(LTRIM(' ABC'))
FROM	dual;

SELECT	'Java' || 'Script' AS "concat"
FROM	DUAL;

--	(2) 날짜형 함수
--		- SYSDATE : 오늘의 날짜를 날짜 타입으로 알려줌
--		- EXTRACT('YEAR'|'MONTH'|'DAY' from dual) : 오늘의 날짜를 날짜 타입으로 알려줌
SELECT	SYSDATE,
		EXTRACT(YEAR FROM sysdate) AS "년도",
		EXTRACT(MONTH FROM sysdate) AS "월",
		EXTRACT(DAY FROM sysdate) AS "일",
		TO_CHAR(sysdate, 'YYYY-MM-DD') AS "날짜(파싱)"
FROM	DUAL;

SELECT EXTRACT(YEAR FROM SYSDATE) AS current_year FROM DUAL;

SELECT 
    EXTRACT(MONTH FROM TIMESTAMP '2023-01-15 09:00:00') AS month,
    EXTRACT(DAY FROM TIMESTAMP '2023-01-15 09:00:00') AS day
FROM DUAL;

-- INTERVAL '123:45' - 123시간 45분의 지속기간
-- 즉, HOUR FROM INTERVAL '123:45' 는 5일 3시간 45분을 의미
-- EXTRACT()로 시간을 추출하면 남는 3시간이 출력
SELECT
	EXTRACT(DAY FROM INTERVAL '123:45' HOUR TO MINUTE) AS days,
    EXTRACT(HOUR FROM INTERVAL '123:45' HOUR TO MINUTE) AS hours,
    EXTRACT(MINUTE FROM INTERVAL '123:45' HOUR TO MINUTE) AS minutes
FROM DUAL;

-- (3) 숫자형 함수
--		- ABS(숫자) : 절대값을 반환
--		- SIGN(숫자) : 양수(1), 음수(-1), 0(0)을 구별
--		- MOD(숫자1, 숫자2) : 숫자1을 숫자2로 나누어 나머지를 계산
--		- CEIL(숫자) or CEILING(숫자) : 올림, 숫자보다 크거나 같은 최소의 정수 반환
--		- FLOOR(숫자) : 내림, 숫자보다 작거나 같은 최대의 정수 반환
--		- ROUND(숫자, m) : 소수점 m자리가 되도록 반올림(m의 기본값은 0)
--		- TRUNC(숫자, m) : 소수점 m자리가 되도록 절삭(m의 기본값은 0)
SELECT	ABS(-1),
		SIGN(10),
		(5 / 2),
		MOD(5, 2),
		CEIL(10.9),
		FLOOR(10.1),
		ROUND(10.222, 1),
		TRUNC(10.321, 2)
FROM DUAL;


-- 12. DECODE와 CASE 문
--	(1) DECODE(exp1, 1000, 'TRUE', 'FALSE') : exp1 = 1000이면 TRUE 반환, exp1 != 1000이면 FALSE 반환
SELECT DECODE(empno, 1000, 'KING', 'SLAVE') 
FROM emp1;

--	(2) CASE() : IF~THEN ... ELSE-END
SELECT * FROM emp1;

SELECT	ename,
		empno,
		CASE
			WHEN empno = 1000 THEN 'KING'
			WHEN empno BETWEEN 1001 AND 1003 THEN 'ROYAL'
			ELSE 'SLAVE'
		END AS "CLASS"
FROM 	emp1;
		

-- 13. ROWNUM과 ROWID
-- 	(1) ROWNUM
--		- ORACLE의 select문 결과에 대해 논리적 일련번호를 부여
--		- 조회되는 행 수를 제한할 때 많이 사용
--		- 화면에 데이터를 출력할 때 부여되는 논리적 순번
--	※ Inline View
--		- SELECT문에서 FROM절에 사용되는 서브쿼리를 의미
SELECT * FROM emp1
WHERE rownum <= 5;


-- 인라인 뷰를 사용하고 ROWNUM에 별칭을 사용해야 함
SELECT * FROM (SELECT * FROM emp1) a;

SELECT * FROM 
	(SELECT ROWNUM list, empno, ename, mgr FROM emp1)
WHERE list <= 5;

SELECT * FROM
	(SELECT ROWNUM list, empno, ename, mgr FROM emp1)
WHERE list BETWEEN 5 AND 10;

-- SQL Server
--SELECT * TOP(10) FROM emp1;

-- MySQL
--SELECT * FROM emp1 LIMIT 10;

-- (2) ROWID
--		- ORACLE에서 데이터를 구분할 수 있는 유일한 값
--		- select 문으로 확인 가능
--		- 데이터가 어떤 데이터 파일, 어느 블록에 저장되어 있는지 알 수 있음
SELECT rowid, empno, ename
FROM emp1;


-- 14. WITH 구문
--	- 서브쿼리를 사용해서 임시 테이블이나 뷰처럼 사용할 수 있는 구문
--	- 서브쿼리 블록에 별칭을 지정할 수 있음
--	- 옵티마이저는 SQL을 인라인 뷰나 임시 테이블로 판단함
WITH viewData AS
	(SELECT * FROM EMP1
		UNION ALL
	SELECT * FROM EMP1
	)
SELECT * FROM viewData WHERE empno = 1000;

-- Q. EMP 테이블에서 WITH 구문을 사용해서 부서번호가 30인 것의 임시 테이블을 만들고 조회하기.
WITH W_EMP AS
	(SELECT * FROM emp1 WHERE deptno=30)
SELECT * FROM W_EMP;


-- 15. DCL(Data Control Language)
--	(1) GRANT : 권한 부여
--		"GRANT privileges ON object TO user;"
--		1) Privileges(권한)
--			- SELECT 
--			- INSERT
--			- UPDATE
--			- DELETE
--			- REFERENCES : 지정된 테이블을 참조하는 제약조건을 생성하는 권한
--			- ALTER : 지정된 테이블에 대해 수정할 수 있는 권한
--			- INDEX : 지정된 테이블에 대해 인덱스를 생성할 수 있는 권한
--			- ALL : 테이블에 대한 모든 권한
GRANT SELECT, INSERT, UPDATE, DELETE
	ON emp1
	TO hiw15;

--	(2) WITH GRANT OPTION
--		1) GRANT 옵션
--			- WITH GRANT OPTION : 특정 사용자에게 권한을 부여할 수 있는 권한을 부여.
--			- WITH ADMIN OPTION : 테이블에 대한 모든 권한을 부여
--				A -> B, B -> C 이후 B권한 취소시 C의 권한은 유지됨
GRANT SELECT, INSERT, UPDATE, DELETE 
	ON emp1
	TO hiw15 WITH GRANT OPTION;

-- (2) REVOKE : 권한 회수
--		"REVOKE privileges ON object TO user;"


-- 16. TCL(Transaction Control Language)
--	(1) COMMIT
--		- INSERT, UPDATE, DELETE문으로 변경한 데이터를 DB에 반영
--		- 변경 이전 데이터는 잃어버림
--	※ Auto commit
--		- SQLPLUS 프로그램을 정상적으로 종료시 자동 COMMIT 됨.
--		- DDL 및 DCL을 사용하는 경우 자동 COMMIT 됨.
--		- "set autocommit on;"을 SQLPLUS에서 실행하면 자동 COMMIT 됨.

--	(2) ROLLBACK
--		- ROLLBACK을 실행하면 데이터에 대한 변경 사용을 모두 취소하고 트랜잭션을 종료함.
--		- INSERT, UPDATE, DELETE문의 작업을 모두 취소함. 단, 이전에 COMMIT한 곳까지만 복구.

--	(3) SAVEPOINT(저장점)
--		- 트랜잭선을 작게 분할하여 관리하는 것. SAVEPOINT를 사용하면 지정된 위치 이후의
--			트랜잭션만 ROLLBACK 할 수 있음.
--		- SAVEPOINT t1; (t1 : SAVEPOINT명)
--		- 지정된 SAVEPOINT까지만 데이터 변경을 취소하고 싶은 경우, ROLLBACK TO t1; 을 실행.
--		- ROLLBACK; 을 실행하면 SAVEPOINT와 관계없이 데이터의 모든 변경사항을 저장하지 않음.

























