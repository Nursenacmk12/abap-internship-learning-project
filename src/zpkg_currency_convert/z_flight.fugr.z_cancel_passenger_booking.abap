FUNCTION Z_CANCEL_PASSENGER_BOOKING.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_HAVAYOLU_KOD) TYPE  SBOOK-CARRID
*"     REFERENCE(IV_BAGLANTI_NO) TYPE  SBOOK-CONNID
*"     REFERENCE(IV_UCUS_TARIH) TYPE  SBOOK-FLDATE
*"     REFERENCE(IV_REZERVASYON_NUMARASI) TYPE  SBOOK-BOOKID
*"  EXPORTING
*"     REFERENCE(EV_SUCCESS) TYPE  CHAR5
*"     REFERENCE(EV_STATUS_TEXT) TYPE  CHAR20
*"  EXCEPTIONS
*"      BOOKING_NOT_FOUND
*"      RECORD_LOCKED
*"      UPDATE_FAILED
*"      ALREADY_CANCELLED
*"----------------------------------------------------------------------
DATA ls_sbook      TYPE sbook.
DATA lv_status_text TYPE char20.
  EV_SUCCESS = 'HAYIR'. "İşlem başarılı olana kadar sonuç Hayır kabul edilir.
  ev_status_text = 'Aktif'.

"KİLİTLEME YAPMA
CALL FUNCTION 'ENQUEUE_EZSBOOK'
EXPORTING
MANDT =  SY-MANDT  "kilit fonksiyonunun beklediği istemci numarası
"SY-MANDT → şu an giriş yaptığımız  SAP istemcisinin numarası
CARRID = IV_HAVAYOLU_KOD
CONNID = IV_BAGLANTI_NO
FLDATE = IV_UCUS_TARIH
BOOKID = IV_REZERVASYON_NUMARASI


 EXCEPTIONS
   foreign_lock  = 1   "kayıt başka kullanıcıda kilitli
   system_failure = 2   " sistem hatası
   OTHERS        = 3.    "diger hata

"kontrol etme
"sy-subrc : SAP’ın bir işlemden sonra işlemin başarılı olup olmadığını bildiren sistem alanıdır.
 IF sy-subrc <> 0.
   RAISE record_locked.

 ENDIF.

* Rezervasyon kaydının kontrol edilmesi
SELECT SINGLE *  "Verilen anahtarlara sahip rezervasyon gerçekten var mı diye kontrol eder.
  INTO ls_sbook
  FROM sbook
  WHERE carrid = IV_HAVAYOLU_KOD
    AND connid = IV_BAGLANTI_NO
    AND fldate = IV_UCUS_TARIH
    AND bookid = IV_REZERVASYON_NUMARASI.

IF sy-subrc <> 0. "Rezervasyon bulunamadıysa kilidi kaldırır.

  CALL FUNCTION 'DEQUEUE_EZSBOOK'
    EXPORTING
      mandt  = sy-mandt
      carrid = IV_HAVAYOLU_KOD
      connid = IV_BAGLANTI_NO
      fldate = IV_UCUS_TARIH
      bookid = IV_REZERVASYON_NUMARASI.

ev_status_text = 'Kayıt bulunamadı'.
RAISE booking_not_found.
  RAISE booking_not_found. "Kayıt bulunamadı exception'ını çalıştırır.

ENDIF.
"güvenlik kontrolü.
"ls_sbook-cancelled alanına bakar.
"Alan zaten:'X'
"ise rezervasyon daha önce iptal edilmiştir. Tekrar güncelleme yapılmaz.
  IF ls_sbook-cancelled = 'X'.
  CALL FUNCTION 'DEQUEUE_EZSBOOK'
    EXPORTING
      mandt  = sy-mandt
      carrid = iv_havayolu_kod
      connid = iv_baglanti_no
      fldate = iv_ucus_tarih
      bookid = iv_rezervasyon_numarasi.

  ev_success = 'HAYIR'.
  ev_status_text = 'zaten iptal'.
  RAISE already_cancelled.
ENDIF.
* Rezervasyonun iptal edilmesi

UPDATE sbook
  SET cancelled = 'X'   "SBOOK tablosundaki rezervasyonu iptal edilmiş olarak işaretler.
  WHERE carrid = IV_HAVAYOLU_KOD   "Yalnızca fonksiyona gönderilen tek rezervasyonu günceller.
    AND connid = IV_BAGLANTI_NO
    AND fldate = IV_UCUS_TARIH
    AND bookid = IV_REZERVASYON_NUMARASI.
"SBOOK tablosunda kalmaya devam eder fakat iptal edilmiş olarak işaretlenir.

IF sy-subrc <> 0. "Güncelleme başarısız olduysa çalışır.
  ROLLBACK WORK. "Güncelleme sırasında hata oluşursa tamamlanmamış işlemleri geri alır.
  CALL FUNCTION 'DEQUEUE_EZSBOOK'
    EXPORTING
      mandt  = sy-mandt
      carrid = IV_HAVAYOLU_KOD
      connid = IV_BAGLANTI_NO
      fldate = IV_UCUS_TARIH
      bookid = IV_REZERVASYON_NUMARASI.

  RAISE update_failed. "Güncelleme hatası exception'ını çalıştırır.
ENDIF.

* İşlemin veritabanına kalıcı olarak kaydedilmesi
COMMIT WORK AND WAIT. "Güncellemeyi veritabanına kalıcı olarak kaydeder.
IF sy-subrc <> 0. "Commit işlemi başarısız olduysa çalışır.

  CALL FUNCTION 'DEQUEUE_EZSBOOK'
    EXPORTING
      mandt  = sy-mandt
      carrid = IV_HAVAYOLU_KOD
      connid = IV_BAGLANTI_NO
      fldate = IV_UCUS_TARIH
      bookid = IV_REZERVASYON_NUMARASI.

  RAISE update_failed.
ENDIF.

* Kilidin kaldırılması
CALL FUNCTION 'DEQUEUE_EZSBOOK'
  EXPORTING
    mandt  = sy-mandt
    carrid = IV_HAVAYOLU_KOD
    connid = IV_BAGLANTI_NO
    fldate = IV_UCUS_TARIH
    bookid = IV_REZERVASYON_NUMARASI.

ev_success = 'EVET'. "Bilet iptal işleminin başarılı olduğunu belirtir.
ev_status_text = 'İptal Edildi'.
ENDFUNCTION.
