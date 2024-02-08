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
	CONNECT BY PRIOR empno = mgr;0099999

	
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















































