-- 1. View

CREATE VIEW T_EMP AS SELECT * FROM emp;

SELECT * FROM T_EMP;

DROP VIEW T_EMP;


-- 2. 테이블 연습 준비
--테이블 구조 및 데이터 복사하기
--CREATE TABLE 신규테이블명 AS SELECT * FROM 복사할테이블명 [WHERE]
-- 
--테이블 구조만 복사하기
--CREATE TABLE 신규테이블명 AS SELECT * FROM 복사할테이블명 WHERE 1=2
-- 
--테이블이 존재할경우, 데이터만 복사하기(구조가 같은경우)
--INSERT INTO 복사대상테이블명 SELECT * FROM 원본테이블명 [WHERE]
-- 
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

SELECT ename AS "이름" FROM emp a WHERE a.EMPNO = 7369;


-- 5. where 문
SELECT * FROM emp1;

SELECT * FROM emp WHERE empno >= 7569 AND sal >= 1500;

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
--DROP TABLE DEPT1;
INSERT INTO dept1 (DEPTNO, DNAME, LOC) VALUES (5, 'DEVELOPEMENT', 'SEOUL');
UPDATE DEPT1 SET DEPTNO = 50 WHERE deptno = 5;
--DELETE FROM dept1 WHERE deptno = 60;
INSERT INTO dept1 (DEPTNO, DNAME, LOC) VALUES (60, 'UNKNOWN', 'TOKYO');
INSERT INTO DEPT1 (DEPTNO, LOC) VALUES (70, 'OSAKA');
INSERT INTO emp1 (empno, ename, job, mgr, HIREDATE, sal, deptno)
	VALUES (
		1014,
		'DANAKA',
		'SALESMAN',
		7190,
		TO_TIMESTAMP('1989-12-22 00:00:00.000', 'YYYY-MM-DD HH24:MI:SS.FF'),
		2000,
		70
);
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
SELECT E1.EMPNO,
       E1.ENAME,
       E1.JOB,
       COALESCE(D1.DNAME, 'No Department') AS DEPARTMENT
FROM EMP1 E1 LEFT JOIN DEPT1 D1 ON E1.DEPTNO = D1.DEPTNO;


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
HAVING SUM(sal) > 10000;


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
SELECT deptno, mgr, avg(sal)
FROM emp1
GROUP BY deptno, mgr ORDER BY avg(sal) desc;

-- 직업별 급여합계 중 급여(sal)합계가 1000 이상인 직업(job)
SELECT job, sum(sal)
FROM emp1
GROUP BY job HAVING sum(sal) >= 5000 ORDER BY sum(sal) desc;

-- 사원번호 1000 ~ 1005 번의 부서별 급여합계
SELECT deptno, sum(sal)
FROM emp1
WHERE empno BETWEEN 1000 AND 1005
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
--		- SUBSTR(문자열, m, n) : 문자열에서 m번째 위치부터 n개를 자른다(인덱스 규칙X)
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
		LENGTH ('A BC'),
		LTRIM(' ABC'),
		LENGTH(LTRIM(' ABC'))
FROM dual;

--	(2) 날짜형 함수
--		- SYSDATE : 오늘의 날짜를 날짜 타입으로 알려줌
--		- EXTRACT('YEAR'|'MONTH'|'DAY' from dual) : 오늘의 날짜를 날짜 타입으로 알려줌
SELECT	SYSDATE,
		EXTRACT(YEAR FROM sysdate) AS "년도",
		TO_CHAR(sysdate, 'YYYY-MM-DD') AS "날짜(파싱)"
FROM DUAL;

SELECT EXTRACT(YEAR FROM SYSDATE) AS current_year FROM DUAL;
SELECT 
    EXTRACT(MONTH FROM TIMESTAMP '2023-01-15 09:00:00') AS month,
    EXTRACT(DAY FROM TIMESTAMP '2023-01-15 09:00:00') AS day
FROM DUAL;
SELECT 
    EXTRACT(HOUR FROM INTERVAL '123:45' HOUR TO MINUTE) AS hours,
    EXTRACT(MINUTE FROM INTERVAL '123:45' HOUR TO MINUTE) AS minutes
FROM DUAL;

-- (3) 숫자형 함수
--		- ABS(숫자) : 절대값을 반환
--		- SIGN(숫자) : 양수(1), 음수(-1), 0(0)을 구별
--		- MOD(숫자1, 숫자2) : 숫자1을 숫자2로 나누어 나머지를 계산(%를 사용해도 됨)
--		- CEIL(숫자) / CEILING(숫자) : 올림, 숫자보다 크거나 같은 최소의 정수 반환
--		- FLOOR(숫자) : 내림, 숫자보다 작거나 같은 최대의 정수 반환
--		- ROUND(숫자, m) : 소수점 m자리에서 반올림(m의 기본값은 0)
--		- TRUNC(숫자, m) : 소수점 m자리에서 절삭(m의 기본값은 0)
SELECT	ABS(-1),
		SIGN(10),  
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

-- (2) CASE() : IF~THEN ... ELSE-END
SELECT * FROM emp1;

SELECT	ename,
		empno,
		CASE
			WHEN empno = 1000 THEN 'EMPEROR'
			WHEN empno between 1001 AND 1005 THEN 'ROYAL'
			ELSE 'SLAVE'
		END AS "계급"
FROM emp1;

































