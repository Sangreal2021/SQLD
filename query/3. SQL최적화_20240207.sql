-- [SQL 최적화의 원리]

-- 1. Top N 쿼리
-- 특정 조건에 따라 데이터를 정렬한 후, 상위 N개의 결과만을 선택하는 쿼리.
-- 이는 보고서 생성, 데이터 분석, 대용량 데이터셋에서 가장 중요한 몇 가지 
--	항목을 추출하는 등 다양한 상황에서 유용하게 사용됨.

--	(1) 일반적인 쿼리 예시
-- ex) emp1 테이블에서 급여를 기준으로 상위 5명의 사원을 조회
SELECT * FROM (
  SELECT empno, ename, sal
  FROM emp1
  ORDER BY sal DESC
)
WHERE ROWNUM <= 5;


--	(2) FETCH FIRST N ROWS ONLY를 사용한 예시
--		(Oracle 12c 이상)
-- ex) emp1 테이블에서 사원을 급여 기준으로 내림차순 정렬 후, 상위 5개의 결과만을 선택하여 반환.
SELECT empno, ename, sal
FROM emp1
ORDER BY sal DESC
FETCH FIRST 5 ROWS ONLY;


--	(3) 주의사항
--		1) ROWNUM을 사용할 때는 반드시 먼저 데이터를 정렬한 후에 ROWNUM 조건을 적용해야 함.
--			(그렇지 않으면, 예상치 못한 결과를 얻을 수 있음)
-- 		2) FETCH FIRST N ROWS ONLY 구문은 Oracle 12c 버전부터 지원됨.
--			(이전 버전의 Oracle을 사용하는 경우 ROWNUM을 사용해야 함)
-- 		3) 동일한 값을 가진 데이터가 N번째에 위치하는 경우, 어떤 행이 반환될지 정확히 예측하기 어려울 수 있음.
--			(이 경우, RANK() 또는 DENSE_RANK()와 같은 윈도우 함수를 사용하여 보다 정밀하게 순위를 지정 가능)



-- 2. PIVOT절 과 UNPIVOT절
--	- 데이터의 표현 방식을 변환하는 데 사용되는 강력한 기능임.
--		이들은 행과 열을 동적으로 회전시켜 데이터를 다른 관점에서 보거나 분석할 수 있게 해줌.

--	(1) PIVOT절
--		- 여러 행의 데이터를 요약하여 열 형태로 표현하는 데 사용.
--		- 특정 열 값을 기반으로 다른 열들의 집계를 새로운 열로 표시 가능.
--		- PIVOT은 주로 카테고리별 집계나 요약 보고서를 생성할 때 유용.

--		1) 기본 구문
SELECT * FROM
(
  -- 기본 쿼리
)
PIVOT
(
  집계함수(집계 대상 컬럼)
  FOR 변환할 컬럼 IN (변환할 컬럼의 값1 AS 새 열1, 변환할 컬럼의 값2 AS 새 열2, ...)
);

--		2) 예시
-- 부서별로 최대 급여를 계산하여, 각 부서에 대한 최대 급여를 열로 표시하는 쿼리.
--	emp1 테이블에서 각 부서(deptno)의 최대 급여(sal)를 계산.
--	PIVOT 절은 각 부서 번호('10', '20', '30')를 기준으로 최대 급여를 집계하고,
--		결과를 새로운 열(dept_10, dept_20, dept_30)로 표시함.
SELECT dept_10, dept_20, dept_30
FROM
(
  SELECT deptno, sal
  FROM emp1
)
PIVOT
(
  MAX(sal) FOR deptno IN ('10' AS dept_10, '20' AS dept_20, '30' AS dept_30)
);


--	(2) UNPIVOT절
--		- PIVOT의 반대 작업을 수행하여, 열 형태로 표현된 데이터를 행 형태로 변환.
--		- 이를 통해 열로 표현된 데이터를 정규화된 형태로 다시 배치할 수 있음.

--		1) 기본 구문
SELECT * FROM
(
  -- 기본 쿼리
)
UNPIVOT
(
  변환할 컬럼 FOR 새로운 컬럼 IN (열1 AS 새 값1, 열2 AS 새 값2, ...)
);

--		2) 예시
/*SELECT deptno, salary
FROM
(
  SELECT dept_10, dept_20, dept_30
  FROM
  (
    SELECT deptno, sal
    FROM emp1
    PIVOT
    (
      MAX(sal) FOR deptno IN ('10' AS dept_10, '20' AS dept_20, '30' AS dept_30)
    )
  )
)
UNPIVOT
(
  salary FOR deptno IN (dept_10 AS '10', dept_20 AS '20', dept_30 AS '30')
);*/



--	(3) 주의사항
--		- PIVOT과 UNPIVOT 절은 데이터를 새로운 관점에서 분석하고, 보고서를 생성하는 데 유용하지만,
--			변환할 데이터의 크기와 구조에 따라 성능에 영향을 줄 수 있음.
--		- 집계 함수와 PIVOT을 사용할 때는 집계 대상이 되는 데이터의 분포를 사전에 파악하는 것이 좋음.
--			너무 많은 유니크한 값을 열로 변환하려고 하면 결과 테이블이 매우 크고 복잡해질 수 있음.
--		- UNPIVOT을 사용할 때는 데이터의 정규화를 목표로 해야 하며,
--			데이터의 의미와 구조를 명확히 이해한 상태에서 사용해야 함.



-- 3. 정규표현식
--	- 문자열 데이터를 검색하고, 매칭, 치환, 분할하는 데 매우 유용한 방법을 제공.
--	- Oracle은 다양한 정규 표현식 함수를 지원하며, 이들을 사용하여 
--		복잡한 문자열 처리 작업을 간단하고 효율적으로 수행할 수 있음.

--	(1) 주요 정규표현식 함수
--		1) REGEXP_LIKE(COL, pattern)
--		- 문자열이 정규 표현식 패턴과 일치하는지를 평가. WHERE 절에서 조건을 검사하는 데 사용 가능.

--		2) REGEXP_INSTR(COL, pattern)
--		- 문자열 내에서 정규 표현식 패턴과 일치하는 부분의 위치를 반환.

--		3) REGEXP_SUBSTR(COL, pattern)
--		- 문자열 내에서 정규 표현식 패턴과 일치하는 부분 문자열을 반환.

--		4) REGEXP_REPLACE(COL, pattern, replace)
--		- 문자열 내에서 정규 표현식 패턴과 일치하는 부분을 다른 문자열로 치환.

--		5) REGEXP_COUNT(COL, pattern)
--		- 문자열 내에서 정규 표현식 패턴과 일치하는 부분의 수를 반환.


--	(2) 정규표현식 패턴
--		- '^' : 문자열의 시작
--		- '$' : 문자열의 끝
--		- '[...]' : 괄호 안의 어느 한 문자와 일치
--		- '|' : 논리적 OR
--		- '*' : 0회 이상 반복
--		- '+' : 1회 이상 반복
--		- '?' : 0회 또는 1회
--		- '\d' : 숫자와 일치
--		- '\w' : 단어 문자와 일치
--		- '\s' : 공백 문자와 일치


--	(3) 예시
--		※ [AEIOUaeiou] 패턴은 대소문자를 구분하지 않고 모음을 나타냄.

--		1) emp1 테이블에서 이름이 'A'로 시작하는 사원을 찾기
SELECT	ename
FROM	emp1
WHERE	REGEXP_LIKE(ename, '^A');

--		2) emp1 테이블에서 각 사원 이름에 나타나는 첫 번째 모음의 위치를 찾기
SELECT	ename,
		REGEXP_INSTR(ename, '[AEIOUaeiou]') AS first_vowel_pos
FROM	emp1;

--		3)  emp1 테이블의 ename 컬럼에서 첫 번째 모음(a, e, i, o, u)을 찾아 반환
--	REGEXP_SUBSTR(COL, 패턴, 검색시작지점, 첫번째로일치하는항목)
SELECT	ename,
		REGEXP_SUBSTR(ename, '[aeiouAEIOU]', 1, 1) AS first_vowel
FROM	emp1;

--		4) emp1 테이블에서 사원 이름에 포함된 'A'를 '*'로 치환
SELECT	ename,
		REGEXP_REPLACE(ename, 'A', '*') AS modified_name
FROM	emp1;

--		5) emp1 테이블의 ename 컬럼에서 모음(a, e, i, o, u)의 개수를 계산
SELECT	ename,
		REGEXP_COUNT(ename, '[aeiouAEIOU]') AS vowel_count
FROM	emp1;



-- 4. 옵티마이저(Optimizer)와 실행 계획
--	★ 실행계획 단축키 : Ctrl + Shift + E

--	(1) 옵티마이저(Optimizer)
--		- SQL 실행 계획(Execution Plan)을 수립하고 SQL을 실행하는 DB 관리 시스템.
--		- 동일한 결과가 나오는 SQL도 어떻게 실행하느냐에 따라 성능이 달라짐.
--			(옵티마이저 실행 계획은 SQL 성능에 아주 중요한 역할)

--	(2) 특징
--		- 데이터 딕셔너리에 있는 오브젝트 통계, 시스템 통계 등의 정보를 사용해서
--			예상되는 비용을 산정.
--		- 여러 개의 실행 계획 중 최저비용을 가지고 있는 계획을 선택해서 SQL 실행.

--	(3) 옵티마이저 실행 계획 확인

-- ex) 터미널에서 sqlplus로 실행
DESC PLAN_TABLE;



-- 5. 옵티마이저

--	(1) 옵티마이저의 실행 방법
--		1) SQL을 실행하면 파싱(Parsing)을 실행해서 SQL 문법 검사 및 구문분석을 수행.
--		2) 구문분석 완료 후 옵티마이저가 규칙 기반 or 비용 기반으로 실행 계획을 수립.
--		3) 옵티마이저는 기본적으로 비용 기반 옵티마이저를 사용해서 실행 계획을 수립.
--			(비용기반 옵티마이저는 통계정보를 활용해 최적의 실행 계획을 수립)
--		4) 실행 계획 수립이 완료되면 최종적으로 SQL을 실행하고 실행이 완료되면
--			데이터 인출(Fetch)

--		5) 옵티마이저 엔진
--			- Query Transformer
--				-> SQL문을 효율적으로 실행하기 위해 옵티마이저가 변환.
--				-> SQL이 변환되어도 그 결과는 동일.
--			- Estimator
--				-> 통계정보를 사용해 SQL 실행비용을 계산.
--				-> 총비용은 최적의 실행 계획을 수립하기 위해서..
--			- Plan Generator
--				-> SQL을 실행할 실행 계획을 수립함.

--	(2) 옵티마이저 엔진
--		- 실행 계획을 수립할 때 15개의 우선순위를 기준으로 실행 계획을 수립

--		1) ROWID를 사용한 단일 행인 경우
--		2) 클러스터 조인에 의한 단일 행인 경우
--		3) 유일하거나, 기본키(PK)를 가진 해시 클러스터 키에 의한 단일 행인 경우
--		4) 유일하거나, 기본키(PK)에 의한 단일 행인 경우
--		5) 클러스터 조인인 경우
--		6) 해시 클러스터 조인인 경우
--		7) 인덱스 클러스터 키인 경우
--		8) 복합 칼럼 인덱스인 경우
--		9) 단일 칼럼 인덱스인 경우
--		10) 인덱스가 구성된 칼럼에서 제한된 범위를 검색하는 경우
--		11) 인덱스가 구성된 칼럼에서 무제한 범위를 검색하는 경우
--		12) 정렬-병합(Sort Merge) 조인인 경우
--		13) 인덱스가 구성된 칼럼에서 MAX 혹은 MIN을 구하는 경우
--		14) 인덱스가 구성된 칼럼에서 ORDER BY를 실행하는 경우
--		15) 전체 테이블을 스캔(FULL TABLE SCAN)하는 경우

-- ROWID를 사용한 단일 행 검색
SELECT rowid, empno, ename
FROM emp1;

SELECT /*+ RULE */ * FROM emp1
WHERE ROWID='AAAWeSAAGAAAAGLAAA';


--	(3) 비용 기반 옵티마이저
--		- 오브젝트 통계 및 시스템 통계를 사용해서 총비용을 계산.
--		- 총비용은 SQL문을 실행하기 위해 예상되는 소요시간 or 자원의 사용량.
--		- 총비용이 적은 쪽으로 실행 계획을 수립.
--			(단, 비용 기반 옵티마이저에서 통계정보가 부적절하면 성능 저하가 발생할 수 있음)
--		- 인덱스 스캔보다 전체 테이블 스캔이 비용이 낮다고 판단하면 적절한 인덱스가
--			존재하더라도 전체 테이블 스캔으로 SQL문을 수행


--	(4) 규칙 기반 옵티마이저
--		- 규칙에 따라 적절한 인덱스가 존재하면 전체 테이블 스캔보다 항상 인덱스를 사용



-- 6. 인덱스(Index)
--	(1) 인덱스
--		1) 데이터를 빠르게 검색할 수 있는 방법을 제공.
--		2) 인덱스 키(ex. empno)로 정렬되어 있어서 원하는 데이터를 빠르게 조회.
--		3) 오름차순 및 내림차순으로 탐색 가능.
--		4) 하나의 테이블에 여러 개의 인덱스를 생성할 수 있고,
--			하나의 인덱스는 여러 개의 칼럼으로 구성될 수 있음.
--		5) 테이블 생성시 기본키(PK)는 자동으로 인덱스가 만들어지고 인덱스 이름은 SYSXXXX.
--		6) idx1 - idx2, idx1 + idx2 등 인덱스 변형이 일어나면 실행되지 않음(성능 저하)
--		7) 인덱스 구조
--			- Root Block : 인덱스 트리에서 가장 상위에 있는 노드.
--			- Branch Block : 다음 단계의 주소를 가지고 있는 포인터(Pointer)로 구성.
--			- Leaf Block : 인덱스 키와 ROWID로 구성되고 인덱스 키는 정렬되어 저장.
--				-> Double Linked List 형태로 되어 있어 양방향 탐색 가능.
--				-> 인덱스 키를 읽으면 ROWID를 사용해 emp 테이블의 행을 직접 읽을 수 있음.


--	(2) 인덱스 생성
--		- "CREATE INDEX" 문을 사용해 생성 가능.
--		- 인덱스 생성시 한 개 이상의 칼럼을 사용해 생성할 수 있음.
--		- 인덱스 키는 기본적으로 오름차순으로 정렬, DESC구를 포함하면 내림차순으로 정렬.
--		- 파티션 인덱스의 경우 파티션 키에 대해 인덱스 생성 가능 (GLOBAL 인덱스)

-- ex) ename에 대해 오름차순으로 정렬, sal은 내림차순으로 정렬하는 인덱스 생성하기
CREATE INDEX ind_emp3 ON emp3 (ename ASC, sal DESC);


--	(3) 인덱스 종류
--		- 순차 인덱스
--		- 결합 인덱스
--		- 비트맵
--		- 클러스터
--		- 해시 인덱스


--	(4) 인덱스 타입
--		- VARCHAR, CHAR, DATE, NUMBER 모두 생성 가능


--	(5) 인덱스 스캔(Index Scan)
--		1) 인덱스 유일 스캔(Index Unique SCAN)
--			- 검색 속도가 가장 빠름.
--			- 인덱스의 키 값이 중복되지 않은 경우, 해당 인덱스를 사용할 때 발생됨.
--			- empno가 중복되지 않는 경우 특정 하나의 empno를 조회함.
SELECT * FROM emp1 WHERE empno=1000;

--		2) 인덱스 범위 스캔(Index Range SCAN)
--			- SELECT문에서 특정 범위를 조회하는 WHERE문을 사용할 경우 발생.
--			- LIKE, BETWEEN이 대표적인 예.
--			(데이터 양이 적은 경우 인덱스 자체를 실행하지 않고 TABLE FULL SCAN이 될 수 있음)
--			- 인덱스의 Leaf Block의 특정 범위를 스캔한 것.
--			- 결과 건수만큼 반환. 즉 결과가 없으면 한 건도 반환X
SELECT empno FROM emp3 WHERE empno >= 1000;

--		3) 인덱스 전체 스캔(Index Full SCAN)
--			- 인덱스에서 검색되는 인덱스 키가 많은 경우 Leaf Block의 처음부터
--				끝까지 전체를 읽어 들임.

--		4) Table Full Scan시 High Watermark
--			- 테이블에 하나의 ROW만 저장되어 있을 때는 가장 유리한 방식
--			- Table Full Scan은 테이블의 데이터를 모두 읽은 것.
--			- 테이블을 읽을 때 High Watermark 이하 까지만 Table Full Scan을 함.
--			- High Watermark는 테이블에 데이터가 저장된 블록에서 최상위 위치를 의미.
--				(데이터 삭제시 High Watermark가 변경)

SELECT ename, sal
FROM emp1 WHERE ename LIKE '%' AND sal > 0;



-- 7. 실행 계획(Execution Plan)
--	- SQL문의 처리를 위한 절차와 방법이 표현
--	- 동일 SQL문에 대해 실행 계획이 다르다고 결과가 달라지지 않음(성능은 달라짐)
--	- 실행 계획은 액세스 기법, 조인 순서, 조인 방법등으로 구성
--	- 최적화 정보는 실행 계획의 단계별 예상 비용을 표시

--	ex) 다음은 emp1 테이블과 dept 테이블을 조인하고 emp1 테이블의 deptno 번호가
--		10번인 것을 조회하는 SQL
SELECT * FROM emp1, dept1
WHERE emp1.DEPTNO = dept1.DEPTNO AND emp1.DEPTNO = 10;

--	- INDEX를 검색하고 ROWID를 사용해서 dept1 테이블을 조회
--	- 먼저 조회되는 테이블을 Outer Table, 그 다음에 조회되는 테이블을 Inner Table.



-- 8. 옵티마이저 조인(Optimizer Join)

--	(1) Nested Loop 조인
--		- 하나의 테이블에서 데이터를 먼저 찾고 그 다음 테이블을 조인하는 방식으로 실행.
--		- 먼저 조회되는 테이블을 외부 테이블(Outer Table)이라고 하고, 
--			그 다음 조회되는 테이블을 내부 테이블(Inner Table)이라고 함.
--		- 외부 테이블(선행 테이블)의 크기가 작은 것을 먼저 찾는 것이 중요.
--			(그래야 데이터가 스캔되는 범위를 줄일 수 있기 때문)
--		- 내부 테이블(후행 테이블) 에 인덱스가 없으면 사용 X
--		- RANDOM ACCESS가 많이 발생.(성능 저하)
--		- 온라인 트랜잭션 처리(OLTP) 시스템에 적합. 

SELECT /*+ ordered use_nl(b) */ * FROM emp1 a, dept1 b
WHERE a.DEPTNO = b.DEPTNO AND a.DEPTNO = 10;

--	- 위의 예는 use_nl 힌트를 사용해서 의도적으로 Nested Loop 조인을 실행.
--	- emp1 테이블을 먼저 FULL SCAN하고 그다음 dept1 테이블을 FULL SCAN하여
--		Nested Loop 조인을 하는 것.
--	- ordered 힌트는 FROM절에 나오는 테이블 순서대로 조인을 하게 하는 것.
--		ordered 힌트는 혼자 사용되지 않고 use_nl, use_merge, use_hash 힌트와 함께 사용.


--	(2) Sort Merge 조인
--		- 두 개의 테이블을 SORT_AREA라는 메모리 공간에 모두 로딩하고 SORT를 수행함.
--		- 두 개의 테이블에 대해 SORT가 완료되면 두 개의 테이블을 병합함.
--		- 정렬(Sort)이 가장 많이 발생하기 때문에 데이터양이 많아지면 성능이 떨어짐.
--		- 정렬 데이터양이 너무 많으면 정렬은 임시 영역에서 수행됨.
--			(임시 영역은 디스크에 있기 때문에 성능이 급격히 떨어짐)
SELECT /*+ ordered use_merge(b) */ * FROM emp1 a, dept1 b
WHERE a.DEPTNO = b.DEPTNO AND a.DEPTNO = 10;

--	- 위의 예는 Oracle DB 힌트를 사용해 의도적으로 SORT MERGE 조인을 한 것.
--	- use_merge 힌트를 사용해 SORT MERGE 조인을 할 수 있음.
--		(단, use_merge 힌트는 ordered 힌트와 같이 사용해야 함)


--	(3) Hash 조인
--		- 두 개의 테이블 중 행의 수가 적은 테이블을 HASH 메모리에 로딩하고
--			두 개의 테이블의 조인 키를 사용해서 해시 테이블을 생성.
--		- 해시 함수를 사용해서 주소를 계산하고 해당 주소를 사용해서 테이블을 조인하기 때문에
--			CPU 연산을 많이 함.
--		- 선행 테이블이 충분히 메모리에 로딩되는 크기여야 함.
SELECT /*+ ordered use_hash(b) */ * FROM emp1 a, dept1 b
WHERE a.DEPTNO = b.DEPTNO AND a.DEPTNO = 10;




























