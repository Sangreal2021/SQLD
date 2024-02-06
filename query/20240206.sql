-- 18. 테이블 변경
--	(1) 테이블명 변경
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

--	(2) 칼럼 추가
ALTER TABLE alter_ex ADD (age NUMBER(3) DEFAULT 1);

SELECT * FROM alter_ex;

--	(3) 칼럼 변경
ALTER TABLE alter_ex MODIFY (ename varchar2(40) NOT NULL);

SELECT * FROM alter_ex;

--	(4) 칼럼 삭제
ALTER TABLE alter_ex DROP COLUMN age;

SELECT * FROM alter_ex;

--	(5) 칼럼명 변경
ALTER TABLE alter_ex RENAME COLUMN ename TO pname;

SELECT * FROM alter_ex;



-- 19. 테이블 삭제
--	(1) DROP TABLE emp;
--		- 테이블의 구조와 데이터 모두 삭제
--	(2) DROP TABLE emp CASCADE CONSTRAINT;
--		- 해당 테이블의 데이터를 FK로 참조한 슬레이브 테이블과 관련된
--		  제약사항도 모두 삭제



-- 20. INSERT문
--	(1) 일반적인 경우
--		INSERT INTO emp (COL1, COL2, ...) VALUES (exp1, exp2, ...);

--	(2) 모든 칼럼에 대한 데이터를 삽입시 칼럼명 생략 가능
--		INSERT INTO emp VALUES (exp1, exp2, ...);

--	(3) SELECT문으로 입력
CREATE TABLE dept3(
    deptno number(2,0),
    dname varchar2(14),
    loc varchar2(13),
    constraint pk_dept3 primary key(deptno)
);

INSERT INTO dept3 SELECT * FROM dept;

SELECT * FROM dept3;

--	(4) Nologging 사용
--		- 로그파일의 기록을 최소화하여 입력 성능을 향상
--		- Buffer Cache라는 메모리 영역을 생략하고 기록
ALTER TABLE dept3 nologging;

SELECT * FROM dept3;



-- 21. UPDATE문
--	- 조건문을 입력하지 않으면 모든 데이터가 수정됨
UPDATE dept3 SET loc='KYOTO' WHERE deptno=70;
UPDATE dept3 SET dname='UNKNOWN' WHERE dname IS NULL;

SELECT * FROM dept3;



-- 22. DELETE문
--	- 조건문을 입력하지 않으면 모든 데이터가 삭제됨(용량 초기화X)
--	- 용량 초기화는 TRUNCATE
DELETE FROM dept3 WHERE deptno=70;

SELECT * FROM dept3;



-- 23. SELECT문
--	(1) 칼럼 지정
SELECT ename || ' 님' FROM emp1;

--	※ SQL 실행순서
--		Alias -> FROM -> WHERE -> GROUP BY -> HAVING -> SELECT -> ORDER BY

--	(2) ORDER BY
--		- ASC : 오름차순
--		- DESC : 내림차순

--	(3) Index를 사용한 정렬 회피
SELECT /*+ INDEX_DESC(A SAL) */ * FROM emp1 A;


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



-- 24. JOIN
--	(1) EQUI(등가) 조인 : 교집합
--		- 조인은 여러 개의 릴레이션을 사용해서 새로운 릴레이션을 만드는 과정
--		- 조인의 기본은 교집합을 만드는 것
--		- 2개의 테이블 간에 일치하는 것을 조인함
SELECT * FROM emp1, dept1
WHERE emp1.DEPTNO = dept1.DEPTNO;

SELECT * FROM emp1, dept1
WHERE emp1.DEPTNO = dept1.DEPTNO
	AND emp1.ENAME LIKE '%S'
ORDER BY ename;

--	(2) INNER JOIN
--		- ISO 표준 SQL로 ON문을 사용해서 테이블을 연결
SELECT * FROM emp1 INNER JOIN dept1
ON emp1.DEPTNO = dept1.DEPTNO;

SELECT * FROM emp1 INNER JOIN dept1
ON emp1.DEPTNO = dept1.DEPTNO
	AND emp1.ENAME LIKE '%S'
ORDER BY ename;

-- ※ 해시 조인(Hash Join)
--	- 먼저 선행 테이블을 결정하고 선행 테이블에서 주어진 조건(where구)에 해당하는 행을 선택
--	- 해당 행이 선택되면 조인 키(Join Key)를 기준으로 해시 함수를 사용해서 해시 테이블을
--		메인 메모리에 생성하고 후행 테이블에서 주어진 조건에 만족하는 행을 찾음
--	- 후행 테이블의 조인 키를 사용해서 해시 함수를 적용하여 해당 버킷을 검색

--		(1) 장점
--		 - 대용량 데이터 세트를 조인할 때 효율적.
--		 - 디스크 I/O 작업을 최소화하고, 조인 키에 대한 빠른 검색을 통해 조인 수행시간을 단축
--		(2) 단점
--		 - 사용 가능한 메모리 양에 따라 성능에 영향
--		 - 조인하는 테이블 중 하나가 너무 클 경우, 메모리 오버헤드 발생 가능(성능 저하)

-- /*+ USE_HASH(e d) */는 옵티마이저에게 emp 테이블(e)과 dept 테이블(d) 간의 조인을 Hash Join 방식으로
-- 수행하라는 힌트를 제공
SELECT /*+ USE_HASH(e d) */ e.empno, e.ename, d.deptno, d.dname
FROM emp1 e, dept1 d
WHERE e.deptno = d.deptno;

--	(3) INTERSECT 연산
--		- 2개의 테이블에서 교집합을 조회
--		- 즉, 2개의 테이블에서 공통된 값을 조회
SELECT deptno FROM emp1
INTERSECT
SELECT deptno FROM dept1;


--	(4) OUTER JOIN
--		- 2개의 테이블 간에 교집합을 조회하고 한쪽 테이블에만 있는 데이터도 포함시켜 조회

--		1) LEFT OUTER JOIN
--			: 2개의 테이블에서 같은 것을 조회하고 왼쪽 테이블에만 있는 것을 포함해서 조회
SELECT * FROM dept1 LEFT OUTER JOIN emp1
ON emp1.DEPTNO = dept1.DEPTNO;

--		2) RIGHT OUTER JOIN
--			: 2개의 테이블에서 같은 것을 조회하고 오른쪽 테이블에만 있는 것을 포함해서 조회
SELECT * FROM dept1 RIGHT OUTER JOIN emp1
ON emp1.DEPTNO = dept1.DEPTNO;

--	(5) CROSS JOIN
--		- 조인 조건구 없이 2개의 테이블을 하나로 조인
--		- 조인구가 없어서 카테시안 곱이 발생(14 * 4 => 56개 행 조회)
SELECT * FROM emp1 CROSS JOIN dept1;

SELECT * FROM emp1, dept1;

--	(6) UNION을 사용한 합집합 구현
--		1) UNION
--			- 2개의 테이블을 하나로 만드는 연산
--			- 중복 데이터 제거 O, 정렬(sort) 과정을 발생 O
SELECT deptno FROM emp1
UNION
SELECT deptno FROM emp1;
--		2) UNION ALL
--			- 2개의 테이블을 하나로 만드는 연산
--			- 중복 데이터 제거 X, 정렬(sort) 과정을 발생 X
SELECT deptno FROM emp1
UNION ALL
SELECT deptno FROM emp1;

--	(7) 차집합을 만드는 MINUS
--		- 먼저 쓴 SELECT문에는 있고 뒤에 쓰는 SELECT문에는 없는 집합을 조회
--		- MySQL에 EXCEPT 문과 동일
SELECT * FROM dept1;
SELECT * FROM emp1;

SELECT deptno FROM dept1
MINUS
SELECT deptno FROM emp1;



-- 25. 계층형 조회(Connect by)
--	- Connect by는 트리 형태의 구조로 질의를 수행하는 것
--	- START WITH구 : 시작 조건
--	- CONNECT BY PRIOR : 조인 조건
--	- 계층형 조회에서 MAX(LEVEL)을 사용하여 최대 계층 수를 구할 수 있음
SELECT MAX(LEVEL)
FROM emp1
START WITH mgr IS NULL
CONNECT BY PRIOR empno = mgr;

SELECT LEVEL, empno, mgr, ename
FROM emp1
START WITH mgr IS NULL
CONNECT BY PRIOR empno = mgr;



-- 26. 서브쿼리(Subquery)
--	- SELECT문 내에 다시 SELECT문을 사용하는 SQL
--	- 종류
--		- 스칼라 서브쿼리(Scala Subquery) : SELECT문에 Subquery를 사용
--		- 인라인 뷰(Inline View) : FROM구에 SELECT문을 사용
--		- 서브쿼리(Subquery) : WHERE구에 SELECT문을 사용

--	(1) 서브쿼리
SELECT * FROM emp1
WHERE deptno = (
	SELECT deptno FROM dept1
	WHERE deptno=10
);

--	(2) 인라인 뷰
SELECT * FROM
	(SELECT rownum num, ename FROM emp1) a
WHERE num < 5;


--	(3) 단일 행 서브쿼리, 다중 행 서브쿼리
--		1) 단일 행 서브쿼리
--			- 결과는 반드시 항 행만 조회
--			- 비교 연산자 =, <, <=, >, >=, <> 를 사용
--		2) 다중 행 서브쿼리
--			- 결과는 여러 개의 행이 조회
--			- 다중 행 비교 연산자 IN, ANY, ALL, EXISTS를 사용

--	IN : 반환되는 여러 개의 행 중에서 하나만 참이 되어도 참
--		emp1 테이블에서 sal이 2000 초과인 사원번호를 반환하고, 반환된 사원번호와
--		메인쿼리에 있는 사원번호와 비교해서 같은 것을 조회
SELECT ename, dname, sal
FROM emp1, dept1
WHERE emp1.DEPTNO = dept1.DEPTNO
	AND emp1.EMPNO IN (SELECT empno FROM emp1 WHERE sal > 2000);

--	ALL : 메인쿼리와 서브쿼리의 결과가 모두 동일하면 참
--		deptno가 20, 30보다 작거나 같으면 조회
SELECT * FROM emp1
WHERE deptno <= ALL (20, 30);

--	EXISTS : Subquery로 어떤 데이터 존재 여부를 확인(true or false 반환)
--		직원 중 급여가 2000 이상이 있으면 참, 없으면 거짓 반환
SELECT ename, dname, sal
FROM emp1, dept1
WHERE emp1.DEPTNO = dept1.DEPTNO
	AND EXISTS (SELECT 1 FROM emp1 WHERE sal > 2000);

--	(4) 스칼라(Scala) 서브쿼리 : 반드시 한 행과 한 칼럼만 반환
--		여러 행이 반환되면 오류 발생
--		아래는 특정 직원의 급여와 전체 직원 평균급여 출력
SELECT	ename AS "이름",
		sal AS "급여",
		(SELECT AVG(sal) FROM emp1) AS "평균급여"
FROM	emp1
WHERE	empno=1000;



-- 27. 그룹 함수
--	(1) ROLLUP
--		- GROUP BY의 칼럼에 대해 Subtotal을 만들어 줌
--		- ROLLUP을 할 때 GROUP BY구에 칼럼이 두 개 이쌍 오면
--			순서에 따라 결과가 달라짐
SELECT * FROM dept1;
SELECT * FROM emp1;

-- 전체합계의 deptno는 null이기 때문에 마지막에 전체합계가 출력
-- ROLLUP으로 부서별 전체 합계 계산
SELECT	decode(deptno, NULL, '전체합계', deptno) AS deptno,
		sum(sal)
FROM	emp1
GROUP BY ROLLUP (deptno);

SELECT	decode(deptno, NULL, '전체합계', deptno) AS deptno,
		job, sum(sal)
FROM	emp1
GROUP BY ROLLUP (deptno, job);

--	(2) GROUPING 함수
--	ROLLUP, CUBE, GROUPING SETS에서 생성되는 합계값을 구분하기 위해
--	만들어진 함수
SELECT	decode(deptno, NULL, '전체합계', deptno) AS deptno,
		GROUPING(deptno),
		job,
		GROUPING(job),
		SUM(sal) 
FROM	emp1
GROUP BY ROLLUP (deptno, job);

SELECT	deptno,
		decode(GROUPING(deptno), 1, '전체합계') TOT,
		job,
		decode(GROUPING(job), 1, '부서합계') T_DEPT,
		sum(sal)
FROM	emp1
GROUP BY ROLLUP (deptno, job);

--	(3) GROUPING SETS 함수
--		- GROUP BY에 나오는 칼럼의 순서와 관계없이 다양한 소계를 구할 수 있음
--		- GROUP BY에 나오는 칼럼의 순서와 관계없이 개별적으로 모두 처리

-- 각 부서별, 직업별 합계를 각각 출력
SELECT	deptno,
		job,
		sum(sal)
FROM	emp1
GROUP BY GROUPING SETS (deptno, job);

--	(4) CUBE 함수
--		- 제시한 칼럼에 대해 결합 가능한 모든 집계를 계산
SELECT	deptno,
		job,
		sum(sal)
FROM	emp1
GROUP BY CUBE (deptno, job);



-- 28. 윈도우 함수
--	- 행과 행 간의 관계를 정의하기 위해 제공되는 함수
--	- 순위, 합계, 평균, 행 위치 등을 조작할 수 있음

--	- 구조
SELECT WINDOW_FUNCTION(args)
	OVER(PARTITION BY 칼럼 ORDER BY WINDOWING절)
FROM 테이블명;

--		1) args(인수) : 0 ~ N개의 인수를 설정
--		2) PARTITION BY : 전체 집합을 기준에 의해 소그룹으로 나눔
--		3) ORDER BY : 어떤 항목에 대해 정렬
--		4) WINDOWING : 행 기준의 범위를 정함
--			ROWS는 물리적 결과의 행 수, RANGE는 논리적 값에 의한 범위

--	- WINDOWING
--		- ROWS : 부분집합인 윈도우 크기를 물리적 단위로 행의 집합을 지정
--		- RANGE : 논리적 주소에 의해 집합을 지정
--		- BETWEEN ~ AND : 윈도우의 시작과 끝의 위치를 지정
--		- UNBOUNDED PRECEDING : 윈도우 시작 위치가 첫 번째 행임을 의미
--		- UNBOUNDED FOLLOWING : 윈도우 마지막 위치가 마지막 행임을 의미
--		- CURRENT ROW : 윈도우 시작 위치가 현재 행임을 의미

SELECT	empno,
		ename,
		sal,
		sum(sal) OVER (ORDER BY sal
			ROWS BETWEEN UNBOUNDED PRECEDING
			AND UNBOUNDED FOLLOWING
		) TOTSAL
FROM	emp1;

-- p.197


























