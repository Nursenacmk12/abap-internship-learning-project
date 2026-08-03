FUNCTION Z_CONVERT_FLIGHT_PRICE.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_ORIJINAL_FIYAT) TYPE  SFLIGHT-PAYMENTSUM
*"     REFERENCE(IV_ORIJINAL_BIRIM) TYPE  SFLIGHT-CURRENCY
*"     REFERENCE(IV_HEDEF_PARA_BIRIMI) TYPE  SFLIGHT-CURRENCY
*"     REFERENCE(IV_KUR_TARIHI) TYPE  SFLIGHT-FLDATE
*"  EXPORTING
*"     REFERENCE(EV_CEVRILMIS_FIYAT) TYPE  SFLIGHT-PAYMENTSUM
*"  EXCEPTIONS
*"      TARIHTE_KUR_BULUNAMADI
*"      PARA_BIRIMI_BULUNAMADI
*"----------------------------------------------------------------------

IF IV_ORIJINAL_BIRIM = IV_HEDEF_PARA_BIRIMI .
   EV_CEVRILMIS_FIYAT =  IV_ORIJINAL_FIYAT.
   RETURN.
ENDIF.

CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
  EXPORTING
*   CLIENT                  = SY-MANDT
    date                    = IV_KUR_TARIHI
    foreign_amount          = IV_ORIJINAL_FIYAT
    foreign_currency        = IV_ORIJINAL_BIRIM
    local_currency = iv_hedef_para_birimi
*   RATE                    = 0
*   TYPE_OF_RATE            = 'M'
*   READ_TCURR              = 'X'
 IMPORTING
*   EXCHANGE_RATE           =
*   FOREIGN_FACTOR          =
   LOCAL_AMOUNT            = ev_cevrilmis_fiyat


*   LOCAL_FACTOR            =
*   EXCHANGE_RATEX          =
*   FIXED_RATE              =
*   DERIVED_RATE_TYPE       =
 EXCEPTIONS
   NO_RATE_FOUND           = 1
   OVERFLOW                = 2
   NO_FACTORS_FOUND        = 3.
*   NO_SPREAD_FOUND         = 4
*   DERIVED_2_TIMES         = 5
*   OTHERS                  = 6
          .
IF sy-subrc = 1.
  RAISE TARIHTE_KUR_BULUNAMADI.
ELSEIF sy-subrc <> 0.
  RAISE para_birimi_bulunamadi.
* Implement suitable error handling here
ENDIF.

ENDFUNCTION.
