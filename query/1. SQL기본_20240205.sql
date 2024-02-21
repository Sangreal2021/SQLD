-- [SQL 기본]

-- 1. DDL(Data Definition Language)
--	- CREATE, ALTER, DROP, RENAME, TRUNCATE
--	- 자동 commit 실행

-- 	(1) 테이블 생성
--		- 제약조건
--		1) 외래키(Foreign Key) 지정 : dept2의 deptno를 참조함
--		2) CASCADE : 참조 관계(기본키 - 외래키)가 있을 경우 참조되는 데이터를 자동으로 반영
--			- emp2 테이블의 '카리나' 행은 참조하고 있는 테이블 deptno의 '1000'을 삭제시 자동 삭제됨
--		3) 제약조건
--			- 테이블명과 칼럼명은 반드시 문자로 시작해야 함
--			- 테이블명은 영 대소문자, 숫자, '_', '$', '#'만 허용
DROP TABLE emp2;
DROP TABLE dept2;

CREATE TABLE dept2(
	deptno varchar2(4) PRIMARY KEY,
	dname varchar2(20)
);

INSERT INTO dept2 VALUES ('1000', '인사팀');
INSERT INTO dept2 VALUES ('1001', '총무팀');

CREATE TABLE emp2(
	empno number(10),
	ename varchar2(20),
	sal number(10,2) DEFAULT 0,
	deptno varchar2(4) NOT NULL,
	createdate DATE DEFAULT sysdate,
	CONSTRAINT emp2_pk PRIMARY KEY (empno),
	CONSTRAINT dept2_fk FOREIGN KEY (deptno)
		REFERENCES dept2 (deptno)
		ON DELETE CASCADE
);

INSERT INTO emp2 VALUES (100, '카리나', 1000, '1000', sysdate);
INSERT INTO emp2 VALUES (101, '차은우', 2000, '1001', sysdate);

SELECT * FROM dept2;
SELECT * FROM emp2;

DELETE FROM dept2 WHERE deptno = '1000';
SELECT * FROM emp2;

-- Q. EMP3 테이블에 DEPT3 테이블의 기본키 deptno 칼럼을 참조하는 외래키 dept_fk를
--	추가하고자 한다. 
ALTER TABLE		emp3
ADD CONSTRAINT	dept3_fk FOREIGN KEY (deptno)
REFERENCES		dept3 (deptno);


--	(2) 테이블 변경
--		1) 테이블명 변경
CREATE TABLE alter01(
	empno number(10),
	ename varchar2(20),
	sal number(10,2) DEFAULT 0,
	deptno varchar2(4) NOT NULL,
	createdate DATE DEFAULT sysdate
);

SELECT * FROM alter01;

ALTER TABLE alter01 RENAME TO alter_ex;

SELECT * FROM alter_ex;

--		2) 칼럼 추가
ALTER TABLE alter_ex ADD (age NUMBER(3) DEFAULT 1);

SELECT * FROM alter_ex;

--		3) 칼럼 변경
ALTER TABLE alter_ex MODIFY (ename varchar2(40) NOT NULL);

SELECT * FROM alter_ex;

--		4) 칼럼 삭제
ALTER TABLE alter_ex DROP COLUMN age;

SELECT * FROM alter_ex;

--		5) 칼럼명 변경
ALTER TABLE alter_ex RENAME COLUMN ename TO pname;

SELECT * FROM alter_ex;


--	(3) 테이블 삭제
--		1) DROP TABLE emp;
--			- 테이블의 구조와 데이터 모두 삭제
--		2) DROP TABLE emp CASCADE CONSTRAINT;
--			- 해당 테이블의 데이터를 FK로 참조한 슬레이브 테이블과 관련된
--		  	제약사항도 모두 삭제


--	(4) 뷰(View) 생성 및 삭제
--		- 뷰란 테이블로부터 유도된 가상 테이블.
--		- 실제 데이터를 가지고 있지 않고, 테이블을 참조해서 원하는 칼럼만 조회 가능
--		<특징>
--		- 참조한 테이블이 변경되면 뷰도 변경
--		- 뷰에 대한 입력, 수정, 삭제에는 제약 있음
--		- 보안성 향상
--		- 변경 불가, 변경하려면 삭제 후 재생성해야 함

CREATE VIEW T_EMP AS SELECT * FROM emp;

SELECT * FROM T_EMP;

DROP VIEW T_EMP;


-- ※ 최대 저장할 수 있는 공간
SELECT TABLE_NAME, MAX_EXTENTS
FROM USER_TABLES;

-- ※ < DELETE vs TRUNCATE >
--	- DELETE : 테이블 용량은 감소하지 않음
--	- TRUNCATE : 테이블의 용량 초기화, ROLLBACK X, 로그 기록 X,
--		외래키 무결성 확인 X, WHERE절 지정 불가, 자동 COMMIT



-- 2. DML(Data Manipulation Language)
--	- INSERT, UPDATE, DELETE, SELECT

-- 	(1) INSERT 문
--		1) 일반적인 경우
--			INSERT INTO emp (COL1, COL2, ...) VALUES (exp1, exp2, ...);

--		2) 모든 칼럼에 대한 데이터를 삽입시 칼럼명 생략 가능
--			INSERT INTO emp VALUES (exp1, exp2, ...);

--		3) SELECT문으로 입력
CREATE TABLE dept3(
    deptno number(2,0),
    dname varchar2(14),
    loc varchar2(13),
    constraint pk_dept3 primary key(deptno)
);

INSERT INTO dept3 SELECT * FROM dept;

SELECT * FROM dept3;

--		4) Nologging 사용
--		- 로그파일의 기록을 최소화하여 입력 성능을 향상
--		- Buffer Cache라는 메모리 영역을 생략하고 기록
ALTER TABLE dept3 nologging;

SELECT * FROM dept3;


--	(2) UPDATE 문
--	- 조건문을 입력하지 않으면 모든 데이터가 수정됨
UPDATE dept3 SET loc='KYOTO' WHERE deptno=70;
UPDATE dept3 SET dname='UNKNOWN' WHERE dname IS NULL;

SELECT * FROM dept3;


--	(3) DELETE 문
--	- 조건문을 입력하지 않으면 모든 데이터가 삭제됨(용량 초기화X)
--	- 용량 초기화는 TRUNCATE
DELETE FROM dept3 WHERE deptno=70;

SELECT * FROM dept3;


--	(4) SELECT 문
--		1) 칼럼 지정
SELECT ename || ' 님' FROM emp1;

--	※ SQL 실행순서
--		Alias -> FROM -> WHERE -> GROUP BY -> HAVING -> SELECT -> ORDER BY

--		2) ORDER BY
--		- ASC : 오름차순
--		- DESC : 내림차순

--		3) Index를 사용한 정렬 회피
SELECT /*+ INDEX_DESC(A SAL) */ * FROM emp1 A;

----------------------------------------------------------------------------------------------------------
-- Q. 차은우, 카리나가 나오도록 UNION과 MAX 함수를 이용해서 출력

-- 	(1) '차은우'라는 문자열을 A 컬럼에, 빈 문자열('')을 B 컬럼에 할당
SELECT '차은우' A, '' B FROM dual;
--	(2) 빈 문자열('')을 A 컬럼에, '카리나'라는 문자열을 B 컬럼에 할당
SELECT '' A, '카리나' B FROM dual;

-- ※ MAX() : MAX 함수는 숫자 뿐만 아니라 문자열 값에 대해서도 사용할 수 있으며,
--		문자열의 경우 사전식 순서에 따라 "최대값"을 결정합니다.

--	(3) 위의 두 SELECT문을 UNION ALL 로 결합

--	(4) MAX(A) AS 남자베스트: A 컬럼의 최대값을 계산. 이 경우 '차은우'와 빈 문자열 중 '차은우'가 최대값.
--	(5) MAX(B) AS 여자베스트: B 컬럼의 최대값을 계산. 이 경우 '카리나'와 빈 문자열 중 '카리나'가 최대값.
SELECT	MAX(A) AS 남자베스트, MAX(B) AS 여자베스트
FROM
(
	SELECT '차은우' A, '' B FROM dual
	UNION ALL
	SELECT '' A, '카리나' B FROM dual
);

SELECT '차은우' AS 남자, '카리나' AS 여자 FROM dual;
----------------------------------------------------------------------------------------------------------

--		4) Distinct, Alias
-- 		- Distinct : 중복된 데이트를 한 번만 조회
--		- Alias : 별칭
SELECT deptno, ename FROM emp ORDER BY deptno;

SELECT DISTINCT deptno FROM emp ORDER BY deptno;

SELECT	empno AS "사번", ename AS "이름"
FROM	emp a
WHERE	a.empno BETWEEN 1000 AND 1005;

--	(5) MERGE 문
CREATE TABLE dept_m AS SELECT * FROM dept3;
CREATE TABLE emp_m AS SELECT * FROM emp3;
SELECT * FROM dept_m;
SELECT * FROM emp_m;
DROP TABLE emp_m;

--	new_emp_data 테이블 : 새로 업데이트될 직원 정보 테이블 
CREATE TABLE new_emp_data AS SELECT * FROM emp3;
TRUNCATE TABLE new_emp_data;
SELECT * FROM new_emp_data;

INSERT INTO new_emp_data VALUES
	(7950, 'DANAKA', 'SALESMAN', 7566, to_date('2024-01-18', 'YYYY-MM-DD'), 2800, 10, 30);
INSERT INTO new_emp_data VALUES
	(7960, 'BECKHAM', 'DEVELOPER', 7839, to_date('2024-01-02', 'YYYY-MM-DD'), 4500, 500, 40);
INSERT INTO new_emp_data VALUES
	(7934, 'GREEN', 'ANALYST', 7839, to_date('2024-02-15', 'YYYY-MM-DD'), 1300, NULL, 20);

SELECT * FROM new_emp_data;
--		1) UPDATE 예시
--		- e.empno와 n.empno가 일치하는 조건이 있다면 숫자 1을 반환.
--		- EXISTS는 해당 값이 존재한다면 TRUE를 반환(서브쿼리 결과가 비어있지 않으면 조건 만족)
--		- MILLER를 GREEN으로 대체
UPDATE emp_m e
SET (e.ename, e.job, e.hiredate, e.sal, e.deptno) = 
	(SELECT n.ename, n.job, n.hiredate, n.sal, n.deptno
     FROM new_emp_data n
     WHERE e.empno = n.empno)
WHERE EXISTS (
    SELECT 1 FROM new_emp_data n
    WHERE e.empno = n.empno
);

--		2) INSERT 예시
--		- DANAKA와 BECKHAM 추가
INSERT INTO emp_m (empno, ename, job, mgr, hiredate, sal, comm, deptno)
SELECT n.empno, n.ename, n.job, n.mgr, n.hiredate, n.sal, n.comm, n.deptno
FROM new_emp_data n
WHERE NOT EXISTS (
    SELECT 1 FROM emp_m e
    WHERE e.empno = n.empno
);

SELECT * FROM emp_m;

--		3) MERGE 예시 (UPDATE + INSERT)
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

-- MERGE INTO emp_m e: emp_m 테이블이 업데이트 또는 새로운 행을 삽입할 대상.
-- USING 절: new_emp_data로부터 가져온 데이터를 사용하여 emp_m 테이블을 업데이트하거나 
--	행을 삽입할 소스 데이터를 제공. 여기서는 empno, ename, job, mgr, hiredate, sal, comm, deptno 컬럼을 선택.
-- ON (e.empno = n.empno): emp_m 테이블의 empno와 new_emp_data의 empno를 비교하여 일치하는 행을 찾음.
--	이는 업데이트 또는 삽입 작업의 기준이 됨.
-- WHEN MATCHED THEN 절: 조건에 일치하는 행이 있을 경우, 해당 행을 new_emp_data의 값으로 업데이트.
--	ename, job, hiredate, sal, deptno 컬럼이 업데이트 대상.
--	mgr와 comm 컬럼은 이 예시에서 업데이트하지 않음. 필요에 따라 업데이트 항목에 추가할 수 있음.
-- WHEN NOT MATCHED THEN 절: emp_m 테이블에 일치하는 empno가 없을 경우, new_emp_data로부터 가져온 데이터를
--	새로운 행으로 삽입함. 모든 컬럼 empno, ename, job, mgr, hiredate, sal, comm, deptno가 삽입됨.



-- 3. WHERE 문
--	(1) WHERE문 연산자
--		1) BETWEEN a AND b : a 이상, b 이하
--		2) NOT BETWEEN a AND b : a 미만, b 초과
--		3) IN (a, b) : a 또는 b
--		4) NOT IN(a, b) : a, b 가 아닌 것
--		5) IN NULL / IS NOT NULL
--		6) 연산자 우선순위
--			- 산술 연산자( *, /, +, - )
--			- 연결 연산자( || )
--			- 비교 연산자( <, >, <=, >=, <>, = )
--			- IS NULL, LIKE, IN
--			- BETWEEN
--			- NOT 연산자
--			- AND 연산자
--			- OR 연산자
--			- 

SELECT * FROM emp1;

SELECT * FROM emp1 WHERE empno >= 1000 AND sal >= 1500;

SELECT * FROM emp1 WHERE ename LIKE '%N';

SELECT * FROM emp1 WHERE sal BETWEEN 1000 AND 2000;

SELECT * FROM emp1 WHERE job IN ('CLERK', 'MANAGER');

SELECT * FROM emp1 WHERE (job, ename) IN (('CLERK','SMITH'), ('MANAGER','BLAKE'));

SELECT * FROM emp1 WHERE (job, ename) NOT IN (('CLERK','SMITH'), ('MANAGER','BLAKE'));

-- ※ 기타 범위 조회
--	(1) 1000 초과 2000 이하
SELECT * FROM emp1 WHERE sal > 1000 AND sal <= 2000;

--	(2) 1000 미만 2000 이상
SELECT * FROM emp1 WHERE sal < 1000 OR sal >= 2000;

------------------------------------------------------------------------------------------------------------
-- ※ NULL 특징
--	- 모르는 값
--	- 값의 부재
--	- NULL + (숫자 or 날짜) => NULL
--	- NULL 과 어떤 값을 비교 => '알수 없음' 반환

-- ※ 날짜 관련
--	(1) TO_DATE('1989-12-22', 'YYYY-MM-DD')
--	(2) TO_TIMESTAMP('1989-12-22 00:00:00.000', 'YYYY-MM-DD HH24:MI:SS.FF')
--	(3) SYSDATE : 초 단위까지
--	(4) CURRENT_TIMESTAMP : 밀리초 단위까지

-- 	※ NULL 관련 함수
-- 		(1) NVL 함수 : NVL(MGR, 0) - MGR 칼럼이 NULL이면 0으로 바꿈
--		(2) NVL2 함수 : NVL2(MGR, 1, 0) - MGR 칼럼이 NULL이 아니면 1, NULL이면 0 반환
--		(3) NULLIF 함수 : NULLIF(exp1, exp2) - exp1과 exp2가 같으면 NULL, 다르면 exp1 반환
--		(4) COALESCE : COALESCE(exp1, exp2, ...)
--			- 인자들을 순차적으로 조회하여 최초로 NULL이 아닌 값을 찾으면 해당 값을 반환,
--			전부 NULL이면 NULL 반환.
SELECT * FROM emp1 WHERE MGR IS NULL;
SELECT * FROM emp1 WHERE MGR IS NOT NULL;

SELECT * FROM emp1;
SELECT * FROM dept1;
DROP TABLE dept1;
--INSERT INTO dept1 (DEPTNO, DNAME, LOC) VALUES (5, 'DEVELOPEMENT', 'SEOUL');
--UPDATE DEPT1 SET DEPTNO = 50 WHERE deptno = 5;
--DELETE FROM dept1 WHERE deptno = 60;
--INSERT INTO dept1 (DEPTNO, DNAME, LOC) VALUES (60, 'UNKNOWN', 'TOKYO');
--INSERT INTO dept1 (DEPTNO, LOC) VALUES (70, 'OSAKA');
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

--	(1) NVL(MGR, 0) : MGR 컬럼이 NULL이면 0으로 바꿈
SELECT NVL(MGR, 0) FROM EMP WHERE EMPNO = 1001;
SELECT NVL(MGR, 0) FROM EMP WHERE EMPNO = 1000;

--	(2) NVL2(MGR, 1, 0) : MGR 컬럼이 NULL이 아니면 1을, NULL이면 0을 반환
SELECT NVL2(MGR, 1, 0) FROM EMP WHERE EMPNO = 1001;
SELECT NVL2(MGR, 1, 0) FROM EMP WHERE EMPNO = 1000;

--	(3) NULLIF(exp1, exp2) : exp1 = exp2이면 NULL을 exp1 != exp2이면 exp1을 반환
-- 		이 함수는 데이터 변환 또는 데이터 정제 과정에서 유용하게 사용.
-- 		예를 들어, 특정 조건에서 값이 유효하지 않거나 기대하지 않는 경우에 NULL 값을 할당하여
-- 		이후 처리에서 제외시킬 수 있음.
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

--	(4) COALESCE(exp1, exp2, exp3, ...)
-- 입력된 인자 목록 중에서 첫 번째 NULL이 아닌 값을 반환합니다.
-- COALESCE 함수가 리스트의 모든 값을 순차적으로 검사하고, 모든 값이 NULL이면 리스트의 마지막 값을 반환.
--		(인자 전부 NULL이면 NULL 값을 반환)
-- 이 함수는 데이터 처리 시 기본값을 제공하거나, 여러 컬럼 중 유효한 값을 선택해야 할 때 유용하게 사용.
SELECT * FROM dept1;
SELECT * FROM emp1;

-- 	EMP 테이블에서 사원의 커미션(COMM)과 급여(SAL) 사용하기:
-- 		(급여는 존재하지만 COMM은 존재하지 않을 수 있으므로..)
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
-- 		'No Department'라는 기본값을 제공하는 예시.
-- 아래의 쿼리에서는 EMP1 테이블을 "왼쪽" 테이블로, DEPT1 테이블을 "오른쪽" 테이블로 사용하여
--		LEFT JOIN을 수행함.
-- 여기서 EMP1 테이블은 사원 정보를, DEPT1 테이블은 부서 정보를 담음.
-- EMP1 테이블의 모든 행은 결과에 포함됩니다. 즉, 모든 사원 정보가 쿼리 결과에 출력.
-- EMP1 테이블의 각 행에 대해, DEPTNO 컬럼을 사용하여 DEPT1 테이블의 DEPTNO 컬럼과 매칭을 시도.
SELECT E1.empno,
       E1.deptno,
       E1.ename,
       E1.job,
       COALESCE(D1.dname, 'No Department') AS DEPARTMENT
FROM EMP1 E1 LEFT JOIN DEPT1 D1 ON E1.deptno = D1.deptno;
------------------------------------------------------------------------------------------------------------



-- 4. GROUP 연산
--	(1) GROUP BY문
--		- 소규모 행을 그룹화하여 합계, 평균, 최대값, 초소값 등을 계산
SELECT * FROM EMP1;
SELECT * FROM DEPT1;

SELECT	deptno,
		SUM(SAL)
FROM emp1 GROUP BY deptno ORDER BY deptno;


-- 	(2) HAVING문
--	: GROUP BY에 조건절을 사용하기 위한 조건문
SELECT		deptno, 
			SUM(sal)
FROM		emp1
GROUP BY	deptno
HAVING		SUM(sal) > 5000 ORDER BY deptno;


-- 	(3) 집계 함수
--		1) COUNT() : 행 수를 조회, 어떤 데이터 타입도 사용 가능
--			- COUNT(*) : NULL 값 포함 모든 행 수
--			- COUNT(칼럼명) : NULL 값 제외 행 수
--		2)	SUM() : 합계를 계산
--		3)	AVG() : 평균을 계산
--		4)	MAX(), MIN() : 최대값과 최소값을 계산
--		5)	STDDEV() : 표준편차를 계산
--		6)	VARIAN() : 분산을 계산
SELECT * FROM emp1;

SELECT count(*) FROM emp1;
SELECT count(MGR) FROM emp1;

-- ex1) 부서별, 관리자별 급여평균 계산
SELECT	deptno, mgr, avg(sal)
FROM	emp1
GROUP BY deptno, mgr ORDER BY avg(sal) ASC;

SELECT	deptno,
		ROUND(avg(sal), 2) AS "avg"
FROM	emp1
GROUP BY deptno ORDER BY avg(sal) asc;

SELECT	job,
		ROUND(avg(sal), 2) AS "avg"
FROM	emp1
GROUP BY job ORDER BY avg(sal) asc;

-- ex2) 직업별 급여합계 중 급여(sal)합계가 5000 이상인 직업(job)
SELECT	job, sum(sal)
FROM	emp1
GROUP BY job HAVING sum(sal) >= 5000 ORDER BY sum(sal) desc;

-- ex3) 사원번호 1000 ~ 1005 번의 부서별 급여합계
SELECT	deptno, sum(sal)
FROM	emp1
WHERE	empno BETWEEN 1000 AND 1005
GROUP BY deptno;



-- 5. 명시적 형변환과 암시적 형변환
--	- 명시적 형변환 : SQL 개발자가 형변환 함수를 사용해서 형변환을 수행하는 것.
-- 	- 암시작 형변환 : SQL 개발자가 형변환을 수행하지 않았을 경우 DB 관리 시스템이
--		내부적으로 형변환을 수행.
-- 형변환 함수
-- 	(1) TO_NUMBER(문자열) : 문자열을 숫자로 변환
--	(2) TO_CHAR(숫자 혹은 날짜.[FORMAT]) : 숫자 혹은 날짜를 지정된 FORMAT의 문자로 변환
--	(3) TO_DATE(문자열, FORMAT) : 문자열을 지정된 FORMAT의 날짜형으로 변환



-- 6. 내장형 함수(BUILT-IN Function)
--	- 모든 DB는 SQL에서 사용가능한 내장형 함수를 가지고 있음.
--	- 종류 : 형변환 함수, 문자열 및 숫자형 함수, 날짜형 함수
--	- DUAL 테이블
--		-> Oracle DB에 의해 자동으로 생성되는 테이블.
--		-> 임시로 사용할 수 있으며 내장형 함수를 실행할 때도 사용 가능.
--		-> DB의 모든 사용자가 사용 가능.

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
SELECT	ASCII('a') AS ascii,
		SUBSTR('ABC', 2, 2) AS substr,
		CONCAT('Java', 'Script') AS concat,
		LENGTH ('A BC') AS length,
		LTRIM(' ABC') AS ltrim,
		LENGTH(LTRIM(' ABC')) AS length_L
FROM	dual;

SELECT	'Java' || 'Script' AS "concat"
FROM	DUAL;


--	(2) 날짜형 함수
--		- SYSDATE : 오늘의 날짜를 날짜 타입으로 알려줌
--		- EXTRACT('YEAR' or 'MONTH' or 'DAY' from dual) : 오늘의 날짜를 날짜 타입으로 알려줌

--SELECT SESSIONTIMEZONE FROM DUAL;

SELECT	CURRENT_TIMESTAMP AS "현재시간",
		CONCAT(EXTRACT(YEAR FROM sysdate), ' 년') AS "년",
		CONCAT(EXTRACT(MONTH FROM sysdate), ' 월') AS "월",
		CONCAT(EXTRACT(DAY FROM sysdate), ' 일') AS "일",
		TO_CHAR(CURRENT_TIMESTAMP, 'YYYY"년" MM"월" DD"일" HH24"시" MI"분" ss"초"') AS "날짜(파싱)"
FROM	DUAL;

SELECT EXTRACT(YEAR FROM SYSDATE,) AS current_year FROM DUAL;

SELECT 
    CONCAT(EXTRACT(YEAR FROM TIMESTAMP '2023-01-15 09:00:00'), ' 년') AS year,
    CONCAT(EXTRACT(MONTH FROM TIMESTAMP '2023-01-15 09:00:00'), ' 월') AS month,
    CONCAT(EXTRACT(DAY FROM TIMESTAMP '2023-01-15 09:00:00'), ' 일') AS day
FROM DUAL;

-- INTERVAL '123:45' - 123시간 45분의 지속기간
-- 즉, HOUR FROM INTERVAL '123:45' 는 5일 3시간 45분을 의미
-- EXTRACT()로 시간을 추출하면 남는 3시간이 출력
SELECT
	CONCAT(EXTRACT(DAY FROM INTERVAL '123:45' HOUR TO MINUTE), ' 일') AS days,
    CONCAT(EXTRACT(HOUR FROM INTERVAL '123:45' HOUR TO MINUTE), ' 시간') AS hours,
    CONCAT(EXTRACT(MINUTE FROM INTERVAL '123:45' HOUR TO MINUTE), ' 분') AS minutes
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

----------------------------------------------------------------------------------------------------------
-- ※ 절차형 SQL
--	- 주로 PL/SQL(Procedural Language/SQL)을 통해 구현됨
--	- PL/SQL은 SQL에 절차적 기능을 추가하여 복잡한 비즈니스 로직을 구현할 수 있도록 해주는 Oracle의 확장
--	- PL/SQL을 사용하여 저장 프로시저, 트리거, 사용자 정의 함수 등 다양한 데이터베이스 객체를 생성
--	- 각각의 객체는 데이터베이스 내에서 특정 작업을 수행하는 데 사용
CREATE TABLE dept4 AS SELECT * FROM dept3;
CREATE TABLE emp4 AS SELECT * FROM emp3;

--	(1) 저장 프로시저(Prosedure)
--		- SQL 문과 PL/SQL 블록을 조합하여 작성할 수 있는 데이터베이스 내의 하나의 프로그램
--		- 일련의 작업을 수행하고, 필요에 따라 입력 파라미터를 받아 처리한 후 결과를 반환

-- ex) 특정 부서(deptno)의 모든 사원의 급여를 일정 비율로 증가시키는 저장 프로시저
CREATE OR REPLACE PROCEDURE RaiseSalaryByDept(
    p_deptno IN emp4.deptno%TYPE,
    p_percentage IN NUMBER
) IS
BEGIN
    UPDATE emp4
    SET sal = sal * (1 + p_percentage / 100)
    WHERE deptno = p_deptno;

    COMMIT;
END;

-- 확인
SELECT text FROM all_source WHERE name='RAISESALARYBYDEPT' AND TYPE='PROCEDURE' ORDER BY line;


--	(2) 트리거(Trigger)
--		- 특정 이벤트(ex. 테이블에 대한 INSERT, UPDATE, DELETE 연산)가 발생했을 때 자동으로 실행되는 PL/SQL 블록
--		- 데이터의 무결성을 유지하거나, 감사 로깅, 자동화된 데이터 업데이트 등에 유용하게 사용

-- ex) emp 테이블에 새로운 사원이 추가되거나 사원의 정보가 변경될 때, 변경 내용을 emp_audit 테이블에 기록하는 트리거
--CREATE OR REPLACE TRIGGER EMPAUDITTRIGGER
--AFTER INSERT OR UPDATE ON emp4
--FOR EACH ROW
--BEGIN
--    INSERT INTO emp_audit(emp_id, change_date, action_type)
--    VALUES (:NEW.empno, SYSDATE, CASE WHEN INSERTING THEN 'INSERT' ELSE 'UPDATE' END);
--END;
DROP TRIGGER EMPAUDITTRIGGER;

CREATE OR REPLACE TRIGGER EMPAUDITTRIGGER
AFTER INSERT OR UPDATE ON emp4
FOR EACH ROW
BEGIN
    INSERT INTO emp_audit(emp_id, change_date, action_type)
    VALUES (:NEW.empno, SYSDATE, 'changed');
END;

--  emp_audit 테이블 생성
CREATE TABLE emp_audit (
    emp_id NUMBER(4,0),       	-- emp4 테이블의 empno 컬럼과 동일한 타입으로 가정
    change_date TIMESTAMP,    		-- 변경이 발생한 날짜를 기록
    action_type VARCHAR2(20)	-- 수행된 작업의 유형 (예: 'INSERT', 'UPDATE')
);

TRUNCATE TABLE EMP_AUDIT;
DROP TABLE emp_audit;

SELECT * FROM emp_audit;
ALTER TRIGGER EMPAUDITTRIGGER compile;

-- 확인
SELECT * FROM dept4;
SELECT * FROM emp4;
SELECT trigger_name, table_name, status FROM all_triggers WHERE trigger_name='EMPAUDITTRIGGER';

INSERT INTO emp4 (empno, ename, job, mgr, hiredate, sal, comm, deptno)
VALUES (7950, 'BECKHAM', 'DEVELOPER', 7839, SYSDATE, 4500, 500, 40);

DELETE FROM emp4 WHERE empno=7950;

SELECT * FROM user_errors WHERE name='EMPAUDITTRIGGER';


--	(3) 사용자 정의 함수(User Defined Function)
--		- 특정 작업을 수행하고 결과를 반환하는 PL/SQL 프로그램
--		- 함수는 쿼리 내에서 호출되어, 그 결과를 표현식의 일부로 사용할 수 있음

-- ex) 특정 사원(empno)의 연간 급여를 계산하는 함수
CREATE OR REPLACE FUNCTION CalculateAnnualSalary(
    p_empno IN emp4.empno%TYPE
) RETURN NUMBER IS
    v_annual_salary NUMBER := 0; -- 기본값을 0으로 설정
BEGIN
    SELECT sal * 12 INTO v_annual_salary
    FROM emp4
    WHERE empno = p_empno;

    RETURN v_annual_salary; -- 성공적으로 계산된 연간 급여 반환

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        -- 사원이 존재하지 않는 경우, v_annual_salary에 설정된 기본값 0 반환
        RETURN v_annual_salary;
    WHEN OTHERS THEN
        -- 다른 모든 예외 처리: 오류 메시지 로깅 또는 사용자 정의 오류 발생
        RAISE_APPLICATION_ERROR(-20001, 'Unexpected error: ' || SQLERRM);
END;

-- 확인
SELECT object_name, object_type, status
FROM all_objects
WHERE object_name='CALCULATEANNUALSALARY' AND object_type='FUNCTION';

SELECT text FROM all_source
WHERE name='CALCULATEANNUALSALARY' AND TYPE='FUNCTION' ORDER BY line;
----------------------------------------------------------------------------------------------------------



-- 7. DECODE와 CASE 문

--	(1) DECODE(exp1, 1000, 'TRUE', 'FALSE') :
--		exp1 = 1000이면 TRUE 반환, exp1 != 1000이면 FALSE 반환
SELECT	DECODE(empno, 1000, 'KING', 'SLAVE') AS class
FROM	emp1;


--	(2) CASE() :
--		WHEN구에 조건
--		THEN은 해당 조건이 참이면 실행, 거짓이면 ELSE구가 실행
SELECT * FROM emp1;

SELECT	ename,
		empno,
		sal,
		CASE
			WHEN empno = 1000 THEN 'EMPEROR'
			WHEN empno BETWEEN 1001 AND 1003 THEN 'ROYAL'
			WHEN sal >= 3000 THEN 'RICH'
			ELSE 'SLAVE'
		END AS "CLASS"
FROM 	emp1;



-- 8. ROWNUM과 ROWID

-- 	(1) ROWNUM
--		- ORACLE의 select문 결과에 대해 가상의 논리적 일련번호를 부여
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

-- SQL Server 의 경우
--SELECT * TOP(10) FROM emp1;

-- MySQL 의 경우
--SELECT * FROM emp1 LIMIT 10;


-- (2) ROWID(18자로 구성)
--		- ORACLE에서 데이터를 구분할 수 있는 유일한 값
--		- select 문으로 확인 가능
--		- 데이터가 어떤 데이터 파일, 어느 블록에 저장되어 있는지 알 수 있음
--	※ ROWID 구조
--		1) 오브젝트 번호 : 1 ~ 6
--		2) 상대 파일 번호 : 7 ~ 9
--		3) 블록 번호 : 10 ~ 15
--		4) 데이터 번호 : 16 ~ 18
SELECT	SUBSTR(rowid, 1, 6) || '-' ||
		SUBSTR(rowid, 7, 3) || '-' ||
		SUBSTR(rowid, 10, 6) || '-' ||
		SUBSTR(rowid, 16, 3) AS formatted_rowid,
		empno,
		ename
FROM	emp1;



-- 9. WITH 구문
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



-- 10. DCL(Data Control Language)
--	- GRANT, REVOKE

--	(1) GRANT : 권한 부여
--		"GRANT PRIVILEGES ON table TO user;"
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

--		2) WITH GRANT OPTION
--			- WITH GRANT OPTION : 특정 사용자에게 권한을 부여할 수 있는 권한을 부여.
--			- WITH ADMIN OPTION : 테이블에 대한 모든 권한을 부여
--				A -> B, B -> C 이후 B권한 취소시 C의 권한은 유지됨
GRANT SELECT, INSERT, UPDATE, DELETE 
	ON emp1
	TO hiw15 WITH GRANT OPTION;

--		3) DBA 권한
--			- 데이터베이스 생성, 사용자 계정 관리, 보안 설정, 백업 및 복구와 같은
--				중요한 DB 관리 작업을 수행할 수 있는 권한
--			- Object(테이블, 프로시저, 뷰) 등의 권한을 묶어서 관리할 수 있음(ROLL)
GRANT DBA TO username;

-- (2) REVOKE : 권한 회수
--		"REVOKE privileges ON table TO user;"



-- 11. TCL(Transaction Control Language)
--	- COMMIT, ROLLBACK, SAVEPOINT
--	- 데이터의 무결성 보장
--	- 영구적 변경을 하기 전 데이터의 변경사항 확인 가능
--	- 논리적으로 연관된 작업을 그룹핑하여 처리 가능

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




