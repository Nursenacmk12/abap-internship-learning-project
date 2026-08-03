*&---------------------------------------------------------------------*
*& Report Z_SFLIGHT_JOIN
*&---------------------------------------------------------------------*
*& Uçuş Doluluk ve Rezervasyon Raporu
*&---------------------------------------------------------------------*

REPORT z_sflight_join.

*---------------------------------------------------------------------*
* Genel Tanımlar
*---------------------------------------------------------------------*
" SAP'in hazır ikon sabitlerini kullanabilmek için tanımlanmıştır.
PARAMETERS: p_rapor RADIOBUTTON GROUP grp DEFAULT 'X'.
TYPE-POOLS: icon.

" SALV sınıfının program çalışırken yüklenmesini sağlar.
CLASS cl_salv_table DEFINITION LOAD.

" Seçim ekranında ve programda kullanılacak SAP tabloları.
TABLES:
  sflight,
  scarr,
  spfli,
  sbook.
*---------------------------------------------------------------------*
* Seçim Ekranı ve Filtreleme Alanları
*---------------------------------------------------------------------*
" NO INTERVALS:
" Sağ taraftaki aralık kutusunu kaldırır.
" Çoklu seçim butonu kullanılmaya devam eder.
SELECT-OPTIONS:
  s_carrid FOR sflight-carrid  NO INTERVALS,
  s_cname  FOR scarr-carrname  NO INTERVALS,
  s_connid FOR sflight-connid  NO INTERVALS,
  s_ctrfr  FOR spfli-countryfr NO INTERVALS,
  s_cityfr FOR spfli-cityfrom  NO INTERVALS,
  s_ctrto  FOR spfli-countryto NO INTERVALS,
  s_cityto FOR spfli-cityto    NO INTERVALS,
  s_fldate FOR sflight-fldate  NO INTERVALS.
PARAMETERS:P_iptal RADIOBUTTON GROUP grp.
SELECTION-SCREEN BEGIN OF BLOCK b_iptal
  WITH FRAME TITLE TEXT-010.

PARAMETERS:
  p_icarr TYPE sbook-carrid,
  p_iconn TYPE sbook-connid,
  p_idate TYPE sbook-fldate,
  p_ibook TYPE sbook-bookid.
 " p_iptal AS CHECKBOX.

SELECTION-SCREEN END OF BLOCK b_iptal.
*---------------------------------------------------------------------*
* Final Sonuç Yapısı
*---------------------------------------------------------------------*
* Hesaplanan ve ALV ekranında gösterilecek alanları içerir.
*---------------------------------------------------------------------*
TYPES: BEGIN OF ty_result,

         " Havayolu ve uçuş bilgileri
         carrid       TYPE sflight-carrid,
         carrname     TYPE scarr-carrname,
         connid       TYPE sflight-connid,
         fldate       TYPE sflight-fldate,

         " Kalkış ve varış bilgileri
         countryfr    TYPE spfli-countryfr,
         cityfrom     TYPE spfli-cityfrom,
         countryto    TYPE spfli-countryto,
         cityto       TYPE spfli-cityto,

         " Uçak tipi
         planetype    TYPE sflight-planetype,

         " Hesaplanan koltuk bilgileri
         max_seat     TYPE i,
         occ_seat     TYPE i,
         empty_seat   TYPE i,

         " Hesaplanan doluluk oranı
         occ_rate     TYPE p LENGTH 5 DECIMALS 2,

         " Rezervasyon sayısı
         book_count   TYPE i,

         " Rezervasyon tutarı ve para birimi
         paymentsum   TYPE sflight-paymentsum,
         currency     TYPE sflight-currency,
         tl_karsiligi TYPE sflight-paymentsum ,  "Bu alan ALV’de yeni kolon olarak görünecek.

         " Doluluk durumu için ikon ve açıklama
         status_icon  TYPE icon_d,
         status_text  TYPE char20,

         " Her satırın renk bilgilerini tutan iç tablo
         row_color    TYPE lvc_t_scol,

       END OF ty_result.

*---------------------------------------------------------------------*
* Ham Veri Yapısı
*---------------------------------------------------------------------*
* SELECT sorgusundan gelen, henüz hesaplanmamış alanları içerir.
*---------------------------------------------------------------------*
TYPES: BEGIN OF ty_raw,
         " Havayolu ve uçuş bilgileri
         carrid      TYPE sflight-carrid,
         carrname    TYPE scarr-carrname,
         connid      TYPE sflight-connid,
         fldate      TYPE sflight-fldate,

         " Kalkış ve varış bilgileri
         countryfr   TYPE spfli-countryfr,
         cityfrom    TYPE spfli-cityfrom,
         countryto   TYPE spfli-countryto,
         cityto      TYPE spfli-cityto,

         " Uçak tipi
         planetype   TYPE sflight-planetype,

         " Maksimum koltuk sayıları
         seatsmax    TYPE sflight-seatsmax,
         seatsmax_b  TYPE sflight-seatsmax_b,
         seatsmax_f  TYPE sflight-seatsmax_f,

         " Dolu koltuk sayıları
         seatsocc    TYPE sflight-seatsocc,
         seatsocc_b  TYPE sflight-seatsocc_b,
         seatsocc_f  TYPE sflight-seatsocc_f,

         " Rezervasyon tutarı ve para birimi
         paymentsum  TYPE sflight-paymentsum,
         currency    TYPE sflight-currency,

       END OF ty_raw.

TYPES tt_result TYPE STANDARD TABLE OF ty_result
                WITH DEFAULT KEY.
*---------------------------------------------------------------------*
* ALV Kolon Başlıklarını Düzenleyen Yardımcı Sınıf
*---------------------------------------------------------------------*
CLASS lcl_alv_helper DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS set_column_texts
      IMPORTING
        io_cols TYPE REF TO cl_salv_columns_table.

ENDCLASS.


CLASS lcl_alv_helper IMPLEMENTATION.
  METHOD set_column_texts.
    DATA lo_col TYPE REF TO cl_salv_column_table.

    TRY.
        " Havayolu kodu
        lo_col ?= io_cols->get_column( 'CARRID' ).
        lo_col->set_short_text( 'Kod' ).
        lo_col->set_medium_text( 'Havayolu Kodu' ).
        lo_col->set_long_text( 'Havayolu Şirketi Kodu' ).

        " Havayolu adı
        lo_col ?= io_cols->get_column( 'CARRNAME' ).
        lo_col->set_short_text( 'Havayolu' ).
        lo_col->set_medium_text( 'Havayolu Adı' ).
        lo_col->set_long_text( 'Havayolu Şirketi Adı' ).

        " Uçuş numarası
        lo_col ?= io_cols->get_column( 'CONNID' ).
        lo_col->set_short_text( 'Uçuş No' ).
        lo_col->set_medium_text( 'Uçuş Numarası' ).
        lo_col->set_long_text( 'Uçuş Bağlantı Numarası' ).

        " Uçuş tarihi
        lo_col ?= io_cols->get_column( 'FLDATE' ).
        lo_col->set_short_text( 'Tarih' ).
        lo_col->set_medium_text( 'Uçuş Tarihi' ).
        lo_col->set_long_text( 'Uçuş Tarihi' ).

        " Kalkış ülkesi
        lo_col ?= io_cols->get_column( 'COUNTRYFR' ).
        lo_col->set_short_text( 'Kalkış Ü.' ).
        lo_col->set_medium_text( 'Kalkış Ülkesi' ).
        lo_col->set_long_text( 'Kalkış Ülkesi' ).

        " Kalkış şehri
        lo_col ?= io_cols->get_column( 'CITYFROM' ).
        lo_col->set_short_text( 'Kalkış Ş.' ).
        lo_col->set_medium_text( 'Kalkış Şehri' ).
        lo_col->set_long_text( 'Kalkış Şehri' ).

        " Varış ülkesi
        lo_col ?= io_cols->get_column( 'COUNTRYTO' ).
        lo_col->set_short_text( 'Varış Ü.' ).
        lo_col->set_medium_text( 'Varış Ülkesi' ).
        lo_col->set_long_text( 'Varış Ülkesi' ).

        " Varış şehri
        lo_col ?= io_cols->get_column( 'CITYTO' ).
        lo_col->set_short_text( 'Varış Ş.' ).
        lo_col->set_medium_text( 'Varış Şehri' ).
        lo_col->set_long_text( 'Varış Şehri' ).

        " Uçak tipi
        lo_col ?= io_cols->get_column( 'PLANETYPE' ).
        lo_col->set_short_text( 'Uçak' ).
        lo_col->set_medium_text( 'Uçak Tipi' ).
        lo_col->set_long_text( 'Uçak Tipi' ).
        "uçak tipi degerlerini tek tıklanabilir yapı yapar
        lo_col->set_cell_type(
            if_salv_c_cell_type=>hotspot
        ).

        " Maksimum koltuk
        lo_col ?= io_cols->get_column( 'MAX_SEAT' ).
        lo_col->set_short_text( 'Maks.' ).
        lo_col->set_medium_text( 'Maksimum Koltuk' ).
        lo_col->set_long_text( 'Maksimum Koltuk Sayısı' ).

        " Dolu koltuk
        lo_col ?= io_cols->get_column( 'OCC_SEAT' ).
        lo_col->set_short_text( 'Dolu' ).
        lo_col->set_medium_text( 'Dolu Koltuk' ).
        lo_col->set_long_text( 'Dolu Koltuk Sayısı' ).

        " Boş koltuk
        lo_col ?= io_cols->get_column( 'EMPTY_SEAT' ).
        lo_col->set_short_text( 'Boş' ).
        lo_col->set_medium_text( 'Boş Koltuk' ).
        lo_col->set_long_text( 'Boş Koltuk Sayısı' ).

        " Doluluk oranı
        lo_col ?= io_cols->get_column( 'OCC_RATE' ).
        lo_col->set_short_text( 'Oran' ).
        lo_col->set_medium_text( 'Doluluk Oranı' ).
        lo_col->set_long_text( 'Doluluk Oranı' ).

        " Rezervasyon sayısı
        lo_col ?= io_cols->get_column( 'BOOK_COUNT' ).
        lo_col->set_short_text( 'Rez.' ).
        lo_col->set_medium_text( 'Rezervasyon Sayısı' ).
        lo_col->set_long_text( 'Toplam Rezervasyon Sayısı' ).

        " Toplam ücret
        lo_col ?= io_cols->get_column( 'PAYMENTSUM' ).
        lo_col->set_short_text( 'Tutar' ).
        lo_col->set_medium_text( 'Toplam Ücret' ).
        lo_col->set_long_text( 'Toplam Rezervasyon Ücreti' ).

        " Para birimi
        lo_col ?= io_cols->get_column( 'CURRENCY' ).
        lo_col->set_short_text( 'Birim' ).
        lo_col->set_medium_text( 'Para Birimi' ).
        lo_col->set_long_text( 'Para Birimi' ).

        " Doluluk durumu
        lo_col ?= io_cols->get_column( 'STATUS_TEXT' ).
        lo_col->set_short_text( 'Durum' ).
        lo_col->set_medium_text( 'Doluluk Durumu' ).
        lo_col->set_long_text( 'Doluluk Durumu' ).

        " TL karşılığı kolonunun başlıklarını düzenler.
     lo_col ?= io_cols->get_column( 'TL_KARSILIGI' ).
     lo_col->set_short_text( 'TL' ).
     lo_col->set_medium_text( 'TL Karşılığı' ).
     lo_col->set_long_text( 'Toplam Ücretin TL Karşılığı' ).

      CATCH cx_salv_not_found.
        " Kolon bulunamazsa program devam eder.
    ENDTRY.

  ENDMETHOD.

ENDCLASS.

CLASS lcl_event_handler DEFINITION.
  PUBLIC SECTION.

  METHODS:
  constructor    " "Bunun amacı, ALV’de gösterilen lt_result tablosunu sınıfın içine göndermek.
  IMPORTING
    it_result TYPE tt_result,

 on_link_click
        FOR EVENT link_click OF cl_salv_events_table
        IMPORTING
          row
          column.
  PRIVATE SECTION.
    DATA mt_result TYPE  tt_result.    "Bu tablo, event sınıfının bütün uçuş kayıtlarını saklayacağı yerdir.
ENDCLASS.

CLASS lcl_event_handler IMPLEMENTATION.

    "dışarıdan gelen lt_result tablosunu sınıf içindeki mt_result tablosuna kopyaladık.
  METHOD constructor.
    mt_result = it_result.
  ENDMETHOD.

  METHOD on_link_click.
    " tek tıklamayla açılan detay ALV ekranında kullanılıyor.
    DATA:
    ls_selected   TYPE ty_result,  "Kullanıcının tıkladığı tek satırın bilgilerini tutar.
    lt_detail      TYPE tt_result,   "tıklanan uçak tipine ait bütün uçuşların tutulduğu detay iç tablosudur.
    lo_detail_alv TYPE REF TO cl_salv_table,
    lo_detail_cols TYPE REF TO cl_salv_columns_table,
    lv_detail_count    TYPE i,
    lv_detail_count_c  TYPE char10,
    lv_detail_header   TYPE lvc_title,
    lo_detail_display  TYPE REF TO cl_salv_display_settings.


    " Sadece Uçak Tipi kolonuna çift tıklanırsa çalışır.
    "Mesela kullanıcı CARRID, FLDATE veya OCC_RATE kolonuna tıklarsa detay ekranı açılmaz.
  IF column <> 'PLANETYPE'.
    RETURN.
  ENDIF.

" Kullanıcının çift tıkladığı satırı ana sonuç tablosundan okur.
  READ TABLE mt_result
    INDEX row
    INTO ls_selected.

  IF sy-subrc <> 0.
    RETURN.
  ENDIF.
"Bu kod, ana ALV’de tıkladığın uçuşun bütün rezervasyonlarını getirir.
  LOOP AT mt_result INTO DATA(ls_detail)
  WHERE planetype = ls_selected-planetype.

  APPEND ls_detail TO lt_detail.

ENDLOOP.

  " Aynı uçak tipine ait uçuşları yeni ALV ekranında gösterir.
  TRY.
      cl_salv_table=>factory(
        IMPORTING
          r_salv_table = lo_detail_alv   "oluşturulan detay ALV nesnesi
        CHANGING
          t_table      = lt_detail  "tıklanan uçak tipine ait filtrelenmiş kayıtlar
      ).
      " detay ALV kolonlarına erişir
      lo_detail_cols = lo_detail_alv->get_columns( ).

      "detay ALV kolon başlıklarını Türkçeye çevirir
         lcl_alv_helper=>set_column_texts(
           io_cols = lo_detail_cols
    ).

      "kolon başlıklarını otomatik ayarlar
      lo_detail_cols->set_optimize( abap_true ).

       " Detay ekranındaki gerçek kayıt sayısını hesaplar
    lv_detail_count = lines( lt_detail ).
    lv_detail_count_c = lv_detail_count.

    " Detay ekranına özel başlık oluşturur
CONCATENATE
  'Uçak Tipi:'
  ls_selected-planetype
  '- Toplam Kayıt:'
  lv_detail_count_c
  INTO lv_detail_header
  SEPARATED BY space.
    " Başlığı detay ALV'ye uygular
    lo_detail_display = lo_detail_alv->get_display_settings( ).
    lo_detail_display->set_list_header( lv_detail_header ).

"detay ALV yi gösterir
      lo_detail_alv->display( ).

    CATCH cx_salv_msg.
  ENDTRY.
  ENDMETHOD.

ENDCLASS.
*---------------------------------------------------------------------*
* Program Değişkenleri
*---------------------------------------------------------------------*
DATA:

  " Ham ve final sonuç tabloları
  lt_result TYPE TABLE OF ty_result,
  lt_raw    TYPE TABLE OF ty_raw,
  ls_result TYPE ty_result,

  " SALV ana nesnesi
  go_alv    TYPE REF TO cl_salv_table,

  " ALV kolon nesneleri
  go_cols   TYPE REF TO cl_salv_columns_table,
  go_col    TYPE REF TO cl_salv_column_table,

  " ALV filtreleme, export ve diğer standart fonksiyonlar
  go_funcs  TYPE REF TO cl_salv_functions_list,

  " ALV genel görünüm ve başlık ayarları
  lo_display TYPE REF TO cl_salv_display_settings,

  " ALV başlığında kullanılacak kayıt sayısı
  lv_count   TYPE i,
  lv_count_c TYPE char10,
  lv_header  TYPE lvc_title,

  " Ortalama doluluk hesaplamasında kullanılan alanlar
  lv_sum_rate   TYPE p LENGTH 10 DECIMALS 2,
  lv_avg_rate   TYPE p LENGTH 7 DECIMALS 2,
  lv_avg_rate_c TYPE char15,

  " ALV olay nesneleri
  go_events  TYPE REF TO cl_salv_events_table,
  go_handler TYPE REF TO lcl_event_handler,

  " Tek bir renk kaydı hazırlamak için çalışma alanı
  ls_color   TYPE lvc_s_scol,
  gv_iptal_success TYPE char5,
  gv_iptal_text    TYPE char20.
*---------------------------------------------------------------------*
* Programın Asıl Çalışan Bölümü
*---------------------------------------------------------------------*
START-OF-SELECTION.
*---------------------------------------------------------------------*
* Verilerin Tablolardan Çekilmesi
*---------------------------------------------------------------------*
* Ana tablo: SFLIGHT
*
* SCARR:
* Havayolu şirketi adını almak için INNER JOIN kullanılır.
*
* SPFLI:
* Kalkış ve varış bilgilerini almak için INNER JOIN kullanılır.
*
* SBOOK:
* Rezervasyon kaydı olmayan uçuşların da listelenebilmesi için
* LEFT OUTER JOIN kullanılır.
*---------------------------------------------------------------------*

  IF p_iptal = abap_true.

    IF p_icarr IS INITIAL
       OR p_iconn IS INITIAL
       OR p_idate IS INITIAL
       OR p_ibook IS INITIAL.

      MESSAGE 'İptal bilgilerini eksiksiz giriniz' TYPE 'I'.
      RETURN.

    ENDIF.
    CALL FUNCTION 'Z_CANCEL_PASSENGER_BOOKING'
      EXPORTING

        iv_havayolu_kod         = p_icarr
        iv_baglanti_no          = p_iconn
        iv_ucus_tarih           = p_idate
        iv_rezervasyon_numarasi =  p_ibook
      IMPORTING
        ev_success              = gv_iptal_success
        ev_status_text          = gv_iptal_text
      EXCEPTIONS
        booking_not_found       = 1
        record_locked           = 2
        update_failed           = 3
        already_cancelled       = 4
        OTHERS                  = 5.

    CASE sy-subrc.

      WHEN 0.
        MESSAGE gv_iptal_text TYPE 'S'.

      WHEN 1.
        MESSAGE 'Rezervasyon bulunamadı' TYPE 'I'.

      WHEN 2.
        MESSAGE 'Rezervasyon başka kullanıcı tarafından kullanılıyor' TYPE 'I'.

      WHEN 3.
        MESSAGE 'Rezervasyon güncellenemedi' TYPE 'I'.

      WHEN 4.
        MESSAGE 'Rezervasyon zaten iptal edilmiş' TYPE 'I'.

      WHEN OTHERS.
        MESSAGE 'İptal işlemi sırasında hata oluştu' TYPE 'I'.

    ENDCASE.

    RETURN.

  ENDIF.
SELECT DISTINCT
       f~carrid,
       c~carrname,
       f~connid,
       f~fldate,
       p~countryfr,
       p~cityfrom,
       p~countryto,
       p~cityto,
       f~planetype,
       f~seatsmax,
       f~seatsmax_b,
       f~seatsmax_f,
       f~seatsocc,
       f~seatsocc_b,
       f~seatsocc_f,
       f~paymentsum,
       f~currency

  FROM sflight AS f

  INNER JOIN scarr AS c
    ON f~carrid = c~carrid

  INNER JOIN spfli AS p
    ON  f~carrid = p~carrid
    AND f~connid = p~connid

  LEFT OUTER JOIN sbook AS b
    ON  f~carrid = b~carrid
    AND f~connid = b~connid
    AND f~fldate = b~fldate

  WHERE f~carrid    IN @s_carrid
    AND c~carrname  IN @s_cname
    AND f~connid    IN @s_connid
    AND p~countryfr IN @s_ctrfr
    AND p~cityfrom  IN @s_cityfr
    AND p~countryto IN @s_ctrto
    AND p~cityto    IN @s_cityto
    AND f~fldate    IN @s_fldate

  INTO TABLE @lt_raw.
*---------------------------------------------------------------------*
* Ham Verilerin İşlenmesi
*---------------------------------------------------------------------*
* lt_raw içindeki kayıtlar tek tek işlenir.
*
* Hesaplanan bilgiler:
* - Maksimum koltuk sayısı
* - Dolu koltuk sayısı
* - Boş koltuk sayısı
* - Doluluk oranı
* - Rezervasyon sayısı
*---------------------------------------------------------------------*

LOOP AT lt_raw INTO DATA(ls_raw).

  " Önceki uçuş kaydındaki bilgiler temizlenir.
  CLEAR ls_result.
  "---------------------------------------------------------------*
  "* Ham bilgilerin final sonuç yapısına aktarılması
  ls_result-carrid    = ls_raw-carrid.
  ls_result-carrname  = ls_raw-carrname.
  ls_result-connid    = ls_raw-connid.
  ls_result-fldate    = ls_raw-fldate.
  ls_result-countryfr = ls_raw-countryfr.
  ls_result-cityfrom  = ls_raw-cityfrom.
  ls_result-countryto = ls_raw-countryto.
  ls_result-cityto    = ls_raw-cityto.
  ls_result-planetype = ls_raw-planetype.

  "---------------------------------------------------------------*
  "* Rezervasyon sayısının hesaplanması

  "* İlgili havayolu, bağlantı numarası ve uçuş tarihine ait
 "* SBOOK kayıtlarının toplam sayısı alınır.

  SELECT COUNT( * )
    INTO ls_result-book_count
    FROM sbook
    WHERE carrid = ls_raw-carrid
      AND connid = ls_raw-connid
      AND fldate = ls_raw-fldate
      AND CANCELLED = ' '.

  "* Toplam maksimum koltuk sayısının hesaplanması
  "* Economy + Business + First Class maksimum koltukları toplanır.
  ls_result-max_seat =
      ls_raw-seatsmax   +
      ls_raw-seatsmax_b +
      ls_raw-seatsmax_f.

  "* Toplam dolu koltuk sayısının hesaplanması
  " Economy + Business + First Class dolu koltukları toplanır.

  ls_result-occ_seat =
      ls_raw-seatsocc   +
      ls_raw-seatsocc_b +
      ls_raw-seatsocc_f.

  "Boş koltuk sayısının hesaplanması

  ls_result-empty_seat =
      ls_result-max_seat - ls_result-occ_seat.

  " Doluluk oranının hesaplanması
  " Sıfıra bölme hatasını önlemek için maksimum koltuk kontrol edilir.

  IF ls_result-max_seat > 0.

    ls_result-occ_rate =
      ( ls_result-occ_seat * 100 ) /
        ls_result-max_seat.

  ENDIF.
  " Doluluk durumuna göre ikon ve satır rengi belirlenmesi

  IF ls_result-occ_rate >= 80.

    " Doluluk oranı %80 veya daha yüksekse yeşil ikon gösterilir.
    ls_result-status_icon = icon_led_green.
    ls_result-status_text = ' Doluluk %80 ve üstü'.

  ELSE.

    " Doluluk oranı %80'in altındaysa kırmızı ikon gösterilir.
    ls_result-status_icon = icon_led_red.
    ls_result-status_text = 'Doluluk %80 altı'.

    " Önceki renk bilgileri temizlenir.
    CLEAR ls_color.
    " FNAME boş bırakılırsa rengin tüm satıra uygulanması amaçlanır.
    ls_color-fname = ''.

    " 6 numaralı renk kodu kırmızıdır.
    ls_color-color-col = 6.

    " Normal renk yoğunluğu kullanılır.
    ls_color-color-int = 0.

    " Ters renk gösterimi kapalıdır.
    ls_color-color-inv = 0.

    " Hazırlanan renk kaydı ilgili sonuç satırına eklenir.
    APPEND ls_color TO ls_result-row_color.

  ENDIF.

  " Tutar ve para biriminin final sonuca aktarılması

  ls_result-paymentsum = ls_raw-paymentsum.
  ls_result-currency   = ls_raw-currency.
"Hazırlanan sonucun final tabloya eklenmesi
  CALL FUNCTION 'Z_CONVERT_FLIGHT_PRICE'  ""Fiyatı seçilen para birimine (TRY) çeviren fonksiyonu çağırır.

  EXPORTING
  iv_orijinal_fiyat       = ls_raw-paymentsum  "Çevrilecek orijinal fiyat.
    iv_orijinal_birim       = ls_raw-currency   ""Fiyatın mevcut para birimi.
    iv_hedef_para_birimi    = 'TRY'   "Hedef para birimi Türk Lirası.
    iv_kur_tarihi           = sy-datum  "Kurun alınacağı tarih.
 IMPORTING
    ev_cevrilmis_fiyat      = ls_result-tl_karsiligi  "Hesaplanan TL tutarı bu alana döner.
 EXCEPTIONS
   tarihte_kur_bulunamadi  = 1  "Belirtilen tarihte kur bulunamazsa.
    para_birimi_bulunamadi  = 2  " para birimi sistemde yoksa
    OTHERS                  = 3. "diger oluşabilecek hatalar
IF sy-subrc <> 0.   "fonksiyon hata ile döndüyse
  CLEAR ls_result-tl_karsiligi.  "TL karşılığı alanını boş bırak.
ENDIF.
  APPEND ls_result TO lt_result. "TL karşılığı alanını boş bırak.

ENDLOOP.
* Ortalama Doluluk Bilgilerinin Hazırlanması

CLEAR:
  lv_sum_rate,
  lv_avg_rate,
  lv_avg_rate_c.

LOOP AT lt_result INTO DATA(ls_avg).

  " Her uçuşun doluluk oranı toplam değere eklenir.
  lv_sum_rate = lv_sum_rate + ls_avg-occ_rate.

ENDLOOP.

WRITE lv_avg_rate TO lv_avg_rate_c DECIMALS 2.
*---------------------------------------------------------------------*
* ALV Nesnesinin Oluşturulması
*---------------------------------------------------------------------*

cl_salv_table=>factory(
  IMPORTING
    r_salv_table = go_alv
  CHANGING
    t_table      = lt_result
).

*  Click Olayının ALV'ye Bağlanması

CREATE OBJECT go_handler
  EXPORTING      " final sonuç tablosunu event sınıfına gönderdik.
    it_result = lt_result.

go_events = go_alv->get_event( ).

SET HANDLER go_handler->on_link_click
  FOR go_events.

* ALV Başlık Bilgisinin Hazırlanması

" Final sonuç tablosundaki kayıt sayısı bulunur.
lv_count = lines( lt_result ).

" Sayısal değer karakter tipine aktarılır.
lv_count_c = lv_count.

" ALV başlık metni oluşturulur.
CONCATENATE
  'Ucus Raporu - Toplam Kayit:'
  lv_count_c
  INTO lv_header
  SEPARATED BY space.

* ALV Genel Görünüm Ayarları
lo_display = go_alv->get_display_settings( ).

" Oluşturulan metin ALV'nin üst başlığı olarak atanır.
lo_display->set_list_header( lv_header ).
*---------------------------------------------------------------------*
* Standart ALV Fonksiyonlarının Açılması
*---------------------------------------------------------------------*
* Filtreleme, sıralama ve dışa aktarma gibi standart fonksiyonların
* tamamı aktif edilir.
*---------------------------------------------------------------------*
go_funcs = go_alv->get_functions( ).
go_funcs->set_all( abap_true ).

*---------------------------------------------------------------------*
* ALV Başlık Ayarının Tekrar Uygulanması
*---------------------------------------------------------------------*

lo_display = go_alv->get_display_settings( ).
lo_display->set_list_header( lv_header ).

*---------------------------------------------------------------------*
* ALV Kolon Nesnelerine Erişim
*---------------------------------------------------------------------*

go_cols = go_alv->get_columns( ).

" Otomatik kolon genişliği ayarı kullanılmak istenirse açılabilir.
*"go_cols->set_optimize( abap_true ).
*---------------------------------------------------------------------*
* Durum İkonu Kolonunun İlk Sıraya Alınması
*---------------------------------------------------------------------*
go_cols = go_alv->get_columns( ).

lcl_alv_helper=>set_column_texts(
  io_cols = go_cols
).
go_cols->set_column_position(
  columnname = 'STATUS_ICON'
  position   = 1
).
*----------------------------------------------------------------*
* Alternatif ALV Fonksiyon Nesnesi
*---------------------------------------------------------------------*
DATA lo_func TYPE REF TO cl_salv_functions.
lo_func = go_alv->get_functions( ).
lo_func->set_all( abap_true ).

*---------------------------------------------------------------------*
* Satır Renk Alanının ALV'ye Tanıtılması
*---------------------------------------------------------------------*
go_cols = go_alv->get_columns( ).
TRY.
    " Satır renkleri ROW_COLOR alanından okunur.
    go_cols->set_color_column( 'ROW_COLOR' ).

  CATCH cx_salv_data_error.

ENDTRY.
* ALV'nin Ekranda Gösterilmesi
go_alv->display( ).
