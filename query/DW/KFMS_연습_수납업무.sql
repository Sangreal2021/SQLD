
-- 수납관리 > 수납계좌 잔액조회 > 목록조회
SELECT
       TB2.PNO
     , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.BANK_NM           END AS BANK_NM
     , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.ACCT_NO_FORMAT    END AS ACCT_NO_FORMAT
     , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.ACCT_NICK_NM      END AS ACCT_NICK_NM
     , TB2.CUR_AMT || '' AS CUR_AMT
     , TB2.REAL_AMT || '' AS REAL_AMT
     , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.ACCT_HIS_LST_DATE END AS ACCT_HIS_LST_DATE
     , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.ACCT_BAL_LST_DT   END AS ACCT_BAL_LST_DT
     , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.ACCT_BAL_LST_STS  END AS ACCT_BAL_LST_STS
     , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.BANK_CD           END AS BANK_CD
     , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.ACCT_NO           END AS ACCT_NO
     , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.ACCT_SEQ          END AS ACCT_SEQ
     , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.ERR_MSG           END AS ERR_MSG
     , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.FIRM_CD           END AS FIRM_CD
     , TB2.GINFO
  FROM(
     SELECT
            PNO
          , MAX(BANK_NM          ) AS BANK_NM
          , MAX(ACCT_NO_FORMAT   ) AS ACCT_NO_FORMAT
          , MAX(ACCT_NICK_NM     ) AS ACCT_NICK_NM
          , SUM(CUR_AMT          ) AS CUR_AMT
          , SUM(REAL_AMT         ) AS REAL_AMT
          , MAX(ACCT_HIS_LST_DATE) AS ACCT_HIS_LST_DATE
          , MAX(ACCT_BAL_LST_DT  ) AS ACCT_BAL_LST_DT
          , MAX(ACCT_BAL_LST_STS ) AS ACCT_BAL_LST_STS
          , MAX(BANK_CD          ) AS BANK_CD
          , MAX(ACCT_NO          ) AS ACCT_NO
          , MAX(ACCT_SEQ         ) AS ACCT_SEQ
          , MAX(ERR_MSG          ) AS ERR_MSG
          , MAX(FIRM_CD          ) AS FIRM_CD
          , GROUPING(TB.PNO) AS GINFO
       FROM (
            SELECT
                   ROWNUM PNO
                 , BK.BANK_NM AS BANK_NM                /* 은행명 */
                 , FN_ACCT_FORMAT(A.BANK_CD, DWC_CRYPT.DECRYPT(A.ACCT_NO)) AS ACCT_NO_FORMAT /* 계좌번호 포맷 */
                 , A.ACCT_NICK_NM                       /* 계좌별칭 */
                 , NVL(A.CUR_AMT,0) CUR_AMT             /* 현재잔액 */
                 , NVL(A.REAL_AMT,0) REAL_AMT           /* 인출가능액 */
                 , (SELECT /*+ INDEX_DESC (D UIDX_FN_ACCT_HIS_01) */  acct_txday||acct_txtime
                      FROM "FN_ACCT_HIS$" D
                     WHERE D.BANK_CD = A.BANK_CD
                       AND D.ACCT_NO = A.ACCT_NO
                       AND ROWNUM=1) AS ACCT_HIS_LST_DATE /* 최종거래내역일자 */
                 , A.ACCT_BAL_LST_DT                      /* 잔액최종조회일시 */
                 , A.ACCT_BAL_LST_STS                     /* 잔액최종조회상태 */
                 , A.BANK_CD                              /* 은행코드 */
                 , DWC_CRYPT.DECRYPT(A.ACCT_NO) AS ACCT_NO                           /* 계좌번호 */
                 , A.ACCT_SEQ                             /* 계좌일련번호 */
                 , A.ACCT_BAL_LST_MSG AS ERR_MSG /* 에러메세지 */
                 , A.FIRM_CD
               FROM FN_ACCT$ A
                  , BA_BANK BK
                  , BA_USER_GRP_ACCT_A001_V V
             WHERE A.ACCT_TYPE        = '01'
               AND A.USE_YN           = 'Y'
               AND A.DEL_YN           = 'N'
               AND A.TRD_STS          = '001'
               AND A.BANK_CD          = BK.BANK_CD(+)
               AND NVL(A.ACCT_SEQ, 'NOT') = V.ACCT_SEQ
               AND V.USER_ID          = 'SYSTEMADMIN'
               AND A.SVC_DIST IN ('INS', 'MMB', 'BIZ', 'MIS')
               AND A.SVC_DIST        IN ('MMB', 'BIZ', 'MIS')
--               AND A.SVC_DIST         = #{svcDist}
--               AND A.BANK_CD          = #{bankCd}
--               AND DWC_CRYPT.decrypt(A.ACCT_NO) LIKE '%'||#{acctNo}||'%'
--               AND UPPER(A.ACCT_NICK_NM) LIKE '%'||UPPER(#{acctNickNm})||'%'
               AND (A.RECP_YN = 'Y' OR (A.SVC_DIST = 'MIS' AND A.EDI_COLL_ACCT_YN = 'Y'))    /* 수납계좌여부 */
        ) TB
        GROUP BY ROLLUP(PNO)
) TB2
ORDER BY TB2.GINFO, TB2.BANK_NM, TB2.ACCT_NO
;



-- 수납관리 > 특정일 잔액조회 > 목록조회
SELECT ROWNUM PNO
	, CASE WHEN TB2.GINFO = '001' THEN '소계' ELSE TB2.ACCT_TXDAY END    AS ACCT_TXDAY
	, CASE WHEN TB2.GINFO != '111' THEN TB2.BANK_NM ELSE '' END         AS BANK_NM
	, CASE WHEN TB2.GINFO != '111' THEN TB2.ACCT_NO ELSE '' END         AS ACCT_NO
	, CASE WHEN TB2.GINFO = '000' THEN TB2.ACCT_CUST_NM ELSE '' END     AS ACCT_CUST_NM
	, TB2.MNRC_CNT                                                      AS MNRC_CNT
	, TB2.MNRC_AMT || ''                                                AS MNRC_AMT
	, (TB2.DROT_CNT + TB2.IN_CANCL_CNT)                                 AS DROT_CNT
	, (TB2.DROT_AMT - TB2.IN_CANCL_AMT) || ''                           AS DROT_AMT
	, CASE WHEN TB2.GINFO = '000' THEN TO_CHAR(TB2.TX_CUR_BAL, 'FM999,999,999,999,999') ELSE '' END AS TX_CUR_BAL
	, CASE WHEN TB2.GINFO = '000' THEN TB2.ACCT_NICK_NM ELSE '' END     AS ACCT_NICK_NM
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
		, SUM(TB.IN_CANCL_CNT) AS IN_CANCL_CNT
		, SUM(TB.IN_CANCL_AMT) AS IN_CANCL_AMT
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
			, B.IN_CANCL_CNT
			, B.IN_CANCL_AMT
			, B.TX_CUR_BAL
			, A.ACCT_NICK_NM
		FROM FN_ACCT$ A, FN_ACCT_DAY_BLCE B, BA_USER_GRP_ACCT_A001_V V, BA_BANK BANK
		WHERE 1 = 1
			AND B.ACCT_TXDAY between '20240226' and '20240226'
			AND A.ACCT_SEQ = B.ACCT_SEQ
			AND NVL(B.ACCT_SEQ, 'NOT') = V.ACCT_SEQ
			AND A.BANK_CD = BANK.BANK_CD(+)
			AND V.USER_ID = 'SYSTEMADMIN'
			AND A.SVC_DIST IN ('INS', 'MMB', 'BIZ', 'MIS')
			AND A.ACCT_NICK_NM != '공제-수납모계좌'
			AND A.ACCT_NICK_NM != '법인-수납모계좌'
			AND A.SVC_DIST        IN ('MMB', 'BIZ', 'MIS')
			AND A.USE_YN = 'Y'
			AND A.DEL_YN = 'N'
			AND (A.RECP_YN = 'Y')    /* 수납계좌여부 */
		   
		UNION ALL
						
		SELECT
			B.ACCT_TXDAY     AS ACCT_TXDAY
			, A.BANK_CD        AS BANK_CD
			, BANK.BANK_NM     AS BANK_NM  /* 은행명 */
			, FN_ACCT_FORMAT(a.bank_cd, DWC_CRYPT.decrypt(A.acct_no)) AS ACCT_NO
			, A.ACCT_CUST_NM   AS ACCT_CUST_NM
			, 0                AS MNRC_CNT   /* B.MNRC_CNT */
			, CASE WHEN b.trad_dist IN ('32', '52','54' ) THEN -b.tx_amt                 /* 출금취소건 */
				WHEN b.bank_cd = '10000004' AND b.trad_dist IN ('23') THEN -b.tx_amt  /*국민은행 출금취소일 경우*/
				WHEN b.inout_gubun IN ('1','N')  AND b.trad_dist NOT IN ('13','31', '51','53' ) THEN b.tx_amt
				ELSE 0
			END as MNRC_AMT /* 출금액 B.MNRC_AMT */
			, 1               as DROT_CNT   /* B.DROT_CNT */
			, CASE WHEN b.trad_dist IN ('31', '51','53' ) THEN -b.tx_amt                  /* 입금취소건 */
				 WHEN b.bank_cd = '10000004' AND b.trad_dist IN ('13') THEN -b.tx_amt  /*국민은행 입금취소일 경우*/
				 WHEN b.inout_gubun = '2' AND b.trad_dist NOT IN ('23','32', '52','54' )  THEN b.tx_amt
				 ELSE 0
			END as DROT_AMT /* 입금액 B.DROT_AMT */
			, 0               as IN_CANCL_CNT /* B.IN_CANCL_CNT */
			, 0               as IN_CANCL_AMT  /* B.IN_CANCL_AMT */
			, CASE WHEN b.trad_dist IN ('31', '51','53' ) THEN -b.tx_amt             /* 입금취소건 */
				WHEN b.bank_cd = '10000004' AND b.trad_dist IN ('13') THEN -b.tx_amt  /*국민은행 입금취소일 경우*/
				WHEN b.inout_gubun = '2' AND b.trad_dist NOT IN ('23','32', '52','54' )  THEN b.tx_amt
				ELSE 0
			END as TX_CUR_BAL
			, A.ACCT_NICK_NM   AS ACCT_NICK_NM
		FROM FN_ACCT$ a
			, FN_ACCT_HIS$ b
			, BA_USER_GRP_ACCT_A001_V V
			, BA_BANK BANK
		WHERE 1=1
			AND b.acct_txday between '20240226' and '20240226'
			AND a.acct_type    = '01'
			AND a.bank_cd      = b.bank_cd
			AND a.acct_no      = b.acct_no
			AND A.BANK_CD      = BANK.BANK_CD(+)
			AND a.use_yn       = 'Y'
			AND a.del_yn       = 'N'
			AND NVL(A.ACCT_SEQ, 'NOT') = V.ACCT_SEQ
			AND V.USER_ID      = 'SYSTEMADMIN'
			AND A.SVC_DIST     IN ('INS', 'MMB', 'BIZ', 'MIS')
			AND A.SVC_DIST     IN ('MMB', 'BIZ', 'MIS')
			AND A.BANK_CD      = '10000004'
			AND DWC_CRYPT.decrypt(A.ACCT_NO) LIKE '06750104118657' /* 국민은행 EDI수납/지급계좌 */
			AND (A.RECP_YN = 'N' AND B.JEOKYO LIKE '수수료%')  /* 수납계좌여부 */
		) TB
		 GROUP BY ROLLUP(TB.BANK_NM, TB.ACCT_NO, TB.ACCT_TXDAY)
		 ORDER BY BANK_NM, ACCT_NO, GINFO, ACCT_TXDAY DESC
	)TB2
	WHERE TB2.GINFO IN ('000', '001', '111')
;



-- 수납관리 > 수납계좌 거래내역조회 > 목록조회
SELECT ROWNUM PNO
	 , TB2.ACCT_NO
	 , TB2.BANK_NM
	 , TO_CHAR(TO_DATE(TB2.TX_DAY_TIME, 'YYYYMMDDHH24MISS'), 'YYYY-MM-DD HH24:MI:SS') AS TX_DAY_TIME
	 , CASE WHEN TB2.GINFO = '000' THEN TO_CHAR(TO_DATE(TB2.ACCT_TXDAY, 'YYYYMMDD'), 'YYYY-MM-DD') ELSE '' END AS ACCT_TXDAY
	 , CASE WHEN TB2.GINFO = '000' THEN TO_CHAR(TO_DATE(TB2.ACCT_TXTIME, 'HH24MISS'), 'HH24:MI:SS') ELSE '' END AS ACCT_TXTIME
	 , CASE WHEN TB2.GINFO = '001' THEN '합계 : '||TO_CHAR(TB2.MNRC_AMT, 'FM999,999,999,999,999') ELSE ''||TO_CHAR(TB2.MNRC_AMT, 'FM999,999,999,999,999') END AS MNRC_AMT
	 , CASE WHEN TB2.GINFO = '001' THEN '합계 : '||TO_CHAR(TB2.DROT_AMT, 'FM999,999,999,999,999') ELSE ''||TO_CHAR(TB2.DROT_AMT, 'FM999,999,999,999,999') END AS DROT_AMT
	 , CASE WHEN TB2.GINFO = '000' THEN TO_CHAR(TB2.TX_CUR_BAL, 'FM999,999,999,999,999') ELSE '' END AS TX_CUR_BAL
	 , CASE WHEN TB2.GINFO = '000' THEN TB2.REMARK ELSE '' END AS REMARK
	 , CASE WHEN TB2.GINFO = '000' THEN TB2.BRANCH ELSE '' END AS BRANCH
	 , CASE WHEN TB2.GINFO = '000' THEN TB2.BR_NM ELSE ''  END AS BR_NM
	 , CASE WHEN TB2.GINFO != '001' THEN TB2.ACCT_NICK_NM ELSE '' END AS ACCT_NICK_NM
	 , CASE WHEN TB2.GINFO != '001' THEN TB2.DEP_NM ELSE '' END AS DEP_NM
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
		 , MAX(TB.ACCT_TXDAY) AS ACCT_TXDAY
		 , MAX(TB.ACCT_TXTIME) AS ACCT_TXTIME
		 , SUM(TB.MNRC_AMT) AS MNRC_AMT
		 , SUM(TB.DROT_AMT) AS DROT_AMT
		 , MAX(TB.TX_CUR_BAL) AS TX_CUR_BAL
		 , MAX(TB.REMARK) AS REMARK
		 , MAX(TB.BRANCH) AS BRANCH
		 , MAX(BR.BR_NM) AS BR_NM
		 , MAX(TB.ACCT_NICK_NM) AS ACCT_NICK_NM
		 , MAX(TB.DEP_NM) AS DEP_NM
		 , GROUPING(TB.BANK_NM)||GROUPING(TB.ACCT_NO)||GROUPING(TB.TX_DAY_TIME) AS GINFO
	  FROM (
			SELECT
				   BANK.BANK_NM AS BANK_NM /* 은행명 */
				 , FN_ACCT_FORMAT(a.bank_cd, DWC_CRYPT.decrypt(a.acct_no)) as acct_no /* 계좌번호 */
				 , a.acct_nick_nm                       /* 계좌별칭 */
				 , CASE WHEN b.trad_dist IN ('31', '51','53' ) THEN -b.tx_amt             /* 입금취소건 */
							WHEN b.bank_cd = '10000004' AND b.trad_dist IN ('13') THEN -b.tx_amt  /*국민은행 입금취소일 경우*/
							WHEN b.inout_gubun = '2' AND b.trad_dist NOT IN ('23','32', '52','54' )  THEN b.tx_amt
							ELSE 0
				   END as mnrc_amt /* 입금액 */
				 , CASE WHEN b.trad_dist IN ('32', '52','54' ) THEN -b.tx_amt              /* 출금취소건 */
							WHEN b.bank_cd = '10000004' AND b.trad_dist IN ('23') THEN -b.tx_amt  /*국민은행 출금취소일 경우*/
							WHEN b.inout_gubun IN ('1','N')  AND b.trad_dist NOT IN ('13','31', '51','53' ) THEN b.tx_amt
							ELSE 0
				   END as drot_amt /* 출금액 */
				 , nvl(b.tx_cur_bal,0) tx_cur_bal                     /* 현재잔액 */
				 , CASE WHEN B.JEOKYO IS NOT NULL THEN B.JEOKYO
						WHEN B.TRAD_DIST IN ('40', '41', '42') THEN '결산이자'
						ELSE b.jeokyo END as remark                  /* 적요 */
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
				 , b.acct_txtime   as tx_time             /* 거래시간 */
				 , B.ACCT_TXDAY_SEQ
				 , A.BANK_CD      /* 은행코드 */
				 , A.BRN_CD       /* 지점코드 */
				 , B.ACCT_TXDAY   /* 거래일자 */
				 , B.ACCT_TXTIME  /* 거래시간 */
				 , (B.ACCT_TXDAY||B.ACCT_TXTIME) AS TX_DAY_TIME  /* 거래일시 */
				 , CASE WHEN TRIM(TO_SINGLE_BYTE(B.DEP_NM)) IS NOT NULL THEN TRIM(TO_SINGLE_BYTE(B.DEP_NM))
						WHEN B.TRAD_DIST IN ('40', '41', '42') THEN '결산이자'
						ELSE TRIM(TO_SINGLE_BYTE(B.DEP_NM)) END AS DEP_NM /* 입금인 성명 */
			  FROM FN_ACCT$ a
				 , FN_ACCT_HIS$ b
				 , BA_USER_GRP_ACCT_A001_V V
				 , BA_BANK BANK
			 WHERE 1=1
			   AND b.acct_txday between '20230801' and '20230901'
			   AND a.acct_type    = '01'
			   AND a.bank_cd      = b.bank_cd
			   AND a.acct_no      = b.acct_no
			   AND A.BANK_CD      = BANK.BANK_CD(+)
			   AND a.use_yn       = 'Y'
			   AND a.del_yn       = 'N'
			   AND NVL(A.ACCT_SEQ, 'NOT') = V.ACCT_SEQ
			   AND V.USER_ID      = 'SYSTEMADMIN'
			   AND A.SVC_DIST     IN ('INS', 'MMB', 'BIZ', 'MIS')
			   AND A.SVC_DIST     IN ('MMB', 'BIZ', 'MIS')
			   AND A.RECP_YN = 'Y'  /*  수납계좌여부  */
			 ORDER BY A.BIZ_NO, BANK_NM, ACCT_NO, B.ACCT_TXDAY DESC, B.ACCT_TXDAY_SEQ DESC, TX_TIME DESC
	) TB
	, CMS_TC_BR BR
			WHERE TB.BRANCH = BR.BR_ID(+)
	GROUP BY ROLLUP(TB.BANK_NM, TB.ACCT_NO, TB.TX_DAY_TIME)
	ORDER BY TB.BANK_NM, TB.ACCT_NO, GINFO DESC, TB.TX_DAY_TIME DESC
)TB2
WHERE TB2.GINFO IN ('000', '001', '111')
;



-- 수납관리 > 수납모계좌 거래내역조회
SELECT ROWNUM PNO
	, TB2.ACCT_NO
	, TB2.BANK_NM
	, TO_CHAR(TO_DATE(TB2.TX_DAY_TIME, 'YYYYMMDDHH24MISS'), 'YYYY-MM-DD HH24:MI:SS') AS TX_DAY_TIME
	, CASE WHEN TB2.GINFO = '000' THEN TO_CHAR(TO_DATE(TB2.ACCT_TXDAY, 'YYYYMMDD'), 'YYYY-MM-DD') ELSE '' END AS ACCT_TXDAY
	, CASE WHEN TB2.GINFO = '000' THEN TO_CHAR(TO_DATE(TB2.ACCT_TXTIME, 'HH24MISS'), 'HH24:MI:SS') ELSE '' END AS ACCT_TXTIME
	, CASE WHEN TB2.GINFO = '001' THEN '합계 : '||TO_CHAR(TB2.MNRC_AMT, 'FM999,999,999,999,999') ELSE ''||TO_CHAR(TB2.MNRC_AMT, 'FM999,999,999,999,999') END AS MNRC_AMT
	, CASE WHEN TB2.GINFO = '001' THEN '합계 : '||TO_CHAR(TB2.DROT_AMT, 'FM999,999,999,999,999') ELSE ''||TO_CHAR(TB2.DROT_AMT, 'FM999,999,999,999,999') END AS DROT_AMT
	, CASE WHEN TB2.GINFO = '000' THEN TO_CHAR(TB2.TX_CUR_BAL, 'FM999,999,999,999,999') ELSE '' END AS TX_CUR_BAL
	, CASE WHEN TB2.GINFO = '000' THEN TB2.REMARK ELSE '' END AS REMARK
	, CASE WHEN TB2.GINFO = '000' THEN TB2.BRANCH ELSE '' END AS BRANCH
	, CASE WHEN TB2.GINFO = '000' THEN TB2.BR_NM ELSE ''  END AS BR_NM
	, CASE WHEN TB2.GINFO != '001' THEN TB2.ACCT_NICK_NM ELSE '' END AS ACCT_NICK_NM
	, CASE WHEN TB2.GINFO != '001' THEN TB2.DEP_NM ELSE '' END AS DEP_NM
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
		 , MAX(TB.ACCT_TXDAY) AS ACCT_TXDAY
		 , MAX(TB.ACCT_TXTIME) AS ACCT_TXTIME
		 , SUM(TB.MNRC_AMT) AS MNRC_AMT
		 , SUM(TB.DROT_AMT) AS DROT_AMT
		 , MAX(TB.TX_CUR_BAL) AS TX_CUR_BAL
		 , MAX(TB.REMARK) AS REMARK
		 , MAX(TB.BRANCH) AS BRANCH
		 , MAX(BR.BR_NM) AS BR_NM
		 , MAX(TB.ACCT_NICK_NM) AS ACCT_NICK_NM
		 , MAX(TB.DEP_NM) AS DEP_NM
		 , GROUPING(TB.BANK_NM)||GROUPING(TB.ACCT_NO)||GROUPING(TB.TX_DAY_TIME) AS GINFO
	FROM (
		SELECT
			   BANK.BANK_NM AS BANK_NM /* 은행명 */
			 , FN_ACCT_FORMAT(a.bank_cd, DWC_CRYPT.decrypt(a.acct_no)) as acct_no /* 계좌번호 */
			 , a.acct_nick_nm                       /* 계좌별칭 */
			 , CASE WHEN b.trad_dist IN ('31', '51','53' ) THEN -b.tx_amt             /* 입금취소건 */
						WHEN b.bank_cd = '10000004' AND b.trad_dist IN ('13') THEN -b.tx_amt  /*국민은행 입금취소일 경우*/
						WHEN b.inout_gubun = '2' AND b.trad_dist NOT IN ('23','32', '52','54' )  THEN b.tx_amt
						ELSE 0
			   END as mnrc_amt /* 입금액 */
			 , CASE WHEN b.trad_dist IN ('32', '52','54' ) THEN -b.tx_amt              /* 출금취소건 */
						WHEN b.bank_cd = '10000004' AND b.trad_dist IN ('23') THEN -b.tx_amt  /*국민은행 출금취소일 경우*/
						WHEN b.inout_gubun IN ('1','N')  AND b.trad_dist NOT IN ('13','31', '51','53' ) THEN b.tx_amt
						ELSE 0
			   END as drot_amt /* 출금액 */
			 , nvl(b.tx_cur_bal,0) tx_cur_bal                     /* 현재잔액 */
			 , CASE WHEN B.JEOKYO IS NOT NULL THEN B.JEOKYO
					WHEN B.TRAD_DIST IN ('40', '41', '42') THEN '결산이자'
					ELSE b.jeokyo END as remark                  /* 적요 */
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
			 , b.acct_txtime   as tx_time             /* 거래시간 */
			 , B.ACCT_TXDAY_SEQ
			 , A.BANK_CD      /* 은행코드 */
			 , A.BRN_CD       /* 지점코드 */
			 , B.ACCT_TXDAY   /* 거래일자 */
			 , B.ACCT_TXTIME  /* 거래시간 */
			 , (B.ACCT_TXDAY||B.ACCT_TXTIME) AS TX_DAY_TIME  /* 거래일시 */
			 , CASE WHEN TRIM(TO_SINGLE_BYTE(B.DEP_NM)) IS NOT NULL THEN TRIM(TO_SINGLE_BYTE(B.DEP_NM))
					WHEN B.TRAD_DIST IN ('40', '41', '42') THEN '결산이자'
					ELSE TRIM(TO_SINGLE_BYTE(B.DEP_NM)) END AS DEP_NM /* 입금인 성명 */
		FROM FN_ACCT$ a
			 , FN_ACCT_HIS$ b
			 , BA_USER_GRP_ACCT_A001_V V
			 , BA_BANK BANK
			 , DWC_CMM_CODE c
		WHERE 1=1
		   AND b.acct_txday between '20231101' and '20231201'
		   AND a.acct_type    = '01'
		   AND a.bank_cd      = b.bank_cd
		   AND a.acct_no      = b.acct_no
		   AND A.BANK_CD      = BANK.BANK_CD(+)
		   AND a.use_yn       = 'Y'
		   AND a.del_yn       = 'N'
		   AND c.grp_cd       = 'KFMS001'                       /*수납모계좌 그룹코드*/
		   AND (c.eng_nm = a.acct_seq OR a.acct_seq='103')      /*DWC_CMM_CODE 에서의 eng_nm은 계좌seq*/
		   AND c.bigo          = a.bank_cd                      /*DWC_CMM_CODE 에서의 bigo는 은행코드*/
		   AND NVL(A.ACCT_SEQ, 'NOT') = V.ACCT_SEQ
		   AND V.USER_ID      = 'SYSTEMADMIN'
		   AND A.SVC_DIST     IN ('INS', 'MMB', 'BIZ', 'MIS')
		   AND (A.SVC_DIST     IN ('MMB', 'BIZ', 'MIS') OR DWC_CRYPT.decrypt(A.ACCT_NO) ='06750104118657')
		ORDER BY A.BIZ_NO, BANK_NM, ACCT_NO, B.ACCT_TXDAY DESC, B.ACCT_TXDAY_SEQ DESC, TX_TIME DESC
		) TB
		, CMS_TC_BR BR WHERE TB.BRANCH = BR.BR_ID(+)
		GROUP BY ROLLUP(TB.BANK_NM, TB.ACCT_NO, TB.TX_DAY_TIME)
		ORDER BY TB.BANK_NM, TB.ACCT_NO, GINFO DESC, TB.TX_DAY_TIME DESC
	)TB2
	WHERE TB2.GINFO IN ('000', '001', '111')
;



-- CMS 수납 > CMS 수납내역 조회
SELECT
	TB2.PNO
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.BANK_NM        END AS BANK_NM
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.ACCT_NO_FORMAT END AS ACCT_NO_FORMAT
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.ACCT_NO        END AS ACCT_NO
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.ACCT_NICK_NM   END AS ACCT_NICK_NM
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.ACCT_TXDAY     END AS ACCT_TXDAY
	, TB2.MNRC_AMT || '' AS MNRC_AMT
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE ''||TB2.DROT_AMT   END AS DROT_AMT
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE ''||TB2.TX_CUR_BAL END AS TX_CUR_BAL
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.REMARK         END AS REMARK
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.BRANCH         END AS BRANCH
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.BR_NM          END AS BR_NM
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.TX_TIME        END AS TX_TIME
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.BANK_CD        END AS BANK_CD
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.BRN_CD         END AS BRN_CD
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.TX_DAY_TIME    END AS TX_DAY_TIME
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.CMS_CODE       END AS CMS_CODE
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.DEP_NM         END AS DEP_NM
	, TB2.GINFO
FROM(
	SELECT
		TB.PNO
		, MAX(TB.BANK_NM       ) AS BANK_NM                           /* 은행명 */
		, MAX(TB.ACCT_NO_FORMAT) AS ACCT_NO_FORMAT                    /* formated 계좌번호 */
		, MAX(TB.ACCT_NO       ) AS ACCT_NO                           /*계좌번호*/
		, MAX(TB.ACCT_NICK_NM  ) AS ACCT_NICK_NM                      /* 계좌별칭 */
		, MAX(TB.ACCT_TXDAY    ) AS ACCT_TXDAY                        /* 거래일자 */
		, SUM(TB.MNRC_AMT      ) AS MNRC_AMT                          /* 입금액(수납금액) */
		, MAX(TB.DROT_AMT      ) AS DROT_AMT                          /* 출금액 */
		, MAX(TB.TX_CUR_BAL    ) AS TX_CUR_BAL                        /* 현재잔액 */
		, MAX(TB.REMARK        ) AS REMARK                            /* 적요(입금인성명) */
		, MAX(TB.BRANCH        ) AS BRANCH                            /* 취급점 */
		, MAX(BR.BR_NM         ) AS BR_NM                             /* 취급점명*/
		, MAX(TB.TX_TIME       ) AS TX_TIME                           /* 거래시간 */
		, MAX(TB.BANK_CD       ) AS BANK_CD                           /* 은행코드 */
		, MAX(TB.BRN_CD        ) AS BRN_CD                            /* 지점코드 */
		, MAX(TB.TX_DAY_TIME   ) AS TX_DAY_TIME                       /* 거래일시 */
		, MAX(TB.CMS_CODE      ) AS CMS_CODE                          /*CMS코드*/
		, MAX(TB.DEP_NM        ) AS DEP_NM                            /*입금인 성명*/
		, GROUPING(TB.PNO) AS GINFO
	FROM (
		SELECT
			ROWNUM AS PNO
			, BK.BANK_NM                                       /* 은행명 */
			, FN_ACCT_FORMAT(A.BANK_CD, DWC_CRYPT.DECRYPT(A.ACCT_NO)) ACCT_NO_FORMAT
			, DWC_CRYPT.DECRYPT(A.ACCT_NO) AS ACCT_NO          /* 계좌번호 */
			, A.ACCT_NICK_NM                                   /* 계좌별칭 */
			, B.ACCT_TXDAY                                     /* 거래일자 */
			, CASE WHEN B.TRAD_DIST IN ('31', '51','53' ) THEN -B.TX_AMT                 /* 입금취소건 */
			WHEN B.BANK_CD = '10000004' AND B.TRAD_DIST IN ('13') THEN -B.TX_AMT  /*국민은행 입금취소일 경우*/
			WHEN B.INOUT_GUBUN = '2' AND B.TRAD_DIST NOT IN ('23','32', '52','54' )  THEN b.tx_amt
			ELSE 0
			END AS MNRC_AMT /* 입금액(수납금액) */
			, CASE WHEN B.TRAD_DIST IN ('32', '52','54' ) THEN -B.TX_AMT                 /* 출금취소건 */
			WHEN B.BANK_CD = '10000004' AND B.TRAD_DIST IN ('23') THEN -B.TX_AMT  /*국민은행 출금취소일 경우*/
			WHEN B.INOUT_GUBUN IN ('1','N')  AND B.TRAD_DIST NOT IN ('13','31', '51','53' ) THEN b.tx_amt
			ELSE 0
			END as DROT_AMT  /* 출금액 */
			, NVL(B.TX_CUR_BAL,0) TX_CUR_BAL                      /* 현재잔액 */
			, CASE WHEN B.JEOKYO IS NOT NULL THEN B.JEOKYO
				   WHEN B.TRAD_DIST IN ('40', '41', '42') THEN '결산이자'
				   ELSE b.jeokyo END as remark                  /* 적요 */
			, LPAD(CASE
			WHEN B.dep_brn_cd7 IS NULL
			THEN B.BRANCH
			ELSE
			CASE LENGTH(TRIM(B.DEP_BRN_CD7))
			WHEN 4
			THEN B.TR_ACT_BANK_CD3||B.DEP_BRN_CD7
			WHEN 7
			THEN B.DEP_BRN_CD7
			END
			END, 7, '0') AS BRANCH     /* 취급점코드 */
			, B.ACCT_TXTIME   AS TX_TIME               /* 거래시간 */
			, A.BANK_CD    /* 은행코드 */
			, A.BRN_CD     /* 지점코드 */
			, (B.ACCT_TXDAY||B.ACCT_TXTIME) AS TX_DAY_TIME    /* 거래일시 */
			, B.KTCU_CODE1||B.KTCU_CODE2 AS CMS_CODE   /*CMS코드*/
			, CASE WHEN TRIM(TO_SINGLE_BYTE(B.DEP_NM)) IS NOT NULL THEN TRIM(TO_SINGLE_BYTE(B.DEP_NM))
				   WHEN B.TRAD_DIST IN ('40', '41', '42') THEN '결산이자'
				   ELSE TRIM(TO_SINGLE_BYTE(B.DEP_NM)) END AS DEP_NM /* 입금인 성명 */
		FROM FN_ACCT$ a
		   , FN_ACCT_HIS$ b
		   , BA_BANK BK
		   , BA_USER_GRP_ACCT_A001_V V
		WHERE 1=1
			AND B.ACCT_TXDAY BETWEEN '20230901' and '20231001'
			AND A.ACCT_TYPE='01'
			AND A.BANK_CD=B.BANK_CD
			AND A.ACCT_NO=B.ACCT_NO
			AND A.BANK_CD = BK.BANK_CD(+)
			AND A.USE_YN='Y'
			AND A.DEL_YN='N'
			AND NVL(A.ACCT_SEQ, 'NOT') = V.ACCT_SEQ
			AND V.USER_ID = 'SYSTEMADMIN'
			AND A.SVC_DIST IN ('INS', 'MMB', 'BIZ')
			AND A.SVC_DIST        IN ('MMB', 'BIZ')
			AND A.RECP_ACCT_GB = '01'
			AND A.RECP_YN = 'Y'
	) TB, CMS_TC_BR BR
WHERE TB.BRANCH    = BR.BR_ID(+) AND TB.MNRC_AMT != 0
GROUP BY ROLLUP(PNO)
) TB2
ORDER BY TB2.GINFO, TB2.TX_DAY_TIME DESC
;



-- CMS수납 > CMS수납내역 조회
SELECT
	TB2.PNO
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.BANK_NM        END AS BANK_NM
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.ACCT_NO_FORMAT END AS ACCT_NO_FORMAT
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.ACCT_NO        END AS ACCT_NO
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.ACCT_NICK_NM   END AS ACCT_NICK_NM
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.ACCT_TXDAY     END AS ACCT_TXDAY
	, TB2.MNRC_AMT || '' AS MNRC_AMT
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE ''||TB2.DROT_AMT   END AS DROT_AMT
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE ''||TB2.TX_CUR_BAL END AS TX_CUR_BAL
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.REMARK         END AS REMARK
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.BRANCH         END AS BRANCH
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.BR_NM          END AS BR_NM
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.TX_TIME        END AS TX_TIME
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.BANK_CD        END AS BANK_CD
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.BRN_CD         END AS BRN_CD
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.TX_DAY_TIME    END AS TX_DAY_TIME
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.CMS_CODE       END AS CMS_CODE
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.DEP_NM         END AS DEP_NM
	, TB2.GINFO
FROM(
	SELECT
		TB.PNO
		, MAX(TB.BANK_NM       ) AS BANK_NM                           /* 은행명 */
		, MAX(TB.ACCT_NO_FORMAT) AS ACCT_NO_FORMAT                    /* formated 계좌번호 */
		, MAX(TB.ACCT_NO       ) AS ACCT_NO                           /*계좌번호*/
		, MAX(TB.ACCT_NICK_NM  ) AS ACCT_NICK_NM                      /* 계좌별칭 */
		, MAX(TB.ACCT_TXDAY    ) AS ACCT_TXDAY                        /* 거래일자 */
		, SUM(TB.MNRC_AMT      ) AS MNRC_AMT                          /* 입금액(수납금액) */
		, MAX(TB.DROT_AMT      ) AS DROT_AMT                          /* 출금액 */
		, MAX(TB.TX_CUR_BAL    ) AS TX_CUR_BAL                        /* 현재잔액 */
		, MAX(TB.REMARK        ) AS REMARK                            /* 적요(입금인성명) */
		, MAX(TB.BRANCH        ) AS BRANCH                            /* 취급점 */
		, MAX(BR.BR_NM         ) AS BR_NM                             /* 취급점명*/
		, MAX(TB.TX_TIME       ) AS TX_TIME                           /* 거래시간 */
		, MAX(TB.BANK_CD       ) AS BANK_CD                           /* 은행코드 */
		, MAX(TB.BRN_CD        ) AS BRN_CD                            /* 지점코드 */
		, MAX(TB.TX_DAY_TIME   ) AS TX_DAY_TIME                       /* 거래일시 */
		, MAX(TB.CMS_CODE      ) AS CMS_CODE                          /*CMS코드*/
		, MAX(TB.DEP_NM        ) AS DEP_NM                            /*입금인 성명*/
		, GROUPING(TB.PNO) AS GINFO
	FROM (
		SELECT
			ROWNUM AS PNO
			, BK.BANK_NM                                       /* 은행명 */
			, FN_ACCT_FORMAT(A.BANK_CD, DWC_CRYPT.DECRYPT(A.ACCT_NO)) ACCT_NO_FORMAT
			, DWC_CRYPT.DECRYPT(A.ACCT_NO) AS ACCT_NO          /* 계좌번호 */
			, A.ACCT_NICK_NM                                   /* 계좌별칭 */
			, B.ACCT_TXDAY                                     /* 거래일자 */
			, CASE WHEN B.TRAD_DIST IN ('31', '51','53' ) THEN -B.TX_AMT                 /* 입금취소건 */
				WHEN B.BANK_CD = '10000004' AND B.TRAD_DIST IN ('13') THEN -B.TX_AMT  /*국민은행 입금취소일 경우*/
				WHEN B.INOUT_GUBUN = '2' AND B.TRAD_DIST NOT IN ('23','32', '52','54' )  THEN b.tx_amt
				ELSE 0
				END AS MNRC_AMT /* 입금액(수납금액) */
			, CASE WHEN B.TRAD_DIST IN ('32', '52','54' ) THEN -B.TX_AMT                 /* 출금취소건 */
				WHEN B.BANK_CD = '10000004' AND B.TRAD_DIST IN ('23') THEN -B.TX_AMT  /*국민은행 출금취소일 경우*/
				WHEN B.INOUT_GUBUN IN ('1','N')  AND B.TRAD_DIST NOT IN ('13','31', '51','53' ) THEN b.tx_amt
				ELSE 0
				END as DROT_AMT  /* 출금액 */
			, NVL(B.TX_CUR_BAL,0) TX_CUR_BAL                      /* 현재잔액 */
			, CASE WHEN B.JEOKYO IS NOT NULL THEN B.JEOKYO
				   WHEN B.TRAD_DIST IN ('40', '41', '42') THEN '결산이자'
				   ELSE b.jeokyo END as remark                  /* 적요 */
			, LPAD(CASE
					WHEN B.dep_brn_cd7 IS NULL THEN B.BRANCH
					ELSE
						CASE LENGTH(TRIM(B.DEP_BRN_CD7))
							WHEN 4 THEN B.TR_ACT_BANK_CD3||B.DEP_BRN_CD7
							WHEN 7 THEN B.DEP_BRN_CD7
						END
					END, 7, '0') AS BRANCH     /* 취급점코드 */
			, B.ACCT_TXTIME   AS TX_TIME               /* 거래시간 */
			, A.BANK_CD    /* 은행코드 */
			, A.BRN_CD     /* 지점코드 */
			, (B.ACCT_TXDAY||B.ACCT_TXTIME) AS TX_DAY_TIME    /* 거래일시 */
			, B.KTCU_CODE1||B.KTCU_CODE2 AS CMS_CODE   /*CMS코드*/
			, CASE WHEN TRIM(TO_SINGLE_BYTE(B.DEP_NM)) IS NOT NULL THEN TRIM(TO_SINGLE_BYTE(B.DEP_NM))
				   WHEN B.TRAD_DIST IN ('40', '41', '42') THEN '결산이자'
				   ELSE TRIM(TO_SINGLE_BYTE(B.DEP_NM)) END AS DEP_NM /* 입금인 성명 */
		FROM FN_ACCT$ a
			, FN_ACCT_HIS$ b
			, BA_BANK BK
			, BA_USER_GRP_ACCT_A001_V V
		WHERE 1=1
			AND B.ACCT_TXDAY BETWEEN '20230901' and '20231001'
			AND A.ACCT_TYPE='01'
			AND A.BANK_CD=B.BANK_CD
			AND A.ACCT_NO=B.ACCT_NO
			AND A.BANK_CD = BK.BANK_CD(+)
			AND A.USE_YN='Y'
			AND A.DEL_YN='N'
			AND NVL(A.ACCT_SEQ, 'NOT') = V.ACCT_SEQ
			AND V.USER_ID = 'SYSTEMADMIN'
			AND A.SVC_DIST IN ('INS', 'MMB', 'BIZ')
			AND A.SVC_DIST        IN ('MMB', 'BIZ')
			AND A.RECP_ACCT_GB = '01'
			AND A.RECP_YN = 'Y'
        ) TB
		, CMS_TC_BR BR WHERE TB.BRANCH = BR.BR_ID(+)
		  AND TB.MNRC_AMT != 0
		GROUP BY ROLLUP(PNO)
	) TB2
	ORDER BY TB2.GINFO, TB2.TX_DAY_TIME DESC
;



-- 가상계좌수납 > 가상계좌 수납내역 조회
SELECT
	TB2.PNO
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.BANK_NM         END AS BANK_NM
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.BANK_CD         END AS BANK_CD
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.VACCT_NO_FORMAT END AS VACCT_NO_FORMAT
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.VACCT_NO        END AS VACCT_NO
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.TR_DATE         END AS TR_DATE
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.TR_NO           END AS TR_NO
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.TR_TIME         END AS TR_TIME
	, TB2.SUM_AMT || '' AS SUM_AMT
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE ''||TB2.CHK_AMT     END AS CHK_AMT
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE ''||TB2.CASH_AMT    END AS CASH_AMT
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.PROC_STAT_CD    END AS PROC_STAT_CD
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.INP_DT          END AS INP_DT
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.INP_TIME        END AS INP_TIME
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.UPD_DT          END AS UPD_DT
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.UPD_TIME        END AS UPD_TIME
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.ACQ_BANK_BRANCH END AS ACQ_BANK_BRANCH
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE BR.BR_NM            END AS BR_NM
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.ACQ_REQ_NM      END AS ACQ_REQ_NM
	, TB2.GINFO
FROM(
	SELECT
		TB.PNO
		, MAX(TB.BANK_NM        ) AS BANK_NM
		, MAX(TB.BANK_CD        ) AS BANK_CD
		, MAX(TB.VACCT_NO_FORMAT) AS VACCT_NO_FORMAT
		, MAX(TB.VACCT_NO       ) AS VACCT_NO
		, MAX(TB.TR_DATE        ) AS TR_DATE
		, MAX(TB.TR_NO          ) AS TR_NO
		, MAX(TB.TR_TIME        ) AS TR_TIME
		, SUM(TB.SUM_AMT        ) AS SUM_AMT
		, MAX(TB.CHK_AMT        ) AS CHK_AMT
		, MAX(TB.CASH_AMT       ) AS CASH_AMT
		, MAX(TB.PROC_STAT_CD   ) AS PROC_STAT_CD
		, MAX(TB.INP_DT         ) AS INP_DT
		, MAX(TB.INP_TIME       ) AS INP_TIME
		, MAX(TB.UPD_DT         ) AS UPD_DT
		, MAX(TB.UPD_TIME       ) AS UPD_TIME
		, MAX(TB.ACQ_BANK_BRANCH) AS ACQ_BANK_BRANCH
		, MAX(TB.ACQ_REQ_NM     ) AS ACQ_REQ_NM
		, GROUPING(TB.PNO) AS GINFO
	FROM (
		SELECT ROWNUM AS PNO
			 , BANK_NM                                                         /* 은행명 */
			 , BANK_CD                                                         /* 은행코드 */
			 , VACCT_NO_FORMAT                                                 /* formated 계좌번호 */
			 , VACCT_NO                                                        /*계좌번호*/
			 , TR_DATE                                                         /* 거래일자 */
			 , TR_NO                                                           /* 거래순번 */
			 , TR_TIME                                                         /* 거래일자 */
			 , DECODE(PROC_STAT_CD,'0', SUM_AMT, '1', -SUM_AMT) AS SUM_AMT     /* 입금금액 */
			 , DECODE(PROC_STAT_CD,'0', CHK_AMT, '1', -CHK_AMT) AS CHK_AMT     /* 수표금액 */
			 , DECODE(PROC_STAT_CD,'0', CASH_AMT, '1', -CASH_AMT) AS CASH_AMT  /* 현금금액 */
			 , PROC_STAT_CD                                                    /* 처리상태 */
			   /* 취소거래시 입금일시 대신 거래일자, 시간으로 표시해줌 */
			 , DECODE(PROC_STAT_CD,'0', SUBSTR(INP_DT, 0, 10), '1', '') AS INP_DT         /* 입금일시 */
			 , DECODE(PROC_STAT_CD,'0', SUBSTR(INP_DT, 11, 18), '1', '') AS INP_TIME      /* 입금시간 */
			 , DECODE(PROC_STAT_CD,'0', SUBSTR(UPD_DT, 0, 10), '1', TR_DATE) AS UPD_DT    /* 취소일시 */
			 , DECODE(PROC_STAT_CD,'0', SUBSTR(UPD_DT, 9, 18), '1', TR_TIME) AS UPD_TIME /* 취소시간 */
			 , LPAD(SUBSTR(ACQ_BANK_CD,2,2)||ACQ_BANK_BRANCH, 7, '0') AS ACQ_BANK_BRANCH  /* 입금은행지점 */
			 , ACQ_REQ_NM                                                                 /* 입금자성명 */
		FROM (
			SELECT
				   B.BANK_NM                                 /* 은행명 */
				 , A.BANK_CD                                 /* 은행코드 */
				 , FN_ACCT_FORMAT(A.BANK_CD, A.VACCT_NO) AS VACCT_NO_FORMAT /* formated 계좌번호 */
				 , A.VACCT_NO                                /*계좌번호*/
				 , A.TR_DATE                                 /* 거래일자 */
				 , A.TR_NO                                   /* 거래순번 */
				 , A.TR_TIME                                 /* 거래일자 */
				 , A.SUM_AMT                                 /* 입금금액 */
				 , A.CHK_AMT                                 /* 수표금액 */
				 , A.CASH_AMT                                /* 현금금액 */
				 , A.PROC_STAT_CD                            /* 처리상태 */
				 , A.INP_DT                                  /* 입금일시 */
				 , A.UPD_DT                                  /* 취소일시 */
				 , A.ACQ_BANK_CD                             /* 입금은행코드 */
				   /* a.acq_bank_branch,  */
				 , DECODE(LENGTH(A.ACQ_BANK_BRANCH), 5, SUBSTR(A.ACQ_BANK_BRANCH,2,4), A.ACQ_BANK_BRANCH) AS ACQ_BANK_BRANCH                    /* 입금은행지점 */
				 , A.ACQ_REQ_NM                              /* 입금자성명 */
			FROM VA_TRAN A
				 , BA_BANK B
				 , FN_ACCT$ C
			WHERE 1 = 1
			   AND ('10000' || LPAD(TRIM(A.BANK_CD),3,'0')) = B.BANK_CD(+)
			   AND A.TR_DATE BETWEEN '20230801' and '20230810'
			   AND A.SVC_DIST = C.SVC_DIST
			   AND ('10000' || LPAD(TRIM(A.BANK_CD),3,'0')) = CASE WHEN C.BANK_CD = '10000005' THEN '10000081' ELSE C.BANK_CD END
			   AND C.RECP_YN = 'Y'
			   AND C.RECP_ACCT_GB = '02'
			   AND A.SVC_DIST IN ('INS', 'MMB', 'BIZ')
			   AND A.SVC_DIST        IN ('MMB', 'BIZ')
			)
		) TB
		GROUP BY ROLLUP(PNO)
	) TB2
	, CMS_TC_BR BR
WHERE TB2.ACQ_BANK_BRANCH = BR.BR_ID(+)
ORDER BY TB2.GINFO, TB2.TR_DATE DESC, TB2.TR_TIME DESC, TB2.TR_NO DESC
;



-- 자동이체수납 > 자동이체 계좌등록
SELECT
	A.AP_IF_RCPTINFMMAST_PNO AS PNO
	, A.REGI_DATE                    /* 거래등록일자 */
	, A.REGI_TIME                    /* 거래등록시간 */
	, A.SVC_DIST                     /* 시스템구분 */
	, A.REGI_NUM                     /* 거래등록일련번호 */
	, A.SAN_WORK_GB                  /* 업무구분코드 */
	, A.BSWR_NM                      /* 업무명 */
	, A.FILE_NM                      /* 파일명 */
	, A.RCPT_INTT_CD                 /* 수납기관코드 */
	, DECODE(TRIM(A.RCPT_INTT_CD),'10000099','금융결제원', BK.BANK_NM ) AS RCPT_INTT_NM /* 수납기관명 */
	, A.BANK_CD                      /* 은행코드 */
	, BK.BANK_NM                     /* 은행명 */
	, A.MTACT_NO                     /* 모계좌번호 */
	, FN_ACCT_FORMAT(A.BANK_CD, A.MTACT_NO) AS MTACT_NO_FORMAT       /* 수납계좌번호_formated */
	, A.DMND_DATE                    /* 요청일자 */
	, A.REGI_CNT                     /* 등록건수(총건수) */
	, A.NEW_CNT                      /* 신규건수 */
	, A.TRMT_CNT                     /* 해지건수 */
	, A.ENTP_CD                      /* 업체코드 */
	, A.FIRM_CD                      /* 은행기관코드 */
	, A.KTCU_USER_NM                 /* 발의자명 */
	, A.KTCU_DEPT_NM                 /* 발의부서명 */
	, NVL((SELECT COUNT(*) AS CNT    FROM AP_IF_RCPTINFMSUB$ C  WHERE A.REGI_DATE = C.REGI_DATE AND A.SVC_DIST = C.SVC_DIST AND A.REGI_NUM = C.REGI_NUM AND A.REGI_TIME = C.REGI_TIME AND C.RCPT_ACCT_APDS = '1'),0) AS SUB_CNT
	, NVL((SELECT D.REGI_CNT AS CNT  FROM AP_IF_RCPTPROOFMAST D WHERE A.REGI_DATE = D.REGI_DATE AND A.SVC_DIST = D.SVC_DIST AND A.REGI_NUM = D.REGI_NUM AND A.REGI_TIME = D.REGI_TIME ),0) AS PROOFMAST_CNT
	, NVL((SELECT COUNT(*) AS CNT    FROM AP_IF_RCPTPROOFSUB$ D WHERE A.REGI_DATE = D.REGI_DATE AND A.SVC_DIST = D.SVC_DIST AND A.REGI_NUM = D.REGI_NUM AND A.REGI_TIME = D.REGI_TIME ),0) AS PROOFSUB_CNT
	, A.LAST_STATUS
	, CD1.CMM_CD_NM AS LAST_STATUS_NM
FROM AP_IF_RCPTINFMMAST A
	, FN_ACCT            B
	, DWC_CMM_CODE       CD1
	, BA_BANK            BK
	, BA_BANK            BK2
	, BA_USER_GRP_ACCT_A001_V V
WHERE 1 = 1
	AND A.REGI_DATE    = '20230725'
	AND A.SAN_WORK_GB  IN ( '310','EB1')
	AND A.LAST_STATUS  IN ('91', '32', '33')
	AND A.END_GB       IN ('0', 'T')
	AND A.LAST_STATUS  = CD1.CMM_CD(+)
	AND CD1.GRP_CD(+)  = 'S043'
	AND A.BANK_CD      = BK.BANK_CD(+)
	AND A.RCPT_INTT_CD = BK2.BANK_CD(+)
	AND A.MTACT_NO     = B.ACCT_NO
	AND NVL(B.ACCT_SEQ, 'NOT') = V.ACCT_SEQ
	AND V.USER_ID      = 'SYSTEMADMIN'
    AND EXISTS (SELECT '1'
    	FROM AP_IF_RCPTINFMSUB$ B
   		WHERE A.SVC_DIST  = B.SVC_DIST
			 AND A.REGI_NUM  = B.REGI_NUM
			 AND A.REGI_DATE = B.REGI_DATE
			 AND A.REGI_TIME = B.REGI_TIME)
ORDER BY A.REGI_DATE, A.SVC_DIST, A.REGI_NUM, A.REGI_TIME
;



-- 자동이체수납 > 자동이체 계좌등록 결과조회
SELECT
	A.AP_IF_RCPTINFMMAST_PNO AS PNO
	, A.REGI_DATE                             /* 등록일자 */
	, A.REGI_TIME                             /* 등록시간 */
	, A.REGI_DATE || A.REGI_TIME AS REGI_DT   /* 등록일시 */
	, A.REGI_NUM                              /* 등록일련번호 */
	, A.SVC_DIST                              /* 시스템구분 */
	, A.SAN_WORK_GB                           /* 업무구분코드 */
	, A.KTCU_DEPT_NM AS DEPT_NM               /* 발의부서 */
	, A.KTCU_USER_NM AS USER_NM               /* 발의자 */
	, A.BSWR_NM                               /* 업무명 */
	, A.FILE_NM                               /* 파일명 */
	, A.RCPT_INTT_CD                          /* 수납기관코드 */
	, DECODE(TRIM(A.RCPT_INTT_CD),'10000099','금융결제원', BK.BANK_NM ) AS RCPT_INTT_NM /* 수납기관명 */
	, A.BANK_CD                               /* 은행코드 */
	, BK.BANK_NM                              /* 은행명 */
	, DWC_CRYPT.decrypt(A.MTACT_NO) AS MTACT_NO /* 수납계좌번호 */
	, FN_ACCT_FORMAT(A.BANK_CD, DWC_CRYPT.decrypt(A.MTACT_NO)) AS MTACT_NO_FORMAT /* 수납계좌번호_formated */
	, A.DMND_DATE                             /* 요청일자 */
	, A.END_GB                                /* 작업완료여부 code */
	, A.LAST_STATUS AS LAST_STATUS_CD         /* 처리상태코드 */
	, CASE WHEN A.LAST_STATUS = '21' AND NVL(A.FILE_SEND_STS,'0') = '0'      THEN '전송대기'
		WHEN A.LAST_STATUS = '51' AND A.FILE_SEND_STS = '3'               THEN '파일생성완료'
		WHEN A.LAST_STATUS = '51' AND A.FILE_SEND_STS = '5'               THEN 'VAN 수신완료'
		WHEN A.LAST_STATUS = '51' AND A.FILE_SEND_STS = '1'               THEN '은행수신완료'
		WHEN A.LAST_STATUS = '52' AND A.END_GB = '1' AND A.IF_FLAG = 'EP' THEN '최종완료'
		WHEN A.SAN_WORK_GB LIKE 'EB%' AND A.LAST_STATUS = '55' AND A.FILE_SEND_STS = '1' THEN '취소처리중'
		ELSE CD.CMM_CD_NM
		 END AS LAST_STATUS                        /* 처리상태 */
	, A.END_DATETIME                                  /* 처리완료일시 */
	, NVL(A.REGI_CNT,'0') REGI_CNT                    /* 등록건수(총건수) */
	, NVL(A.REGI_AMT,'0') || '' AS REGI_AMT           /* 총금액 */
	, NVL(A.NOR_CNT,'0') NOR_CNT                      /* 정상건수 */
	, NVL(A.NOR_AMT,'0') || '' AS NOR_AMT             /* 정상금액 */
	, NVL(A.ERR_CNT,'0') ERR_CNT                      /* 오류건수 */
	, NVL(A.ERR_AMT,'0') || '' AS ERR_AMT             /* 오류금액 */
	, NVL(A.NEW_CNT,'0') NEW_CNT                      /* 신규건수 */
	, NVL(A.TRMT_CNT,'0') TRMT_CNT                    /* 해지건수 */
FROM AP_IF_RCPTINFMMAST$ A
	, FN_ACCT B
	, BA_BANK BK
	, BA_BANK BK2
	, DWC_CMM_CODE CD
	, BA_USER_GRP_ACCT_A001_V V
WHERE A.SAN_WORK_GB IN ('310' ,'EB1')
	AND A.BANK_CD      = BK.BANK_CD(+)
	AND DWC_CRYPT.decrypt(A.MTACT_NO) = B.ACCT_NO
	AND A.RCPT_INTT_CD = BK2.BANK_CD(+)
	AND A.LAST_STATUS  = CD.CMM_CD(+)
	AND CD.GRP_CD(+)   = 'S043'
	AND NVL(B.ACCT_SEQ, 'NOT') = V.ACCT_SEQ
	AND V.USER_ID      = 'SYSTEMADMIN'
	AND EXISTS (SELECT '1'
				FROM AP_IF_RCPTINFMSUB B
				WHERE A.SVC_DIST  = B.SVC_DIST
				  AND A.REGI_NUM  = B.REGI_NUM
				  AND A.REGI_DATE = B.REGI_DATE
				  AND A.REGI_TIME = B.REGI_TIME)
	AND A.REGI_DATE BETWEEN '20230701' and '20230730'
	AND A.END_GB NOT IN ('0')
ORDER BY A.REGI_DATE DESC, A.END_DATETIME DESC,  A.SVC_DIST, A.DMND_DATE DESC, A.REGI_NUM, A.REGI_TIME
;



-- 자동이체수납 > 자동이체 수납실행
SELECT
	   A.AP_IF_RCPTINFMMAST_PNO AS PNO
	 , A.REGI_DATE                    /* 전송일자 */
	 , A.REGI_TIME                    /* 전송시간 */
	 , A.SVC_DIST                     /* 시스템구분 */
	 , A.DMND_DATE                    /* 요청(수납)일자 */
	 , A.REGI_NUM                     /* 거래등록일련번호 */
	 , A.SAN_WORK_GB                  /* 업무구분코드 */
	 , A.KTCU_DEPT_NM AS DEPT_NM      /* 발의부서 */
	 , A.KTCU_USER_NM AS USER_NM      /* 발의자 */
	 , A.BSWR_NM                      /* 업무명 */
	 , A.RCPT_INTT_CD                 /* 수납기관코드 */
	 , DECODE(TRIM(A.RCPT_INTT_CD),'10000099','금융결제원', BK.BANK_NM ) AS RCPT_INTT_NM /* 수납기관명 */
	 , A.BANK_CD                      /* 은행코드 */
	 , BK.BANK_NM                     /* 은행명 */
	 , A.MTACT_NO                     /* 수납계좌번호 */
	 , FN_ACCT_FORMAT(A.BANK_CD, A.MTACT_NO) AS MTACT_NO_FORMAT /* 수납계좌번호_formated */
	 , NVL(A.REGI_CNT,'0') REGI_CNT                             /* 등록건수(총건수) */
	 , NVL(A.REGI_AMT,'0') || '' AS REGI_AMT                    /* 총금액 */
	 , A.ENTP_CD                      /* 업체코드 */
	 , A.FIRM_CD                      /* 은행기관코드 */
	 , A.LAST_STATUS
	 , CD1.CMM_CD_NM AS LAST_STATUS_NM
FROM AP_IF_RCPTINFMMAST A
	 , FN_ACCT B
	 , BA_BANK BK
	 , BA_BANK BK2
	 , BA_USER_GRP_ACCT_A001_V V
	 , DWC_CMM_CODE CD1
WHERE 
	A.REGI_DATE    = '20230905'
	AND A.SAN_WORK_GB IN ('300','EB2')
	AND A.LAST_STATUS IN ('91', '32', '33')
	AND A.END_GB      IN ('0', 'T')
	AND A.MTACT_NO     = B.ACCT_NO
	AND A.RCPT_INTT_CD = BK2.BANK_CD(+)
	AND A.BANK_CD      = BK.BANK_CD(+)
	AND NVL(B.ACCT_SEQ, 'NOT') = V.ACCT_SEQ
	AND V.USER_ID      = 'SYSTEMADMIN'
	AND A.LAST_STATUS  = CD1.CMM_CD(+)
	AND CD1.GRP_CD(+)  = 'S043'
--           AND EXISTS (SELECT '1'
--                         FROM AP_IF_RCPTINFMSUB B
--                        WHERE A.SVC_DIST  = B.SVC_DIST
--                          AND A.REGI_NUM  = B.REGI_NUM
--                          AND A.REGI_DATE = B.REGI_DATE
--                          AND A.REGI_TIME = B.REGI_TIME)
ORDER BY A.REGI_DATE, A.SVC_DIST, A.REGI_NUM, A.REGI_TIME
;



-- 자동이체수납 > 자동이체 수납결과 조회
SELECT
	A.AP_IF_RCPTINFMMAST_PNO AS PNO
	, A.REGI_DATE                             /* 등록일자 */
	, A.REGI_TIME                             /* 등록시간 */
	, A.REGI_DATE || A.REGI_TIME AS REGI_DT   /* 등록일시 */
	, A.REGI_NUM                              /* 등록일련번호 */
	, A.SVC_DIST                              /* 시스템구분 */
	, A.SAN_WORK_GB                           /* 업무구분코드 */
	, A.KTCU_DEPT_NM AS DEPT_NM               /* 발의부서 */
	, A.KTCU_USER_NM AS USER_NM               /* 발의자 */
	, A.BSWR_NM                               /* 업무명 */
	, A.FILE_NM                               /* 파일명 */
	, A.RCPT_INTT_CD                          /* 수납기관코드 */
	, DECODE(TRIM(A.RCPT_INTT_CD),'10000099','금융결제원', BK.BANK_NM ) AS RCPT_INTT_NM /* 수납기관명 */
	, A.BANK_CD                               /* 은행코드 */
	, BK.BANK_NM                              /* 은행명 */
	, DWC_CRYPT.decrypt(A.MTACT_NO) AS MTACT_NO /* 수납계좌번호 */
	, FN_ACCT_FORMAT(A.BANK_CD, DWC_CRYPT.decrypt(A.MTACT_NO)) AS MTACT_NO_FORMAT       /* 수납계좌번호_formated */
	, A.DMND_DATE                             /* 요청일자 */
	, A.END_GB                                /* 작업완료여부 code */
	, A.LAST_STATUS AS LAST_STATUS_CD         /* 처리상태코드 */
	, CASE WHEN A.LAST_STATUS = '21' AND NVL(A.FILE_SEND_STS,'0') = '0'  THEN '전송대기'
		WHEN A.LAST_STATUS = '51' AND A.FILE_SEND_STS = '3'           THEN '파일생성완료'
		WHEN A.LAST_STATUS = '51' AND A.FILE_SEND_STS = '5'           THEN 'VAN 수신완료'
		WHEN A.LAST_STATUS = '51' AND A.FILE_SEND_STS = '1'           THEN '은행수신완료'
		WHEN A.LAST_STATUS = '52' AND A.END_GB = '1' AND A.IF_FLAG = 'EP' THEN '최종완료'
		WHEN A.SAN_WORK_GB LIKE 'EB%' AND A.LAST_STATUS = '55' AND A.FILE_SEND_STS = '1' THEN '취소처리중'
		ELSE CD.CMM_CD_NM
		 END AS LAST_STATUS                        /* 처리상태 */
	, A.END_DATETIME                                  /* 처리완료일시 */
	, NVL(A.REGI_CNT,'0') REGI_CNT                    /* 등록건수(총건수) */
	, NVL(A.REGI_AMT,'0') || '' AS REGI_AMT           /* 총금액 */
	, NVL(A.NOR_CNT,'0') NOR_CNT                      /* 정상건수 */
	, NVL(A.NOR_AMT,'0') || '' AS NOR_AMT             /* 정상금액 */
	, NVL(A.ERR_CNT,'0') ERR_CNT                      /* 오류건수 */
	, NVL(A.ERR_AMT,'0') || '' AS ERR_AMT             /* 오류금액 */
	, A.ERR_MSG
FROM AP_IF_RCPTINFMMAST$ A
	, FN_ACCT B
	, BA_BANK BK
	, BA_BANK BK2
	, DWC_CMM_CODE CD
	, BA_USER_GRP_ACCT_A001_V V
WHERE A.SAN_WORK_GB IN ('300' ,'EB2' )
	AND A.BANK_CD      = BK.BANK_CD(+)
	AND DWC_CRYPT.decrypt(A.MTACT_NO) = B.ACCT_NO
	AND A.RCPT_INTT_CD = BK2.BANK_CD(+)
	AND A.LAST_STATUS  = CD.CMM_CD(+)
	AND CD.GRP_CD(+)   = 'S043'
	AND NVL(B.ACCT_SEQ, 'NOT') = V.ACCT_SEQ
	AND V.USER_ID      = 'SYSTEMADMIN'
	AND EXISTS (SELECT '1'
				FROM AP_IF_RCPTINFMSUB B
				WHERE A.SVC_DIST  = B.SVC_DIST
					AND A.REGI_NUM  = B.REGI_NUM
					AND A.REGI_DATE = B.REGI_DATE
					AND A.REGI_TIME = B.REGI_TIME)
	AND A.DMND_DATE BETWEEN '20230701' and '20230730'
	AND A.END_GB NOT IN ('0')
ORDER BY A.REGI_DATE DESC, A.END_DATETIME DESC,  A.SVC_DIST, A.DMND_DATE DESC, A.REGI_NUM, A.REGI_TIME
;



-- 자동이체수납 > 금융기관 접수내역 조회(금결원)
SELECT
	A.REGI_DATE                                                   	/*접수일자*/
	, A.REGI_DATE || A.REGI_TIME AS END_DATETIME                      /*접수시간*/
	, A.RCPT_INTT_CD                                                /*접수기관코드*/
	, DECODE(TRIM(A.RCPT_INTT_CD),'10000099','금융결제원', BK.BANK_NM ) AS RCPT_INTT_NM /* 수납기관명 */
	, A.MTACT_NO                                                    /*수납계좌번호*/
	, FN_ACCT_FORMAT(A.BANK_CD, A.MTACT_NO) AS MTACT_NO_FORMAT      /* 수납계좌번호_FORMATED */
	, B.OUT_BANK_CD                                                 /*출금은행*/
	, BK.BANK_NM AS OUT_BANK_NM                                     /* 은행명 */
	, B.OUT_ACCT_NO                                                 /*출금계좌번호*/
	, FN_ACCT_FORMAT(B.OUT_BANK_CD, B.OUT_ACCT_NO) AS OUT_ACCT_NO_FORMAT      /* 출금계좌번호_FORMATED */
	, CASE WHEN A.SAN_WORK_GB='EB0'
		THEN
		DECODE(B.RCPT_ACCT_APDS, '1', '신청',
								 '3', '해지',
								 '7', '임의해지')
		WHEN   A.SAN_WORK_GB='320'
		THEN
		DECODE(B.RCPT_ACCT_APDS, '1', '신청',
								 '2', '해지',
								 '변경')
		END  AS RCPT_ACCT_APDS                                    		/*신청구분*/
	, B.CSTM_APLC_DATE                                               	/*신청일자*/
	, DECODE(B.RRNO, NULL, '', SUBSTR(B.RRNO, 0, 6) || '-' || SUBSTR(B.RRNO, 7, 7)) AS RRNO /*주민/사업자번호*/
	, B.BRCD7                                                        	/*은행점코드*/
	, B.BRCD4                                                        	/*취급점코드*/
	,B.CLPH_NO                                                      	/*전화번호*/
	, B.PAYER_NO1                                                    	/*납부자번호*/
	, D.BR_NM                                                        	/*은행점명*/
	, CASE WHEN A.ENTP_CD = '9983010300' THEN '보험' ELSE '회원' END AS ENTP_NM /*9983010300: 보험, 9983310066: 회원*/
FROM
	AP_IF_RCPTINFMMAST A
	, AP_IF_RCPTINFMSUB  B
	, FN_ACCT            C
	, CMS_TC_BR          D
	, BA_BANK            BK
	, BA_BANK            BK2
	, BA_USER_GRP_ACCT_A001_V V
WHERE
	A.REGI_DATE    = B.REGI_DATE
	AND A.SVC_DIST     = B.SVC_DIST
	AND A.REGI_NUM     = B.REGI_NUM
	AND A.REGI_TIME    = B.REGI_TIME
	AND A.MTACT_NO     = C.ACCT_NO
	AND B.BRCD7        = D.BR_ID(+)
	AND A.SAN_WORK_GB IN ('EB0','320')
	AND B.OUT_BANK_CD  = BK.BANK_CD(+)
	AND A.RCPT_INTT_CD = BK2.BANK_CD(+)
	AND NVL(C.ACCT_SEQ, 'NOT') = V.ACCT_SEQ
	AND V.USER_ID      = 'SYSTEMADMIN'
	AND A.REGI_DATE BETWEEN '20230701' and '20230707'
ORDER BY A.REGI_DATE DESC, A.REGI_TIME DESC
;



-- 자동이체수납 > 금융기관 접수내역 조회(쿠콘)
SELECT
	A.ORG_CD as ENTP_CD
	, CASE WHEN A.ORG_CD IN ('00670701', '1100224') THEN '보험' ELSE '회원' END           AS ENTP_NM
	, A.TR_DATE             AS REGI_DATE                         /*접수일자*/
	, 'coocon'              AS REG_USER_ID                       /*등록자ID*/
	, 'FRM'                 AS SVC_DIST                          /*서비스구분*/
	, A.TR_DATE||'000000'   AS END_DATETIME                      /*접수시간*/
	, A.ORG_CD              AS RCPT_INTT_CD                      /*접수기관코드*/
	, DECODE(TRIM(A.ORG_CD),'10000099','금융결제원', BK.BANK_NM ) AS RCPT_INTT_NM /* 수납기관명 */
	, A.ACCT_NO    AS MTACT_NO                                   /*수납계좌번호*/
	, FN_ACCT_FORMAT('10000' || A.ORG_BANK_CD, A.ACCT_NO) AS MTACT_NO_FORMAT      /* 수납계좌번호_FORMATED */
	, A.ORG_BANK_CD   AS OUT_BANK_CD                             /*출금은행*/
	, BK.BANK_NM AS OUT_BANK_NM                                  /* 은행명 */
	, A.ACCT_NO AS OUT_ACCT_NO                                   /*출금계좌번호*/
	, FN_ACCT_FORMAT('10000' || A.ORG_CD, A.ACCT_NO) AS OUT_ACCT_NO_FORMAT      /* 출금계좌번호_FORMATED */
	, '해지'     AS RCPT_ACCT_APDS                                /*신청구분*/
	, A.TR_DATE        AS CSTM_APLC_DATE                         /*신청일자*/
	, DECODE(A.RSNO, NULL, '', SUBSTR(A.RSNO, 0, 6)||'-'||SUBSTR(A.RSNO, 7, 7)) AS RRNO /*주민/사업자번호*/
	, '' AS BRCD7                                                /*은행점코드*/
	, '' AS  BRCD4                                               /*취급점코드*/
	,'' AS CLPH_NO                                               /*전화번호*/
	, A.CTM_NO    AS PAYER_NO1                                   /*납부자번호*/
	, '' AS BR_NM                                                /*은행점명*/
FROM
	TB_ACCT_CLOSE A
	, FN_ACCT            C
	, BA_BANK            BK
	, BA_USER_GRP_ACCT_A001_V V
WHERE
	A.ACCT_NO     = C.ACCT_NO(+)
	AND '10000' || A.ORG_BANK_CD  = BK.BANK_CD(+)
	AND NVL(C.ACCT_SEQ, 'NOT') = V.ACCT_SEQ
	AND V.USER_ID      = 'SYSTEMADMIN'
	AND A.TR_DATE BETWEEN '20230701' and '20230709'
	
UNION ALL

SELECT
	A.ENTP_CD
	, CASE WHEN A.ENTP_CD IN ('00670701', '1100224') THEN '보험' ELSE '회원' END AS ENTP_NM
	, A.REGI_DATE                                                   /*접수일자*/
	, B.REG_USER_ID
	, B.SVC_DIST
	, A.REGI_DATE||A.REGI_TIME AS END_DATETIME                      /*접수시간*/
	, A.RCPT_INTT_CD                                                /*접수기관코드*/
	, DECODE(TRIM(A.RCPT_INTT_CD),'10000099','금융결제원', BK.BANK_NM ) AS RCPT_INTT_NM /* 수납기관명 */
	, A.MTACT_NO                                                    /*수납계좌번호*/
	, FN_ACCT_FORMAT(A.BANK_CD, A.MTACT_NO) AS MTACT_NO_FORMAT      /* 수납계좌번호_FORMATED */
	, B.OUT_BANK_CD                                                 /*출금은행*/
	, BK.BANK_NM AS OUT_BANK_NM                                     /* 은행명 */
	, B.OUT_ACCT_NO                                                 /*출금계좌번호*/
	, FN_ACCT_FORMAT(B.OUT_BANK_CD, B.OUT_ACCT_NO) AS OUT_ACCT_NO_FORMAT      /* 출금계좌번호_FORMATED */
	, CASE WHEN A.SAN_WORK_GB='EB0'
	   THEN
			DECODE(B.RCPT_ACCT_APDS, '1', '신청',
			'3', '해지',
			'7', '임의해지')
	   WHEN   A.SAN_WORK_GB='320'
	   THEN
			DECODE(B.RCPT_ACCT_APDS, '1', '신청',
			'2', '해지',
			'변경')
	   END  AS RCPT_ACCT_APDS                                    /*신청구분*/
	, B.CSTM_APLC_DATE                                               /*신청일자*/
	, DECODE(B.RRNO, NULL, '', SUBSTR(B.RRNO, 0, 6) || '-' || SUBSTR(B.RRNO, 7, 7)) AS RRNO /*주민/사업자번호*/
	, B.BRCD7                                                        /*은행점코드*/
	, B.BRCD4                                                        /*취급점코드*/
	,B.CLPH_NO                                                      /*전화번호*/
	, B.PAYER_NO1                                                    /*납부자번호*/
	, D.BR_NM                                                        /*은행점명*/
FROM
	AP_IF_RCPTINFMMAST A
	, AP_IF_RCPTINFMSUB  B
	, FN_ACCT            C
	, CMS_TC_BR          D
	, BA_BANK            BK
	, BA_BANK            BK2
	, BA_USER_GRP_ACCT_A001_V V
WHERE
	A.REGI_DATE    = B.REGI_DATE
	AND A.SVC_DIST     = B.SVC_DIST
	AND A.REGI_NUM     = B.REGI_NUM
	AND A.REGI_TIME    = B.REGI_TIME
	AND A.MTACT_NO     = C.ACCT_NO(+)
	AND B.BRCD7        = D.BR_ID(+)
	AND A.SAN_WORK_GB IN ('EB0','320')
	AND B.OUT_BANK_CD  = BK.BANK_CD(+)
	AND A.RCPT_INTT_CD = BK2.BANK_CD(+)
	AND NVL(C.ACCT_SEQ, 'NOT') = V.ACCT_SEQ
	AND V.USER_ID      = 'SYSTEMADMIN'
	AND A.REGI_DATE BETWEEN '20230701' and '20230709'
	AND B.SVC_DIST     = 'FRM'
	AND B.REG_USER_ID  = 'coocon'
ORDER BY REGI_DATE, PAYER_NO1, RCPT_ACCT_APDS
;



-- 즉시출금 이체수납 > 즉시출금 계좌등록 결과조회
SELECT
	ROWNUM AS PNO
	, A.REGI_DATE                             /* 등록일자 */
	, A.REGI_TIME                             /* 등록시간 */
	, A.REGI_DATE || A.REGI_TIME AS REGI_DT   /* 등록일시 */
	, A.REGI_NUM                              /* 등록일련번호 */
	, A.SVC_DIST                              /* 시스템구분 */
	, A.SAN_WORK_GB                           /* 업무구분코드 */
	, A.KTCU_DEPT_NM AS DEPT_NM               /* 발의부서 */
	, A.KTCU_USER_NM AS USER_NM               /* 발의자 */
	, A.BSWR_NM                               /* 업무명 */
	, A.FILE_NM                               /* 파일명 */
	, A.RCPT_INTT_CD                          /* 수납기관코드 */
	, DECODE(TRIM(A.RCPT_INTT_CD),'0110835','금융결제원', BK2.BANK_NM ) AS RCPT_INTT_NM /* 수납기관명 */
	, A.BANK_CD                               /* 은행코드 */
	, BK.BANK_NM                              /* 은행명 */
	, DWC_CRYPT.decrypt(A.MTACT_NO) AS MTACT_NO /* 수납계좌번호 */
	, FN_ACCT_FORMAT(A.BANK_CD, DWC_CRYPT.decrypt(A.MTACT_NO)) AS MTACT_NO_FORMAT /* 수납계좌번호_formated */
	, A.DMND_DATE                             /* 요청일자 */
	, A.END_GB                                /* 작업완료여부 code */
	, A.LAST_STATUS AS LAST_STATUS_CD         /* 처리상태코드 */
	, CASE WHEN A.LAST_STATUS = '51' AND NVL(A.FILE_SEND_STS,'0') = '0'  THEN '전송대기'
		WHEN A.LAST_STATUS = '51' AND A.FILE_SEND_STS = '1'           THEN '은행수신완료'
		WHEN A.LAST_STATUS = '51' AND A.FILE_SEND_STS = '2'           THEN '파일생성중'
		WHEN A.LAST_STATUS = '51' AND A.FILE_SEND_STS = '3'           THEN '파일생성완료'
		WHEN A.LAST_STATUS = '51' AND A.FILE_SEND_STS = '4'           THEN 'VAN 전송중'
		WHEN A.LAST_STATUS = '51' AND A.FILE_SEND_STS = '5'           THEN 'VAN 수신완료'
		WHEN A.LAST_STATUS = '52' AND A.END_GB = '1' AND A.IF_FLAG = 'EP' THEN '최종완료'
		WHEN A.SAN_WORK_GB LIKE 'EB%' AND A.LAST_STATUS = '55' AND A.FILE_SEND_STS = '1' THEN '취소처리중'
		ELSE CD.CMM_CD_NM
		 END AS LAST_STATUS                        /* 처리상태 */
	, A.END_DATETIME                                  /* 처리완료일시 */
	, NVL(A.REGI_CNT,'0') REGI_CNT                    /* 등록건수(총건수) */
	, NVL(A.REGI_AMT,'0') || '' AS REGI_AMT           /* 총금액 */
	, NVL(A.NOR_CNT,'0') NOR_CNT                      /* 정상건수 */
	, NVL(A.NOR_AMT,'0') || '' AS NOR_AMT             /* 정상금액 */
	, NVL(A.ERR_CNT,'0') ERR_CNT                      /* 오류건수 */
	, NVL(A.ERR_AMT,'0') || '' AS ERR_AMT             /* 오류금액 */
FROM AP_IF_RCPTINFMMAST$ A
	, FN_ACCT B
	, BA_BANK BK
	, BA_BANK BK2
	, DWC_CMM_CODE CD
	, BA_USER_GRP_ACCT_A001_V V
WHERE A.SAN_WORK_GB IN ( '360' )
	AND A.BANK_CD      = BK.BANK_CD(+)
	AND DWC_CRYPT.decrypt(A.MTACT_NO) = B.ACCT_NO
	AND A.RCPT_INTT_CD = BK2.BANK_CD(+)
	AND A.LAST_STATUS  = CD.CMM_CD(+)
	AND CD.GRP_CD(+)   = 'S043'
	AND NVL(B.ACCT_SEQ, 'NOT') = V.ACCT_SEQ
	AND V.USER_ID      = 'SYSTEMADMIN'
	AND EXISTS (SELECT '1'
				FROM AP_IF_RCPTINFMSUB B
				WHERE A.SVC_DIST  = B.SVC_DIST
					AND A.REGI_NUM  = B.REGI_NUM
					AND A.REGI_DATE = B.REGI_DATE
					AND A.REGI_TIME = B.REGI_TIME)
	AND A.REGI_DATE BETWEEN '20231001' and '20231030'
	AND A.END_GB NOT IN ('0')
ORDER BY A.REGI_DATE DESC, A.END_DATETIME DESC,  A.SVC_DIST, A.DMND_DATE DESC, A.REGI_NUM, A.REGI_TIME
;


-- 즉시출금 이체수납 > 즉시출금 계좌등록 결과조회 > 상세조회
SELECT
	A.AP_IF_RCPTINFMSUB_PNO AS PNO             /* 일련번호 */
	, A.REGI_NUM                                 /* 거래등록일련번호 */
	, A.REGI_DATE                                /* 이체실행일자 */
	, A.REGI_TIME                                /* 이체실행시간 */
	, A.SVC_DIST                                 /* 시스템구분 */
	, A.REGI_SEQ                                 /* 상세일련번호 */
	, A.RCPT_ACCT_APDS                           /* 수납계좌신청구분코드 */
	, DECODE(A.RCPT_ACCT_APDS, '1', '신규', '2', '해지', '3', '해지', '7', '임의해지') as REQUEST_GBN   /* 수납계좌신청구분 */
	, A.OUT_BANK_CD                              /* 은행코드 */
	, CASE A.OUT_BANK_CD WHEN '10000010'
					 THEN '농협'
					 ELSE BK.BANK_NM
				 END AS BANK_NM              /* 은행명 */
	, A.OUT_ACCT_NO                              /* 출금계좌 */
	, FN_ACCT_FORMAT(A.OUT_BANK_CD, A.OUT_ACCT_NO) AS ACCT_NO_FORMAT  /* 계좌번호 포맷 */
	, A.IN_RMK                   /* 출금통장인자내역 */
	, A.TRAN_AMT || '' AS TRAN_AMT                 /* 원화요청금액 */
	, A.REAL_TRAN_AMT || '' AS REAL_TRAN_AMT       /* 실처리금액 */
	, A.TRAN_FEE || '' AS TRAN_FEE                 /* 원화요청금액 */
	, A.REGI_REF_NM              /* 예금주 */
	, CASE A.END_GB WHEN '5' THEN SUBSTR(A.RRNO,0,6) || '-' ||  SUBSTR(A.RRNO,7,8)
				ELSE SUBSTR(A.RRNO,0,6) || '-' ||  SUBSTR(A.RRNO,7,1)||'******' END AS RRNO  /* 주민번호 */
	, A.RRNO AS REAL_RRNO
	, CASE A.RRNO WHEN A.PAYER_NO1 THEN SUBSTR(A.RRNO,0,7)||'******'
			  ELSE A.PAYER_NO1 END PAYER_NO1  /* 납부자번호 */
	, A.END_GB                   /* 처리완료여부 */
	, DECODE(A.END_GB,'0','미완료','1','정상','2','처리중','5','오류','4','재처리건반송') as END_GB_TEXT
	, A.PROC_STS                 /* 처리결과코드 */
	, CASE WHEN B.SAN_WORK_GB IN ('300', '310', '360', '350') THEN F_ERR_MSG(B.BANK_CD,A.PROC_STS,'1', NVL(A.ORG_CD,'COOCON'))
	   ELSE F_ERR_MSG(DECODE(SUBSTR(B.SAN_WORK_GB,1,2),'EB','10000099',B.BANK_CD),A.PROC_STS,'1',NVL(A.ORG_CD,'NCOM'))
	   END AS PROC_STS_TEXT  /* 처리결과 */
FROM AP_IF_RCPTINFMSUB A
	, AP_IF_RCPTINFMMAST B
	, BA_BANK BK
WHERE 1 = 1
	AND A.OUT_BANK_CD = BK.BANK_CD(+)
	AND A.REGI_NUM    = B.REGI_NUM
	AND A.REGI_DATE   = B.REGI_DATE
	AND A.REGI_TIME   = B.REGI_TIME
	AND A.SVC_DIST    = B.SVC_DIST
	AND A.REGI_NUM    = '2000073625'
	AND A.REGI_DATE   = '20231030'
	AND A.REGI_TIME   = '102749'
	AND A.SVC_DIST    = 'INS'
ORDER BY A.REGI_SEQ ASC
;



-- 즉시출금 이체수납 > 즉시출금 수납결과 조회
SELECT
	ROWNUM AS PNO
	, A.REGI_DATE                             /* 등록일자 */
	, A.REGI_TIME                             /* 등록시간 */
	, A.REGI_DATE || A.REGI_TIME AS REGI_DT   /* 등록일시 */
	, A.REGI_NUM                              /* 등록일련번호 */
	, A.SVC_DIST                              /* 시스템구분 */
	, A.SAN_WORK_GB                           /* 업무구분코드 */
	, A.KTCU_DEPT_NM AS DEPT_NM               /* 발의부서 */
	, A.KTCU_USER_NM AS USER_NM               /* 발의자 */
	, A.BSWR_NM                               /* 업무명 */
	, A.FILE_NM                               /* 파일명 */
	, A.RCPT_INTT_CD                          /* 수납기관코드 */
	, DECODE(TRIM(A.RCPT_INTT_CD),'0110835','금융결제원', BK2.BANK_NM ) AS RCPT_INTT_NM /* 수납기관명 */
	, A.BANK_CD                               /* 은행코드 */
	, BK.BANK_NM                              /* 은행명 */
	, DWC_CRYPT.decrypt(A.MTACT_NO) AS MTACT_NO /* 수납계좌번호 */
	, FN_ACCT_FORMAT(A.BANK_CD, DWC_CRYPT.decrypt(A.MTACT_NO)) AS MTACT_NO_FORMAT       /* 수납계좌번호_formated */
	, A.DMND_DATE                             /* 요청일자 */
	, A.END_GB                                /* 작업완료여부 code */
	, A.LAST_STATUS AS LAST_STATUS_CD         /* 처리상태코드 */
	, CASE WHEN A.LAST_STATUS = '51' AND NVL(A.FILE_SEND_STS,'0') = '0'  THEN '전송대기'
		WHEN A.LAST_STATUS = '51' AND A.FILE_SEND_STS = '1'           THEN '은행수신완료'
		WHEN A.LAST_STATUS = '51' AND A.FILE_SEND_STS = '2'           THEN '파일생성중'
		WHEN A.LAST_STATUS = '51' AND A.FILE_SEND_STS = '3'           THEN '파일생성완료'
		WHEN A.LAST_STATUS = '51' AND A.FILE_SEND_STS = '4'           THEN 'VAN 전송중'
		WHEN A.LAST_STATUS = '51' AND A.FILE_SEND_STS = '5'           THEN 'VAN 수신완료'
		WHEN A.LAST_STATUS = '52' AND A.END_GB = '1' AND A.IF_FLAG = 'EP' THEN '최종완료'
		WHEN A.SAN_WORK_GB LIKE 'EB%' AND A.LAST_STATUS = '55' AND A.FILE_SEND_STS = '1' THEN '취소처리중'
		ELSE CD.CMM_CD_NM
		 END AS LAST_STATUS                        /* 처리상태 */
	, A.END_DATETIME                                  /* 처리완료일시 */
	, NVL(A.REGI_CNT,'0') REGI_CNT                    /* 등록건수(총건수) */
	, NVL(A.REGI_AMT,'0') || '' AS REGI_AMT           /* 총금액 */
	, NVL(A.NOR_CNT,'0') NOR_CNT                      /* 정상건수 */
	, NVL(A.NOR_AMT,'0') || '' AS NOR_AMT             /* 정상금액 */
	, NVL(A.ERR_CNT,'0') ERR_CNT                      /* 오류건수 */
	, NVL(A.ERR_AMT,'0') || '' AS ERR_AMT             /* 오류금액 */
FROM AP_IF_RCPTINFMMAST$ A
	, FN_ACCT B
	, BA_BANK BK
	, BA_BANK BK2
	, DWC_CMM_CODE CD
	, BA_USER_GRP_ACCT_A001_V V
WHERE A.SAN_WORK_GB IN ( '350' )
	AND A.BANK_CD      = BK.BANK_CD(+)
	AND DWC_CRYPT.decrypt(A.MTACT_NO) = B.ACCT_NO
	AND A.RCPT_INTT_CD = BK2.BANK_CD(+)
	AND A.LAST_STATUS  = CD.CMM_CD(+)
	AND CD.GRP_CD(+)  = 'S043'
	AND NVL(B.ACCT_SEQ, 'NOT') = V.ACCT_SEQ
	AND V.USER_ID      = 'SYSTEMADMIN'
	AND EXISTS (SELECT '1'
			 FROM AP_IF_RCPTINFMSUB B
			WHERE A.SVC_DIST  = B.SVC_DIST
			  AND A.REGI_NUM  = B.REGI_NUM
			  AND A.REGI_DATE = B.REGI_DATE
			  AND A.REGI_TIME = B.REGI_TIME)
	AND A.REGI_DATE BETWEEN '20230901' and '20230930'
	AND A.END_GB NOT IN ('0')
ORDER BY A.REGI_DATE DESC, A.END_DATETIME DESC,  A.SVC_DIST, A.DMND_DATE DESC, A.REGI_NUM, A.REGI_TIME
;



-- 즉시출금 이체수납 > 즉시출금 수납결과 조회 > 상세조회
SELECT
	A.AP_IF_RCPTINFMSUB_PNO AS PNO             /* 일련번호 */
	, A.REGI_NUM                                 /* 거래등록일련번호 */
	, A.REGI_DATE                                /* 이체실행일자 */
	, A.REGI_TIME                                /* 이체실행시간 */
	, A.SVC_DIST                                 /* 시스템구분 */
	, A.REGI_SEQ                                 /* 상세일련번호 */
	, A.RCPT_ACCT_APDS                           /* 수납계좌신청구분코드 */
	, DECODE(A.RCPT_ACCT_APDS, '1', '신규', '2', '해지', '3', '해지', '7', '임의해지') as REQUEST_GBN   /* 수납계좌신청구분 */
	, A.OUT_BANK_CD                              /* 은행코드 */
	, CASE A.OUT_BANK_CD WHEN '10000010'
					 THEN '농협'
					 ELSE BK.BANK_NM
				 END AS BANK_NM              /* 은행명 */
	, A.OUT_ACCT_NO                              /* 출금계좌 */
	, FN_ACCT_FORMAT(A.OUT_BANK_CD, A.OUT_ACCT_NO) AS ACCT_NO_FORMAT  /* 계좌번호 포맷 */
	, A.IN_RMK                   /* 출금통장인자내역 */
	, A.TRAN_AMT || '' AS TRAN_AMT                 /* 원화요청금액 */
	, A.REAL_TRAN_AMT || '' AS REAL_TRAN_AMT       /* 실처리금액 */
	, A.TRAN_FEE || '' AS TRAN_FEE                 /* 원화요청금액 */
	, A.REGI_REF_NM              /* 예금주 */
	, CASE A.END_GB WHEN '5' THEN SUBSTR(A.RRNO,0,6) || '-' ||  SUBSTR(A.RRNO,7,8)
				ELSE SUBSTR(A.RRNO,0,6) || '-' ||  SUBSTR(A.RRNO,7,1)||'******' END AS RRNO  /* 주민번호 */
	, A.RRNO AS REAL_RRNO
	, CASE A.RRNO WHEN A.PAYER_NO1 THEN SUBSTR(A.RRNO,0,7)||'******'
			  ELSE A.PAYER_NO1 END PAYER_NO1  /* 납부자번호 */
	, A.END_GB                   /* 처리완료여부 */
	, DECODE(A.END_GB,'0','미완료','1','정상','2','처리중','5','오류','4','재처리건반송') as END_GB_TEXT
	, A.PROC_STS                 /* 처리결과코드 */
	, CASE WHEN B.SAN_WORK_GB IN ('300', '310', '360', '350') THEN F_ERR_MSG(B.BANK_CD,A.PROC_STS,'1', NVL(A.ORG_CD,'COOCON'))
	   ELSE F_ERR_MSG(DECODE(SUBSTR(B.SAN_WORK_GB,1,2),'EB','10000099',B.BANK_CD),A.PROC_STS,'1',NVL(A.ORG_CD,'NCOM'))
	   END AS PROC_STS_TEXT  /* 처리결과 */
FROM AP_IF_RCPTINFMSUB A
	, AP_IF_RCPTINFMMAST B
	, BA_BANK BK
WHERE 1 = 1
	AND A.OUT_BANK_CD = BK.BANK_CD(+)
	AND A.REGI_NUM    = B.REGI_NUM
	AND A.REGI_DATE   = B.REGI_DATE
	AND A.REGI_TIME   = B.REGI_TIME
	AND A.SVC_DIST    = B.SVC_DIST
	AND A.REGI_NUM    = '2000070494'
	AND A.REGI_DATE   = '20230907'
	AND A.REGI_TIME   = '171957'
	AND A.SVC_DIST    = 'INS'
ORDER BY A.REGI_SEQ ASC
;

















