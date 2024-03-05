
-- 자금통보현황 > 자금통보현황
SELECT
	TB2.PNO
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.DEPT_CD             END AS DEPT_CD
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE ''||TB2.PI_ID           END AS PI_ID
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.PCSN_DATE           END AS PCSN_DATE
	, CASE WHEN INOG_DSNC = 'I' THEN TB2.INOG_AMT || '' ELSE '0'   END AS INOG_AMT_IMP
	, CASE WHEN INOG_DSNC = 'O' THEN TB2.INOG_AMT || '' ELSE '0'   END AS INOG_AMT_EXP
	, TB2.INOG_AMT_A || '' AS INOG_AMT_A
	, TB2.INOG_AMT_B || '' AS INOG_AMT_B
	, TB2.INOG_AMT_C || '' AS INOG_AMT_C
	, TB2.INOG_AMT_D || '' AS INOG_AMT_D
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.ERP_GB              END AS ERP_GB
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.DEPT_CD_TXT         END AS DEPT_CD_TXT
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.CANCEL_POSBL_YN     END AS CANCEL_POSBL_YN
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.CNTN                END AS CNTN
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.INOG_DSNC           END AS INOG_DSNC
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.INOG_DSNC_TXT       END AS INOG_DSNC_TXT
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.ARAP_CD             END AS ARAP_CD
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.ARAP_CD_TXT         END AS ARAP_CD_TXT
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.SNCT_MSCD           END AS SNCT_MSCD
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.SNCT_MSCD_TXT       END AS SNCT_MSCD_TXT
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.IN_ACCT_NO          END AS IN_ACCT_NO
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.IN_ACCT_NO_FORMAT   END AS IN_ACCT_NO_FORMAT
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.OUT_ACCT_NO         END AS OUT_ACCT_NO
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.OUT_ACCT_NO_FORMAT  END AS OUT_ACCT_NO_FORMAT
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.CUST_NM             END AS CUST_NM
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.REGI_DATE           END AS REGI_DATE
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.REG_USER_ID         END AS REG_USER_ID
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.REGI_NUM||''        END AS REGI_NUM
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.RETURN_POSIBL_YN    END AS RETURN_POSIBL_YN
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.LAST_STATUS         END AS LAST_STATUS
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.CONFIRM_DT          END AS CONFIRM_DT
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.MAST_LAST_STATUS    END AS MAST_LAST_STATUS
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.MAST_LAST_STATUS_NM END AS MAST_LAST_STATUS_NM
	, TB2.GINFO
FROM(
	SELECT
		TB.PNO
		, MAX(TB.DEPT_CD            ) AS DEPT_CD
		, MAX(TB.PI_ID              ) AS PI_ID
		, MAX(TB.PCSN_DATE          ) AS PCSN_DATE
		, SUM(TB.INOG_AMT           ) AS INOG_AMT
		, SUM(TB.INOG_AMT_A         ) AS INOG_AMT_A
		, SUM(TB.INOG_AMT_B         ) AS INOG_AMT_B
		, SUM(TB.INOG_AMT_C         ) AS INOG_AMT_C
		, SUM(TB.INOG_AMT_D         ) AS INOG_AMT_D
		, MAX(TB.ERP_GB             ) AS ERP_GB
		, MAX(TB.DEPT_CD_TXT        ) AS DEPT_CD_TXT
		, MAX(TB.CANCEL_POSBL_YN    ) AS CANCEL_POSBL_YN
		, MAX(TB.CNTN               ) AS CNTN
		, MAX(TB.INOG_DSNC          ) AS INOG_DSNC
		, MAX(TB.INOG_DSNC_TXT      ) AS INOG_DSNC_TXT
		, MAX(TB.ARAP_CD            ) AS ARAP_CD
		, MAX(TB.ARAP_CD_TXT        ) AS ARAP_CD_TXT
		, MAX(TB.SNCT_MSCD          ) AS SNCT_MSCD
		, MAX(TB.SNCT_MSCD_TXT      ) AS SNCT_MSCD_TXT
		, MAX(TB.IN_ACCT_NO         ) AS IN_ACCT_NO
		, MAX(TB.IN_ACCT_NO_FORMAT  ) AS IN_ACCT_NO_FORMAT
		, MAX(TB.OUT_ACCT_NO        ) AS OUT_ACCT_NO
		, MAX(TB.OUT_ACCT_NO_FORMAT ) AS OUT_ACCT_NO_FORMAT
		, MAX(TB.CUST_NM            ) AS CUST_NM
		, MAX(TB.REGI_DATE          ) AS REGI_DATE
		, MAX(TB.REG_USER_ID        ) AS REG_USER_ID
		, MAX(TB.REGI_NUM           ) AS REGI_NUM
		, MAX(TB.RETURN_POSIBL_YN   ) AS RETURN_POSIBL_YN
		, MAX(TB.CONFIRM_DT         ) AS CONFIRM_DT
		, MAX(TB.LAST_STATUS        ) AS LAST_STATUS
		, MAX(TB.MAST_LAST_STATUS   ) AS MAST_LAST_STATUS
		, MAX(TB.MAST_LAST_STATUS_NM) AS MAST_LAST_STATUS_NM
		, GROUPING(TB.PNO           ) AS GINFO
	FROM (
		SELECT
			   A.AP_INOG_FNDSNTCNINFM_PNO AS PNO
			 , A.DEPT_CD                                            /*부서코드*/
			 , D.DEPT_NM DEPT_CD_TXT                                /*부서명*/
			 , B.EXP_PI_ID AS PI_ID                                 /*프로세스 인스턴스ID*/
			 , A.PCSN_DATE
			 , NVL(A.INOG_AMT, 0) INOG_AMT                          /*금액*/
			 , NVL(CASE WHEN A.INOG_DSNC='O' AND A.SNCT_MSCD = (SELECT CMM_CD
																FROM DWC_CMM_CODE
																WHERE GRP_CD  = 'KT002'
																   AND CD_DESC = '직불배분')
						THEN A.INOG_AMT END,0) INOG_AMT_A                         /*직불배분*/
			 , NVL(CASE WHEN A.INOG_DSNC='O' AND A.SNCT_MSCD = (SELECT CMM_CD
																FROM DWC_CMM_CODE
																WHERE GRP_CD  = 'KT002'
																   AND CD_DESC = '계좌이체')
						THEN A.INOG_AMT END,0) INOG_AMT_B                         /*계좌이체*/
			 , NVL(CASE WHEN A.INOG_DSNC='O' AND A.SNCT_MSCD = (SELECT CMM_CD
																FROM DWC_CMM_CODE
																WHERE GRP_CD  = 'KT002'
																   AND CD_DESC = '기타')
						THEN A.INOG_AMT END,0) INOG_AMT_C                                       /*기타*/
			 , NVL(CASE WHEN A.INOG_DSNC='O' AND A.SNCT_MSCD = (SELECT CMM_CD
																FROM DWC_CMM_CODE
																WHERE GRP_CD  = 'KT002'
																   AND CD_DESC = '지준이체')
						THEN A.INOG_AMT END,0) INOG_AMT_D                                       /*지준이체*/
			 , NVL(A.ERP_GB,'N') AS ERP_GB
			 , CASE WHEN B.LAST_STATUS IN ('21', '10') THEN 'Y' ELSE 'N' END CANCEL_POSBL_YN
			 , A.CNTN                                                 /*내용*/
			 , A.INOG_DSNC                                            /*수입지출구분*/
			 , CASE WHEN A.INOG_DSNC = 'I' AND A.SNCT_MSCD = (SELECT CMM_CD
															   FROM DWC_CMM_CODE
															   WHERE GRP_CD = 'KT002'
																 AND CD_DESC = '직불배분')
					THEN '환입'
					WHEN A.INOG_DSNC = 'I'
					THEN '수입'
					WHEN A.INOG_DSNC = 'O'
					THEN '지출' END INOG_DSNC_TXT                      /*수지구분(수입,지출)*/
			 , A.ARAP_CD                                              /*수지항목구분코드*/
			 , CD1.CD_DESC AS ARAP_CD_TXT                             /*수지항목*/
			 , A.SNCT_MSCD                                            /*결재수단코드*/
			 , CD2.CD_DESC AS SNCT_MSCD_TXT                           /*결재수단*/
			 , DECODE(A.INOG_DSNC,'O',A.IN_ACCT_NO) AS IN_ACCT_NO     /*입금계좌번호*/
			 , DECODE(A.INOG_DSNC,'I',A.IN_ACCT_NO) AS OUT_ACCT_NO    /*출금계좌번호*/
			 , DECODE(A.INOG_DSNC,'O',FN_ACCT_FORMAT(A.IN_BANK_CD, A.IN_ACCT_NO)) AS IN_ACCT_NO_FORMAT   /*입금계좌번호*/
			 , DECODE(A.INOG_DSNC,'I',FN_ACCT_FORMAT(A.IN_BANK_CD, A.IN_ACCT_NO)) AS OUT_ACCT_NO_FORMAT   /*출금계좌번호*/
			 , A.CUST_NM
			 , A.REGI_DATE
			 , A.REG_USER_ID
			 , A.REGI_NUM
			 , CASE WHEN NVL(B.LAST_STATUS, '21') = '21' THEN 'Y' ELSE 'N' END AS RETURN_POSIBL_YN
			 , A.CONFIRM_DT
			 , A.LAST_STATUS
			 , B.LAST_STATUS AS MAST_LAST_STATUS
			 , CASE WHEN B.LAST_STATUS IS NULL THEN CASE WHEN A.LAST_STATUS = '21' THEN '확인' ELSE CD4.CMM_CD_NM END
					ELSE CASE WHEN B.LAST_STATUS = '21' THEN '확인' ELSE CD3.CMM_CD_NM END
					END MAST_LAST_STATUS_NM
		FROM AP_INOG_FNDSNTCNINFM A
			 , AP_INOG_FNDSNTCNMAST B
			 , DWC_DEPT_MSTR        D
			 , DWC_CMM_CODE         CD1
			 , DWC_CMM_CODE         CD2
			 , DWC_CMM_CODE         CD3
			 , DWC_CMM_CODE         CD4
		WHERE 1 = 1
			AND A.LAST_STATUS IN ('91', '52')
			AND A.REGI_DATE      = B.REGI_DATE(+)
			AND A.REGI_NUM       = B.REGI_NUM(+)
			AND A.REG_USER_ID    = B.REG_USER_ID(+)
			AND A.ARAP_CD        = CD1.CMM_CD(+)
			AND CD1.GRP_CD(+)    = 'KT003'
			AND A.SNCT_MSCD = CD2.CMM_CD(+)
			AND CD2.GRP_CD(+)    = 'KT002'
			AND B.LAST_STATUS    = CD3.CMM_CD(+)
			AND CD3.GRP_CD(+)    = 'S043'
			AND A.LAST_STATUS    = CD4.CMM_CD(+)
			AND CD4.GRP_CD(+)    = 'S043'
			AND A.DEPT_CD        = D.DEPT_CD(+)
--			AND A.PCSN_DATE BETWEEN '20240228' and '20240228'
		) TB
		GROUP BY ROLLUP(PNO)
	) TB2
	ORDER BY TB2.GINFO, TB2.PCSN_DATE DESC, TB2.PI_ID DESC
;



-- 자금통보현황 > 직불송금 결제등록
SELECT
	TB2.PNO
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.REGI_DATE          END AS REGI_DATE
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.REG_USER_ID        END AS REG_USER_ID
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.REG_USER_NM        END AS REG_USER_NM
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE ''||TB2.REGI_NUM       END AS REGI_NUM
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.SAN_WORK_GB        END AS SAN_WORK_GB
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.INOG_DSNC          END AS INOG_DSNC
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.INOG_DSNC_TXT      END AS INOG_DSNC_TXT
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.CUST_CD            END AS CUST_CD
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.CUST_NM            END AS CUST_NM
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.CNTN               END AS CNTN
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.DEPT_CD            END AS DEPT_CD
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.DEPT_CD_TXT        END AS DEPT_CD_TXT
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.ARAP_CD            END AS ARAP_CD
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.ARAP_CD_TXT        END AS ARAP_CD_TXT
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.SNCT_MSCD          END AS SNCT_MSCD
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.SNCT_MSCD_TXT      END AS SNCT_MSCD_TXT
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.CURR_CD            END AS CURR_CD
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.PCSN_DATE          END AS PCSN_DATE
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.IN_ACCT_NO         END AS IN_ACCT_NO
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.OUT_ACCT_NO        END AS OUT_ACCT_NO
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.IN_BANK_CD         END AS IN_BANK_CD
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.IN_BANK_NM         END AS IN_BANK_NM
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.OUT_BANK_CD        END AS OUT_BANK_CD
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.OUT_BANK_NM        END AS OUT_BANK_NM
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.BIZ_NO             END AS BIZ_NO
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.IN_ACCT_NO_FORMAT  END AS IN_ACCT_NO_FORMAT
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.OUT_ACCT_NO_FORMAT END AS OUT_ACCT_NO_FORMAT
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE ''||TB2.PI_ID          END AS PI_ID
	, TB2.INOG_AMT_A || '' AS INOG_AMT_A
	, TB2.INOG_AMT_B || '' AS INOG_AMT_B
	, TB2.INOG_AMT_C || '' AS INOG_AMT_C
	, TB2.INOG_AMT_D || '' AS INOG_AMT_D
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE ''||TB2.INOG_AMT       END AS INOG_AMT
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE ''||TB2.REG_DTM        END AS REG_DTM
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE ''||TB2.IN_ACCT_SEQ    END AS IN_ACCT_SEQ
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE ''||TB2.OUT_ACCT_SEQ   END AS OUT_ACCT_SEQ
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE ''||TB2.CONFIRM_DT     END AS CONFIRM_DT
	, '('||OUT_BANK_NM||')'||OUT_ACCT_NO_FORMAT||'<'||OUT_ACCT_NICK_NM||'>' AS OUT_ACCT_NO_TXT
	, '('||IN_BANK_NM||')'||IN_ACCT_NO_FORMAT||'<'||IN_ACCT_NICK_NM||'>'    AS IN_ACCT_NO_TXT
	, TB2.GINFO
FROM(
	SELECT
		TB.PNO
		, MAX(TB.REGI_DATE         ) AS REGI_DATE
		, MAX(TB.REG_USER_ID       ) AS REG_USER_ID
		, MAX(TB.REG_USER_NM       ) AS REG_USER_NM
		, MAX(TB.REGI_NUM          ) AS REGI_NUM
		, MAX(TB.SAN_WORK_GB       ) AS SAN_WORK_GB
		, MAX(TB.INOG_DSNC         ) AS INOG_DSNC
		, MAX(TB.INOG_DSNC_TXT     ) AS INOG_DSNC_TXT
		, MAX(TB.CUST_CD           ) AS CUST_CD
		, MAX(TB.CUST_NM           ) AS CUST_NM
		, MAX(TB.CNTN              ) AS CNTN
		, MAX(TB.DEPT_CD           ) AS DEPT_CD
		, MAX(TB.DEPT_CD_TXT       ) AS DEPT_CD_TXT
		, MAX(TB.ARAP_CD           ) AS ARAP_CD
		, MAX(TB.ARAP_CD_TXT       ) AS ARAP_CD_TXT
		, MAX(TB.SNCT_MSCD         ) AS SNCT_MSCD
		, MAX(TB.SNCT_MSCD_TXT     ) AS SNCT_MSCD_TXT
		, MAX(TB.CURR_CD           ) AS CURR_CD
		, MAX(TB.PCSN_DATE         ) AS PCSN_DATE
		, MAX(TB.IN_ACCT_NO        ) AS IN_ACCT_NO
		, MAX(TB.OUT_ACCT_NO       ) AS OUT_ACCT_NO
		, MAX(TB.IN_BANK_CD        ) AS IN_BANK_CD
		, MAX(TB.IN_BANK_NM        ) AS IN_BANK_NM
		, MAX(TB.IN_ACCT_NICK_NM   ) AS IN_ACCT_NICK_NM
		, MAX(TB.OUT_BANK_CD       ) AS OUT_BANK_CD
		, MAX(TB.OUT_BANK_NM       ) AS OUT_BANK_NM
		, MAX(TB.OUT_ACCT_NICK_NM  ) AS OUT_ACCT_NICK_NM
		, MAX(TB.BIZ_NO            ) AS BIZ_NO
		, MAX(TB.IN_ACCT_NO_FORMAT ) AS IN_ACCT_NO_FORMAT
		, MAX(TB.OUT_ACCT_NO_FORMAT) AS OUT_ACCT_NO_FORMAT
		, MAX(TB.PI_ID             ) AS PI_ID
		, NVL(SUM(TB.INOG_AMT_A), 0) AS INOG_AMT_A
		, NVL(SUM(TB.INOG_AMT_B), 0) AS INOG_AMT_B
		, NVL(SUM(TB.INOG_AMT_C), 0) AS INOG_AMT_C
		, NVL(SUM(TB.INOG_AMT_D), 0) AS INOG_AMT_D
		, NVL(MAX(TB.INOG_AMT),   0) AS INOG_AMT
		, MAX(TB.REG_DTM           ) AS REG_DTM
		, MAX(TB.IN_ACCT_SEQ       ) AS IN_ACCT_SEQ
		, MAX(TB.OUT_ACCT_SEQ      ) AS OUT_ACCT_SEQ
		, MAX(TB.CONFIRM_DT        ) AS CONFIRM_DT
		, GROUPING(TB.PNO) AS GINFO
	FROM (
		SELECT
			   A.AP_INOG_FNDSNTCNMAST_PNO AS PNO
			 , A.REGI_DATE                                    /*등록일자*/
			 , A.REG_USER_ID                                  /*등록자ID(사업부서)*/
			 , U.USER_NM AS REG_USER_NM                       /*등록자명, 발의자명*/
			 , A.REGI_NUM                                     /*등록일련번호*/
			 , A.SAN_WORK_GB
			 , A.INOG_DSNC                                    /*수지구분(수입,지출)*/
			 , CASE WHEN A.INOG_DSNC = 'I' AND A.SNCT_MSCD = (SELECT CMM_CD
																FROM DWC_CMM_CODE
															   WHERE GRP_CD  = 'KT002'
																 AND CD_DESC = '직불배분')
						THEN '환입'
					WHEN A.INOG_DSNC = 'I'
						THEN '수입'
					WHEN A.INOG_DSNC = 'O'
						THEN '지출'
				END INOG_DSNC_TXT                        /*수지구분(수입,지출)*/
			 , A.CUST_CD                                      /*거래처구분코드*/
			 , A.CUST_NM                                      /*거래처명*/
			 , A.CNTN                                         /*내용*/
			 , A.DEPT_CD                                      /*부서코드*/
			 , D.DEPT_NM AS DEPT_CD_TXT                       /*부서명*/
			 , A.ARAP_CD                                      /*수지항목구분코드*/
			 , CD1.CD_DESC AS ARAP_CD_TXT                     /*수지항목*/
			 , A.SNCT_MSCD                                    /*결재수단코드*/
			 , CD2.CD_DESC AS SNCT_MSCD_TXT     /*결재수단*/
			 , A.CURR_CD                                      /*통화코드*/
			 , A.PCSN_DATE                                    /*자금처리년월일*/
			 , A.IN_ACCT_NO                                   /*입금계좌번호*/
			 , A.OUT_ACCT_NO                                  /*출금계좌번호*/
			 , A.IN_BANK_CD                                   /*입금은행코드*/
			 , B_IN.BANK_NM AS IN_BANK_NM                     /*입금은행명*/
			 , F_IN.ACCT_NICK_NM AS IN_ACCT_NICK_NM           /*입금계좌별칭*/
			 , A.OUT_BANK_CD                                  /*출금은행코드*/
			 , B_OUT.BANK_NM AS OUT_BANK_NM                   /*출금은행명*/
			 , F_OUT.ACCT_NICK_NM AS OUT_ACCT_NICK_NM         /*출금계좌별칭*/
			 , A.BIZ_NO                                       /*사업장코드*/
			 , FN_ACCT_FORMAT(A.IN_BANK_CD, A.IN_ACCT_NO) AS IN_ACCT_NO_FORMAT   /*입금계좌번호*/
			 , FN_ACCT_FORMAT(A.OUT_BANK_CD, A.OUT_ACCT_NO) AS OUT_ACCT_NO_FORMAT   /*출금계좌번호*/
			 , A.EXP_PI_ID AS PI_ID
			 , CASE WHEN A.SNCT_MSCD = (SELECT CMM_CD
										FROM DWC_CMM_CODE
										WHERE GRP_CD  = 'KT002'
										   AND CD_DESC = '직불배분')
				THEN A.INOG_AMT END INOG_AMT_A
			 , CASE WHEN A.SNCT_MSCD = (SELECT CMM_CD
										FROM DWC_CMM_CODE
										WHERE GRP_CD  = 'KT002'
										   AND CD_DESC = '계좌이체')
				 THEN A.INOG_AMT END INOG_AMT_B
			 , CASE WHEN A.SNCT_MSCD = (SELECT CMM_CD
										FROM DWC_CMM_CODE
										WHERE GRP_CD  = 'KT002'
										  AND CD_DESC = '기타')
				THEN A.INOG_AMT END INOG_AMT_C
			 , CASE WHEN A.SNCT_MSCD = (SELECT CMM_CD
										FROM DWC_CMM_CODE
									    WHERE GRP_CD  = 'KT002'
										 AND CD_DESC = '지준이체')
				THEN A.INOG_AMT END INOG_AMT_D
			 , A.INOG_AMT
			 , A.REG_DTM
			 , F_IN.ACCT_SEQ AS IN_ACCT_SEQ
			 , F_OUT.ACCT_SEQ AS OUT_ACCT_SEQ
			 , B.CONFIRM_DT
		FROM AP_INOG_FNDSNTCNMAST A
			 , AP_INOG_FNDSNTCNINFM B
			 , DWC_USER_MSTR        U
			 , DWC_DEPT_MSTR        D
			 , DWC_CMM_CODE         CD1
			 , DWC_CMM_CODE         CD2
			 , FN_ACCT              F_IN
			 , FN_ACCT              F_OUT
			 , BA_BANK              B_IN
			 , BA_BANK              B_OUT
		WHERE A.REGI_DATE        = B.REGI_DATE
		   AND A.REGI_NUM         = B.REGI_NUM
		   AND A.REG_USER_ID      = B.REG_USER_ID
		   AND A.REG_USER_ID      = U.USER_ID(+)
		   AND A.LAST_STATUS      IN ('21', '32')
		   AND A.PCSN_DATE BETWEEN '20230701' and '20230715'
		   AND A.SNCT_MSCD = (SELECT CMM_CD
								FROM DWC_CMM_CODE
							   WHERE GRP_CD = 'KT002'
								 AND CD_DESC = '직불배분')
		   --AND B.DRPM_SHR_APLY_YN='N'
		   AND A.DEPT_CD          = D.DEPT_CD(+)
		   AND A.ARAP_CD          = CD1.CMM_CD(+)
		   AND CD1.GRP_CD(+)      = 'KT003'
		   AND A.SNCT_MSCD        = CD2.CMM_CD(+)
		   AND CD2.GRP_CD(+)      = 'KT002'
		   AND A.IN_ACCT_NO       = F_IN.ACCT_NO(+)
		   AND A.OUT_ACCT_NO      = F_OUT.ACCT_NO(+)
		   AND A.IN_BANK_CD       = B_IN.BANK_CD(+)
		   AND A.OUT_BANK_CD      = B_OUT.BANK_CD(+)
		) TB
		GROUP BY ROLLUP(PNO)
	) TB2
	ORDER BY TB2.GINFO, TB2.PCSN_DATE DESC, TB2.PI_ID DESC
;



-- 자금통보현황 > 직불배분현황
SELECT
	TB2.PNO
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.REGI_DATE          END AS REGI_DATE
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.REG_USER_ID        END AS REG_USER_ID
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE ''||TB2.REGI_NUM       END AS REGI_NUM
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.SAN_WORK_GB        END AS SAN_WORK_GB
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.LAST_STATUS        END AS LAST_STATUS
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.LAST_STATUS_TXT    END AS LAST_STATUS_TXT
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.INOG_DSNC          END AS INOG_DSNC
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.INOG_DSNC_TXT      END AS INOG_DSNC_TXT
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.CUST_CD            END AS CUST_CD
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.CUST_NM            END AS CUST_NM
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.CNTN               END AS CNTN
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.DEPT_CD            END AS DEPT_CD
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.DEPT_CD_TXT        END AS DEPT_CD_TXT
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.ARAP_CD            END AS ARAP_CD
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.ARAP_CD_TXT        END AS ARAP_CD_TXT
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.SNCT_MSCD          END AS SNCT_MSCD
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.SNCT_MSCD_TXT      END AS SNCT_MSCD_TXT
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.CURR_CD            END AS CURR_CD
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.PCSN_DATE          END AS PCSN_DATE
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.IN_ACCT_NO         END AS IN_ACCT_NO
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.OUT_ACCT_NO        END AS OUT_ACCT_NO
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.IN_BANK_CD         END AS IN_BANK_CD
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.BIZ_NO             END AS BIZ_NO
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.IN_ACCT_NO_FORMAT  END AS IN_ACCT_NO_FORMAT
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.OUT_ACCT_NO_FORMAT END AS OUT_ACCT_NO_FORMAT
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE ''||TB2.PI_ID          END AS PI_ID
	, TB2.INOG_AMT || '' AS INOG_AMT
	, CASE WHEN TB2.GINFO = 1 THEN '' ELSE TB2.DRPM_SHR_APLY_YN   END AS DRPM_SHR_APLY_YN
	, TB2.GINFO
FROM(
	SELECT
		   TB.PNO
		 , MAX(TB.REGI_DATE         ) AS REGI_DATE
		 , MAX(TB.REG_USER_ID       ) AS REG_USER_ID
		 , MAX(TB.REGI_NUM          ) AS REGI_NUM
		 , MAX(TB.SAN_WORK_GB       ) AS SAN_WORK_GB
		 , MAX(TB.LAST_STATUS       ) AS LAST_STATUS
		 , MAX(TB.LAST_STATUS_TXT   ) AS LAST_STATUS_TXT
		 , MAX(TB.INOG_DSNC         ) AS INOG_DSNC
		 , MAX(TB.INOG_DSNC_TXT     ) AS INOG_DSNC_TXT
		 , MAX(TB.CUST_CD           ) AS CUST_CD
		 , MAX(TB.CUST_NM           ) AS CUST_NM
		 , MAX(TB.CNTN              ) AS CNTN
		 , MAX(TB.DEPT_CD           ) AS DEPT_CD
		 , MAX(TB.DEPT_CD_TXT       ) AS DEPT_CD_TXT
		 , MAX(TB.ARAP_CD           ) AS ARAP_CD
		 , MAX(TB.ARAP_CD_TXT       ) AS ARAP_CD_TXT
		 , MAX(TB.SNCT_MSCD         ) AS SNCT_MSCD
		 , MAX(TB.SNCT_MSCD_TXT     ) AS SNCT_MSCD_TXT
		 , MAX(TB.CURR_CD           ) AS CURR_CD
		 , MAX(TB.PCSN_DATE         ) AS PCSN_DATE
		 , MAX(TB.IN_ACCT_NO        ) AS IN_ACCT_NO
		 , MAX(TB.OUT_ACCT_NO       ) AS OUT_ACCT_NO
		 , MAX(TB.IN_BANK_CD        ) AS IN_BANK_CD
		 , MAX(TB.BIZ_NO            ) AS BIZ_NO
		 , MAX(TB.IN_ACCT_NO_FORMAT ) AS IN_ACCT_NO_FORMAT
		 , MAX(TB.OUT_ACCT_NO_FORMAT) AS OUT_ACCT_NO_FORMAT
		 , MAX(TB.PI_ID             ) AS PI_ID
		 , NVL(SUM(TB.INOG_AMT),   0) AS INOG_AMT
		 , MAX(TB.DRPM_SHR_APLY_YN  ) AS DRPM_SHR_APLY_YN
		 , GROUPING(TB.PNO) AS GINFO
	FROM (
		SELECT
			   A.AP_INOG_FNDSNTCNMAST_PNO AS PNO
			 , A.REGI_DATE                                    /*등록일자*/
			 , A.REG_USER_ID                                  /*등록자ID(사업부서)*/
			 , A.REGI_NUM                                     /*등록일련번호*/
			 , A.SAN_WORK_GB
			 , A.LAST_STATUS
			 , CD3.CMM_CD_NM AS LAST_STATUS_TXT
			 , A.INOG_DSNC                                    /*수지구분(수입,지출)*/
			 , CASE WHEN A.INOG_DSNC = 'I' AND A.SNCT_MSCD = (SELECT CMM_CD
															   FROM DWC_CMM_CODE
															   WHERE GRP_CD  = 'KT002'
																AND CD_DESC = '직불배분')
						THEN '환입'
					WHEN A.INOG_DSNC = 'I'
						THEN '수입'
					WHEN A.INOG_DSNC = 'O'
						THEN '지출'
				END INOG_DSNC_TXT                        /*수지구분(수입,지출)*/
			 , A.CUST_CD                                      /*거래처구분코드*/
			 , A.CUST_NM                                      /*거래처명*/
			 , A.CNTN                                         /*내용*/
			 , A.DEPT_CD                                      /*부서코드*/
			 , D.DEPT_NM AS DEPT_CD_TXT                       /*부서명*/
			 , A.ARAP_CD                                      /*수지항목구분코드*/
			 , CD1.CD_DESC AS ARAP_CD_TXT                     /*수지항목*/
			 , A.SNCT_MSCD                                    /*결재수단코드*/
			 , CD2.CD_DESC AS SNCT_MSCD_TXT                   /*결재수단*/
			 , A.CURR_CD                                      /*통화코드*/
			 , A.PCSN_DATE                                    /*자금처리년월일*/
			 , A.IN_ACCT_NO                                   /*입금계좌번호*/
			 , A.OUT_ACCT_NO                                  /*출금계좌번호*/
			 , A.IN_BANK_CD                                   /*입금은행코드*/
			 , A.BIZ_NO                                       /*사업장코드*/
			 , FN_ACCT_FORMAT(A.IN_BANK_CD, A.IN_ACCT_NO) AS IN_ACCT_NO_FORMAT   /*입금계좌번호*/
			 , FN_ACCT_FORMAT(A.OUT_BANK_CD, A.OUT_ACCT_NO) AS OUT_ACCT_NO_FORMAT   /*출금계좌번호*/
			 , A.EXP_PI_ID AS PI_ID
			 , A.INOG_AMT
			 , B.DRPM_SHR_APLY_YN
		FROM AP_INOG_FNDSNTCNMAST A
			 , AP_INOG_FNDSNTCNINFM B
			 , DWC_DEPT_MSTR        D
			 , DWC_CMM_CODE         CD1
			 , DWC_CMM_CODE         CD2
			 , DWC_CMM_CODE         CD3
		WHERE A.REGI_DATE        = B.REGI_DATE
		   AND A.REGI_NUM         = B.REGI_NUM
		   AND A.REG_USER_ID      = B.REG_USER_ID
		   AND A.LAST_STATUS      IN ('10', '20', '32')
		   AND A.SAN_WORK_GB      = 'J10'
		   AND A.DEPT_CD          = D.DEPT_CD(+)
		   AND A.ARAP_CD          = CD1.CMM_CD(+)
		   AND CD1.GRP_CD(+)      = 'KT003'
		   AND A.SNCT_MSCD        = CD2.CMM_CD(+)
		   AND CD2.GRP_CD(+)      = 'KT002'
		   AND A.LAST_STATUS      = CD3.CMM_CD(+)
		   AND CD3.GRP_CD(+)      = 'S043'
		   AND A.PCSN_DATE BETWEEN '20230710' and '20230711'
		ORDER BY A.EXP_PI_ID DESC
		) TB
		GROUP BY ROLLUP(PNO)
	) TB2
	ORDER BY TB2.GINFO, TB2.PCSN_DATE DESC, TB2.PI_ID DESC
;



-- 자금통보현황 > 자금통보 내역조회









































