SELECT * FROM APP_APPR_COLL_TRAN_MAST;

SELECT * FROM AP_INOG_FNDSNTCNINFM;
SELECT * FROM AP_INOG_FNDSNTCNMAST$;
SELECT * FROM AP_INOG_FNDSNTCNSHR;

SELECT * FROM AP_IF_DETAIL
WHERE 1=1
	AND (REGI_NUM, TRAD_GB, REGI_DATE) IN (SELECT REGI_NUM, TRAD_GB, REGI_DATE FROM AP_IF_MAST$
		WHERE 1=1
			AND TRAD_GB = '102'
			AND LAST_STATUS = '52'
			AND REGI_DATE = '20231027');
			

SELECT TB.* FROM (
    SELECT
           C.AP_IF_MAST_PNO AS PNO
         , A.AP_IF_DETAIL_PNO AS DETAIL_PNO  /* AP_IF_DETAIL_PNO */
         , A.REGI_SEQ         /*순번 */
         , A.IN_BANK_CD       /*입금은행 코드 */
         , DECODE(A.IN_BANK_CD, '10000010', '농협', BK.BANK_NM) as BANK_NM            /*입금은행 이름 */
         , A.IN_ACCT_NO      /*입금계좌번호 */
         , FN_ACCT_FORMAT(A.IN_BANK_CD, A.IN_ACCT_NO) AS ACCT_NO /*FORMAT 적용 계좌번호 */
         , A.TRAN_AMT || '' AS TRAN_AMT  /*이체금액 */
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
         , F_ERR_MSG(A.OUT_BANK_CD,A.PROC_STS,'1', A.ORG_CD) AS FORMAT_ERR_MSG
         , A.ELCTRN_PAY_NO    /*전자납부번호*/
         , A.PAY_SE          /*납부구분*/
         , CD2.CMM_CD_NM AS PAY_SE_NM     /*납부구분명*/
         , A.GIRO_NO          /*지로번호*/
         , M.DEDT_BEFORE_YMD  /*지로납부기한*/
         , C.VOTE_NO          /*결의서번호*/
         , DECODE(C.KTCU_DEPT_NM,
                 '',
                (SELECT DEPT_NM
                   FROM DWC_DEPT_MSTR D, DWC_USER_MSTR B
                  WHERE B.USER_ID=C.KTCU_USER_ID
                    AND B.DEPT_CD=D.DEPT_CD ),
                 C.KTCU_DEPT_NM) AS DEPT_NM /*발의부서명*/
         , C.KTCU_USER_NM /*발의자명*/
         , C.LAST_STATUS
         , CD3.CMM_CD_NM AS LAST_STATUS_NM
         , (SELECT ERR_MSG FROM COM_ERRCDMST
             WHERE 1=1
               AND ORG_CD = 'KB_GIRO'
               AND ERR_CD = A.PROC_STS) AS ERR_MSG
      FROM AP_IF_DETAIL A
         , AP_IF_MAST C
         , DWC_CMM_CODE CD1
         , DWC_CMM_CODE CD2
         , DWC_CMM_CODE CD3
         , BA_BANK BK
         , (SELECT ELCTRN_PAY_NO
                 , MIN(DEDT_BEFORE_YMD) KEEP (DENSE_RANK FIRST ORDER BY PNO DESC) AS DEDT_BEFORE_YMD
              FROM MB_GIRO_INFO
             GROUP BY ELCTRN_PAY_NO) M
     WHERE A.REGI_DATE     = C.REGI_DATE
       AND A.REGI_NUM      = C.REGI_NUM
       AND A.TRAD_GB       = C.TRAD_GB
       AND A.SVC_DIST      = C.SVC_DIST
       AND A.ELCTRN_PAY_NO = M.ELCTRN_PAY_NO(+)
       AND A.END_GB        = CD1.CMM_CD(+)
       AND CD1.GRP_CD(+)   = 'S049'
       AND A.PAY_SE        = CD2.CMM_CD(+)
       AND CD2.GRP_CD(+)   = 'GC0014'
       AND C.LAST_STATUS   = CD3.CMM_CD(+)
       AND CD3.GRP_CD(+)   = 'S043'
       AND A.IN_BANK_CD    = BK.BANK_CD(+)
       AND C.LAST_STATUS  IN ('20','30','31','51', '52')
       AND C.TRAD_GB       = '100'          /*통합공과금*/
       AND A.ELCTRN_PAY_NO IS NOT NULL
     ORDER BY A.REGI_DATE DESC, TO_NUMBER(A.REGI_NUM) ASC, TO_NUMBER(A.REGI_SEQ) ASC
	) TB
WHERE 1 = 1
;



SELECT * FROM AP_IF_RCPTINFMSUB
WHERE REGI_DATE = '20231226'
	AND REGI_NUM = '2000073632'
	AND OUT_ACCT_NO IN (
		SELECT OUT_ACCT_NO FROM AP_IF_RCPTINFMSUB
		WHERE REGI_DATE = '20231226' AND REGI_NUM = '2000073632'
	);


/* 매입 */
select * from CATS_TMP_ACQUIRE
 where 1=1
   and cardno = '5585269916491635'
   and apprno = '30003271'
--   and apprtot <> acqutot
 order by seq desc
;

select 
    *
--    a.appramt as "매입금액", a.appramt1 as "매입금액1", a.vat as "부가세", a.vat1 as "부가세1", a.mccname, a.mcccode as "가맹점코드", a.* 
  from IF_FA_CDBUYL_D a
 where 1=1
--   and a.vat <> a.vat1 
   and cardno = '5585269916491635'
   and apprno = '30003271'
 order by seq desc  
;


SELECT * FROM DWC_CAL_MSTR
WHERE REGEXP_LIKE(CAL_NM, '[ㄱ-힣]') AND HOLD_CODE = '01';

SELECT * FROM DWC_CAL_MSTR
WHERE CAL_NM = '대체휴일';





















