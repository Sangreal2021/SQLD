
-- 자금집금 > 집금실행 > 집금업무선택 > 목록조회
SELECT D.CA_COLL_MNG_PNO AS PNO
     , A.AUTH_GRP_CD
     , A.GRP_NM
     , A.GRP_CNTN
     , D.COLL_CD                    /*집금코드*/
     , D.COLL_NM
     , D.ACCT_SEQ
     , F.ACCT_NO
     , FN_ACCT_FORMAT(F.BANK_CD , F.ACCT_NO) as FORMAT_ACCT_NO
     , F.CUR_AMT || '' AS CUR_AMT               /*현재잔액*/
     , F.REAL_AMT || '' AS REAL_AMT             /*인출가능잔액*/
     , F.MOD_DT
     , F.BANK_CD
     , BK.BANK_NM                    /*은행명 */
     , F.ACCT_BAL_LST_DT             /*잔액최종조회일시*/
     , F.ACCT_HIS_LST_DATE           /*최종거래내역일자*/
     , NVL(D.RESVE_SET_YN, 'N') AS RESVE_SET_YN /*예약여부*/
     , D.COLL_EXE_DT_CD              /*집금실행일구분코드  */
     , D.RESVE_SET_TIME              /*예약시간  */
     , D.REMARK_CD                   /*적요코드  */
     , C.CMM_CD_NM AS REMARK_CD_NM   /*적용코드명*/
     , NVL(E.EXE_YN, 'N') AS EXE_YN  /*실행여부  */
     , DECODE(E.EXE_YN, 'Y', '완료', '미완료') AS EXE_YN_NM
     , CASE WHEN NVL(D.RESVE_SET_YN, 'N') = 'N' THEN '즉시' ELSE '예약' END AS RESVE_SET_YN_NM
     , F.FIRM_CD
FROM DWC_GRP_MSTR     A
     , DWC_CMM_CODE     C
     , CA_COLL_MNG      D /*자금집금모계좌 정보*/
     , (
        SELECT DECODE(COUNT(*), 0, 'N', 'Y') AS EXE_YN
             , COLL_CD
          FROM APP_APPR_COLL_TRAN_MAST
         WHERE COLL_APPR_GB = 'C'
           AND TRAN_SET_DATE = TO_CHAR(SYSDATE, 'YYYYMMDD')
         GROUP BY COLL_CD
        ) E
     , FN_ACCT          F /*계좌*/
     , BA_BANK          BK
     , CA_GRP_USER_COLL_A001_V V1
     , BA_USER_GRP_ACCT_A001_V V2
WHERE D.COLL_CD      = E.COLL_CD(+)
   AND A.AUTH_TYPE    = '3'
   AND A.USE_YN       = 'Y'
   AND D.USE_YN       = 'Y'
   AND F.ACCT_SEQ     = D.ACCT_SEQ
   AND V1.AUTH_GRP_CD = A.AUTH_GRP_CD
   AND D.COLL_CD      = V1.COLL_CD
   AND F.USE_YN       = 'Y'
   AND F.DEL_YN       = 'N'
   AND NVL(F.ACCT_SEQ, 'NOT') = V2.ACCT_SEQ
   AND V1.USER_ID     = 'SYSTEMADMIN'
   AND V2.USER_ID     = 'ADMIN'
   AND F.BANK_CD      = BK.BANK_CD(+)
   AND D.REMARK_CD    = C.CMM_CD(+)
   AND C.GRP_CD(+)    = 'KT010'
   AND A.GRP_GB       = 'TOBE'
 ORDER BY A.GRP_NM, A.AUTH_GRP_CD
;


-- 집금실행 > 집금대상설정 > 목록조회
SELECT T1.CA_COLL_DTL_PNO AS PNO
     , T1.IN_ACCT_SEQ       /*입금은행계좌일련번호*/
     , T1.COLL_NM
     , T1.IN_BANK_CD            /*입금은행코드:결제이체상세등록항목*/
     , T1.IN_ACCT_NO            /*입금계좌번호:결제이체상세등록항목*/
     , T1.IN_BIZ_NO             /*입금계좌사업장코드:결제이체상세등록항목*/
     , NVL(T1.IN_ACCT_RMK, substr(T1.ACCT_NICK_NM,1,7)) AS IN_RMK /*입금계좌인자내역:결제이체상세등록항목*/
     , T1.BANK_CD AS OUT_BANK_CD  /*출금은행코드:결제이체상세등록항목*/
     , T1.ACCT_NO AS OUT_ACCT_NO  /*출금계좌번호:결제이체상세등록항목*/
     , T1.BIZ_NO AS OUT_BIZ_NO    /*출금계좌사업장코드:결제이체상세등록항목*/
     , NVL(T1.OUT_ACCT_RMK, substr(T1.IN_ACCT_NICK_NM,1,7)) AS OUT_RMK /*출금계좌인자내역:결제이체상세등록항목*/
     , T1.COLL_CD           /*집금코드*/
     , T1.ACCT_SEQ          /*출금계좌일련번호*/
     , T1.COLL_TYPE         /*집금방식*/
     , T1.COLL_TYPE_NM
     , T1.FIX_AMT || '' AS FIX_AMT           /*일정금액*/
     , T1.ONCE_TRAN_LMT || '' AS ONCE_TRAN_LMT     /*1회이체한도*/
     , T1.IN_ACCT_RMK_FRML  /*입금계좌적요방식*/
     , T1.IN_ACCT_RMK       /*입금계좌적요*/
     , T1.OUT_ACCT_RMK_FRML /*출금계좌적요방식*/
     , T1.OUT_ACCT_RMK      /*출금계좌적요*/
     , T1.ACCT_TYPE         /*계좌종류구분*/
     , T1.ACCT_TYPE_NM      /*계좌분류명 */
     , T1.BANK_CD           /*금융기관코드*/
     , T1.BANK_NM           /* 은행명 */
     , T1.BRN_CD            /*지점코드*/
     , T1.ACCT_NO           /*계좌번호*/
     , FN_ACCT_FORMAT(T1.BANK_CD, T1.ACCT_NO) as FORMAT_ACCT_NO
     , T1.CUR_AMT || '' AS CUR_AMT           /*현재잔액*/
     , T1.REAL_AMT || '' AS REAL_AMT         /*인출가능잔액*/
     , T1.ACCT_NICK_NM      /*계좌별칭*/
     , T1.ACCT_BAL_LST_DT   /*잔액최종조회일시*/
     , T1.ACCT_HIS_LST_DATE /*최종거래내역일자*/
     , T1.COLL_EXEC_AMT || '' AS TRAN_AMT  /*집금실행금액(=원화이체금액):결제이체상세등록항목*/
     , T1.CUR_AMT-T1.COLL_EXEC_AMT || '' AS COLL_AF_AMT /*집금후잔액*/
     , T1.ERR_MSG           /*잔액조회결과메세지*/
     , T1.BANK_DISP_SEQ
     , '실행일 인출 가능 금액' AS RESVE_AMT
     , T1.FIRM_CD
  FROM (
        SELECT A.CA_COLL_DTL_PNO
             , IV1.IN_ACCT_SEQ     /*입금계좌일련번호*/
             , IV1.COLL_NM
             , IV1.IN_BANK_CD      /*입금은행코드*/
             , IV1.IN_ACCT_NO      /*입금계좌번호*/
             , IV1.IN_BIZ_NO       /*입금계좌사업장코드*/
             , IV1.IN_ACCT_NICK_NM
             , A.COLL_CD           /*집금코드*/
             , A.ACCT_SEQ          /*출금계좌일련번호*/
             , A.COLL_TYPE         /*집금방식*/
             , CD1.CD_DESC AS COLL_TYPE_NM
             , A.FIX_AMT           /*일정금액*/
             , A.ONCE_TRAN_LMT     /*1회이체한도*/
             , A.IN_ACCT_RMK_FRML  /*입금계좌적요방식*/
             , A.IN_ACCT_RMK       /*입금계좌적요*/
             , A.OUT_ACCT_RMK_FRML /*출금계좌적요방식*/
             , A.OUT_ACCT_RMK      /*출금계좌적요*/
             , B.ACCT_TYPE         /*계좌종류구분*/
             , CD2.CD_DESC AS ACCT_TYPE_NM /* 계좌분류명 */
             , B.BANK_CD           /*금융기관코드*/
             , CD3.SORT_NUM AS BANK_DISP_SEQ
             , D.BANK_NM /* 은행명 */
             , B.BRN_CD            /*지점코드*/
             , B.ACCT_NO           /*계좌번호*/
             , NVL(B.CUR_AMT,0) AS CUR_AMT       /*현재잔액*/
             , NVL(B.REAL_AMT,0) as REAL_AMT     /*인출가능잔액*/
             , B.ACCT_NICK_NM      /*계좌별칭*/
             , B.BIZ_NO
             , B.ACCT_BAL_LST_DT   /*잔액최종조회일시*/
             , B.ACCT_HIS_LST_DATE /*최종거래내역일자*/
             , CASE WHEN NVL(IV1.RESVE_SET_YN, 'N') = 'Y' THEN 0 ELSE
                       DECODE(A.COLL_TYPE, '5', DECODE(SIGN(NVL(B.REAL_AMT,0)-10000)   , -1, 0, FLOOR(NVL(B.REAL_AMT,0)/10000   )*10000   ) /*만원이상*/
                                         , '6', DECODE(SIGN(NVL(B.REAL_AMT,0)-100000)  , -1, 0, FLOOR(NVL(B.REAL_AMT,0)/100000  )*100000  ) /*십만원이상*/
                                         , '7', DECODE(SIGN(NVL(B.REAL_AMT,0)-1000000) , -1, 0, FLOOR(NVL(B.REAL_AMT,0)/1000000 )*1000000 ) /*백만원이상*/
                                         , '8', DECODE(SIGN(NVL(B.REAL_AMT,0)-10000000), -1, 0, FLOOR(NVL(B.REAL_AMT,0)/10000000)*10000000) /*천만원이상*/
                                         , '9', DECODE(SIGN(NVL(B.REAL_AMT,0)-NVL(A.FIX_AMT,0)), -1, 0, NVL(B.REAL_AMT,0)-NVL(A.FIX_AMT,0)) /*일정잔액유지*/
                                         , '10',DECODE(SIGN(NVL(B.REAL_AMT,0)-NVL(A.FIX_AMT,0)), -1, 0, NVL(A.FIX_AMT,0)) /*일정금액집금*/
                                         , '0', DECODE(SIGN(NVL(B.REAL_AMT,0)), -1, 0, NVL(B.REAL_AMT,0)) /*인출가능잔액전액*/
                                         )
                     END AS COLL_EXEC_AMT /*집금실행금액*/
             , B.ACCT_BAL_LST_MSG AS ERR_MSG
             , B.FIRM_CD
          FROM (
                SELECT A.COLL_CD
                     , A.USE_YN
                     , A.ACCT_SEQ  AS IN_ACCT_SEQ
                     , A.COLL_NM
                     , B.BANK_CD   AS IN_BANK_CD
                     , B.ACCT_NO   AS IN_ACCT_NO
                     , B.BIZ_NO    AS IN_BIZ_NO
                     , B.ACCT_NICK_NM AS IN_ACCT_NICK_NM
                     , A.RESVE_SET_YN
                  FROM CA_COLL_MNG A
                     , FN_ACCT     B
                 WHERE B.ACCT_SEQ  = A.ACCT_SEQ
                   AND B.USE_YN    = 'Y'
                   AND B.DEL_YN    = 'N'
                   AND A.COLL_CD   = '01'
                    ) IV1
             , CA_COLL_DTL      A
             , FN_ACCT          B
             , BA_BANK          D
             , DWC_CMM_CODE     CD1
             , DWC_CMM_CODE     CD2
             , DWC_CMM_CODE     CD3
         WHERE B.ACCT_SEQ    = A.ACCT_SEQ
           AND B.USE_YN      = 'Y'
           AND B.DEL_YN      = 'N'
           AND A.COLL_CD     = IV1.COLL_CD
           AND CD1.CMM_CD(+) = A.COLL_TYPE
           AND CD1.GRP_CD(+) = 'S026'
           AND CD2.CMM_CD(+) = B.ACCT_TYPE
           AND CD2.GRP_CD(+) = 'S010'
           AND CD3.CMM_CD(+) = B.BANK_CD
           AND CD3.GRP_CD(+) = 'S001'
           AND B.BANK_CD     = D.BANK_CD(+)
     ) T1
ORDER BY T1.BANK_DISP_SEQ, T1.ACCT_NO
;


-- 집금결과조회 > 목록조회
SELECT
       TB2.PNO
     , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.PI_ID END AS PI_ID
     , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.COLL_APPR_GB END AS COLL_APPR_GB
     , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.COLL_CD END AS COLL_CD
     , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.APPR_CD END AS APPR_CD
     , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.TRAN_SET_DATE END AS TRAN_SET_DATE
     , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.TRAN_SET_TIME END AS TRAN_SET_TIME
     , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.COLL_NM END AS COLL_NM
     , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.CMS_ACCT_NO END AS CMS_ACCT_NO
     , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.BANK_NM END AS BANK_NM
     , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.END_GB END AS END_GB
     , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.END_GB_NM END AS END_GB_NM
     , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.ACCT_SEQ END AS ACCT_SEQ
     , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.LAST_STATUS END AS LAST_STATUS
     , CASE WHEN TB2.GINFO = 1 THEN '' ELSE ''||TB2.REGI_CNT END AS REGI_CNT
     , TB2.REGI_AMT || '' AS REGI_AMT
     , CASE WHEN TB2.GINFO = 1 THEN '' ELSE ''||TB2.NOR_CNT END AS NOR_CNT
     , CASE WHEN TB2.GINFO = 1 THEN '' ELSE ''||TB2.NOR_AMT END AS NOR_AMT
     , CASE WHEN TB2.GINFO = 1 THEN '' ELSE ''||TB2.ERR_CNT END AS ERR_CNT
     , CASE WHEN TB2.GINFO = 1 THEN '' ELSE ''||TB2.ERR_AMT END AS ERR_AMT
     , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.ACCT_NICK_NM END AS ACCT_NICK_NM
     , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.RESVE_SET_YN END AS RESVE_SET_YN
     , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.RESVE_SET_YN_NM END AS RESVE_SET_YN_NM
     , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.RESVE_SET_DATE END AS RESVE_SET_DATE
     , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.RESVE_SET_TIME END AS RESVE_SET_TIME
     , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.WORK_GB_NM END AS WORK_GB_NM
     , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.VOTE_NO END AS VOTE_NO
     , TB2.GINFO
  FROM(
    SELECT
           TB.PNO
         , MAX(TB.PI_ID) AS PI_ID
         , MAX(TB.COLL_APPR_GB) AS COLL_APPR_GB
         , MAX(TB.COLL_CD) AS COLL_CD
         , MAX(TB.APPR_CD) AS APPR_CD
         , MAX(TB.TRAN_SET_DATE) AS TRAN_SET_DATE
         , MAX(TB.TRAN_SET_TIME) AS TRAN_SET_TIME
         , MAX(TB.COLL_NM) AS COLL_NM
         , MAX(TB.CMS_ACCT_NO) AS CMS_ACCT_NO
         , MAX(TB.BANK_NM) AS BANK_NM
         , MAX(TB.END_GB) AS END_GB
         , MAX(TB.END_GB_NM) AS END_GB_NM
         , MAX(TB.ACCT_SEQ) AS ACCT_SEQ
         , MAX(TB.LAST_STATUS) AS LAST_STATUS
         , MAX(TB.REGI_CNT) AS REGI_CNT
         , SUM(REGI_AMT) AS REGI_AMT
         , MAX(TB.NOR_CNT) AS NOR_CNT
         , MAX(TB.NOR_AMT) AS NOR_AMT
         , MAX(TB.ERR_CNT) AS ERR_CNT
         , MAX(TB.ERR_AMT) AS ERR_AMT
         , MAX(TB.ACCT_NICK_NM) AS ACCT_NICK_NM
         , MAX(TB.RESVE_SET_YN) AS RESVE_SET_YN
         , MAX(TB.RESVE_SET_YN_NM) AS RESVE_SET_YN_NM
         , MAX(TB.RESVE_SET_DATE) AS RESVE_SET_DATE
         , MAX(TB.RESVE_SET_TIME) AS RESVE_SET_TIME
         , MAX(TB.WORK_GB_NM) AS WORK_GB_NM
         , MAX(TB.VOTE_NO) AS VOTE_NO
         , GROUPING(TB.PNO) AS GINFO
          FROM (
            SELECT A.APP_APPR_COLL_TRAN_MAST_PNO AS PNO
                 , A.PI_ID
                 , A.COLL_APPR_GB
                 , A.COLL_CD
                 , A.APPR_CD
                 , A.TRAN_SET_DATE
                 , A.TRAN_SET_TIME
                 , B.COLL_NM
                 , FN_ACCT_FORMAT(C.BANK_CD , C.ACCT_NO) AS CMS_ACCT_NO
                 , D.BANK_NM
                 , A.END_GB
                 , CD1.CD_DESC AS END_GB_NM
                 , A.ACCT_SEQ
                 , A.LAST_STATUS
                 , A.REGI_CNT
                 , A.REGI_AMT
                 , A.NOR_CNT
                 , A.NOR_AMT
                 , A.ERR_CNT
                 , A.ERR_AMT
                 , C.ACCT_NICK_NM
                 , A.RESVE_SET_YN
                 , DECODE(A.RESVE_SET_YN, 'Y', '예약', '즉시') AS RESVE_SET_YN_NM
                 , A.RESVE_SET_DATE
                 , A.RESVE_SET_TIME
                 , A.TRAD_GB
                 , CD2.CMM_CD_NM AS WORK_GB_NM
                 , A.VOTE_NO
              FROM APP_APPR_COLL_TRAN_MAST A
                 , CA_COLL_MNG             B
                 , FN_ACCT                 C
                 , BA_BANK                 D
                 , DWC_CMM_CODE            CD1
                 , DWC_CMM_CODE            CD2
                 , BA_USER_GRP_ACCT_A001_V V1
                 , CA_GRP_USER_COLL_A001_V V2
             WHERE 1 = 1
               AND A.COLL_CD      = B.COLL_CD
               AND A.ACCT_SEQ     = C.ACCT_SEQ
               AND C.BANK_CD      = D.BANK_CD(+)
               AND A.END_GB       = CD1.CMM_CD(+)
               AND CD1.GRP_CD(+)  = 'S045'
               AND A.TRAD_GB      = CD2.CMM_CD(+)
               AND CD2.GRP_CD(+)  = 'S107'
               AND NVL(A.ACCT_SEQ, 'NOT') = V1.ACCT_SEQ
               AND B.COLL_CD      = V2.COLL_CD
               AND V1.USER_ID     = 'SYSTEMADMIN'
               AND V2.USER_ID     = 'SYSTEMADMIN'
               AND B.USE_YN       = 'Y'
               AND A.LAST_STATUS IN ('20','30','31','51', '52')
               AND A.COLL_APPR_GB = 'C'
--             AND A.TRAN_SET_DATE BETWEEN '20240222' and '20240222'
            ) TB
            GROUP BY ROLLUP(PNO)
        ) TB2
ORDER BY TB2.GINFO, TB2.TRAN_SET_DATE DESC, NVL(TB2.TRAN_SET_TIME, '000000') DESC, TB2.PNO DESC
;



CMS_P_CHECK_VA_TRAN

CMS_P_INSERT_VA_TRAN

SELECT * FROM AP_IF_RCPTINFMMAST 
WHERE SAN_WORK_GB = '360' AND LAST_STATUS = '52'
;

SELECT * FROM AP_IF_RCPTPROOFSUB 
WHERE PROOF_DATA IS NOT NULL;


-- 집금결과조회 > 상세목록조회
SELECT
       ROWNUM AS PNO
     , CASE WHEN TB2.GINFO = 1 THEN '' ELSE ''||TB2.PI_ID END AS PI_ID
     , CASE WHEN TB2.GINFO = 1 THEN '' ELSE ''||TB2.REGI_SEQ END AS REGI_SEQ
     , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.ACCT_SEQ END AS ACCT_SEQ
     , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.BANK_CD END AS BANK_CD
     , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.BANK_NM END AS BANK_NM
     , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.ACCT_NO END AS ACCT_NO
     , TB2.TRAN_AMT || '' AS TRAN_AMT
     , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.END_GB END AS END_GB
     , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.END_GB_NM END AS END_GB_NM
     , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.TRAN_DATE END AS TRAN_DATE
     , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.TRAN_TIME END AS TRAN_TIME
     , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.TRAN_DATE||TB2.TRAN_TIME END AS TRAN_DT
     , TB2.TRAN_FEE || '' AS TRAN_FEE
     , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.PROC_STS END AS PROC_STS
     , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.PROC_STS_NM END AS PROC_STS_NM
     , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.ACCT_NICK_NM END AS ACCT_NICK_NM
     , TB2.GINFO
  FROM(
       SELECT
               MAX(TB.PI_ID) AS PI_ID
             , MAX(TB.REGI_SEQ) AS REGI_SEQ
             , MAX(TB.ACCT_SEQ) AS ACCT_SEQ
             , MAX(TB.BANK_CD) AS BANK_CD
             , MAX(TB.BANK_NM) AS BANK_NM
             , MAX(TB.ACCT_NO) AS ACCT_NO
             , SUM(TRAN_AMT) AS TRAN_AMT
             , MAX(TB.END_GB) AS END_GB
             , MAX(TB.END_GB_NM) AS END_GB_NM
             , MAX(TB.TRAN_DATE) AS TRAN_DATE
             , MAX(TB.TRAN_TIME) AS TRAN_TIME
             , SUM(TRAN_FEE) AS TRAN_FEE
             , MAX(TB.PROC_STS) AS PROC_STS
             , MAX(TB.PROC_STS_NM) AS PROC_STS_NM
             , MAX(TB.ACCT_NICK_NM) AS ACCT_NICK_NM
             , GROUPING(TB.REGI_SEQ) AS GINFO
          FROM (
                SELECT
                       A.PI_ID     /* 프로세스 인스턴스ID */
                     , A.REGI_SEQ  /* 상세일련번호        */
                     , A.ACCT_SEQ  /* 출금계좌일련번호    */
                     , C.BANK_CD   /* 은행코드    */
                     , D.BANK_NM   /* 은행명    */
                     , FN_ACCT_FORMAT(C.BANK_CD , C.ACCT_NO) AS ACCT_NO
                     , A.TRAN_AMT  /* 원화이체금액        */
                     , A.END_GB    /* 작업완료구분        */
                     , CODE.CD_DESC AS END_GB_NM /* 작업완료구분명        */
                     , A.TRAN_DATE /* 이체실행일자        */
                     , A.TRAN_TIME /* 이체실행시간        */
                     , A.TRAN_FEE  /* 원화이체수수료      */
                     , A.PROC_STS  /* 처리결과코드        */
                     , F_ERR_MSG(C.BANK_CD, A.PROC_STS, 2, A.ORG_CD) AS PROC_STS_NM /* 처리결과명        */
                     , C.ACCT_NICK_NM /* 계좌별칭        */
                  FROM APP_APPR_COLL_TRAN_DETAIL A
                     , FN_ACCT       C
                     , BA_BANK       D
                     , DWC_CMM_CODE  CODE
                 WHERE 1 = 1
                   AND A.ACCT_SEQ = C.ACCT_SEQ
                   AND C.BANK_CD = D.BANK_CD(+)
                   AND A.END_GB = CODE.CMM_CD(+)
                   AND CODE.GRP_CD(+) = 'S049'
                   AND A.PI_ID = '20231219_1544066'
            ) TB
            GROUP BY ROLLUP(REGI_SEQ)
        ) TB2
ORDER BY TB2.GINFO, TO_NUMBER(TB2.REGI_SEQ)
;


-- 배분실행 > 배분업무선택 > 목록조회
SELECT A.CA_APPR_DTL_PNO AS PNO
	 , IV1.OUT_ACCT_SEQ     /*출금계좌일련번호*/
	 , IV1.APPR_NM
	 , IV1.OUT_BANK_CD      /*출금은행코드:결제이체상세등록항목*/
	 , IV1.OUT_ACCT_NO      /*출금계좌번호:결제이체상세등록항목*/
	 , IV1.OUT_BIZ_NO       /*출금계좌사업장코드:결제이체상세등록항목*/
	 , NVL(A.OUT_ACCT_RMK, substr(B.ACCT_NICK_NM,1,7)) AS OUT_RMK /*출금계좌인자내역:결제이체상세등록항목*/
	 , B.BANK_CD AS IN_BANK_CD /*입금은행코드:결제이체상세등록항목*/
	 , B.BIZ_NO AS IN_BIZ_NO   /*입금은행코드:결제이체상세등록항목*/
	 , B.ACCT_NO AS IN_ACCT_NO /*입금계좌사업장코드:결제이체상세등록항목*/
	 , NVL(A.IN_ACCT_RMK, substr(IV1.OUT_ACCT_NICK_NM,1,7)) AS IN_RMK /*입금계좌인자내역:결제이체상세등록항목*/
	 , A.APPR_CD           /*배분코드*/
	 , A.ACCT_SEQ          /*출금계좌일련번호*/
	 , A.CUR_LMT           /*자금한도*/
	 , A.IN_ACCT_RMK_FRML  /*입금계좌적요방식*/
	 , A.IN_ACCT_RMK       /*입금계좌적요*/
	 , A.OUT_ACCT_RMK_FRML /*출금계좌적요방식*/
	 , A.OUT_ACCT_RMK      /*출금계좌적요*/
	 , B.ACCT_TYPE         /*계좌종류구분*/
	 , CD1.CD_DESC AS ACCT_TYPE_NM /* 계좌분류명 */
	 , B.BANK_CD           /*금융기관코드*/
	 , D.BANK_NM AS BANK_NM /* 은행명 */
	 , B.BRN_CD            /*지점코드*/
	 , B.ACCT_NO           /*계좌번호*/
	 , FN_ACCT_FORMAT(B.BANK_CD , B.ACCT_NO) as FORMAT_ACCT_NO
	 , NVL(B.CUR_AMT , 0) || '' AS CUR_AMT /*현재잔액*/
	 , NVL(B.REAL_AMT, 0) || '' AS REAL_AMT /*인출가능잔액*/
	 , 0                AS TRAN_AMT  /*배분실행금액(=원화이체금액):결제이체상세등록항목*/
	 , B.ACCT_NICK_NM      /*계좌별칭*/
	 , B.ACCT_BAL_LST_DT   /*잔액최종조회일시*/
	 , B.ACCT_HIS_LST_DATE /*최종거래내역일자*/
	 , CD2.SORT_NUM AS BANK_DISP_SEQ
	 , B.ACCT_CUST_NM      /*예금주명*/
	 , IV1.FIRM_CD
FROM (SELECT A.APPR_CD
             , A.USE_YN
             , A.ACCT_SEQ  AS OUT_ACCT_SEQ
             , A.APPR_NM
             , B.BANK_CD   AS OUT_BANK_CD
             , B.ACCT_NO   AS OUT_ACCT_NO
             , B.BIZ_NO    AS OUT_BIZ_NO
             , B.ACCT_NICK_NM AS OUT_ACCT_NICK_NM
             , B.FIRM_CD
          FROM CA_APPR_MNG A
             , FN_ACCT     B
         WHERE B.ACCT_SEQ  = A.ACCT_SEQ
           AND B.USE_YN    = 'Y'
       AND B.DEL_YN    = 'N'
       AND A.APPR_CD   = 'KK04'
         ) IV1
     , CA_APPR_DTL      A
     , FN_ACCT          B
     , BA_BANK          D
     , DWC_CMM_CODE     CD1
     , DWC_CMM_CODE     CD2
WHERE B.ACCT_SEQ   = A.ACCT_SEQ
	   AND B.USE_YN     = 'Y'
	   AND B.DEL_YN     = 'N'
	   AND A.APPR_CD    = IV1.APPR_CD
	   AND B.BANK_CD = D.BANK_CD(+)
	   AND CD1.CMM_CD(+) = B.ACCT_TYPE
	   AND CD1.GRP_CD(+) = 'S010'
	   AND CD2.CMM_CD(+) = B.BANK_CD
	   AND CD2.GRP_CD(+) = 'S001'
ORDER BY BANK_DISP_SEQ, B.ACCT_NO
;



-- 자금배분 > 배분결과조회
SELECT
	   CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.PNO||'' END AS PNO
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.PI_ID END AS PI_ID
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.COLL_APPR_GB END AS COLL_APPR_GB
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.COLL_CD END AS COLL_CD
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.APPR_CD END AS APPR_CD
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.TRAN_SET_DATE END AS TRAN_SET_DATE
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.TRAN_SET_TIME END AS TRAN_SET_TIME
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.APPR_NM END AS APPR_NM
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.CMS_ACCT_NO END AS CMS_ACCT_NO
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.BANK_NM END AS BANK_NM
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.END_GB END AS END_GB
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.END_GB_NM END AS END_GB_NM
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.ACCT_SEQ END AS ACCT_SEQ
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.LAST_STATUS END AS LAST_STATUS
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE ''||TB2.REGI_CNT END AS REGI_CNT
	 , TB2.REGI_AMT || '' AS REGI_AMT
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE ''||TB2.NOR_CNT END AS NOR_CNT
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE ''||TB2.NOR_AMT END AS NOR_AMT
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE ''||TB2.ERR_CNT END AS ERR_CNT
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE ''||TB2.ERR_AMT END AS ERR_AMT
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.ACCT_NICK_NM END AS ACCT_NICK_NM
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.ERR_MSG END AS ERR_MSG
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.RETRAN_COMPT_YN END AS RETRAN_COMPT_YN
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.RETRAN_POSIBLE_YN END AS RETRAN_POSIBLE_YN
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.BRIEF_TITLE END AS BRIEF_TITLE
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.VOTE_NO END AS VOTE_NO
	 , TB2.GINFO
FROM(
	SELECT
		   TB.PNO
		 , MAX(TB.PI_ID) AS PI_ID
		 , MAX(TB.COLL_APPR_GB) AS COLL_APPR_GB
		 , MAX(TB.COLL_CD) AS COLL_CD
		 , MAX(TB.APPR_CD) AS APPR_CD
		 , MAX(TB.TRAN_SET_DATE) AS TRAN_SET_DATE
		 , MAX(TB.TRAN_SET_TIME) AS TRAN_SET_TIME
		 , MAX(TB.APPR_NM) AS APPR_NM
		 , MAX(TB.CMS_ACCT_NO) AS CMS_ACCT_NO
		 , MAX(TB.BANK_NM) AS BANK_NM
		 , MAX(TB.END_GB) AS END_GB
		 , MAX(TB.END_GB_NM) AS END_GB_NM
		 , MAX(TB.ACCT_SEQ) AS ACCT_SEQ
		 , MAX(TB.LAST_STATUS) AS LAST_STATUS
		 , MAX(TB.REGI_CNT) AS REGI_CNT
		 , SUM(REGI_AMT) AS REGI_AMT
		 , MAX(TB.NOR_CNT) AS NOR_CNT
		 , MAX(TB.NOR_AMT) AS NOR_AMT
		 , MAX(TB.ERR_CNT) AS ERR_CNT
		 , MAX(TB.ERR_AMT) AS ERR_AMT
		 , MAX(TB.ACCT_NICK_NM) AS ACCT_NICK_NM
		 , MAX(TB.ERR_MSG) AS ERR_MSG
		 , MAX(TB.RETRAN_COMPT_YN) AS RETRAN_COMPT_YN
		 , MAX(TB.RETRAN_POSIBLE_YN) AS RETRAN_POSIBLE_YN
		 , MAX(TB.BRIEF_TITLE) AS BRIEF_TITLE
		 , MAX(TB.VOTE_NO) AS VOTE_NO
		 , GROUPING(TB.PNO) AS GINFO
	  FROM (
		   SELECT
				  E.APP_APPR_COLL_TRAN_DETAIL_PNO AS PNO
				, A.PI_ID
				, A.COLL_APPR_GB
				, A.COLL_CD
				, A.APPR_CD
				, A.TRAN_SET_DATE
				, A.TRAN_SET_TIME
				, B.APPR_NM
				, FN_ACCT_FORMAT(C.BANK_CD , C.ACCT_NO) AS CMS_ACCT_NO
				, D.BANK_NM
				, CASE
					   WHEN E.END_GB = '1' THEN '3'
					   WHEN E.END_GB = '5' THEN '4'
					   WHEN A.LAST_STATUS IN ('10', '15', '20') THEN '1'
					   WHEN A.LAST_STATUS IN ('30', '51') THEN '2'
					   WHEN A.LAST_STATUS IN ('55') THEN '5'
						END AS END_GB
				, CASE
					   WHEN E.END_GB = '1' THEN '배분완료'
					   WHEN E.END_GB = '5' THEN '오류'
					   WHEN A.LAST_STATUS IN ('10', '15', '20') THEN '결재중'
					   WHEN A.LAST_STATUS IN ('30', '51') THEN '배분중'
					   WHEN A.LAST_STATUS IN ('55') THEN '등록취소'
						END AS END_GB_NM
				 , A.ACCT_SEQ
				 , A.LAST_STATUS
				 , A.REGI_CNT
				 , A.REGI_AMT
				 , A.NOR_CNT
				 , A.NOR_AMT
				 , A.ERR_CNT
				 , A.ERR_AMT
				 , C.ACCT_NICK_NM
				 , F_ERR_MSG(F.BANK_CD, E.PROC_STS, '2', E.ORG_CD) AS ERR_MSG
				 , E.RETRAN_COMPT_YN
				 , CASE WHEN E.END_GB = '5' AND E.RETRAN_COMPT_YN = 'N' THEN 'Y' ELSE 'N' END AS RETRAN_POSIBLE_YN
				 , A.BRIEF_TITLE
				 , A.VOTE_NO
			  FROM APP_APPR_COLL_TRAN_MAST   A
				 , CA_APPR_MNG               B
				 , FN_ACCT                   C
				 , BA_BANK                   D
				 , APP_APPR_COLL_TRAN_DETAIL E
				 , FN_ACCT$                  F
				 , BA_USER_GRP_ACCT_A001_V   V1
				 , CA_GRP_USER_APPR_A001_V   V2
			 WHERE 1 = 1
			   AND A.PI_ID        = E.PI_ID
			   AND A.ACCT_SEQ     = F.ACCT_SEQ
			   AND A.APPR_CD      = B.APPR_CD
			   AND A.ACCT_SEQ     = C.ACCT_SEQ
			   AND C.BANK_CD      = D.BANK_CD(+)
			   AND NVL(A.ACCT_SEQ, 'NOT') = V1.ACCT_SEQ
			   AND B.APPR_CD      = V2.APPR_CD
			   AND V1.USER_ID     = 'SYSTEMADMIN'
			   AND V2.USER_ID     = 'SYSTEMADMIN'
			   AND B.USE_YN       = 'Y'
			   AND A.LAST_STATUS IN ('10', '15', '20','30','31','51', '52', '55')
			   AND A.COLL_APPR_GB = 'A'
			   AND A.TRAN_SET_DATE BETWEEN '20231101' and '20231131'
		) TB
		GROUP BY ROLLUP(TB.PNO)
	) TB2
ORDER BY GINFO, TB2.TRAN_SET_DATE DESC, TB2.TRAN_SET_TIME DESC, TB2.PNO DESC
;



-- 자금배분 > 배분결과조회 > 배분결과 상세조회
SELECT
	   ROWNUM AS PNO
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE ''||TB2.PI_ID END AS PI_ID
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE ''||TB2.REGI_SEQ END AS REGI_SEQ
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.ACCT_SEQ END AS ACCT_SEQ
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.BANK_CD END AS BANK_CD
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.BANK_NM END AS BANK_NM
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.ACCT_NO END AS ACCT_NO
	 , TB2.TRAN_AMT || '' AS TRAN_AMT
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.END_GB END AS END_GB
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.END_GB_NM END AS END_GB_NM
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.TRAN_DATE END AS TRAN_DATE
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.TRAN_TIME END AS TRAN_TIME
	 , TB2.TRAN_FEE || '' AS TRAN_FEE
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.PROC_STS END AS PROC_STS
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.PROC_STS_NM END AS PROC_STS_NM
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.ACCT_NICK_NM END AS ACCT_NICK_NM
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.RETRAN_COMPT_YN END AS RETRAN_COMPT_YN
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.TRAN_DT END AS TRAN_DT
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.IN_ACCT_RMK END AS IN_ACCT_RMK
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.OUT_ACCT_RMK END AS OUT_ACCT_RMK
	 , TB2.GINFO
  FROM(
	   SELECT
			   MAX(TB.PI_ID) AS PI_ID
			 , MAX(TB.REGI_SEQ) AS REGI_SEQ
			 , MAX(TB.ACCT_SEQ) AS ACCT_SEQ
			 , MAX(TB.BANK_CD) AS BANK_CD
			 , MAX(TB.BANK_NM) AS BANK_NM
			 , MAX(TB.ACCT_NO) AS ACCT_NO
			 , SUM(TRAN_AMT) AS TRAN_AMT
			 , MAX(TB.END_GB) AS END_GB
			 , MAX(TB.END_GB_NM) AS END_GB_NM
			 , MAX(TB.TRAN_DATE) AS TRAN_DATE
			 , MAX(TB.TRAN_TIME) AS TRAN_TIME
			 , SUM(TRAN_FEE) AS TRAN_FEE
			 , MAX(TB.PROC_STS) AS PROC_STS
			 , MAX(TB.PROC_STS_NM) AS PROC_STS_NM
			 , MAX(TB.ACCT_NICK_NM) AS ACCT_NICK_NM
			 , MAX(TB.RETRAN_COMPT_YN) AS RETRAN_COMPT_YN
			 , MAX(TB.TRAN_DT) AS TRAN_DT
			 , MAX(TB.IN_ACCT_RMK) AS IN_ACCT_RMK
			 , MAX(TB.OUT_ACCT_RMK) AS OUT_ACCT_RMK
			 , GROUPING(TB.REGI_SEQ) AS GINFO
		  FROM (
				SELECT
					   A.PI_ID     /* 프로세스 인스턴스ID */
					 , A.REGI_SEQ  /* 상세일련번호        */
					 , A.ACCT_SEQ  /* 출금계좌일련번호    */
					 , C.BANK_CD   /* 은행코드    */
					 , D.BANK_NM   /* 은행명    */
					 , FN_ACCT_FORMAT(C.BANK_CD , C.ACCT_NO) AS ACCT_NO
					 , A.TRAN_AMT  /* 원화이체금액        */
					 , A.END_GB    /* 작업완료구분        */
					 , CODE.CD_DESC AS END_GB_NM /* 작업완료구분명        */
					 , A.TRAN_DATE /* 이체실행일자        */
					 , A.TRAN_TIME /* 이체실행시간        */
					 , A.TRAN_FEE  /* 원화이체수수료      */
					 , A.PROC_STS  /* 처리결과코드        */
					 , F_ERR_MSG(C.BANK_CD, A.PROC_STS, 2, A.ORG_CD) AS PROC_STS_NM /* 처리결과명        */
					 , C.ACCT_NICK_NM /* 계좌별칭        */
					 , A.RETRAN_COMPT_YN /* 재전송완료여부 */
					 , A.TRAN_DATE||A.TRAN_TIME AS TRAN_DT/* 이체실행일시 */
					 , A.IN_ACCT_RMK  /* 입금계좌적요 */
					 , A.OUT_ACCT_RMK /* 출금계좌적요 */
				  FROM APP_APPR_COLL_TRAN_DETAIL A
					 , FN_ACCT       C
					 , BA_BANK       D
					 , DWC_CMM_CODE  CODE
				 WHERE 1 = 1
				   AND A.ACCT_SEQ = C.ACCT_SEQ
				   AND C.BANK_CD = D.BANK_CD(+)
				   AND A.END_GB = CODE.CMM_CD(+)
				   AND CODE.GRP_CD(+) = 'S049'
				   AND A.PI_ID = '20231127_462245'
			) TB
			GROUP BY ROLLUP(REGI_SEQ)
		) TB2
ORDER BY GINFO, TO_NUMBER(TB2.REGI_SEQ)
;



-- 직불계좌배분 > 자금통보 배분실행
SELECT
	   A.AP_INOG_FNDSNTCNMAST_PNO AS PNO
	 , A.REGI_DATE
	 , A.REG_USER_ID
	 , A.REGI_NUM
	 , A.DEPT_CD
	 , D.DEPT_NM
	 , OUT_BK.BANK_NM AS OUT_BANK_NM /* 출금은행명 */
	 , A.OUT_BANK_CD                 /* 출금은행코드 */
	 , A.OUT_ACCT_NO                 /* 출금계좌번호 */
	 , F.FIRM_CD AS OUT_FIRM_CD      /* 출금펌코드 */
	 , FN_ACCT_FORMAT(A.OUT_BANK_CD , A.OUT_ACCT_NO) AS FORMAT_OUT_ACCT_NO
	 , IN_BK.BANK_NM AS IN_BANK_NM   /* 입금은행명 */
	 , A.IN_BANK_CD                  /* 입금은행코드 */
	 , A.IN_ACCT_NO                  /* 입금계좌번호 */
	 , F_IN.FIRM_CD AS IN_FIRM_CD    /* 입금펌코드 */
	 , FN_ACCT_FORMAT(A.IN_BANK_CD , A.IN_ACCT_NO) AS FORMAT_IN_ACCT_NO
	 , F.CUR_AMT                     /*현재잔액*/
	 , F.REAL_AMT                    /*인출가능잔액*/
	 , F.ACCT_SEQ                    /*계좌일련번호*/
	 , F.ACCT_BAL_LST_MSG AS ERR_MSG /*에러메세지*/
	 , F.ACCT_BAL_LST_DT             /*잔액최종조회일시*/
	 , F.ACCT_HIS_LST_DATE           /*최종거래내역일자*/
	 , A.FILE_NM                     /*배분업무명*/
	 , A.INOG_AMT                    /*총 배분요청금액*/
	 , NVL(S.INOG_AMT, 0) AS EXE_INOG_AMT    /*배분확정금액*/
	 , NVL(S.CNT, 0) AS CNT                  /*배분건수*/
	 , A.LAST_STATUS
	 , C.CMM_CD_NM AS LAST_STATUS_TXT
	 , F_IN.ACCT_BAL_LST_DT AS IN_ACCT_BAL_LST_DT /*입금계좌잔액최종조회일시*/
	 , FB.TX_CUR_BAL                              /*입금계좌의 전일잔액*/
	 , F_IN.CUR_AMT AS IN_CUR_AMT                 /*현재잔액*/
	 , F_IN.REAL_AMT AS IN_REAL_AMT               /*인출가능잔액*/
	 , A.BRIEF_TITLE                              /*적요*/
	 , CASE WHEN A.LAST_STATUS = '52' THEN 'N' ELSE 'Y' END AS EXEC_YN /*자금통보 배분실행 가능여부 'Y'가능 'N'불가능*/
  FROM AP_INOG_FNDSNTCNMAST A
	 , (
			SELECT SUM(S.APPR_AMT) AS INOG_AMT
				 , COUNT('1')      AS CNT
				 , S.REGI_DATE
				 , S.REG_USER_ID
				 , S.REGI_NUM
			  FROM AP_INOG_FNDSNTCNSHR S
			 GROUP BY S.REGI_DATE, S.REG_USER_ID, S.REGI_NUM
	   )                    S
	 , BA_BANK              IN_BK
	 , BA_BANK              OUT_BK
	 , DWC_CMM_CODE         C
	 , DWC_DEPT_MSTR        D
	 , FN_ACCT              F
	 , FN_ACCT              F_IN
	 , FN_ACCT_DAY_BLCE     FB
 WHERE A.SAN_WORK_GB    = 'J10'
   AND A.REGI_DATE      = S.REGI_DATE(+)
   AND A.REG_USER_ID    = S.REG_USER_ID(+)
   AND A.REGI_NUM       = S.REGI_NUM(+)
   AND A.OUT_BANK_CD    = OUT_BK.BANK_CD(+)
   AND A.IN_BANK_CD     = IN_BK.BANK_CD(+)
   AND A.DEPT_CD        = D.DEPT_CD(+)
   AND A.OUT_ACCT_NO    = F.ACCT_NO
   AND A.IN_ACCT_NO     = F_IN.ACCT_NO
   AND F_IN.ACCT_SEQ    = FB.ACCT_SEQ(+)
   AND FB.ACCT_TXDAY(+) = TO_CHAR(SYSDATE - 1, 'YYYYMMDD')
   AND A.LAST_STATUS    IN ('20','30','52')
   AND A.LAST_STATUS    = C.CMM_CD(+)
   AND C.GRP_CD(+)      = 'S043'
   AND A.REGI_DATE      = TO_CHAR(SYSDATE, 'YYYYMMDD')
ORDER BY REGI_DATE DESC, TO_NUMBER(REGI_NUM) ASC
;



-- 직불계좌배분 > 자금통보배분 결과조회
SELECT A.AP_INOG_FNDSNTCNSHR_PNO AS PNO
	 , B.REGI_DATE                   /*결재등록일자        */
	 , B.REGI_NUM                    /*결재일련번호        */
	 , A.SEQ_NO                      /*상세일련번호        */
	 , B.REGI_DATE||B.REGI_TIME AS REG_DATE_TIME
	 , A.APPR_DATETIME
	 , DWC_CRYPT.decrypt(B.IN_ACCT_NO) AS IN_ACCT_NO
	 , FN_ACCT_FORMAT(B.IN_BANK_CD, DWC_CRYPT.decrypt(B.IN_ACCT_NO)) AS IN_ACCT_NO_FORMAT   /*입금계좌번호*/
	 , B.IN_BANK_CD
	 , IN_BK.BANK_NM AS IN_BANK_NM                /* 입금은행명 */
	 , A.APPR_AMT                                        /*배분실행금액*/
	 , A.IN_RMK                                          /*입금통장인쇄내역*/
	 , DWC_CRYPT.decrypt(B.OUT_ACCT_NO) AS OUT_ACCT_NO
	 , FN_ACCT_FORMAT(B.OUT_BANK_CD, DWC_CRYPT.decrypt(B.OUT_ACCT_NO)) AS OUT_ACCT_NO_FORMAT   /*출금계좌번호*/
	 , B.OUT_BANK_CD
	 , OUT_BK.BANK_NM AS OUT_BANK_NM                /* 출금은행명        */
	 , A.OUT_RMK                                          /*출금통장인쇄내역   */
	 , A.END_GB
	 , C.CD_DESC AS END_GB_TXT              /*처리상태            */
	 , 0 AS TRAN_FEE                                      /*원화이체수수료      */
	 , A.PROC_STS                                         /*처리결과코드        */
	 , F_ERR_MSG(B.OUT_BANK_CD,A.PROC_STS,'2', A.ORG_CD) AS ERR_MSG
FROM AP_INOG_FNDSNTCNSHR A
	 , AP_INOG_FNDSNTCNMAST$ B
	 , DWC_CMM_CODE C
	 , BA_BANK IN_BK
	 , BA_BANK OUT_BK
WHERE A.REGI_DATE   = B.REGI_DATE
   AND A.REG_USER_ID = B.REG_USER_ID
   AND A.REGI_NUM    = B.REGI_NUM
   AND B.IN_BANK_CD  = IN_BK.BANK_CD(+)
   AND B.OUT_BANK_CD = OUT_BK.BANK_CD(+)
   AND A.END_GB      = C.CMM_CD(+)
   AND C.GRP_CD(+)   = 'S049'
   AND B.SAN_WORK_GB = 'J10'
   AND SUBSTR(A.APPR_DATETIME, 1, 8) BETWEEN '20230701' and '202731'
ORDER BY A.REGI_DATE DESC, TO_NUMBER(A.REGI_NUM) DESC, TO_NUMBER(SEQ_NO) DESC
;



-- EDI 지급 > EDI 지급승인
SELECT
	   TB2.PNO
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.SLR_KND_DSCD     END AS SLR_KND_DSCD
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.SLR_KND_DSCD_TXT END AS SLR_KND_DSCD_TXT
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.REGI_DATE        END AS REGI_DATE
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.SVC_DIST         END AS SVC_DIST
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE ''||TB2.REGI_NUM     END AS REGI_NUM
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.VOTE_NO          END AS VOTE_NO
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.ERP_CD           END AS ERP_CD
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.DEPT_NM          END AS DEPT_NM
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.KTCU_USER_ID     END AS KTCU_USER_ID
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.USER_NM          END AS USER_NM
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.KTCU_REG_DT      END AS KTCU_REG_DT
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.TRAN_SET_DATE    END AS TRAN_SET_DATE
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.BRIEF_TITLE      END AS BRIEF_TITLE
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE ''||TB2.REGI_CNT     END AS REGI_CNT
	 , TB2.REGI_AMT || '' AS REGI_AMT
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.TRAD_NM          END AS TRAD_NM
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.OUT_BANK_CD      END AS OUT_BANK_CD
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.OUT_BANK_NM      END AS OUT_BANK_NM
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.OUT_ACCT_NO      END AS OUT_ACCT_NO
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.FORMAT_OUT_ACCT_NO  END AS FORMAT_OUT_ACCT_NO
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.TRAD_GB          END AS TRAD_GB
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.LAST_STATUS      END AS LAST_STATUS
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.LAST_STATUS_NM   END AS LAST_STATUS_NM
	 , TB2.GINFO
  FROM(
	   SELECT
			   PNO
			 , MAX(TB.SLR_KND_DSCD) AS SLR_KND_DSCD
			 , MAX(TB.SLR_KND_DSCD_TXT) AS SLR_KND_DSCD_TXT
			 , MAX(TB.REGI_DATE) AS REGI_DATE
			 , MAX(TB.SVC_DIST) AS SVC_DIST
			 , MAX(TB.REGI_NUM) AS REGI_NUM
			 , MAX(TB.VOTE_NO) AS VOTE_NO
			 , MAX(TB.ERP_CD) AS ERP_CD
			 , MAX(TB.DEPT_NM) AS DEPT_NM
			 , MAX(TB.KTCU_USER_ID) AS KTCU_USER_ID
			 , MAX(TB.USER_NM) AS USER_NM
			 , MAX(TB.KTCU_REG_DT) AS KTCU_REG_DT
			 , MAX(TB.TRAN_SET_DATE) AS TRAN_SET_DATE
			 , MAX(TB.BRIEF_TITLE) AS BRIEF_TITLE
			 , MAX(TB.REGI_CNT) AS REGI_CNT
			 , SUM(REGI_AMT) AS REGI_AMT
			 , MAX(TB.TRAD_NM) AS TRAD_NM
			 , MAX(TB.OUT_BANK_CD) AS OUT_BANK_CD
			 , MAX(TB.OUT_BANK_NM) AS OUT_BANK_NM
			 , MAX(TB.out_acct_no) AS OUT_ACCT_NO
			 , MAX(TB.FORMAT_OUT_ACCT_NO) AS FORMAT_OUT_ACCT_NO
			 , MAX(TB.TRAD_GB) AS TRAD_GB
			 , MAX(TB.LAST_STATUS) AS LAST_STATUS
			 , MAX(TB.LAST_STATUS_NM) AS LAST_STATUS_NM
			 , GROUPING(TB.PNO) AS GINFO
		  FROM (
				SELECT
					   A.AP_IF_MAST_PNO AS PNO
					 , A.SLR_KND_DSCD  /* 급여종류코드(지급구분) */
					 , CD1.CMM_CD_NM AS SLR_KND_DSCD_TXT
					 , A.REGI_DATE     /*등록일자(KEY)*/
					 , A.SVC_DIST      /*시스템구분(KEY)*/
					 , A.REGI_NUM      /*등록일련번호(KEY) */
					 , A.VOTE_NO       /*결의서번호*/
					 , A.ERP_CD        /*발의부서*/
					 , DECODE(A.KTCU_DEPT_NM,
							  '',
							 (SELECT DEPT_NM
								FROM DWC_DEPT_MSTR A, DWC_USER_MSTR B
							   WHERE B.USER_ID=A.KTCU_USER_ID
								 AND B.DEPT_CD=A.DEPT_CD ),
							  A.KTCU_DEPT_NM) AS DEPT_NM/*발의부서명*/
					 , A.KTCU_USER_ID  /*발의부서 처리자 ID(발의자)*/
					 , A.KTCU_USER_NM AS USER_NM       /*발의부서 처리자명(발의자명)*/
					 , A.KTCU_REG_DT   /*발의부서 결재일시(전송일자) */
					 , A.TRAN_SET_DATE /*지급일자*/
					 , A.BRIEF_TITLE   /*적요*/
					 , A.REGI_CNT      /*등록건수(총건수) */
					 , A.REGI_AMT      /*등록금액 */
					 , A.TRAD_NM       /* 업무명 */
					 , A.OUT_BANK_CD   /*출금은행코드*/
					 , B.BANK_NM AS OUT_BANK_NM                           /*출금은행코드*/
					 , DWC_CRYPT.decrypt(A.OUT_ACCT_NO) AS OUT_ACCT_NO    /*출금계좌 */
					 , FN_ACCT_FORMAT(A.OUT_BANK_CD, DWC_CRYPT.decrypt(A.OUT_ACCT_NO))  AS FORMAT_OUT_ACCT_NO /*포멧출금계좌 */
					 , A.TRAD_GB
					 , A.LAST_STATUS
					 , CD2.CMM_CD_NM AS LAST_STATUS_NM
				  FROM AP_IF_MAST$  A
					 , DWC_CMM_CODE CD1
					 , DWC_CMM_CODE CD2
					 , BA_BANK      B
					 , BA_USER_GRP_SLRDIST_A001_V V
				 WHERE 1 = 1
				   AND A.OUT_BANK_CD  = B.BANK_CD(+)
				   AND A.SLR_KND_DSCD = CD1.CMM_CD(+)
				   AND CD1.GRP_CD(+) = 'KT001'
				   AND A.LAST_STATUS = CD2.CMM_CD(+)
				   AND CD2.GRP_CD(+) = 'S043'
				   AND A.REGI_DATE    = '20230615' /*전송일자 */
				   AND A.TRAD_GB      = '200'   /*이체종류*/
				   AND A.LAST_STATUS  IN ( '91', '33' )        /*처리상태*/
				   AND A.SLR_KND_DSCD = V.SLR_DIST
				   AND V.USER_ID      = 'SYSTEMADMIN'
				   AND EXISTS ( SELECT '1'
								  FROM AP_IF_DETAIL$ D
								 WHERE A.REGI_DATE = D.REGI_DATE
								   AND A.SVC_DIST  = D.SVC_DIST
								   AND A.REGI_NUM  = D.REGI_NUM
								   AND A.TRAD_GB   = D.TRAD_GB
							)
		) TB
		GROUP BY ROLLUP(PNO)
) TB2
ORDER BY TB2.GINFO, TO_NUMBER(TB2.REGI_NUM)
;



-- EDI 지급 > EDI 지급실행
SELECT
	   TB2.PNO
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.SLR_KND_DSCD     END AS SLR_KND_DSCD
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.SLR_KND_DSCD_TXT END AS SLR_KND_DSCD_TXT
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.REGI_DATE        END AS REGI_DATE
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.SVC_DIST         END AS SVC_DIST
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE ''||TB2.REGI_NUM     END AS REGI_NUM
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.VOTE_NO          END AS VOTE_NO
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.ERP_CD           END AS ERP_CD
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.DEPT_NM          END AS DEPT_NM
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.KTCU_USER_ID     END AS KTCU_USER_ID
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.USER_NM          END AS USER_NM
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.KTCU_REG_DT      END AS KTCU_REG_DT
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.TRAN_SET_DATE    END AS TRAN_SET_DATE
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.BRIEF_TITLE      END AS BRIEF_TITLE
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE ''||TB2.REGI_CNT     END AS REGI_CNT
	 , TB2.REGI_AMT
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.TRAD_NM          END AS TRAD_NM
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.out_bank_cd      END AS out_bank_cd
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.out_acct_no      END AS out_acct_no
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.TRAD_GB          END AS TRAD_GB
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.LAST_SAN_USER_ID END AS LAST_SAN_USER_ID
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.LAST_SAN_USER_NM END AS LAST_SAN_USER_NM
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.PI_ID            END AS PI_ID
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.LAST_STATUS      END AS LAST_STATUS
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.LAST_STATUS_NM   END AS LAST_STATUS_NM
	 , TB2.GINFO
  FROM(
	   SELECT
			   PNO
			 , MAX(TB.SLR_KND_DSCD) AS SLR_KND_DSCD
			 , MAX(TB.SLR_KND_DSCD_TXT) AS SLR_KND_DSCD_TXT
			 , MAX(TB.REGI_DATE) AS REGI_DATE
			 , MAX(TB.SVC_DIST) AS SVC_DIST
			 , MAX(TB.REGI_NUM) AS REGI_NUM
			 , MAX(TB.VOTE_NO) AS VOTE_NO
			 , MAX(TB.ERP_CD) AS ERP_CD
			 , MAX(TB.DEPT_NM) AS DEPT_NM
			 , MAX(TB.KTCU_USER_ID) AS KTCU_USER_ID
			 , MAX(TB.USER_NM) AS USER_NM
			 , MAX(TB.KTCU_REG_DT) AS KTCU_REG_DT
			 , MAX(TB.TRAN_SET_DATE) AS TRAN_SET_DATE
			 , MAX(TB.BRIEF_TITLE) AS BRIEF_TITLE
			 , MAX(TB.REGI_CNT) AS REGI_CNT
			 , SUM(REGI_AMT) AS REGI_AMT
			 , MAX(TB.TRAD_NM) AS TRAD_NM
			 , MAX(TB.out_bank_cd) AS out_bank_cd
			 , MAX(TB.out_acct_no) AS out_acct_no
			 , MAX(TB.TRAD_GB) AS TRAD_GB
			 , MAX(TB.LAST_SAN_USER_ID) AS LAST_SAN_USER_ID
			 , MAX(TB.LAST_SAN_USER_NM) AS LAST_SAN_USER_NM
			 , MAX(TB.PI_ID) AS PI_ID
			 , MAX(TB.LAST_STATUS) AS LAST_STATUS
			 , MAX(TB.LAST_STATUS_NM) AS LAST_STATUS_NM
			 , GROUPING(TB.PNO) AS GINFO
		  FROM (
				SELECT
					   A.AP_IF_MAST_PNO AS PNO
					 , A.SLR_KND_DSCD  /* 급여종류코드(지급구분) */
					 , CODE1.CMM_CD_NM AS SLR_KND_DSCD_TXT
					 , A.REGI_DATE     /*등록일자(KEY)*/
					 , A.SVC_DIST      /*시스템구분(KEY)*/
					 , A.REGI_NUM      /*등록일련번호(KEY) */
					 , A.VOTE_NO       /*결의서번호*/
					 , A.ERP_CD        /*발의부서*/
					 , DECODE(A.KTCU_DEPT_NM,
							  '',
							 (SELECT DEPT_NM
								FROM DWC_DEPT_MSTR A, DWC_USER_MSTR B
							   WHERE B.USER_ID=A.KTCU_USER_ID
								 AND B.DEPT_CD=A.DEPT_CD ),
							  A.KTCU_DEPT_NM) AS DEPT_NM/*발의부서명*/
					 , A.KTCU_USER_ID  /*발의부서 처리자 ID(발의자)*/
					 , A.KTCU_USER_NM AS USER_NM       /*발의부서 처리자명(발의자명)*/
					 , A.KTCU_REG_DT   /*발의부서 결재일시(전송일자) */
					 , A.TRAN_SET_DATE /*지급일자*/
					 , A.BRIEF_TITLE   /*적요*/
					 , A.REGI_CNT      /*등록건수(총건수) */
					 , A.REGI_AMT      /*등록금액 */
					 , A.TRAD_NM       /* 업무명 */
					 , A.out_bank_cd   /*출금은행코드*/
					 , DWC_CRYPT.decrypt(A.out_acct_no) AS out_acct_no    /*출금계좌 */
					 , A.TRAD_GB
					 , C.USER_ID   AS LAST_SAN_USER_ID /* 최종결재자ID */
					 , C.USER_NM   AS LAST_SAN_USER_NM /* 최종결재자명 */
					 , B.PI_ID
					 , A.LAST_STATUS
					 , CODE2.CMM_CD_NM AS LAST_STATUS_NM
				  FROM AP_IF_MAST$ A
					 , DWC_ASSIGN_INFO B
					 , DWC_USER_MSTR C
					 , DWC_CMM_CODE CODE1
					 , DWC_CMM_CODE CODE2
				 WHERE 1 = 1
				   AND A.SLR_KND_DSCD     = CODE1.CMM_CD(+)
				   AND CODE1.GRP_CD(+)    = 'KT001'
				   AND A.LAST_STATUS      = CODE2.CMM_CD(+)
				   AND CODE2.GRP_CD(+)    = 'S043'
				   AND A.BIZ_PI_ID        = B.PI_ID(+)
				   AND B.FINAL_ASSIGN_UID = C.USER_ID(+)
				   AND A.TRAN_SET_DATE    = '20231205'  /*전송일자 */
				   AND A.TRAD_GB      = '200'   /*이체종류*/
				   AND A.LAST_STATUS      IN ('21', '32')   /*처리상태*/
				   AND EXISTS ( SELECT '1'
								  FROM AP_IF_DETAIL$ D
								 WHERE A.REGI_DATE = D.REGI_DATE
								   AND A.SVC_DIST  = D.SVC_DIST
								   AND A.REGI_NUM  = D.REGI_NUM
								   AND A.TRAD_GB   = D.TRAD_GB
							)
		) TB
		GROUP BY ROLLUP(PNO)
) TB2
ORDER BY TB2.GINFO, TO_NUMBER(TB2.REGI_NUM)
;



-- EDI 지급 > EDI 지급실행 > 상세조회
SELECT A.AP_IF_DETAIL_PNO AS PNO
	 , A.REGI_SEQ            /*순번 */
	 , A.IN_BANK_CD          /*입금은행 코드 */
	 , DECODE(A.IN_BANK_CD,'10000010','농협', BK.BANK_NM) as BANK_NM            /*입금은행 이름 */
	 , A.IN_ACCT_NO          /*입금계좌번호 */
	 , FN_ACCT_FORMAT(A.IN_BANK_CD, A.IN_ACCT_NO) AS ACCT_NO /*FORMAT 적용 계좌번호 */
	 , A.TRAN_AMT            /*이체금액 */
	 , A.REGI_REF_NM         /*예금주명 */
	 , A.CREDITOR_DIV        /*채주구분 */
	 , DECODE(A.RRNO, null, '', SUBSTR(A.RRNO,0,7)||'******') AS RRNO /*주민 / 사업자 번호 */
	 , A.IN_RMK              /*입금통장에 찍힐 내용 */
	 , A.ATTACHTAG_SEQ       /*부표순번 */
	 , A.REGI_DATE           /*등록일자 */
	 , A.REGI_NUM            /*등록일련번호*/
	 , A.TRAD_GB             /*업무구분코드*/
	 , A.SVC_DIST            /*시스템구분*/
  FROM AP_IF_DETAIL A
	 , AP_IF_MAST   C
	 , BA_BANK      BK
 WHERE A.REGI_DATE    = C.REGI_DATE
   AND A.REGI_NUM     = C.REGI_NUM
   AND A.TRAD_GB      = C.TRAD_GB
   AND A.SVC_DIST     = C.SVC_DIST
   AND A.IN_BANK_CD   = BK.BANK_CD(+)
   AND A.REGI_DATE    = '20231201'
   AND A.SVC_DIST     = 'INS'
   AND A.TRAD_GB      = '200'
   AND A.REGI_NUM     = '1'
 ORDER BY A.REGI_SEQ
;



-- EDI 지급 > EDI 지급결과조회
SELECT
	   TB2.PNO
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.REGI_DATE         END AS REGI_DATE
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.SVC_DIST          END AS SVC_DIST
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE ''||TB2.REGI_NUM      END AS REGI_NUM
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.TRAD_GB           END AS TRAD_GB
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.REG_DATE_TIME     END AS REG_DATE_TIME
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.TRAN_SET_YN       END AS TRAN_SET_YN             /*예약이체여부 */
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.TRAN_SET_DATE     END AS TRAN_SET_DATE           /*예약일자    */
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.TRAN_SET_TIME     END AS TRAN_SET_TIME           /*예약시간    */
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.END_DATETIME      END AS END_DATETIME            /*처리완료일시 */
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.DEPT_NM           END AS DEPT_NM
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.USER_NM           END AS USER_NM
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.SLR_KND_DSCD      END AS SLR_KND_DSCD             /*지급구분   */
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.SLR_KND_DSCD_TXT  END AS SLR_KND_DSCD_TXT
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.TRAD_NM           END AS TRAD_NM                  /*업무명     */
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.END_GB            END AS END_GB                   /*작업완료여부 */
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.END_GB_NM         END AS END_GB_NM                /* 파일전송상태 */
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE ''||TB2.REGI_CNT      END AS REGI_CNT                 /*등록건수    */
	 , TB2.REGI_AMT
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE ''||TB2.NOR_CNT       END AS NOR_CNT                  /*정상건수    */
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE ''||TB2.NOR_AMT       END AS NOR_AMT                  /*정상금액    */
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE ''||TB2.BUL_CNT       END AS BUL_CNT                  /*불능건수    */
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE ''||TB2.BUL_AMT       END AS BUL_AMT                  /*불능금액    */
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE ''||TB2.ERR_CNT       END AS ERR_CNT                  /*에러건수    */
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE ''||TB2.ERR_AMT       END AS ERR_AMT                  /*에러금액    */
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.OUT_ACCT_NO       END AS OUT_ACCT_NO              /*출금계좌     */
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.FILE_SEND_STS     END AS FILE_SEND_STS            /*파일전송상태 */
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.REGI_CANCEL_YN    END AS REGI_CANCEL_YN           /*등록취소여부 */
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.KTCU_USER_ID      END AS KTCU_USER_ID             /*발의부서 처리자 ID(발의자)*/
	 , CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.KTCU_USER_NM      END AS KTCU_USER_NM             /*발의부서 처리자명(발의자명)*/
	 , TB2.GINFO
  FROM(
		SELECT
			   PNO
			 , MAX(TB.REGI_DATE              ) AS REGI_DATE
			 , MAX(TB.SVC_DIST               ) AS SVC_DIST
			 , MAX(TB.REGI_NUM               ) AS REGI_NUM
			 , MAX(TB.TRAD_GB                ) AS TRAD_GB
			 , MAX(TB.REG_DATE_TIME          ) AS REG_DATE_TIME
			 , MAX(TB.TRAN_SET_YN            ) AS TRAN_SET_YN             /*예약이체여부 */
			 , MAX(TB.TRAN_SET_DATE          ) AS TRAN_SET_DATE           /*예약일자    */
			 , MAX(TB.TRAN_SET_TIME          ) AS TRAN_SET_TIME           /*예약시간    */
			 , MAX(TB.END_DATETIME           ) AS END_DATETIME            /*처리완료일시 */
			 , MAX(TB.DEPT_NM                ) AS DEPT_NM
			 , MAX(TB.USER_NM                ) AS USER_NM
			 , MAX(TB.SLR_KND_DSCD           ) AS SLR_KND_DSCD             /*지급구분   */
			 , MAX(TB.SLR_KND_DSCD_TXT       ) AS SLR_KND_DSCD_TXT
			 , MAX(TB.TRAD_NM                ) AS TRAD_NM                  /*업무명     */
			 , MAX(TB.END_GB                 ) AS END_GB                   /*작업완료여부 */
			 , MAX(TB.END_GB_NM              ) AS END_GB_NM                /* 파일전송상태 */
			 , MAX(TB.REGI_CNT               ) AS REGI_CNT                 /*등록건수    */
			 , SUM(REGI_AMT) AS REGI_AMT
			 , MAX(TB.NOR_CNT                ) AS NOR_CNT                  /*정상건수    */
			 , MAX(TB.NOR_AMT                ) AS NOR_AMT                  /*정상금액    */
			 , MAX(TB.BUL_CNT                ) AS BUL_CNT                  /*불능건수    */
			 , MAX(TB.BUL_AMT                ) AS BUL_AMT                  /*불능금액    */
			 , MAX(TB.ERR_CNT                ) AS ERR_CNT                  /*에러건수    */
			 , MAX(TB.ERR_AMT                ) AS ERR_AMT                  /*에러금액    */
			 , MAX(TB.OUT_ACCT_NO            ) AS OUT_ACCT_NO              /*출금계좌    */
			 , MAX(TB.FILE_SEND_STS          ) AS FILE_SEND_STS            /*파일전송상태 */
			 , MAX(TB.REGI_CANCEL_YN         ) AS REGI_CANCEL_YN           /*등록취소여부 */
			 , MAX(TB.KTCU_USER_ID           ) AS KTCU_USER_ID             /*발의부서 처리자 ID(발의자)*/
			 , MAX(TB.KTCU_USER_NM           ) AS KTCU_USER_NM             /*발의부서 처리자명(발의자명)*/
			 , GROUPING(TB.PNO) AS GINFO
		  FROM (
				SELECT
					   A.AP_IF_MAST_PNO AS PNO
					 , A.REGI_DATE
					 , A.SVC_DIST
					 , A.REGI_NUM
					 , A.TRAD_GB
					 , A.REGI_DATE||A.REGI_TIME AS REG_DATE_TIME
					 , A.TRAN_SET_YN       /*예약이체여부            */
					 , A.TRAN_SET_DATE     /*예약일자               */
					 , A.TRAN_SET_TIME     /*예약시간               */
					 , A.END_DATETIME      /*처리완료일시            */
					 , A.KTCU_DEPT_NM AS DEPT_NM
					 , A.KTCU_USER_NM AS USER_NM
					 , A.SLR_KND_DSCD      /*지급구분   */
					 , CD1.CMM_CD_NM SLR_KND_DSCD_TXT
					 , A.TRAD_NM           /*업무명                 */
					 , A.END_GB            /*작업완료여부           */
					 , CASE WHEN A.LAST_STATUS IN ('10', '11', '15') THEN '결재중'
							WHEN A.LAST_STATUS IN ('20', '21') THEN '결재완료'
							WHEN A.LAST_STATUS = '51' AND A.FILE_SEND_STS IN('0', '3') THEN 'EDI파일생성'
							WHEN A.LAST_STATUS = '51' AND A.FILE_SEND_STS = '1' THEN '은행수신완료'
							WHEN A.LAST_STATUS = '52' THEN '처리완료'
							WHEN A.LAST_STATUS = '55' THEN '등록취소'
							ELSE '미처리'
							 END END_GB_NM   /* 파일전송상태 */
					 , CASE WHEN A.LAST_STATUS IN ('10', '11', '15') THEN '1'
							WHEN A.LAST_STATUS IN ('20', '21') THEN '2'
							WHEN A.LAST_STATUS = '51' AND A.FILE_SEND_STS IN('0', '3') THEN '3'
							WHEN A.LAST_STATUS = '51' AND A.FILE_SEND_STS = '1' THEN '4'
							WHEN A.LAST_STATUS = '52' THEN '5'
							WHEN A.LAST_STATUS = '55' THEN '6'
							ELSE '0'
							 END END_GB_NM_SH   /* 검색용 파일전송상태 */
					 , NVL(A.REGI_CNT, 0) AS REGI_CNT /*등록건수    */
					 , NVL(A.REGI_AMT, 0) AS REGI_AMT /*등록금액    */
					 , NVL(A.NOR_CNT , 0) AS NOR_CNT  /*정상건수    */
					 , NVL(A.NOR_AMT , 0) AS NOR_AMT  /*정상금액    */
					 , NVL(A.BUL_CNT , 0) AS BUL_CNT  /*불능건수    */
					 , NVL(A.BUL_AMT , 0) AS BUL_AMT  /*불능금액    */
					 , NVL(A.ERR_CNT , 0) AS ERR_CNT  /*에러건수    */
					 , NVL(A.ERR_AMT , 0) AS ERR_AMT  /*에러금액    */
					 , FN_ACCT_FORMAT(A.OUT_BANK_CD, A.OUT_ACCT_NO)  as OUT_ACCT_NO       /*출금계좌               */
					 , A.FILE_SEND_STS
					 , CASE WHEN A.FILE_SEND_STS IS NULL AND A.LAST_STATUS IN ('15', '20') THEN 'Y' ELSE 'N' END AS REGI_CANCEL_YN
					 , A.KTCU_USER_ID
					 , A.KTCU_USER_NM
				  FROM AP_IF_MAST   A
					 , DWC_ASSIGN_INFO B
					 , FN_ACCT        C
					 , DWC_CMM_CODE CD1
					 , BA_USER_GRP_SLRDIST_A001_V V
				 WHERE A.EXP_PI_ID      = B.PI_ID(+)
				   AND B.ACCT_SEQ       = C.ACCT_SEQ(+)
				   AND A.SLR_KND_DSCD   = CD1.CMM_CD(+)
				   AND CD1.GRP_CD(+)    = 'KT001'
				   AND A.LAST_STATUS    NOT IN ('91', '55')
				   AND A.TRAD_GB      = '200'   /*이체종류*/
				   AND B.FINAL_APPR_YN(+) = 'Y'
				   AND A.SLR_KND_DSCD = V.SLR_DIST
				   AND V.USER_ID      = 'SYSTEMADMIN'
				   AND A.TRAN_SET_DATE BETWEEN '20231101' and '20231231'
			) TB
		GROUP BY ROLLUP(PNO)
	) TB2
ORDER BY TB2.GINFO, TO_DATE(TB2.TRAN_SET_DATE,'YYYYMMDD') DESC, TO_DATE(TB2.END_DATETIME,'YYYYMMDD HH24MISS') DESC, TB2.TRAD_NM
;



-- EDI 지급 > EDI 지급결과조회 > 상세조회
SELECT A.AP_IF_DETAIL_PNO PNO
	 , A.REGI_SEQ         /*순번 */
	 , A.IN_BANK_CD       /*입금은행 코드 */
	 , DECODE(A.IN_BANK_CD, '10000010', '농협', BK.BANK_NM) as BANK_NM            /*입금은행 이름 */
	 , A.IN_ACCT_NO      /*입금계좌번호 */
	 , FN_ACCT_FORMAT(A.IN_BANK_CD, A.IN_ACCT_NO) AS ACCT_NO /*FORMAT 적용 계좌번호 */
	 , A.TRAN_AMT        /*이체금액 */
	 , A.REGI_REF_NM     /*예금주명 */
	 , A.OUT_ACCT_NO     /*출금계좌번호*/
	 , DECODE(A.RRNO, null, '', SUBSTR(A.RRNO,0,7)||'******') AS NAME_NO         /*주민등록,사업자번호*/
	 , NVL(C.ERR_CNT , 0) AS ERR_CNT  /*에러건수    */
	 , NVL(C.ERR_AMT , 0) AS ERR_AMT  /*에러금액    */
	 , A.CREDITOR_DIV    /*채주구분 */
	 , DECODE(A.CREDITOR_DIV, 'A03001','거래처','A03002','사원','A03003','부서','A03001','법인카드') AS CREDITOR_DIV_NM
	 , A.IN_RMK          /*입금통장에 찍힐 내용 */
	 , A.ATTACHTAG_SEQ    /*부표순번 */
	 , A.END_GB           /*처리완료여부        */
	 , CD1.CD_DESC AS END_GB_NM
	 , F_ERR_MSG('10000004', A.PROC_STS, '1', A.ORG_CD) AS FORMAT_ERR_MSG
FROM AP_IF_DETAIL A
	 , AP_IF_MAST C
	 , DWC_CMM_CODE CD1
	 , BA_BANK BK
 WHERE A.REGI_DATE    = C.REGI_DATE
   AND A.REGI_NUM     = C.REGI_NUM
   AND A.TRAD_GB      = C.TRAD_GB
   AND A.SVC_DIST     = C.SVC_DIST
   AND A.END_GB       = CD1.CMM_CD(+)
   AND CD1.GRP_CD(+)  = 'S049'
   AND A.IN_BANK_CD   = BK.BANK_CD(+)
   AND A.REGI_DATE    = '20231128'
   AND A.SVC_DIST     = 'MMB'
   AND A.TRAD_GB      = '200'
   AND A.REGI_NUM     = '5002'
 ORDER BY A.REGI_SEQ
;



-- 법인예탁급여지급 > 법인예탁급여 지급실행
SELECT A.AP_IF_MAST_PNO AS PNO
	 , A.REGI_DATE
	 , A.SVC_DIST
	 , A.REGI_NUM
	 , A.TRAD_GB
	 , A.VOTE_NO
	 , B.ATTACHTAG_SEQ
	 , A.KTCU_DEPT_NM
	 , A.KTCU_USER_NM
	 , A.TRAN_SET_DATE
	 , A.TRAD_NM
	 , A.OUT_BANK_CD
	 , BK1.BANK_NM AS BANK_NM
	 , A.OUT_ACCT_NO
	 , FN_ACCT_FORMAT(A.OUT_BANK_CD, A.OUT_ACCT_NO)  as FORMAT_OUT_ACCT_NO
	 , B.AP_IF_DETAIL_PNO
	 , B.TRAN_AMT || '' AS TRAN_AMT
	 , B.REGI_REF_NM
	 , B.FIND_REF_NM
	 , B.DPSTR_INQIRE_SUCCES_YN
	 , CASE WHEN B.DPSTR_INQIRE_SUCCES_YN = 'Y' THEN '성공'
			WHEN B.DPSTR_INQIRE_SUCCES_YN = 'N' THEN '실패'
			ELSE '미실행' END AS DPSTR_INQIRE_SUCCES_YN_NM
	 /* , DECODE(B.DPSTR_INQIRE_SUCCES_YN, 'Y', '성공', '실패') AS DPSTR_INQIRE_SUCCES_YN_NM */
	 , CASE WHEN B.DPSTR_INQIRE_SUCCES_YN = 'Y' AND SUBSTR(B.REGI_REF_NM,1,LENGTH(B.FIND_REF_NM)) = B.FIND_REF_NM THEN '일치'
			WHEN B.DPSTR_INQIRE_SUCCES_YN = 'Y' AND SUBSTR(B.REGI_REF_NM,1,LENGTH(B.FIND_REF_NM)) != B.FIND_REF_NM THEN '불일치'
			ELSE '' END AS DPSTR_INQIRE_COMPARE_NM /* 예금주명조회 일치여부 */
	 , B.IN_RMK
	 , A.AGNC_NAME
	 , C.DEPT_NAME AS FUND_DEPT_NM
	 , B.TOT_DOWN_CN
	 , B.PYM_RESV_TRAN_YN
	 , DECODE(B.PYM_RESV_TRAN_YN, 'Y', '대상', '비대상') AS PYM_RESV_TRAN_YN_NM
	 , A.VRIFY_YN
	 , CASE WHEN A.VRIFY_YN = 'Y' AND TO_DATE(A.VRIFY_DT, 'YYYYMMDDHH24MISS') + 5/(24 * 60) > SYSDATE THEN 'N'
			ELSE 'Y' END AS VRIFY_POSIBLE_YN
	 , CASE WHEN A.VRIFY_YN = 'N'  THEN '검증실패'
			WHEN NVL(A.VRIFY_YN, 'N') != 'Y' OR TO_DATE(A.VRIFY_DT, 'YYYYMMDDHH24MISS') + 5/(24 * 60) <= SYSDATE THEN '미검증'
			WHEN A.VRIFY_YN = 'Y'  THEN '검증완료' ELSE '' END AS VRIFY_TXT
	 , FN_ACCT_FORMAT(B.IN_BANK_CD, B.IN_ACCT_NO)  as FORMAT_IN_ACCT_NO
	 , BK2.BANK_NM AS IN_BANK_NM
	 , B.IN_BANK_CD
	 , B.IN_ACCT_NO
	 , A.LAST_STATUS
	 , CD1.CMM_CD_NM AS LAST_STATUS_NM
  FROM AP_IF_MAST A
	 ,(SELECT
			  MIN(AP_IF_DETAIL_PNO) AS AP_IF_DETAIL_PNO
			, REGI_DATE
			, REGI_NUM
			, SVC_DIST
			, IN_BANK_CD
			, IN_ACCT_NO
			, REGI_REF_NM
			, FIND_REF_NM
			, IN_RMK
			, ATTACHTAG_SEQ
			, SUM(TRAN_AMT) AS TRAN_AMT
			, COUNT(*) AS TOT_DOWN_CN
			, CASE WHEN SUM(DECODE(PYM_RESV_TRAN_YN, 'Y', 1, 0))  >  0 THEN 'Y' ELSE 'N' END PYM_RESV_TRAN_YN
			, MIN(DPSTR_INQIRE_SUCCES_YN) KEEP (DENSE_RANK FIRST ORDER BY AP_IF_DETAIL_PNO) AS DPSTR_INQIRE_SUCCES_YN
		 FROM AP_IF_DETAIL
		GROUP BY
			  REGI_DATE
			, REGI_NUM
			, SVC_DIST
			, IN_BANK_CD
			, IN_ACCT_NO
			, REGI_REF_NM
			, FIND_REF_NM
			, IN_RMK
			, ATTACHTAG_SEQ
	   ) B
	 , BA_ACCT_DEPT C
	 , BA_BANK      BK1
	 , BA_BANK      BK2
	 , DWC_CMM_CODE CD1
	 , BA_USER_GRP_ACCT_DEPT_A001_V V1
	 , BA_USER_GRP_PAY_DEPT_A001_V V2
 WHERE A.REGI_DATE   = B.REGI_DATE
	AND A.SVC_DIST    = B.SVC_DIST
	AND A.REGI_NUM    = B.REGI_NUM
	AND A.OUT_BANK_CD = BK1.BANK_CD(+)
	AND B.IN_BANK_CD  = BK2.BANK_CD(+)
	AND A.LAST_STATUS = CD1.CMM_CD(+)
	AND CD1.GRP_CD(+) = 'S043'
	AND A.FUND_DEPT_CODE = C.DEPT_CODE(+)
	AND A.TRAD_GB     = '102' /* 법인예탁급여 */
	AND A.LAST_STATUS IN ('91', '32', '33')
	AND A.TRAN_SET_DATE = '20230525'
	AND A.AGNC_CODE      = V1.ACCT_DEPT_CD
	AND V1.USER_ID       = 'SYSTEMADMIN'
	AND A.TRAD_GB LIKE V1.TRAD_GB||'%'
	AND A.FUND_DEPT_CODE = V2.PAY_DEPT_CD
	AND V2.USER_ID       = 'SYSTEMADMIN'
	AND A.TRAD_GB LIKE V2.TRAD_GB||'%'
 ORDER BY A.REGI_NUM ASC
;



-- 법인예탁급여지급 > 법인예탁급여 지급실행 > 상세조회
SELECT A.REGI_DATE
	 , A.SVC_DIST
	 , A.REGI_NUM
	 , A.TRAD_GB
	 , A.VOTE_NO
	 , B.REGI_SEQ
	 , B.ATTACHTAG_SEQ
	 , A.KTCU_DEPT_NM
	 , A.KTCU_USER_NM
	 , A.TRAN_SET_DATE
	 , A.TRAD_NM
	 , B.IN_BANK_CD
	 , D.BANK_NM AS BANK_NM
	 , B.IN_ACCT_NO
	 , FN_ACCT_FORMAT(B.IN_BANK_CD, B.IN_ACCT_NO)  as FORMAT_IN_ACCT_NO
	 , B.TRAN_AMT || '' AS TRAN_AMT
	 , B.REGI_REF_NM
	 , B.IN_RMK
	 , A.AGNC_NAME
	 , C.DEPT_NAME AS FUND_DEPT_NM
	 , B.PYM_RESV_TRAN_YN
  FROM AP_IF_MAST A
	 , AP_IF_DETAIL B
	 , BA_ACCT_DEPT C
	 , BA_BANK D
 WHERE A.REGI_DATE      = B.REGI_DATE
   AND A.SVC_DIST       = B.SVC_DIST
   AND A.REGI_NUM       = B.REGI_NUM
   AND B.IN_BANK_CD     = D.BANK_CD(+)
   AND A.FUND_DEPT_CODE = C.DEPT_CODE(+)
   AND A.REGI_DATE      = '20230523'
   AND A.SVC_DIST       = 'BIZ'
   AND A.REGI_NUM       = '93001'
   AND A.TRAD_GB        = '102'
 ORDER BY A.REGI_NUM ASC, B.REGI_SEQ ASC
;



-- 법인예탁급여지급 > 법인예탁급여 지급결과 조회
SELECT
		TB2.AP_IF_MAST_PNO AS PNO
		, TB2.AP_IF_DETAIL_PNO AS DETAIL_PNO
		, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.REGI_DATE     END AS REGI_DATE
		, CASE WHEN TB2.GINFO = 1 THEN '' ELSE ''||TB2.REGI_NUM  END AS REGI_NUM
		, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.TRAN_SET_DATE END AS TRAN_SET_DATE
		, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.TRAN_DATE     END AS TRAN_DATE
		, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.TRAN_TIME     END AS TRAN_TIME
		, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.TRAD_GB       END AS TRAD_GB
		, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.GUBUN         END AS GUBUN
		, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.DEPT_NM       END AS DEPT_NM
		, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.USER_NM       END AS USER_NM
		, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.REGI_TIME     END AS REGI_TIME
		, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.BRIEF_TITLE   END AS BRIEF_TITLE
		, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.ERP_CD        END AS ERP_CD
		, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.OUT_BANK_CD   END AS OUT_BANK_CD
		, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.OUT_ACCT_NO   END AS OUT_ACCT_NO
		, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.NON_FORMAT_OUT_ACCT_NO   END AS NON_FORMAT_OUT_ACCT_NO
		, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.END_GB        END AS END_GB
		, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.END_GB_NM     END AS END_GB_NM
		, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.DETAIL_END_GB END AS DETAIL_END_GB
		, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.PROC_MSG      END AS PROC_MSG
		, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.RE_SEARCH_YN  END AS RE_SEARCH_YN
		, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.BANK_NM       END AS BANK_NM
		, TB2.TRAN_AMT || '' AS TRAN_AMT
		, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.VOTE_NO       END AS VOTE_NO
		, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.FUND_DEPT_NM  END AS FUND_DEPT_NM
		, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.PYM_RESV_TRAN_YN  END AS PYM_RESV_TRAN_YN
		, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.PYM_RESV_TRAN_YN_NM  END AS PYM_RESV_TRAN_YN_NM
		, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.SVC_DIST     END AS SVC_DIST
		, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.RETRY_YN     END AS RETRY_YN
		, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.RETRY_YN_NM  END AS RETRY_YN_NM
		, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.EXP_PI_ID    END AS EXP_PI_ID
		, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.LAST_STATUS  END AS LAST_STATUS
		, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.LAST_STATUS_NM END AS LAST_STATUS_NM
		, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.FORMAT_IN_ACCT_NO END AS FORMAT_IN_ACCT_NO
		, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.IN_BANK_NM   END AS IN_BANK_NM
		, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.IN_BANK_CD   END AS IN_BANK_CD
		, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.IN_ACCT_NO   END AS IN_ACCT_NO
		, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.REGI_REF_NM  END AS REGI_REF_NM
		, CASE WHEN TB2.GINFO = 1 THEN '' ELSE CANCEL_YN        END AS ERR_CANCEL_YN
		, CASE WHEN TB2.GINFO = 1 THEN '' ELSE CASE WHEN CANCEL_YN = 'Y' THEN '가능' ELSE '불가' END END AS ERR_CANCEL_YN_NM
		, CASE WHEN TB2.GINFO = 1 THEN '' ELSE SEQ_NO           END AS SEQ_NO
		, TB2.GINFO
	FROM(
	SELECT
		MAX(AP_IF_MAST_PNO )      AS AP_IF_MAST_PNO
		, AP_IF_DETAIL_PNO
		, MAX(REGI_DATE    )      AS REGI_DATE
		, MAX(REGI_NUM     )      AS REGI_NUM
		, MAX(TRAN_SET_DATE)      AS TRAN_SET_DATE
		, MAX(TRAN_DATE)          AS TRAN_DATE
		, MAX(TRAN_TIME)          AS TRAN_TIME
		, MAX(TRAD_GB      )      AS TRAD_GB
		, MAX(GUBUN        )      AS GUBUN
		, MAX(DEPT_NM      )      AS DEPT_NM
		, MAX(USER_NM      )      AS USER_NM
		, MAX(REGI_TIME    )      AS REGI_TIME
		, MAX(BRIEF_TITLE  )      AS BRIEF_TITLE
		, MAX(ERP_CD       )      AS ERP_CD
		, MAX(OUT_BANK_CD  )      AS OUT_BANK_CD
		, MAX(OUT_ACCT_NO  )      AS OUT_ACCT_NO
		, MAX(NON_FORMAT_OUT_ACCT_NO) AS NON_FORMAT_OUT_ACCT_NO
		, MAX(END_GB       )      AS END_GB
		, MAX(END_GB_NM    )      AS END_GB_NM
		, MAX(DETAIL_END_GB)      AS DETAIL_END_GB
		, MAX(PROC_MSG     )      AS PROC_MSG
		, MAX(RE_SEARCH_YN )      AS RE_SEARCH_YN
		, MAX(BANK_NM      )      AS BANK_NM
		, SUM(TRAN_AMT)           AS TRAN_AMT
		, MAX(VOTE_NO      )      AS VOTE_NO
		, MAX(FUND_DEPT_NM )      AS FUND_DEPT_NM
		, MAX(PYM_RESV_TRAN_YN )  AS PYM_RESV_TRAN_YN
		, MAX(PYM_RESV_TRAN_YN_NM )  AS PYM_RESV_TRAN_YN_NM
		, MAX(SVC_DIST )          AS SVC_DIST
		, MAX(RETRY_YN )          AS RETRY_YN
		, MAX(RETRY_YN_NM )       AS RETRY_YN_NM
		, MAX(EXP_PI_ID )         AS EXP_PI_ID
		, MAX(LAST_STATUS )       AS LAST_STATUS
		, MAX(LAST_STATUS_NM )    AS LAST_STATUS_NM
		, MAX(FORMAT_IN_ACCT_NO ) AS FORMAT_IN_ACCT_NO
		, MAX(IN_BANK_NM )        AS IN_BANK_NM
		, MAX(IN_BANK_CD )        AS IN_BANK_CD
		, MAX(IN_ACCT_NO )        AS IN_ACCT_NO
		, MAX(REGI_REF_NM )       AS REGI_REF_NM
		, CASE WHEN SUM(DECODE(DETAIL_END_GB,'5',1,0)) = MAX(REGI_CNT) THEN 'Y' ELSE 'N' END AS CANCEL_YN
		, MAX(SEQ_NO)             AS SEQ_NO
		, GROUPING(TB.AP_IF_DETAIL_PNO)        AS GINFO
	FROM (
		SELECT
			A.AP_IF_MAST_PNO
			, B.AP_IF_DETAIL_PNO
			, A.REGI_DATE
			, A.REGI_NUM
			, A.TRAN_SET_DATE
			, B.TRAN_DATE
			, B.TRAN_TIME
			, A.TRAD_GB
			, DECODE(A.TRAD_GB,'100','일반경비','101','투자금','102','법인예탁급여','103','환전') AS GUBUN
			, A.KTCU_DEPT_NM AS DEPT_NM
			, A.KTCU_USER_NM AS USER_NM
			, A.REGI_TIME
			, A.BRIEF_TITLE
			, A.REGI_CNT
			, A.ERP_CD
			, B.OUT_BANK_CD
			, FN_ACCT_FORMAT(A.OUT_BANK_CD, DWC_CRYPT.decrypt(A.OUT_ACCT_NO))  AS OUT_ACCT_NO
			, DWC_CRYPT.decrypt(A.OUT_ACCT_NO) AS NON_FORMAT_OUT_ACCT_NO
			, A.END_GB
			, CD1.CD_DESC AS END_GB_NM
			, B.END_GB  AS DETAIL_END_GB
			, F_ERR_MSG('10000004', B.PROC_STS, 2, 'KB_FIRM') AS PROC_MSG
			, CASE WHEN B.PROC_STS = '9997' THEN 'Y'
			  ELSE 'N' END AS RE_SEARCH_YN
			, BK1.BANK_NM
			, B.TRAN_AMT
			, A.VOTE_NO
			, E.DEPT_NAME AS FUND_DEPT_NM
			, B.PYM_RESV_TRAN_YN
			, DECODE(B.PYM_RESV_TRAN_YN, 'Y', '대상', '비대상') AS PYM_RESV_TRAN_YN_NM
			, A.SVC_DIST
			, CASE WHEN A.RETRY_YN = 'Y' AND B.END_GB = '5' AND B.PROC_STS = '0133' THEN 'Y' ELSE 'N' END AS RETRY_YN
			, CASE WHEN A.RETRY_YN = 'Y' AND B.END_GB = '5' AND B.PROC_STS = '0133' THEN '가능' ELSE '불가' END AS RETRY_YN_NM
			, A.EXP_PI_ID
			, A.LAST_STATUS
			, CD2.CMM_CD_NM AS LAST_STATUS_NM
			, FN_ACCT_FORMAT(B.IN_BANK_CD, B.IN_ACCT_NO)  as FORMAT_IN_ACCT_NO
			, BK2.BANK_NM AS IN_BANK_NM
			, B.IN_BANK_CD
			, B.IN_ACCT_NO
			, B.REGI_REF_NM
			, F.SEQ_NO
		FROM AP_IF_MAST A
			, AP_IF_DETAIL B
			, DWC_ASSIGN_INFO C
			, BA_ACCT_DEPT E
			, MB_TRANSFR_DIRECT F
			, BA_BANK BK1
			, BA_BANK BK2
			, DWC_CMM_CODE    CD1
			, DWC_CMM_CODE    CD2
			, BA_USER_GRP_ACCT_DEPT_A001_V V1
			, BA_USER_GRP_PAY_DEPT_A001_V V2
			, BA_USER_GRP_ACCT_A001_V V3
		WHERE A.REGI_DATE      = B.REGI_DATE
			AND A.SVC_DIST       = B.SVC_DIST
			AND A.REGI_NUM       = B.REGI_NUM
			AND A.TRAD_GB        = B.TRAD_GB
			AND A.OUT_BANK_CD    = BK1.BANK_CD(+)
			AND B.IN_BANK_CD     = BK2.BANK_CD(+)
			AND CD1.GRP_CD(+)    = 'S049'
			AND CD1.CMM_CD(+)    = A.END_GB
			AND CD2.GRP_CD(+)    = 'S043'
			AND CD2.CMM_CD(+)    = A.LAST_STATUS
			AND V1.USER_ID       = 'SYSTEMADMIN'
			AND A.AGNC_CODE      = V1.ACCT_DEPT_CD
			AND A.TRAD_GB LIKE V1.TRAD_GB||'%'
			AND A.FUND_DEPT_CODE = V2.PAY_DEPT_CD
			AND V2.USER_ID       = 'SYSTEMADMIN'
			AND A.TRAD_GB LIKE V2.TRAD_GB||'%'
			AND V3.USER_ID       = 'SYSTEMADMIN'
			AND NVL(C.ACCT_SEQ, 'NOT') = V3.ACCT_SEQ
			AND C.FINAL_APPR_YN(+) = 'Y'
			AND A.EXP_PI_ID      = C.PI_ID(+)
			AND A.TRAD_GB        = '102'
			AND A.LAST_STATUS IN ('20','30','31','51','52','55')
			AND A.FUND_DEPT_CODE = E.DEPT_CODE(+)
			AND A.TRAN_SET_DATE BETWEEN '20230301' and '20230401'
			AND B.AP_IF_DETAIL_PNO = F.BIZ_PNO(+)
		ORDER BY A.TRAN_SET_DATE DESC, A.REGI_NUM DESC, A.REGI_TIME DESC
		) TB
	GROUP BY ROLLUP(AP_IF_DETAIL_PNO)
	) TB2
;


























