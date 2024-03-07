-- [SQL 활용]

-- 1. JOIN

--	(1) EQUI(등가) 조인 : 교집합
--		- 조인은 여러 개의 릴레이션을 사용해서 새로운 릴레이션을 만드는 과정
--		- 조인의 기본은 교집합을 만드는 것
--		- 2개의 테이블 간에 일치하는 것을 조인함
--		- 마스터 테이블과 슬레이브 테이블 간의 조인은 일반적으로 기본키와 외래키 사이에서 발생
--			하지만 반드시 기본키, 외래키 관계에 의해서만 성립되는 것 아님
--		-	(조인 칼럼 1:1 매핑 가능하면 사용가능)
SELECT * FROM emp1, dept1
WHERE emp1.DEPTNO = dept1.DEPTNO;

SELECT * FROM emp1, dept1
WHERE emp1.DEPTNO = dept1.DEPTNO
	AND emp1.ENAME LIKE '%S'
ORDER BY ename;

--	※ NON-EQUI Join은 ">", "<", ">=","<=" 를 사용

----------------------------------------------------------------------------------------------------------
-- ※ 해시 조인(Hash Join)

--	- EQUI JOIN에서만 나타나는 실행계획.
--	- 먼저 선행 테이블을 결정하고 선행 테이블에서 주어진 조건(where구)에 해당하는 행을 선택.
--		(행의 수가 적은 테이블을 선행 테이블로 사용하는 것이 유리)
--	- 해당 행이 선택되면 조인 키(Join Key)를 기준으로 해시 함수를 사용해서 해시 테이블을
--		메인 메모리에 생성하고 후행 테이블에서 주어진 조건에 만족하는 행을 찾음.
--	- 후행 테이블의 조인 키를 사용해서 해시 함수를 적용하여 해당 버킷을 검색.
--	- 해시 테이블을 저장할 때 메모리 용량 초과시 임시 영역(디스크)에 저장.
--	- 조인 칼럼의 인덱스가 존재하지 않은 경우에도 사용 가능.

--		(1) 장점
--		 - 정렬 작업이 없어서 대용량 데이터 세트를 조인할 때 효율적.
--		 - 디스크 I/O 작업을 최소화하고, 조인 키에 대한 빠른 검색을 통해 조인 수행시간을 단축
--		(2) 단점
--		 - 사용 가능한 메모리 양에 따라 성능에 영향
--		 - 조인하는 테이블 중 하나가 너무 클 경우, 메모리 오버헤드 발생 가능(성능 저하)

-- /*+ USE_HASH(e d) */는 옵티마이저에게 emp 테이블(e)과 dept 테이블(d) 간의 조인을 Hash Join 방식으로
-- 수행하라는 힌트를 제공
SELECT /*+ USE_HASH(e d) */ e.empno, e.ename, d.deptno, d.dname
FROM emp1 e, dept1 d
WHERE e.deptno = d.deptno;
----------------------------------------------------------------------------------------------------------


--	(2) INNER JOIN
--		- ISO 표준 SQL로 ON문을 사용해서 테이블을 연결
SELECT * FROM emp1 INNER JOIN dept1
ON emp1.DEPTNO = dept1.DEPTNO;

SELECT * FROM emp1 e, dept1 d
WHERE e.DEPTNO = d.DEPTNO;

SELECT * FROM emp1 INNER JOIN dept1
ON emp1.DEPTNO = dept1.DEPTNO
	AND emp1.ENAME LIKE '%S'
ORDER BY ename;


--	(3) INTERSECT 연산
--		- 2개의 테이블에서 교집합을 조회
--		- 즉, 2개의 테이블에서 공통된 값을 조회
SELECT deptno FROM emp1
INTERSECT
SELECT deptno FROM dept1;


--	(4) OUTER JOIN
--		- 2개의 테이블 간에 교집합을 조회하고 한쪽 테이블에만 있는 데이터도 포함시켜 조회
--		- 조인 조건을 만족하지 않는 데이터도 조회 가능

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
--		- where절에 Join 조건을 추가할 수 있음
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
--			- 성능 측면에서 UNION 보다 우수함
SELECT deptno FROM emp1
UNION ALL
SELECT deptno FROM emp1;


--	(7) 차집합을 만드는 MINUS
--		- 먼저 쓴 SELECT문에는 있고 뒤에 쓰는 SELECT문에는 없는 집합을 조회
--		- MS-SQL에 EXCEPT 문과 동일
SELECT * FROM dept1;
SELECT * FROM emp1;

SELECT deptno FROM dept1
MINUS
SELECT deptno FROM emp1;

--		- MariaDB, MySQL 의 경우
--			1) LEFT JOIN과 NULL 사용
SELECT a.*
FROM table1 a LEFT JOIN table2 b
ON a.id = b.id
WHERE b.id IS NULL;

--			2) NOT EXISTS 사용
--			- a.id = b.id 가 존재하지 않는 경우에만 결과 반환
SELECT a.*
FROM table1 a
WHERE NOT EXISTS (
    SELECT 1 FROM table2 b
    WHERE a.id = b.id
);


--	(8) 셀프 조인(SELF JOIN)
--		- 테이블을 자기 자신과 조인하는 기법.
--		- 이 방법은 1개의 테이블 내에서 2개의 연관된 칼럼(데이터)을 비교하거나 조회할 때 유용함.
--		- 주로 계층적 데이터나 연관된 레코드를 찾는 데 사용됨.
--		- 셀프 조인을 구현할 때는 같은 테이블을 서로 다른 별칭(alias)으로 참조하여 조인 조건을 명시.

--		1) 예시
--	- emp 테이블에는 사원의 정보(예: empno, ename, mgr 등)가 저장되어 있으며,
--		mgr 필드는 해당 사원의 관리자(manager)의 empno를 나타냄.
--		즉, mgr 필드는 empno 필드를 참조하는 외래키 역할을 함.
--		여기서, 각 사원과 그 사원의 관리자 이름을 조회하는 쿼리를 셀프 조인을 사용하여 작성할 수 있음.
SELECT * FROM emp3 ORDER BY deptno;

SELECT	e1.ename AS "Employee",
		e2.ename AS "Manager"
FROM	emp3 e1 LEFT JOIN emp3 e2 ON e1.mgr = e2.empno;

--	- 사원이 속한 부서 정보와 그 부서의 위치를 함께 조회하는 쿼리를 작성.
--		이 경우에는 emp 테이블의 사원 정보와 dept 테이블의 부서 정보를 조인하지만,
--		셀프 조인의 개념을 확장하여 두 관련 테이블 간의 조인을 보여주는 예시로 사용할 수 있음.
SELECT	e1.ename AS "Employee",
		e1.deptno AS "Department",
		e2.ename AS "Colleague"
FROM	emp3 e1 JOIN emp3 e2 ON e1.deptno = e2.deptno AND e1.empno != e2.empno;

--		2) 주의사항
--		- 셀프 조인 시 두 별칭을 명확히 구분하여 사용해야 함. 그렇지 않으면 어떤 열이
--			어떤 별칭의 테이블에서 왔는지 혼동할 수 있음.
--		- 셀프 조인은 테이블 내부의 데이터 간 관계를 명확히 이해할 때 가장 효과적.
--			테이블의 데이터 구조와 관계를 잘 파악하고 쿼리를 작성해야 함.
--		- 셀프 조인은 계층적 데이터나 참조 관계를 가진 데이터를 조회하는 데 특히 유용.


-- (9) 내츄럴 조인(NATURAL JOIN)
--		- 두 테이블에서 동일한 칼럼 이름을 가지는 칼럼을 모두 조회
--		- Alias를 사용할 수 없음
--		- where절에서 Join 조건을 추가할 수 없음
--	ex)
SELECT empno, ename, deptno
FROM emp3 NATURAL JOIN dept3;



-- 2. 계층형 조회(Connect by)
--	(1) Connect by는 트리 형태의 구조로 질의를 수행하는 것
--	(2) START WITH구 : 시작 조건
--	(3) CONNECT BY PRIOR : 조인 조건
--	(4) 계층형 조회에서 MAX(LEVEL)을 사용하여 최대 계층 수를 구할 수 있음
--		(Root = 1, 마지막 LEAF는 4)
--	(5) 키워드
--		1) LEVEL : 검색 항목의 깊이를 의미(가장 상위 레벨이 1)
--		2) CONNECT_BY_ROOT : 계층구조에서 가장 최상위 값을 표시
--		3) CONNECT_BY_ISLEAF : 계층구조에서 가장 최하위를 표시(Leaf 데이터면 1, 아니면 0)
--		4) SYS_CONNECT_BY_PATH : 계층구조의 전체 전개 경로를 표시
--		5) NOCYCLE : 순환구조가 발생지점까지만 전개
--		6) CONNECT_BY_ISCYCLE : 순환구조 발생지점을 표시 

-- MAX(LEVEL)을 사용하여 최대 계층 수를 계산.(마지막 Leaf Node의 계층값)
--	-> 트리의 최대 깊이는 4
SELECT MAX(LEVEL)
FROM emp3
	START WITH mgr IS NULL
	CONNECT BY PRIOR empno = mgr;

-- 
SELECT LEVEL, empno, mgr, ename
FROM emp3
	START WITH mgr IS NULL
	CONNECT BY PRIOR empno = mgr;

-- 계층형 조회 결과를 명확히 보기 위해 LPAD 함수 사용
SELECT	LEVEL,
		LPAD(' ', 4*(LEVEL-1)) || empno AS "TREE",
		mgr, ename
FROM	emp3
	START WITH mgr IS NULL
	CONNECT BY PRIOR empno = mgr;

-- - SYS_CONNECT_BY_PATH(ename, '/') AS "Path": 각 사원의 이름(ename)을 경로로 나타내며,
--		경로의 각 단계는 /로 구분됨. 
--		이 경로는 최상위 관리자(즉, mgr가 NULL인 사원)부터 시작하여 현재 사원까지의 계층적 경로를 보여줌.
-- - START WITH mgr IS NULL : 계층 구조의 최상위에서 시작.
--		여기서 최상위 사원은 관리자(mgr)가 없는 사원, 즉 mgr 컬럼이 NULL인 사원.
-- - CONNECT BY PRIOR empno = mgr : 현재 행의 empno가 이전 행의 mgr와 일치하는 방식으로 계층적 관계를 정의.
--		이는 각 관리자(mgr)에게 직접 보고하는 사원들을 찾아 계층을 구성하는 데 사용됨.
SELECT	SYS_CONNECT_BY_PATH(ename, '/') AS "PATH",
		empno, mgr, ename
FROM	emp3
	START WITH mgr IS NULL
	CONNECT BY PRIOR empno = mgr;



-- 3. 서브쿼리(Subquery)
--	- SELECT문 내에 다시 SELECT문을 사용하는 SQL문.
--	- 상호연관 서브쿼리는 실행속도가 상대적으로 느림
--	- 정렬을 수행하기 위해 내부에 ORDER BY를 사용하지 못함
--	- 서브쿼리 내부에서 메인쿼리 칼럼 사용O, 메인쿼리에서 서브쿼리 칼럼 사용X

--	<종류>
--		- 스칼라 서브쿼리(Scala Subquery) : SELECT문에 Subquery를 사용
--		- 인라인 뷰(Inline View) : FROM구에 SELECT문을 사용
--		- 서브쿼리(Subquery) : WHERE구에 SELECT문을 사용

--	(1) 서브쿼리
SELECT * FROM emp1
WHERE deptno = (SELECT deptno FROM dept1 WHERE deptno=10);


--	(2) 인라인 뷰
SELECT * FROM
	(SELECT rownum num, ename FROM emp1) a
WHERE num < 5;


--	(3) 단일 행 서브쿼리, 다중 행 서브쿼리
--		1) 단일 행 서브쿼리
--			-> 결과는 반드시 항 행만 조회
--			-> 비교 연산자 =, <, <=, >, >=, <> 를 사용

--		2) 다중 행(Multi Row) 서브쿼리
--			-> 결과는 여러 개의 행이 조회
--			-> 다중 행 비교 연산자 IN, ANY, ALL, EXISTS를 사용

--		- IN : 반환되는 여러 개의 행 중에서 하나만 참이 되어도 참
--	ex) emp1 테이블에서 sal이 2000 초과인 사원번호를 반환하고, 반환된 사원번호와
--		메인쿼리에 있는 사원번호와 비교해서 같은 것을 조회
SELECT ename, dname, sal
FROM emp1, dept1
WHERE emp1.DEPTNO = dept1.DEPTNO
	AND emp1.EMPNO IN (SELECT empno FROM emp1 WHERE sal > 2000);

--		- ANY : 서브쿼리의 결과 집합에 있는 어떤 값이라도 조건을 만족하는지를 검사하는 데 사용
--	ex) 특정 부서의 평균 급여보다 더 많은 급여를 받는 사원들을 찾는 쿼리를 작성
SELECT deptno, ename, sal
FROM emp3
WHERE sal > ANY (
	SELECT AVG(sal) FROM emp3 GROUP BY deptno 
);

-- ex) 셀프 조인, 모든 관리자보다 급여가 많은 직원 조회
SELECT a.*
FROM emp3 a, emp3 b
WHERE a.mgr = b.empno AND a.sal >= ANY b.sal;

SELECT a.*
FROM emp3 a
JOIN emp3 b ON a.mgr = b.empno
WHERE a.sal >= b.sal;

--		- ALL : 메인쿼리와 서브쿼리의 결과가 모두 동일하면 참
--	ex) deptno가 20, 30보다 작거나 같으면 조회
SELECT * FROM emp1
WHERE deptno <= ALL (20, 30);

--		- EXISTS : Subquery로 어떤 데이터 존재 여부를 확인(true or false 반환)
--	ex) 직원 중 급여가 2000 이상이 있으면 참, 없으면 거짓 반환
SELECT ename, dname, sal
FROM emp1, dept1
WHERE emp1.DEPTNO = dept1.DEPTNO
	AND EXISTS (SELECT 1 FROM emp1 WHERE sal > 2000);


--	(4) 스칼라(Scala) 서브쿼리 : 반드시 한 행과 한 칼럼만 반환
--		(여러 행이 반환되면 오류 발생)
--	ex) 특정 직원의 급여와 전체 직원 평균급여 출력
SELECT	ename AS "이름",
		sal AS "급여",
		ROUND((SELECT AVG(sal) FROM emp1), 2) AS "평균급여"
FROM	emp1
WHERE	empno=1000;


--	(5) SQL 개선 측면에서 서브쿼리의 종류
--		1) Access Subquery : 쿼리의 변형이 없고, 제공자의 역할
--		2) Filter Subquery : 쿼리의 변형이 없고, 확인자 역할
--		3) Early Filter Subquery : 쿼리의 변형이 없고, 서브쿼리가 먼저 실행하여
--								데이터를 걸러냄
--		4) Correlated Subquery : 메인쿼리 값을 서브쿼리가 사용하고, 서브쿼리 값을
--								받아서 메인쿼리가 계산되는 쿼리
 


-- 4. 그룹 함수
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
FROM	emp3
GROUP BY CUBE (deptno, job);



-- 5. 윈도우 함수(Window Function)

--	(1) 윈도우 함수
--		- 행과 행 간의 관계를 정의하기 위해 제공되는 함수
--		- 순위, 합계, 평균, 행 위치 등을 조작할 수 있음

--		- 구조
--			- args(인수) : 0 ~ N개의 인수를 설정
--			- PARTITION BY : 전체 집합을 기준에 의해 소그룹으로 나눔
--			- ORDER BY : 어떤 항목에 대해 정렬
--			- WINDOWING : 행 기준의 범위를 정함
--				ROWS는 물리적 결과의 행 수, RANGE는 논리적 값에 의한 범위
SELECT WINDOW_FUNCTION(args)
	OVER(PARTITION BY 칼럼 ORDER BY WINDOWING절)
FROM 테이블명;

--		- WINDOWING
--			- ROWS : 부분집합인 윈도우 크기를 물리적 단위로 행의 집합을 지정
--			- RANGE : 논리적 주소에 의해 집합을 지정
--			- BETWEEN ~ AND : 윈도우의 시작과 끝의 위치를 지정
--			- UNBOUNDED PRECEDING : 윈도우 시작 위치가 첫 번째 행임을 의미
--			- UNBOUNDED FOLLOWING : 윈도우 마지막 위치가 마지막 행임을 의미
--			- CURRENT ROW : 윈도우 시작 위치가 현재 행임을 의미

-- ex) 처음 행(UNBOUNDED PRECEDING) 부터 마지막 행(UNBOUNDED FOLLOWING)까지의 합계
SELECT	empno,
		ename,
		sal,
		sum(sal) OVER (ORDER BY sal
			ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
		) TOTSAL
FROM	emp1;

-- ex) 처음(UNBOUNDED PRECEDING)부터 현재 행(CURRENT ROW)까지의 합계(누적 합계)
SELECT	empno,
		ename,
		sal,
		sum(sal) OVER (ORDER BY sal
			ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
		) TOTSAL
FROM	emp1;

-- ex) 현재 행(CURRENT ROW)부터 마지막 행(UNBOUNDED FOLLOWING)까지의 합계
SELECT	empno,
		ename,
		sal,
		sum(sal) OVER (ORDER BY sal
			ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING
		) TOTSAL
FROM	emp1;


-- 	(2) 순위 함수(RANK Function)
--		- 특정 항목과 파티션에 대해 순위를 계산할 수 있는 함수

--		1) RANK 함수
--			- 특정항목 및 파티션에 대해 순위를 계산
--			- 동일한 순위는 동일한 값이 부여
--			- ex) 2등이 2명이면 그 다음 순위는 4등부터

-- ex) ALL RANK는 전체 급여 순위를 메긴 것
-- 	   JOB RANK는 각 직업별(job) 내에서 순위를 메긴 것
SELECT	ename,
		job,
		sal,
		RANK() OVER (ORDER BY sal DESC) AS "ALL_RANK",
		RANK() OVER (PARTITION BY job ORDER BY sal DESC) AS "JOB_RANK"
FROM	emp1;

--		2) DENSE_RANK 함수
--			- 동일한 순위를 하나의 건수로 계산
--			- 누적된 순위를 부여할 수 있음
-- ex) 2등이 2명이면 그 다음 순위는 3등부터
SELECT	ename,
		sal,
		RANK() OVER (ORDER BY sal DESC) AS "RANK_FUNC",
		DENSE_RANK() OVER (ORDER BY sal DESC) AS "DENSE_RANK"
FROM	emp1;

--		3) ROW_NUMBER 함수
--			- 동일한 순위에 대해 고유의 순위를 부여
SELECT	ename,
		sal,
		RANK() OVER (ORDER BY sal DESC) AS "RANK_FUNC",
		ROW_NUMBER() OVER (ORDER BY sal DESC) AS "ROW_NUM"
FROM	emp1;

--		4) 순위 함수 비교
SELECT	ename,
		sal,
		RANK() OVER (ORDER BY sal DESC) AS "RANK_FUNC",
		DENSE_RANK() OVER (ORDER BY sal DESC) AS "DENSE_RANK",
		ROW_NUMBER () OVER (ORDER BY sal DESC) AS "ROW_NUM"
FROM	emp1;



--	(3) 집계 함수(RANK Function)
--		1) SUM : 파티션 별로 합계를 계산
--		2) AVG : 파티션 별로 평균을 계산
--		3) COUNT : 파티션 별로 행 수를 계산
--		4) MAX, MIN : 파티션 별로 최대값과 최소값 계산

-- ex) 같은 관리자(mgr)에 파티션을 만들고 합계, 등등을 계산
SELECT	ename,
		mgr,
		sal,
		SUM(sal) OVER (PARTITION BY mgr) AS "SUM_MGR",
		ROUND(AVG(sal) OVER (PARTITION BY mgr), 2) AS "AVG_MGR",
		COUNT(sal) OVER (PARTITION BY mgr) AS "COUNT_MGR",
		MAX(sal) OVER (PARTITION BY mgr) AS "MAX_MGR",
		MIN(sal) OVER (PARTITION BY mgr) AS "MIN_MGR"
FROM 	emp1;



--	(4) 행 순서 관련 함수
--		1) FIRST_VALUE : 파티션에서 가장 처음 나오는 값(MIN 함수와 같은 결과)
SELECT	deptno,
		ename,
		sal,
		FIRST_VALUE(ename) OVER (PARTITION BY deptno
			ORDER BY sal DESC ROWS UNBOUNDED PRECEDING) AS "DEPT_A"
FROM 	emp1;

--		2) LAST_VALUE : 파티션에서 가장 나중에 나오는 값(MAX 함수와 같은 결과)
SELECT	deptno,
		ename,
		sal,
		LAST_VALUE(ename) OVER (PARTITION BY deptno
			ORDER BY sal DESC ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING
		) AS "DEPT_A"
FROM 	emp1;

--		3) LAG : 이전 행을 가지고 옴
-- ex) PRE_SAL은 SAL의 이전 행을 출력
SELECT	deptno,
		ename,
		sal,
		LAG(sal) OVER (ORDER BY sal DESC) AS "PRE_SAL"
FROM	emp1;

--		4) LEAD : 특정 위치의 행을 가지고 옴(Default는 1, 첫번째 행의 값)
-- ex) SAL에서 2번째 행의 값을 가져옴
-- 	LEAD(sal, 2): 현재 행으로부터 두 행 뒤에 위치한 행의 sal 값을 가져옴.
SELECT	deptno,
		ename,
		sal,
		LEAD(sal, 2) OVER (ORDER BY sal DESC) AS "LEAD_SAL"
FROM	emp1;



-- 	(5) 비율 관련 함수
--		1) CUME_DIST()
--			- 파티션 전체 건수에서 현재 행보다 작거나 같은 건수에 대한 누적 백분율 조회
--			- 누적 분포상에 위치는 0 ~ 1 사이 값
SELECT	deptno,
		ename,
		sal,
		CUME_DIST() OVER (PARTITION BY deptno ORDER BY sal DESC) AS "CUME_SAL"
FROM	emp1;

--		2) PERCENT_RANK()
--			- 파티션에서 제일 먼저 나온 것을 0으로, 제일 늦게 나온 것을 1로 하여
--				값이 아닌 행의 순서별 백분율을 조회
-- ex) 각 파티션에서 급여 등수의 퍼센트를 출력
SELECT	deptno,
		ename,
		sal,
		PERCENT_RANK() OVER (PARTITION BY deptno ORDER BY sal DESC) AS "PERCENT_SAL"
FROM	emp1;

--		3) NTILE(N)
--			- 파티션별로 전체 건수를 ARGUMENT 값으로 N 등분한 결과를 조회
-- ex) 급여 높은 순으로 4등분 하여 구분
SELECT	deptno,
		ename,
		sal,
		NTILE(4) OVER (ORDER BY sal DESC) AS "N_TILE"
FROM	emp1;

--		4) RATIO_TO_REPORT(COL)
--			- 파티션 내에 전체 SUM(칼럼)에 대한 행 별 칼럼값의 백분율을 소수점까지 조회
-- ex) 각 부서(deptno)별로 사원(ename)의 급여(sal)가 그 부서의 전체 급여에 대해
-- 		차지하는 비율을 "RATIO_SAL"로 계산하여 반환
SELECT	deptno,
		ename,
		sal,
		ROUND(RATIO_TO_REPORT(sal) OVER (PARTITION BY deptno), 2) AS "RATIO_SAL"
FROM	emp1;



-- 6. 테이블 파티션(Table Partition)

--	(1) Partition 기능
--		- 대용량 테이블을 여러 개의 데이터 파일에 분리해서 저장
--		- 입력, 수정, 삭제, 조회 성능이 향상
--		- 파티션 별로 독립적으로 관리(파티션별 백업, 복구 가능)
--		- 논리적 관리 단위인 테이블 스페이스 간 이동이 가능


--	(2) 종류
--		1) Range Partition
--			- 테이블 칼럼 중 값의 범위를 기준으로 여러 개의 파티션으로 데이터를 나누어 저장

--		2) List Partition
--			- 특정 값을 기준으로 분할하는 방법

--		3) Hash Partition
--			- DB 관리 시스템이 내부적으로 해시 함수를 사용해 데이터를 분할
--			(DB 관리 시스템이 알아서 분할하고 관리)

--		※ Composite Partition : 여러 개의 파티션 기법을 조합해서 사용


--	(3) 파티션 인덱스
--		1) Global Index : 여러 개의 파티션에서 하나의 인덱스를 사용
--		2) Local Index : 해당 파티션 별로 각자의 인덱스를 사용
--		3) Prefixed Index : 파티션 키와 인덱스 키가 동일
--		4) Non Prefixed Index : 파티션 키와 인덱스 키가 다름




