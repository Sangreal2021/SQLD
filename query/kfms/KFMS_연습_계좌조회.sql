-- 은행계좌조회 > 실시간 잔액조회
SELECT
	ROWNUM AS PNO
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.BANK_NM END AS BANK_NM
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.ACCT_NO_FORMAT END AS ACCT_NO_FORMAT
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.ACCT_NICK_NM END AS ACCT_NICK_NM
	, TB2.CUR_AMT || '' AS CUR_AMT
	, TB2.REAL_AMT || '' AS REAL_AMT
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.ACCT_HIS_LST_DATE END AS ACCT_HIS_LST_DATE
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.ACCT_BAL_LST_DT END AS ACCT_BAL_LST_DT
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.ACCT_BAL_LST_STS END AS ACCT_BAL_LST_STS
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.BANK_CD END AS BANK_CD
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.ACCT_NO END AS ACCT_NO
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.ACCT_SEQ END AS ACCT_SEQ
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.ERR_MSG END AS ERR_MSG
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.FIRM_CD END AS FIRM_CD
	, TB2.GINFO
FROM(
	SELECT
		   MAX(TB.BANK_NM) AS BANK_NM
		 , MAX(TB.ACCT_NO_FORMAT) AS ACCT_NO_FORMAT
		 , MAX(TB.ACCT_NICK_NM) AS ACCT_NICK_NM
		 , SUM(CUR_AMT) AS CUR_AMT
		 , SUM(REAL_AMT) AS REAL_AMT
		 , MAX(TB.ACCT_HIS_LST_DATE) AS ACCT_HIS_LST_DATE
		 , MAX(TB.ACCT_BAL_LST_DT) AS ACCT_BAL_LST_DT
		 , MAX(TB.ACCT_BAL_LST_STS) AS ACCT_BAL_LST_STS
		 , MAX(TB.BANK_CD) AS BANK_CD
		 , MAX(TB.ACCT_NO) AS ACCT_NO
		 , MAX(TB.ACCT_SEQ) AS ACCT_SEQ
		 , MAX(TB.ERR_MSG) AS ERR_MSG
		 , MAX(TB.FIRM_CD) AS FIRM_CD
		 , GROUPING(TB.GRIDUNQID) AS GINFO
	FROM (
		SELECT A.BIZ_NO||A.ACCT_SEQ  AS GRIDUNQID   /*Use Jex grid PK (소문자로 바꿔줘야함)*/
			 , B.BANK_NM                            /* 은행명 */
			 , FN_ACCT_FORMAT(A.BANK_CD, DWC_CRYPT.decrypt(A.ACCT_NO)) AS ACCT_NO_FORMAT /* 계좌번호 포맷 */
			 , A.ACCT_NICK_NM                       /* 계좌별칭 */
			 , NVL(A.CUR_AMT,0) CUR_AMT             /* 현재잔액 */
			 , NVL(A.REAL_AMT,0) REAL_AMT           /* 인출가능액 */
			 , (SELECT /*+ INDEX_DESC (D UIDX_FN_ACCT_HIS_01) */  ACCT_TXDAY||ACCT_TXTIME
				  FROM FN_ACCT_HIS$ D
				 WHERE D.BANK_CD=A.BANK_CD
				   AND D.ACCT_NO=A.ACCT_NO
				   AND NOT D.ACCT_TXDAY='99999999'
				   AND ROWNUM=1) AS ACCT_HIS_LST_DATE  /* 최종거래내역일자 */
			 , A.ACCT_BAL_LST_DT                       /* 잔액최종조회일시 */
			 , A.ACCT_BAL_LST_STS                      /* 잔액최종조회상태 */
			 , A.BANK_CD                               /* 은행코드 */
			 , DWC_CRYPT.decrypt(A.ACCT_NO) AS ACCT_NO /* 계좌번호 */
			 , A.ACCT_SEQ                          /* 계좌일련번호 */
			 , A.ACCT_BAL_LST_MSG AS ERR_MSG       /* 에러메세지 */
			 , A.FIRM_CD                           /* 펌기관코드 */
		FROM FN_ACCT$ A
			 , BA_USER_GRP_ACCT_A001_V V
			 , BA_BANK B
		WHERE A.ACCT_TYPE = '01'
		   AND A.BANK_CD   = B.BANK_CD(+)
		   AND A.USE_YN    = 'Y'
		   AND A.DEL_YN    = 'N'
		   AND A.TRD_STS   = '001'
		   AND NVL(A.ACCT_SEQ, 'NOT')  = V.ACCT_SEQ
		   AND V.USER_ID   = 'SYSTEMADMIN'
		) TB
		GROUP BY ROLLUP(GRIDUNQID)
	) TB2
	ORDER BY TB2.GINFO, TB2.BANK_NM, TB2.ACCT_NO
;



-- 은행계좌조회 > 기간별 잔액조회
SELECT ROWNUM PNO
	, CASE WHEN TB2.GINFO = '001' THEN '소계' ELSE TB2.ACCT_TXDAY END AS ACCT_TXDAY
	, CASE WHEN TB2.GINFO = '000' THEN TB2.BANK_NM ELSE '' END AS BANK_NM
	, CASE WHEN TB2.GINFO = '000' THEN TB2.ACCT_NO ELSE '' END AS ACCT_NO
	, CASE WHEN TB2.GINFO = '000' THEN TB2.ACCT_CUST_NM ELSE '' END AS ACCT_CUST_NM
	, TB2.MNRC_CNT
	, TB2.MNRC_AMT || '' AS MNRC_AMT
	, TB2.DROT_CNT
	, TB2.DROT_AMT || '' AS DROT_AMT
	, CASE WHEN TB2.GINFO = '000' THEN TO_CHAR(TB2.TX_CUR_BAL, 'FM999,999,999,999,999') ELSE '' END AS TX_CUR_BAL
	, CASE WHEN TB2.GINFO = '000' THEN TB2.ACCT_NICK_NM ELSE '' END AS ACCT_NICK_NM
	, TB2.GINFO
	, TB2.TOT_COUNT
FROM(
	SELECT
		   COUNT(1) TOT_COUNT
		 , TO_CHAR(TO_DATE(TB.ACCT_TXDAY, 'YYYYMMDD'), 'YYYY-MM-DD') AS ACCT_TXDAY
		 , TB.BANK_NM AS BANK_NM
		 , TB.ACCT_NO AS ACCT_NO
		 , MAX(TB.ACCT_CUST_NM) AS ACCT_CUST_NM
		 , SUM(TB.MNRC_CNT) AS MNRC_CNT
		 , SUM(TB.MNRC_AMT) AS MNRC_AMT
		 , SUM(TB.DROT_CNT) AS DROT_CNT
		 , SUM(TB.DROT_AMT) AS DROT_AMT
		 , MAX(TB.TX_CUR_BAL) AS TX_CUR_BAL
		 , MAX(TB.ACCT_NICK_NM) AS ACCT_NICK_NM
		 , GROUPING(TB.BANK_NM)||GROUPING(TB.ACCT_NO)||GROUPING(TB.ACCT_TXDAY) AS GINFO
	FROM (
			SELECT
				   B.ACCT_TXDAY
				 , A.BANK_CD
				 , BANK.BANK_NM AS BANK_NM  /* 은행명 */
				 , FN_ACCT_FORMAT(a.bank_cd, DWC_CRYPT.decrypt(A.acct_no)) as ACCT_NO
				 , A.ACCT_CUST_NM
				 , B.MNRC_CNT
				 , B.MNRC_AMT
				 , B.DROT_CNT
				 , B.DROT_AMT
				 , B.TX_CUR_BAL
				 , A.ACCT_NICK_NM
			FROM FN_ACCT$ A
				 , FN_ACCT_DAY_BLCE B
				 , BA_USER_GRP_ACCT_A001_V V
				 , BA_BANK BANK
			WHERE 1 = 1
			   AND B.ACCT_TXDAY between '20231001' and '20231030'
			   AND A.ACCT_SEQ = B.ACCT_SEQ
			   AND NVL(B.ACCT_SEQ, 'NOT') = V.ACCT_SEQ
			   AND A.BANK_CD  = BANK.BANK_CD(+)
			   AND V.USER_ID  = 'SYSTEMADMIN'
			   AND B.DEAL_YN  = 'Y'
			   AND A.DEL_YN  = 'N'
			ORDER BY BANK_NM, ACCT_NO, B.ACCT_TXDAY DESC
		) TB
		 GROUP BY ROLLUP(TB.BANK_NM, TB.ACCT_NO, TB.ACCT_TXDAY)
		 ORDER BY BANK_NM, ACCT_NO, GINFO, ACCT_TXDAY DESC
	) TB2
	WHERE TB2.GINFO IN ('000', '001', '111')
;



-- 은행계좌조회 > 거래내역조회
SELECT ROWNUM PNO
	, TB2.ACCT_NO
	, TB2.BANK_NM
	, TO_CHAR(TO_DATE(TB2.TX_DAY_TIME, 'YYYYMMDDHH24MISS'), 'YYYY-MM-DD HH24:MI:SS') AS TX_DAY_TIME
	, CASE WHEN TB2.GINFO = '0011' THEN '합계 : '||TO_CHAR(TB2.MNRC_AMT, 'FM999,999,999,999,999') ELSE ''||TO_CHAR(TB2.MNRC_AMT, 'FM999,999,999,999,999') END AS MNRC_AMT
	, CASE WHEN TB2.GINFO = '0011' THEN '합계 : '||TO_CHAR(TB2.DROT_AMT, 'FM999,999,999,999,999') ELSE ''||TO_CHAR(TB2.DROT_AMT, 'FM999,999,999,999,999') END AS DROT_AMT
	, CASE WHEN TB2.GINFO = '0000' THEN TO_CHAR(TB2.TX_CUR_BAL, 'FM999,999,999,999,999') ELSE '' END AS TX_CUR_BAL
	, CASE WHEN TB2.GINFO = '0000' THEN TB2.REMARK ELSE '' END AS REMARK
	, CASE WHEN TB2.GINFO = '0000' THEN TB2.BRANCH ELSE '' END AS BRANCH
	, CASE WHEN TB2.GINFO = '0000' THEN TB2.BR_NM ELSE ''  END AS BR_NM
	, CASE WHEN TB2.GINFO != '1111' THEN TB2.ACCT_NICK_NM ELSE '' END AS ACCT_NICK_NM
	, TB2.GINFO
	, CASE WHEN TB2.GINFO = '0001' THEN 'Y' ELSE '' END AS GRP_OPEN_YN
	, 'Y' AS GRP_VIEW_YN
	, TB2.ACCT_NO AS GKEY
	, TB2.TOT_COUNT
	, CASE WHEN TB2.GINFO = '0000' THEN TB2.FN_ACCT_HIS_PNO ELSE 0 END AS FN_ACCT_HIS_PNO
	, CASE WHEN TB2.GINFO = '0000' THEN TB2.INOUT_GUBUN ELSE '' END AS INOUT_GUBUN
	, CASE WHEN TB2.GINFO = '0000' THEN TB2.GINFO||'_'||TB2.ACCT_NO ELSE TB2.GINFO||'_'||TB2.ACCT_NO END AS ID
	, CASE WHEN TB2.GINFO = '0000' THEN '0011'||'_'||TB2.ACCT_NO ELSE '' END AS PID
	, TR_INT
	, CORP_TAX_AMT  /*MMT해지 시 법인세*/
	, LOC_TAX_AMT   /*MMT해지 시 지방세*/
FROM(
	SELECT
		   COUNT(1) TOT_COUNT
		 , TB.ACCT_NO AS ACCT_NO
		 , TB.BANK_NM AS BANK_NM
		 , MAX(TB.TX_DAY_TIME) AS TX_DAY_TIME
		 , MAX(TB.TX_DAY) AS TX_DAY
		 , SUM(TB.MNRC_AMT) AS MNRC_AMT
		 , SUM(TB.DROT_AMT) AS DROT_AMT
		 , MAX(TB.TX_CUR_BAL) AS TX_CUR_BAL
		 , MAX(TB.REMARK) AS REMARK
		 , MAX(TB.BRANCH) AS BRANCH
		 , MAX(BR.BR_NM) AS BR_NM
		 , MAX(TB.ACCT_NICK_NM) AS ACCT_NICK_NM
		 , MAX(TB.FN_ACCT_HIS_PNO) AS FN_ACCT_HIS_PNO
		 , MAX(TB.INOUT_GUBUN) AS INOUT_GUBUN
		 , NVL(SUM(TR_INT),0) AS TR_INT        /*MMT해지 시 발생이자*/
		 , NVL(SUM(CORP_TAX_AMT),0) AS CORP_TAX_AMT  /*MMT해지 시 법인세*/
		 , NVL(SUM(LOC_TAX_AMT),0) AS LOC_TAX_AMT   /*MMT해지 시 지방세*/
		 , TB.NOTI_TR_NO
		 , GROUPING(TB.BANK_NM)||GROUPING(TB.ACCT_NO)|| GROUPING(TB.NOTI_TR_NO) ||GROUPING(tb.TX_DAY_TIME) AS GINFO
	FROM (
			SELECT
				   BANK.BANK_NM AS BANK_NM /* 은행명 */
				 , FN_ACCT_FORMAT(a.bank_cd, DWC_CRYPT.decrypt(a.acct_no)) as acct_no /* 계좌번호 */
				 , a.acct_nick_nm                       /* 계좌별칭 */
				 , b.acct_txday                         /* 거래일자 */
				 , CASE WHEN b.trad_dist IN ('31', '51','53' ) THEN -b.tx_amt                 /* 입금취소건 */
						WHEN b.bank_cd = '10000004' AND b.trad_dist IN ('13') THEN -b.tx_amt  /*국민은행 입금취소일 경우*/
						WHEN b.inout_gubun = '2' AND b.trad_dist NOT IN ('23','32', '52','54' )  THEN b.tx_amt
						ELSE 0
				   END as mnrc_amt /* 입금액 */
				 , CASE WHEN b.trad_dist IN ('32', '52','54' ) THEN -b.tx_amt                 /* 출금취소건 */
						WHEN b.bank_cd = '10000004' AND b.trad_dist IN ('23') THEN -b.tx_amt  /*국민은행 출금취소일 경우*/
						WHEN b.inout_gubun IN ('1','N')  AND b.trad_dist NOT IN ('13','31', '51','53' ) THEN b.tx_amt
						ELSE 0
				   END as drot_amt /* 출금액 */
				 , nvl(b.tx_cur_bal,0) tx_cur_bal                     /* 현재잔액 */
				 , CASE WHEN B.JEOKYO IS NOT NULL THEN B.JEOKYO
						WHEN B.TRAD_DIST IN ('40', '41', '42') THEN '결산이자'
						ELSE b.jeokyo END as remark    /* 적요 */
				 , LPAD(CASE
					   WHEN b.dep_brn_cd7 IS NULL
					   THEN B.BRANCH
					   ELSE
						   CASE LENGTH(TRIM(B.DEP_BRN_CD7))
							   WHEN 4
							   THEN B.TR_ACT_BANK_CD3||B.DEP_BRN_CD7
							   WHEN 7
							   THEN B.DEP_BRN_CD7
						   END
				   END, 7, '0') AS BRANCH                            /* 취급점 */
				 , b.acct_txtime   as tx_time               /* 거래시간 */
				 , B.ACCT_TXDAY_SEQ
				 , A.BANK_CD    /* 은행코드 */
				 , A.BRN_CD     /* 지점코드 */
				 , B.ACCT_TXDAY AS TX_DAY   /* 거래일자 */
				 , (B.ACCT_TXDAY||B.ACCT_TXTIME) AS TX_DAY_TIME   /* 거래일시 */
				 , B.EXPENSE_YN
				 , B.VOTE_NO
				 , C.CMM_CD_NM AS EXPENSE_YN_TXT
				 , B.FN_ACCT_HIS_PNO
				 , B.INOUT_GUBUN
				 , B.TR_INT        /*MMT해지 시 발생이자*/
				 , B.CORP_TAX_AMT  /*MMT해지 시 법인세*/
				 , B.LOC_TAX_AMT   /*MMT해지 시 지방세*/
				 , TO_NUMBER(B.NOTI_TR_NO) AS NOTI_TR_NO
			FROM FN_ACCT$ a
				 , FN_ACCT_HIS$ b
				 , DWC_CMM_CODE C
				 , BA_USER_GRP_ACCT_A001_V V
				 , BA_BANK BANK
			WHERE 1=1
			   AND b.acct_txday between '20231101' and '20231115'
			   AND a.acct_type='01'
			   AND a.bank_cd=b.bank_cd
			   AND a.acct_no=b.acct_no
			   AND A.BANK_CD = BANK.BANK_CD(+)
			   AND B.EXPENSE_YN = C.CMM_CD(+)
			   AND C.GRP_CD(+) = 'S303'
			   AND a.del_yn='N'
			   AND NVL(A.ACCT_SEQ, 'NOT') = V.ACCT_SEQ
			   AND V.USER_ID = 'SYSTEMADMIN'
		) TB
		, CMS_TC_BR BR
            WHERE TB.BRANCH = BR.BR_ID(+)
            GROUP BY ROLLUP(TB.BANK_NM, TB.ACCT_NO, TB.NOTI_TR_NO, TB.TX_DAY_TIME)
            ORDER BY TB.BANK_NM, TB.ACCT_NO, GINFO DESC, TX_DAY_TIME DESC, TB.NOTI_TR_NO DESC
	) TB2
	WHERE TB2.GINFO IN ('0000', '0011', '1111')
;



-- 은행계좌조회 > 거래내역조회(보고서)



-- 은행계좌조회 > 평잔조회
SELECT
	ROWNUM PNO
	, TB.BANK_CD
	, BANK.BANK_NM AS BANK_NM /* 은행명 */
	, '' AS ACCT_NO
	, '' AS ACCT_TXDAY
	, TRUNC(TB.CUR_BAL / (to_date( '20240226', 'YYYYMMDD' ) - to_date( '20240219', 'YYYYMMDD' ) + 1) ) AS CUR_BAL_AVG
	, TB.CUR_BAL || '' AS CUR_BAL
	, '' AS ACCT_NICK_NM
FROM(
	SELECT
		  A.BANK_CD
		, SUM(B.TX_CUR_BAL) AS CUR_BAL
	  FROM FN_ACCT$ A, FN_ACCT_DAY_BLCE B
	WHERE 1 = 1
	   AND B.ACCT_TXDAY between '20240219' and '20240226'
	   AND A.ACCT_SEQ = B.ACCT_SEQ
	   AND DWC_CRYPT.decrypt(A.ACCT_NO) NOT LIKE '%'||06754974050105||'%'  /*MMT계좌 제외*/
	   AND A.DEL_YN = 'N'
	GROUP BY A.BANK_CD
	) TB,
	BA_BANK BANK
		WHERE TB.BANK_CD = BANK.BANK_CD(+)
		ORDER BY BANK_NM
;



-- 기타수입등록/조회 > 기타수입등록
SELECT
	TB2.FN_ACCT_HIS_PNO AS PNO
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.BANK_CD END AS BANK_CD
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.BANK_NM END AS BANK_NM
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.ACCT_NO END AS ACCT_NO
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.ACCT_NO1 END AS ACCT_NO1
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.ACCT_TXDAY END AS ACCT_TXDAY
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.ACCT_TXTIME END AS ACCT_TXTIME
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.ACCT_TXDAY||TB2.ACCT_TXTIME END AS ACCT_DT
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE ''||TB2.ACCT_TXDAY_SEQ END AS ACCT_TXDAY_SEQ
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.INOUT_GUBUN END AS INOUT_GUBUN
	, TB2.TX_AMT || '' AS TX_AMT
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.JEOKYO END AS JEOKYO
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.BRANCH END AS BRANCH
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.BR_NM  END AS BR_NM
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.ACRS_APLY_YN END AS ACRS_APLY_YN
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.LEAS_EX_IPRT_YN END AS LEAS_EX_IPRT_YN
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.LEAS_EX_IPRT_TXT END AS LEAS_EX_IPRT_TXT
	, TB2.GINFO
FROM(
	SELECT
		   MAX(TB.FN_ACCT_HIS_PNO) AS FN_ACCT_HIS_PNO
		 , MAX(TB.BANK_CD) AS BANK_CD
		 , MAX(TB.BANK_NM) AS BANK_NM
		 , MAX(TB.ACCT_NO) AS ACCT_NO
		 , MAX(TB.ACCT_NO1) AS ACCT_NO1
		 , MAX(TB.ACCT_TXDAY) AS ACCT_TXDAY
		 , MAX(TB.ACCT_TXDAY_SEQ) AS ACCT_TXDAY_SEQ
		 , MAX(TB.INOUT_GUBUN) AS INOUT_GUBUN
		 , SUM(TX_AMT) AS TX_AMT
		 , MAX(TB.JEOKYO) AS JEOKYO
		 , MAX(TB.BRANCH) AS BRANCH
		 , MAX(BR.BR_NM) AS BR_NM
		 , MAX(TB.ACCT_TXTIME) AS ACCT_TXTIME
		 , MAX(TB.ACRS_APLY_YN) AS ACRS_APLY_YN
		 , MAX(TB.LEAS_EX_IPRT_YN) AS LEAS_EX_IPRT_YN
		 , MAX(TB.LEAS_EX_IPRT_TXT) AS LEAS_EX_IPRT_TXT
		 , GROUPING(TB.FN_ACCT_HIS_PNO) AS GINFO
	FROM(
			SELECT
				   B.FN_ACCT_HIS_PNO /* FN_ACCT_HIS$ PK NO */
				 , B.BANK_CD /* 은행코드 */
				 , C.BANK_NM /* 은행명 */
				 , DWC_CRYPT.decrypt(B.ACCT_NO) AS ACCT_NO /* 계좌번호 */
				 , FN_ACCT_FORMAT(B.BANK_CD, DWC_CRYPT.decrypt(B.ACCT_NO)) AS ACCT_NO1 /* 계좌번호 함수쓰기 */
				 , B.ACCT_TXDAY /* 거래일자 */
				 , B.ACCT_TXDAY_SEQ /* 일련번호 */
				 , B.INOUT_GUBUN /* 입출구분 */
				 , B.TX_AMT /* 거래금액 */
				 , B.JEOKYO /* 적요 */
				 , LPAD(CASE
					   WHEN b.dep_brn_cd7 IS NULL
					   THEN B.BRANCH
					   ELSE
						   CASE LENGTH(TRIM(B.DEP_BRN_CD7))
							   WHEN 4
							   THEN B.TR_ACT_BANK_CD3||B.DEP_BRN_CD7
							   WHEN 7
							   THEN B.DEP_BRN_CD7
						   END
				   END, 7, '0') AS BRANCH                             /* 취급점 */
				 , B.ACCT_TXTIME /* 거래시간 */
				 , B.ACRS_APLY_YN /* 실적적용여부 */
				 , NVL(B.LEAS_EX_IPRT_YN, 'N') AS LEAS_EX_IPRT_YN /* 임대료외수입여부 */
				 , DECODE(NVL(B.LEAS_EX_IPRT_YN, 'N'), 'Y', '기타수입', '') AS LEAS_EX_IPRT_TXT
			FROM FN_ACCT$ A
				 , FN_ACCT_HIS$ B
				 , BA_BANK C
				 , BA_USER_GRP_ACCT_A001_V V
			WHERE 1 = 1
			   AND B.ACCT_TXDAY BETWEEN '20230601' and '20230630'
			   AND (B.ACRS_APLY_YN = 'N' OR B.ACRS_APLY_YN IS NULL)
			   AND A.ACCT_USE_TYPE = '00'
			   AND B.INOUT_GUBUN   = '2'
			   AND A.BANK_CD       = B.BANK_CD
			   AND A.ACCT_NO       = B.ACCT_NO
			   AND B.BANK_CD       = C.BANK_CD(+)
			   AND NVL(A.ACCT_SEQ, 'NOT') = V.ACCT_SEQ
			   AND V.USER_ID       = 'SYSTEMADMIN'
			   AND B.BANK_CD       = '10000004'
			   AND DWC_CRYPT.decrypt(A.ACCT_NO) = '06750104118660'
			ORDER BY B.ACCT_TXDAY DESC, C.BANK_NM
		) TB
			, CMS_TC_BR BR
			WHERE TB.BRANCH = BR.BR_ID(+)
            GROUP BY ROLLUP(TB.FN_ACCT_HIS_PNO)
	) TB2
	ORDER BY TB2.GINFO, TB2.ACCT_TXDAY DESC, TB2.BANK_NM
;



-- 기타수입등록/조회 > 기타수입내역조회
SELECT ROWNUM PNO
	, TB2.ACCT_NO
	, TB2.BANK_NM
	, TO_CHAR(TO_DATE(TB2.TX_DAY_TIME, 'YYYYMMDDHH24MISS'), 'YYYY-MM-DD HH24:MI:SS') AS TX_DAY_TIME
	, CASE WHEN TB2.GINFO = '001' THEN '합계 : '||TO_CHAR(TB2.MNRC_AMT, 'FM999,999,999,999,999') ELSE ''||TO_CHAR(TB2.MNRC_AMT, 'FM999,999,999,999,999') END AS MNRC_AMT
	, CASE WHEN TB2.GINFO = '000' THEN TO_CHAR(TB2.TX_CUR_BAL, 'FM999,999,999,999,999') ELSE '' END AS TX_CUR_BAL
	, CASE WHEN TB2.GINFO = '000' THEN TB2.REMARK ELSE '' END AS REMARK
	, CASE WHEN TB2.GINFO = '000' THEN TB2.BRANCH ELSE '' END AS BRANCH
			 , CASE WHEN TB2.GINFO = '000' THEN TB2.BR_NM ELSE ''  END AS BR_NM
	, CASE WHEN TB2.GINFO != '111' THEN TB2.ACCT_NICK_NM ELSE '' END AS ACCT_NICK_NM
	, TB2.GINFO
	, CASE WHEN TB2.GINFO = '001' THEN 'Y' ELSE '' END AS GRP_OPEN_YN
	, 'Y' AS GRP_VIEW_YN
	, TB2.ACCT_NO AS GKEY
	, TB2.TOT_COUNT
	, CASE WHEN TB2.GINFO = '000' THEN TB2.GINFO||'_'||TB2.ACCT_NO ELSE TB2.GINFO||'_'||TB2.ACCT_NO END AS ID
	, CASE WHEN TB2.GINFO = '000' THEN '001'||'_'||TB2.ACCT_NO ELSE '' END AS PID
FROM(
	SELECT
		   COUNT(1) TOT_COUNT
		 , TB.ACCT_NO AS ACCT_NO
		 , TB.BANK_NM AS BANK_NM
		 , TB.TX_DAY_TIME AS TX_DAY_TIME
		 , SUM(TB.MNRC_AMT) AS MNRC_AMT
		 , MAX(TB.TX_CUR_BAL) AS TX_CUR_BAL
		 , MAX(TB.REMARK) AS REMARK
		 , MAX(TB.BRANCH) AS BRANCH
				 , MAX(BR.BR_NM) AS BR_NM
		 , MAX(TB.ACCT_NICK_NM) AS ACCT_NICK_NM
		 , GROUPING(TB.BANK_NM)||GROUPING(TB.ACCT_NO)||GROUPING(TB.TX_DAY_TIME) AS GINFO
	FROM (
			SELECT
				   BANK.BANK_NM AS BANK_NM /* 은행명 */
				 , FN_ACCT_FORMAT(a.bank_cd, DWC_CRYPT.decrypt(a.acct_no)) as acct_no /* 계좌번호 */
				 , a.acct_nick_nm                        /* 계좌별칭 */
				 , b.acct_txday                          /* 거래일자 */
				 , DECODE(b.inout_gubun, '1', 0, '2', tx_amt) as  mnrc_amt  /* 입금액 */
				 , nvl(b.tx_cur_bal,0) tx_cur_bal                      /* 현재잔액 */
				 , b.jeokyo as remark                                /* 적요 */
				 , LPAD(CASE
					   WHEN b.dep_brn_cd7 IS NULL
					   THEN B.BRANCH
					   ELSE
						   CASE LENGTH(TRIM(B.DEP_BRN_CD7))
							   WHEN 4
							   THEN B.TR_ACT_BANK_CD3||B.DEP_BRN_CD7
							   WHEN 7
							   THEN B.DEP_BRN_CD7
						   END
				   END, 7, '0') AS BRANCH                           /* 취급점 */
				 , b.acct_txtime   as tx_time              /* 거래시간 */
				 , B.ACCT_TXDAY_SEQ
				 , A.BANK_CD   /* 은행코드 */
				 , A.BRN_CD    /* 지점코드 */
				 , (B.ACCT_TXDAY||B.ACCT_TXTIME) AS TX_DAY_TIME   /* 거래일시 */
				 , B.EXPENSE_YN
				 , B.VOTE_NO
				 , C.CMM_CD_NM AS EXPENSE_YN_TXT
			FROM FN_ACCT$ a
				 , FN_ACCT_HIS$ b
				 , DWC_CMM_CODE C
				 , BA_USER_GRP_ACCT_A001_V V
				 , BA_BANK BANK
			WHERE 1=1
			   AND b.acct_txday between '20230601' and '20230630'
			   AND a.acct_type       = '01'
			   AND a.bank_cd         = b.bank_cd
			   AND a.acct_no         = b.acct_no
			   AND A.BANK_CD         = BANK.BANK_CD(+)
			   AND B.EXPENSE_YN      = C.CMM_CD(+)
			   AND C.GRP_CD(+)       = 'S303'
			   AND A.use_yn          = 'Y'
			   AND A.del_yn          = 'N'
			   AND A.ACCT_USE_TYPE   = '00'
			   AND B.LEAS_EX_IPRT_YN = 'Y'
			   AND B.INOUT_GUBUN     = '2'
			   AND NVL(A.ACCT_SEQ, 'NOT') = V.ACCT_SEQ
			   AND V.USER_ID         = 'SYSTEMADMIN'
			ORDER BY A.BIZ_NO, BANK_NM, ACCT_NO, B.ACCT_TXDAY DESC, B.ACCT_TXDAY_SEQ DESC, TX_TIME DESC
		) TB
			, CMS_TC_BR BR
			WHERE TB.BRANCH = BR.BR_ID(+)
			GROUP BY ROLLUP(TB.BANK_NM, TB.ACCT_NO, TB.TX_DAY_TIME)
			ORDER BY TB.BANK_NM, TB.ACCT_NO, GINFO DESC, TB.TX_DAY_TIME DESC
	) TB2
	WHERE TB2.GINFO IN ('000', '111')
;



-- 출금내역조회 > 출금내역조회
SELECT
	TB2.PNO
	, CASE WHEN TB2.GINFO != '00' THEN '' ELSE TB2.SAN_WORK_GB    END AS SAN_WORK_GB
	, CASE WHEN TB2.GINFO != '11' THEN TB2.SAN_WORK_NM ELSE ''    END AS SAN_WORK_NM
	, CASE WHEN TB2.GINFO != '00' THEN '' ELSE TB2.TRAN_SET_DATE  END AS TRAN_SET_DATE
	, CASE WHEN TB2.GINFO != '00' THEN '' ELSE TB2.WORK_NM        END AS WORK_NM
	, CASE WHEN TB2.GINFO = '01' THEN '합계 : '||TO_CHAR(TB2.REGI_CNT, 'FM999,999,999,999,999') ELSE ''||TO_CHAR(TB2.REGI_CNT, 'FM999,999,999,999,999') END AS REGI_CNT
	, CASE WHEN TB2.GINFO = '01' THEN '합계 : '||TO_CHAR(TB2.REGI_CNT, 'FM999,999,999,999,999') ELSE ''||TO_CHAR(TB2.REGI_CNT, 'FM999,999,999,999,999') END AS REGI_CNT_TMP
	, CASE WHEN TB2.GINFO = '01' THEN '합계 : '||TO_CHAR(TB2.REGI_AMT, 'FM999,999,999,999,999') ELSE ''||TO_CHAR(TB2.REGI_AMT, 'FM999,999,999,999,999') END AS REGI_AMT
	, CASE WHEN TB2.GINFO != '00' THEN '' ELSE TB2.OUT_BANK_NM    END AS OUT_BANK_NM
	, CASE WHEN TB2.GINFO != '00' THEN '' ELSE TB2.OUT_ACCT_NO    END AS OUT_ACCT_NO
	, CASE WHEN TB2.GINFO != '00' THEN '' ELSE TB2.IN_BANK_NM     END AS IN_BANK_NM
	, CASE WHEN TB2.GINFO != '00' THEN '' ELSE TB2.IN_ACCT_NO     END AS IN_ACCT_NO
	, CASE WHEN TB2.GINFO != '00' THEN '' ELSE TB2.PROC_STS       END AS PROC_STS
	, CASE WHEN TB2.GINFO != '00' THEN '' ELSE TB2.LAST_STATUS    END AS LAST_STATUS
	, CASE WHEN TB2.GINFO != '00' THEN '' ELSE TB2.LAST_STATUS_NM END AS LAST_STATUS_NM
	, TB2.TOT_COUNT
	, TB2.PNO AS GKEY
	, CASE WHEN TB2.GINFO = '00' THEN '01'||'_'||TB2.SAN_WORK_GB ELSE '' END AS PID
	, CASE WHEN TB2.GINFO = '00' THEN '01'||'_'||TB2.SAN_WORK_GB||'_'||TB2.PNO ELSE TB2.GINFO||'_'||TB2.SAN_WORK_GB END AS ID
	, TB2.GINFO
FROM(
	SELECT
		COUNT(1) TOT_COUNT
		, PNO
		, MAX(SAN_WORK_GB   ) AS SAN_WORK_GB
		, MAX(SAN_WORK_NM   ) AS SAN_WORK_NM
		, MAX(TRAN_SET_DATE ) AS TRAN_SET_DATE
		, MAX(WORK_NM       ) AS WORK_NM
		, SUM(REGI_CNT      ) AS REGI_CNT
		, SUM(REGI_AMT      ) AS REGI_AMT
		, MAX(OUT_BANK_NM   ) AS OUT_BANK_NM
		, MAX(OUT_ACCT_NO   ) AS OUT_ACCT_NO
		, MAX(IN_BANK_NM    ) AS IN_BANK_NM
		, MAX(IN_ACCT_NO    ) AS IN_ACCT_NO
		, MAX(PROC_STS      ) AS PROC_STS
		, MAX(LAST_STATUS   ) AS LAST_STATUS
		, MAX(LAST_STATUS_NM) AS LAST_STATUS_NM
		, GROUPING(TB.SAN_WORK_NM)||GROUPING(TB.PNO) AS GINFO
	FROM (
		SELECT
			   ROWNUM PNO
			 , A.SAN_WORK_GB
			 , A.SAN_WORK_NM
			 , A.TRAN_SET_DATE
			 , A.WORK_NM
			 , A.REGI_CNT
			 , A.REGI_AMT
			 , A.OUT_BANK_NM
			 , A.OUT_ACCT_NO
			 , A.IN_BANK_NM
			 , A.IN_ACCT_NO
			 , A.PROC_STS
			 , A.LAST_STATUS
			 , DECODE(A.LAST_STATUS,'10','결재진행','11','결재진행','20','결재완료','21','결재완료','51','출금대기','52','출금완료', C.CMM_CD_NM) AS LAST_STATUS_NM
		FROM (
			SELECT
				   A.TRAD_GB AS SAN_WORK_GB
				 , CASE WHEN A.TRAD_GB = '200' THEN CD1.CMM_CD_NM ELSE '' END AS SAN_WORK_NM
				 , A.TRAN_SET_DATE
				 , CD2.CMM_CD_NM AS WORK_NM
				 , MAX(A.REGI_CNT) || '' AS REGI_CNT
				 , MAX(A.REGI_AMT) AS REGI_AMT
				 , BK1.BANK_NM AS OUT_BANK_NM
				 , FN_ACCT_FORMAT(A.OUT_BANK_CD, DWC_CRYPT.decrypt(A.OUT_ACCT_NO)) AS OUT_ACCT_NO
				 , '' AS IN_BANK_NM
				 , '' AS IN_ACCT_NO
				 , B.PROC_STS
				 , A.LAST_STATUS
			FROM AP_IF_MAST$ A
				 , AP_IF_DETAIL$ B
				 , BA_BANK BK1
				 , DWC_CMM_CODE CD1
				 , DWC_CMM_CODE CD2
			WHERE 1 = 1
			   AND A.REGI_DATE     = B.REGI_DATE
			   AND A.REGI_NUM      = B.REGI_NUM
			   AND A.SVC_DIST      = B.SVC_DIST
			   AND A.TRAD_GB       = B.TRAD_GB
			   AND A.OUT_BANK_CD   = BK1.BANK_CD(+)
			   AND A.TRAD_GB       = CD1.CMM_CD(+)
			   AND CD1.GRP_CD(+)   = 'S107'
			   AND A.SLR_KND_DSCD  = CD2.CMM_CD(+)
			   AND CD2.GRP_CD(+)   = 'KT001'
			   AND A.TRAN_SET_DATE = '20230613'
			   AND A.TRAD_GB       = '200'
			   AND A.LAST_STATUS NOT IN ('32','55','91') AND (B.PROC_STS = '0000' OR B.PROC_STS = '' OR B.PROC_STS IS NULL)
			GROUP BY A.TRAD_GB
				 , A.TRAN_SET_DATE
				 , A.OUT_BANK_CD
				 , A.OUT_ACCT_NO
				 , B.PROC_STS
				 , A.LAST_STATUS
				 , A.SLR_KND_DSCD
				 , CD1.CMM_CD_NM
				 , CD2.CMM_CD_NM
				 , BK1.BANK_NM
				 
			UNION
			 
			SELECT
				   A.TRAD_GB AS SAN_WORK_GB
				 , CASE WHEN A.TRAD_GB = '101' THEN '투자금 집행'
						WHEN A.TRAD_GB = '102' THEN '법인직불계좌입금'
						WHEN A.TRAD_GB = '103' THEN '환전 집행' END AS SAN_WORK_NM
				 , A.TRAN_SET_DATE
				 , '' AS WORK_NM
				 , COUNT(1)||'' AS REGI_CNT
				 , SUM(B.TRAN_AMT) AS REGI_AMT
				 , BK1.BANK_NM AS OUT_BANK_NM
				 , FN_ACCT_FORMAT(A.OUT_BANK_CD, DWC_CRYPT.decrypt(A.OUT_ACCT_NO)) AS OUT_ACCT_NO
				 , BK2.BANK_NM AS IN_BANK_NM
				 , FN_ACCT_FORMAT(B.IN_BANK_CD, DWC_CRYPT.decrypt(B.IN_ACCT_NO)) AS IN_ACCT_NO
				 , B.PROC_STS
				 , A.LAST_STATUS
			FROM AP_IF_MAST$ A
				 , AP_IF_DETAIL$ B
				 , BA_BANK BK1
				 , BA_BANK BK2
			WHERE 1 = 1
				AND A.REGI_DATE     = B.REGI_DATE
				AND A.REGI_NUM      = B.REGI_NUM
				AND A.SVC_DIST      = B.SVC_DIST
				AND A.TRAD_GB       = B.TRAD_GB
				AND A.OUT_BANK_CD   = BK1.BANK_CD(+)
				AND B.IN_BANK_CD    = BK2.BANK_CD(+)
				AND A.TRAN_SET_DATE = '20230613'
				AND A.TRAD_GB         IN ('101', '102', '103')
				AND A.LAST_STATUS NOT IN ('32','55','91') AND (B.PROC_STS = '0000' OR B.PROC_STS = '' OR B.PROC_STS IS NULL)
			GROUP BY A.TRAD_GB
				, A.TRAN_SET_DATE
				, A.OUT_BANK_CD
				, A.OUT_ACCT_NO
				, B.PROC_STS
				, B.IN_BANK_CD
				, B.IN_ACCT_NO
				, A.LAST_STATUS
				, A.SLR_KND_DSCD
				, BK1.BANK_NM
				, BK2.BANK_NM
				
			UNION
			
			SELECT
				   A.SAN_WORK_GB
				 , CASE WHEN INA.SVC_DIST = 'MMB' AND INA.ACCT_USE_TYPE = '01' THEN '회원직불계좌입금'
						WHEN INA.SVC_DIST = 'INS' AND INA.ACCT_USE_TYPE = '01' THEN '보험직불계좌입금' ELSE '' END AS SAN_WORK_NM
				 , A.REGI_DATE AS TRAN_SET_DATE
				 , '' AS WORK_NM
				 , COUNT(B.SEQ_NO) || '' AS REGI_CNT
				 , A.INOG_AMT AS REGI_AMT
				 , BK1.BANK_NM AS OUT_BANK_NM
				 , FN_ACCT_FORMAT(A.OUT_BANK_CD, DWC_CRYPT.decrypt(A.OUT_ACCT_NO)) AS OUT_ACCT_NO
				 , BK2.BANK_NM AS IN_BANK_NM
				 , FN_ACCT_FORMAT(A.IN_BANK_CD, DWC_CRYPT.decrypt(A.IN_ACCT_NO)) AS IN_ACCT_NO
				 , MAX(B.PROC_STS) AS PROC_STS
				 , A.LAST_STATUS
			FROM AP_INOG_FNDSNTCNMAST$ A
				 , AP_INOG_FNDSNTCNSHR B
				 , FN_ACCT$ INA
				 , FN_ACCT$ OUTA
				 , BA_BANK BK1
				 , BA_BANK BK2
			WHERE 1= 1
			   AND A.IN_ACCT_NO       = INA.ACCT_NO
			   AND A.OUT_ACCT_NO      = OUTA.ACCT_NO
			   AND A.OUT_BANK_CD      = BK1.BANK_CD(+)
			   AND A.IN_BANK_CD       = BK2.BANK_CD(+)
			   AND A.REGI_DATE        = '20230613'
			   AND A.REGI_DATE        = B.REGI_DATE
			   AND A.REGI_NUM         = B.REGI_NUM
			   AND A.SAN_WORK_GB      = B.SAN_WORK_GB
			   AND OUTA.ACCT_USE_TYPE = '00'
			   AND INA.ACCT_USE_TYPE  = '01'
			   AND INA.SVC_DIST      IN ('MMB', 'INS')
			   AND A.SAN_WORK_GB     IN ('J10', 'J11')
			   AND A.LAST_STATUS NOT IN ('32','55','91') AND (B.PROC_STS = '0000' OR B.PROC_STS = '' OR B.PROC_STS IS NULL)
			GROUP BY A.SAN_WORK_GB
				, INA.SVC_DIST
				, INA.ACCT_USE_TYPE
				, A.REGI_DATE
				, A.INOG_AMT
				, BK1.BANK_NM
				, BK2.BANK_NM
				, A.OUT_BANK_CD
				, A.OUT_ACCT_NO
				, A.IN_BANK_CD
				, A.IN_ACCT_NO
				, A.LAST_STATUS
				
			UNION
			
			SELECT
				'J00' AS SAN_WORK_GB
				, CASE WHEN A.APPR_CD IN ('20', '50') THEN '경비계좌입금'
					   WHEN INA.ACCT_USE_TYPE = '03'  THEN '직장어린이집계좌입금'
					   WHEN A.APPR_CD IN ('21','23')  THEN 'EDI부족액 입금' ELSE '' END AS SAN_WORK_NM
				, A.TRAN_SET_DATE
				, '' AS WORK_NM
				, TO_CHAR(A.REGI_CNT) AS REGI_CNT
				, A.REGI_AMT AS REGI_AMT
				, BK1.BANK_NM AS OUT_BANK_NM
				, FN_ACCT_FORMAT(OUTA.BANK_CD, DWC_CRYPT.decrypt(OUTA.ACCT_NO)) AS OUT_ACCT_NO
				, BK2.BANK_NM AS IN_BANK_NM
				, FN_ACCT_FORMAT(INA.BANK_CD, DWC_CRYPT.decrypt(INA.ACCT_NO)) AS IN_ACCT_NO
				, B.PROC_STS
				, A.LAST_STATUS
			FROM APP_APPR_COLL_TRAN_MAST A
				, APP_APPR_COLL_TRAN_DETAIL B
				, FN_ACCT$ INA
				, FN_ACCT$ OUTA
				, BA_BANK BK1
				, BA_BANK BK2
			WHERE 1 = 1
				AND A.PI_ID         = B.PI_ID
				AND A.ACCT_SEQ      = OUTA.ACCT_SEQ
				AND B.ACCT_SEQ      = INA.ACCT_SEQ
				AND OUTA.BANK_CD    = BK1.BANK_CD(+)
				AND INA.BANK_CD     = BK2.BANK_CD(+)
				AND A.TRAN_SET_DATE = '20230613'
				AND A.COLL_APPR_GB  = 'A' /* 배분 */
				AND OUTA.ACCT_USE_TYPE = '00'
				AND (A.APPR_CD IN ('20', '50', '21', '23') OR INA.ACCT_USE_TYPE IN ('02', '03') )/* 21: TOBE 23: ASIS EDI부족액입금 */
				AND A.LAST_STATUS NOT IN ('32','55','91') AND (B.PROC_STS = '0000' OR B.PROC_STS = '' OR B.PROC_STS IS NULL)
			) A
			, DWC_CMM_CODE C
				WHERE A.LAST_STATUS = C.CMM_CD(+)
				AND C.GRP_CD(+) = 'S043'
	   ) TB
	   GROUP BY ROLLUP(TB.SAN_WORK_NM, TB.PNO)
	   ORDER BY TB.SAN_WORK_NM, GINFO DESC, TB.PNO ASC
	) TB2
;



-- 은행별계좌 잔액조회 > 잔고통계 계좌관리
SELECT ROWNUM  AS PNO
	, BK.BANK_NM AS BANK_NM /* 은행명 */
	, FN_ACCT_FORMAT(A.BANK_CD, A.ACCT_NO) AS ACCT_NO_FORMAT /* 계좌번호 포맷 */
	, A.ACCT_NICK_NM                       /* 계좌별칭 */
	, A.BANK_CD                           /* 은행코드 */
	, A.ACCT_NO                           /* 계좌번호 */
	, A.ACCT_SEQ                          /* 계좌일련번호 */
	, DECODE(NVL(BALN_STTC_OTPT_YN, 'N'),'N','비적용','적용') AS BALN_STTC_OTPT
	, NVL(BALN_STTC_OTPT_YN, 'N')                           AS BALN_STTC_OTPT_YN
FROM FN_ACCT A
	, BA_USER_GRP_ACCT_A001_V V
	, BA_BANK BK
WHERE 1 = 1
	AND A.ACCT_TYPE = '01'
	AND A.USE_YN    = 'Y'
	AND A.DEL_YN    = 'N'
	AND A.TRD_STS   = '001'
	AND NVL(A.ACCT_SEQ, 'NOT') = V.ACCT_SEQ
	AND V.USER_ID   = 'SYSTEMADMIN'
	AND A.BANK_CD   = BK.BANK_CD(+)
ORDER BY A.BIZ_NO, BANK_NM, A.ACCT_NO, A.DISP_SEQ, A.CURR_CD
;



-- 은행별계좌 잔액조회 > 보통예금계정 차이금액 조회
--	차익금
SELECT
	A.ACCT_TXDAY AS TXDAY
	, A.AMT4_004 - B.AMT4_004 AS TX_CUR_BAL_004 /*국민*/
	, A.AMT4_011 - B.AMT4_011 AS TX_CUR_BAL_011 /*농협*/
	, A.AMT4_081 - B.AMT4_081 AS TX_CUR_BAL_081 /*하나*/
	, A.AMT4_032 - B.AMT4_032 AS TX_CUR_BAL_032 /*부산*/
	, A.AMT4_020 - B.AMT4_020 AS TX_CUR_BAL_020 /*우리*/
	, A.AMT4_088 - B.AMT4_088 AS TX_CUR_BAL_088 /*신한*/
	, A.AMT4_035 - B.AMT4_035 AS TX_CUR_BAL_035 /*제주*/
FROM (
	 SELECT
		   A.ACCT_TXDAY
		 , NVL(SUM(DECODE(B.BANK_CD, 10000004, TX_CUR_BAL)), 0) AS AMT4_004 /*국민*/
		 , NVL(SUM(DECODE(B.BANK_CD, 10000011, TX_CUR_BAL)), 0) AS AMT4_011 /*농협*/
		 , NVL(SUM(DECODE(B.BANK_CD, 10000005, TX_CUR_BAL)), 0) AS AMT4_081 /*하나*/
		 , NVL(SUM(DECODE(B.BANK_CD, 10000032, TX_CUR_BAL)), 0) AS AMT4_032 /*부산*/
		 , NVL(SUM(DECODE(B.BANK_CD, 10000020, TX_CUR_BAL)), 0) AS AMT4_020 /*우리*/
		 , NVL(SUM(DECODE(B.BANK_CD, 10000088, TX_CUR_BAL)), 0) AS AMT4_088 /*신한*/
		 , NVL(SUM(DECODE(B.BANK_CD, 10000035, TX_CUR_BAL)), 0) AS AMT4_035 /*제주*/
	FROM FN_ACCT_DAY_BLCE A
		 , FN_ACCT$ B
	WHERE A.ACCT_SEQ = B.ACCT_SEQ
	   AND NVL(B.BALN_STTC_OTPT_YN, 'N') = 'Y'
	   AND A.ACCT_TXDAY BETWEEN '20230701' and '20230730'
	GROUP BY A.ACCT_TXDAY
    ) A
    ,(
	SELECT
		   TXDAY
		 , NVL(SUM(DECODE(BANK_CD, '004', AMT4)), 0) AS AMT4_004 /*국민*/
		 , NVL(SUM(DECODE(BANK_CD, '011', AMT4)), 0) AS AMT4_011 /*농협*/
		 , NVL(SUM(DECODE(BANK_CD, '081', AMT4)), 0) AS AMT4_081 /*하나*/
		 , NVL(SUM(DECODE(BANK_CD, '032', AMT4)), 0) AS AMT4_032 /*부산*/
		 , NVL(SUM(DECODE(BANK_CD, '020', AMT4)), 0) AS AMT4_020 /*우리*/
		 , NVL(SUM(DECODE(BANK_CD, '088', AMT4)), 0) AS AMT4_088 /*신한*/
		 , NVL(SUM(DECODE(BANK_CD, '035', AMT4)), 0) AS AMT4_035 /*제주*/
	FROM AP_DAY_BANK_BLCE
	WHERE TXDAY BETWEEN '20230701' and '20230730'
	   AND BANK_CD IS NOT NULL
	GROUP BY TXDAY
   ) B
WHERE A.ACCT_TXDAY = B.TXDAY
ORDER BY TXDAY
;

-- 기간계 잔고통계
SELECT
	TXDAY
	, NVL(SUM(DECODE(BANK_CD, 004, AMT4)), 0) AS TX_CUR_BAL_004 /*국민*/
	, NVL(SUM(DECODE(BANK_CD, 011, AMT4)), 0) AS TX_CUR_BAL_011 /*농협*/
	, NVL(SUM(DECODE(BANK_CD, 081, AMT4)), 0) AS TX_CUR_BAL_081 /*하나*/
	, NVL(SUM(DECODE(BANK_CD, 032, AMT4)), 0) AS TX_CUR_BAL_032 /*부산*/
	, NVL(SUM(DECODE(BANK_CD, 020, AMT4)), 0) AS TX_CUR_BAL_020 /*우리*/
	, NVL(SUM(DECODE(BANK_CD, 088, AMT4)), 0) AS TX_CUR_BAL_088 /*신한*/
	, NVL(SUM(DECODE(BANK_CD, 035, AMT4)), 0) AS TX_CUR_BAL_035 /*제주*/
FROM AP_DAY_BANK_BLCE
WHERE TXDAY BETWEEN '20230701' and '20230730'
	AND BANK_CD IS NOT NULL
GROUP BY TXDAY ORDER BY TXDAY
;

-- 접속계정 정보
SELECT DECODE(COUNT(*), 0, 'N', 'Y') AS PROC_USE_YN
FROM AP_PROC_USE A
WHERE A.PROC_TYPE   = '01'
	AND A.PROC_USE_YN = 'Y'
	AND A.USER_ID     = 'iwham'
;


-- MMT결과조회 > MMT거래결과조회
SELECT ROWNUM PNO
	, TB2.ACCT_NO
	, TB2.BANK_NM
	, TO_CHAR(TO_DATE(TB2.TX_DAY_TIME, 'YYYYMMDDHH24MISS'), 'YYYY-MM-DD HH24:MI:SS') AS TX_DAY_TIME
	, CASE WHEN TB2.GINFO = '0011' THEN '합계 : '||TO_CHAR(TB2.MNRC_AMT, 'FM999,999,999,999,999') ELSE ''||TO_CHAR(TB2.MNRC_AMT, 'FM999,999,999,999,999') END AS MNRC_AMT
	, CASE WHEN TB2.GINFO = '0011' THEN '합계 : '||TO_CHAR(TB2.DROT_AMT, 'FM999,999,999,999,999') ELSE ''||TO_CHAR(TB2.DROT_AMT, 'FM999,999,999,999,999') END AS DROT_AMT
	, CASE WHEN TB2.GINFO = '0000' THEN TO_CHAR(TB2.TX_CUR_BAL, 'FM999,999,999,999,999') ELSE '' END AS TX_CUR_BAL
	, CASE WHEN TB2.GINFO = '0000' THEN TB2.REMARK ELSE '' END AS REMARK
	, CASE WHEN TB2.GINFO = '0000' THEN TB2.BRANCH ELSE '' END AS BRANCH
	, CASE WHEN TB2.GINFO = '0000' THEN TB2.BR_NM ELSE ''  END AS BR_NM
	, CASE WHEN TB2.GINFO != '1111' THEN TB2.ACCT_NICK_NM ELSE '' END AS ACCT_NICK_NM
	, TB2.GINFO
	, CASE WHEN TB2.GINFO = '0001' THEN 'Y' ELSE '' END AS GRP_OPEN_YN
	, 'Y' AS GRP_VIEW_YN
	, TB2.ACCT_NO AS GKEY
	, TB2.TOT_COUNT
	, CASE WHEN TB2.GINFO = '0000' THEN TB2.FN_ACCT_HIS_PNO ELSE 0 END AS FN_ACCT_HIS_PNO
	, CASE WHEN TB2.GINFO = '0000' THEN TB2.INOUT_GUBUN ELSE '' END AS INOUT_GUBUN
	, CASE WHEN TB2.GINFO = '0000' THEN TB2.GINFO||'_'||TB2.ACCT_NO ELSE TB2.GINFO||'_'||TB2.ACCT_NO END AS ID
	, CASE WHEN TB2.GINFO = '0000' THEN '0011'||'_'||TB2.ACCT_NO ELSE '' END AS PID
	, TR_INT
	, CORP_TAX_AMT  /*MMT해지 시 법인세*/
	, LOC_TAX_AMT   /*MMT해지 시 지방세*/
FROM(
	SELECT
		COUNT(1) TOT_COUNT
		, TB.ACCT_NO AS ACCT_NO
		, TB.BANK_NM AS BANK_NM
		, MAX(TB.TX_DAY_TIME) AS TX_DAY_TIME
		, MAX(TB.TX_DAY) AS TX_DAY
		, SUM(TB.MNRC_AMT) AS MNRC_AMT
		, SUM(TB.DROT_AMT) AS DROT_AMT
		, MAX(TB.TX_CUR_BAL) AS TX_CUR_BAL
		, MAX(TB.REMARK) AS REMARK
		, MAX(TB.BRANCH) AS BRANCH
		, MAX(BR.BR_NM) AS BR_NM
		, MAX(TB.ACCT_NICK_NM) AS ACCT_NICK_NM
		, MAX(TB.FN_ACCT_HIS_PNO) AS FN_ACCT_HIS_PNO
		, MAX(TB.INOUT_GUBUN) AS INOUT_GUBUN
		, NVL(SUM(TR_INT),0) AS TR_INT        /*MMT해지 시 발생이자*/
		, NVL(SUM(CORP_TAX_AMT),0) AS CORP_TAX_AMT  /*MMT해지 시 법인세*/
		, NVL(SUM(LOC_TAX_AMT),0) AS LOC_TAX_AMT   /*MMT해지 시 지방세*/
		, TB.NOTI_TR_NO
		, GROUPING(TB.BANK_NM)||GROUPING(TB.ACCT_NO)|| GROUPING(TB.NOTI_TR_NO) ||GROUPING(tb.TX_DAY_TIME) AS GINFO
	FROM (
		SELECT
			   BANK.BANK_NM AS BANK_NM /* 은행명 */
			 , FN_ACCT_FORMAT(a.bank_cd, DWC_CRYPT.decrypt(a.acct_no)) as acct_no /* 계좌번호 */
			 , a.acct_nick_nm                       /* 계좌별칭 */
			 , b.acct_txday                         /* 거래일자 */
			 , CASE WHEN b.trad_dist IN ('31', '51','53' ) THEN -b.tx_amt                 /* 입금취소건 */
					WHEN b.bank_cd = '10000004' AND b.trad_dist IN ('13') THEN -b.tx_amt  /*국민은행 입금취소일 경우*/
					WHEN b.inout_gubun = '2' AND b.trad_dist NOT IN ('23','32', '52','54' )  THEN b.tx_amt
					ELSE 0
			   END as mnrc_amt /* 입금액 */
			 , CASE WHEN b.trad_dist IN ('32', '52','54' ) THEN -b.tx_amt                 /* 출금취소건 */
					WHEN b.bank_cd = '10000004' AND b.trad_dist IN ('23') THEN -b.tx_amt  /*국민은행 출금취소일 경우*/
					WHEN b.inout_gubun IN ('1','N')  AND b.trad_dist NOT IN ('13','31', '51','53' ) THEN b.tx_amt
					ELSE 0
			   END as drot_amt /* 출금액 */
			 , nvl(b.tx_cur_bal,0) tx_cur_bal                     /* 현재잔액 */
			 , CASE WHEN B.JEOKYO IS NOT NULL THEN B.JEOKYO
					WHEN B.TRAD_DIST IN ('40', '41', '42') THEN '결산이자'
					ELSE b.jeokyo END as remark    /* 적요 */
			 , LPAD(CASE
				   WHEN b.dep_brn_cd7 IS NULL
				   THEN B.BRANCH
				   ELSE
					   CASE LENGTH(TRIM(B.DEP_BRN_CD7))
						   WHEN 4
						   THEN B.TR_ACT_BANK_CD3||B.DEP_BRN_CD7
						   WHEN 7
						   THEN B.DEP_BRN_CD7
					   END
			   END, 7, '0') AS BRANCH                            /* 취급점 */
			 , b.acct_txtime   as tx_time               /* 거래시간 */
			 , B.ACCT_TXDAY_SEQ
			 , A.BANK_CD    /* 은행코드 */
			 , A.BRN_CD     /* 지점코드 */
			 , B.ACCT_TXDAY AS TX_DAY   /* 거래일자 */
			 , (B.ACCT_TXDAY||B.ACCT_TXTIME) AS TX_DAY_TIME   /* 거래일시 */
			 , B.EXPENSE_YN
			 , B.VOTE_NO
			 , C.CMM_CD_NM AS EXPENSE_YN_TXT
			 , B.FN_ACCT_HIS_PNO
			 , B.INOUT_GUBUN
			 , B.TR_INT        /*MMT해지 시 발생이자*/
			 , B.CORP_TAX_AMT  /*MMT해지 시 법인세*/
			 , B.LOC_TAX_AMT   /*MMT해지 시 지방세*/
			 , TO_NUMBER(B.NOTI_TR_NO) AS NOTI_TR_NO
		FROM FN_ACCT$ a
			 , FN_ACCT_HIS$ b
			 , DWC_CMM_CODE C
			 , BA_USER_GRP_ACCT_A001_V V
			 , BA_BANK BANK
		WHERE 1=1
			AND b.acct_txday between '20230701' and '20230730'
			AND a.acct_type='01'
			AND a.bank_cd=b.bank_cd
			AND a.acct_no=b.acct_no
			AND A.BANK_CD = BANK.BANK_CD(+)
			AND B.EXPENSE_YN = C.CMM_CD(+)
			AND C.GRP_CD(+) = 'S303'
			AND a.del_yn='N'
			AND NVL(A.ACCT_SEQ, 'NOT') = V.ACCT_SEQ
			AND V.USER_ID = 'SYSTEMADMIN'
			AND DWC_CRYPT.decrypt(A.ACCT_NO) LIKE '%'||'06754974050105'||'%'
		) TB
		, CMS_TC_BR BR
		WHERE TB.BRANCH = BR.BR_ID(+)
		GROUP BY ROLLUP(TB.BANK_NM, TB.ACCT_NO, TB.NOTI_TR_NO, TB.TX_DAY_TIME)
		ORDER BY TB.BANK_NM, TB.ACCT_NO, GINFO DESC, TX_DAY_TIME DESC, TB.NOTI_TR_NO DESC
	) TB2
	WHERE TB2.GINFO IN ('0000', '0011', '1111')
;


























