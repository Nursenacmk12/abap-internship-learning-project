# SAP ABAP Internship Learning Project

## 📌 Projenin Amacı
## Uçuş ALV Raporu
Bu ekran, SCARR, SPFLI, SFLIGHT ve SBOOK tablolarından alınan verilerin
SALV ALV üzerinde raporlanmasını göstermektedir.

<img width="600" height="300" alt="image" src="https://github.com/user-attachments/assets/3048dba6-f04e-45bb-b0b7-e5d30f9bbae4" />
<img width="600" height="300" alt="Ekran görüntüsü 2026-08-03 101356" src="https://github.com/user-attachments/assets/54892272-0d6d-4260-8b8d-7173859b6113" />


Bu proje, SAP ABAP stajı süresince edinilen teorik bilgilerin uygulamaya dönüştürülmesi amacıyla geliştirilmiştir. Projede kullanıcıların havayolu şirketi, bağlantı numarası, kalkış/varış noktaları ve uçuş tarihi gibi kriterlere göre sorgulama yapabilmesini sağlayan Selection Screen, Open SQL ile geliştirilen ALV raporu, döviz kuru ile para birimi dönüştürme ve rezervasyon iptal işlemleri yer almaktadır.

## 📋 Proje Özeti
| Özellik | Açıklama |
|---------|----------|
| 🎓 Staj | SAP ABAP Internship |
| 💻 Geliştirme Dili | ABAP |
| 🖥️ Geliştirme Ortamı | SAP NetWeaver AS ABAP Developer Edition |
| 🛫 Senaryo | Flight Management (SCARR, SPFLI, SFLIGHT, SBOOK) |
| 📦 Versiyon Kontrol | abapGit + GitHub |
| 📅 Geliştirme Süresi | Staj Dönemi |

## 🛠️ Kullanılan SAP Teknolojileri

| Teknoloji | Kullanım Amacı |
|-----------|----------------|
| Open SQL | Veri sorgulama ve JOIN işlemleri |
| SALV ALV | Rapor ekranlarının oluşturulması |
| Function Module | İş mantığının modüler hale getirilmesi |
| Lock Object | Eş zamanlı veri güncellemelerinin kontrolü |
| Package | Proje organizasyonu |
| abapGit | GitHub ile versiyon kontrolü |

## 🔒 Kullanılan SAP Nesneleri

| Nesne | Açıklama |
|---|---|
| `EZSBOOK` | Rezervasyon kaydını işlem süresince kilitleyerek veri tutarlılığını sağlar |
| `ENQUEUE` Function Module | Güncelleme öncesinde ilgili rezervasyon kaydını kilitler |
| `DEQUEUE` Function Module | İşlem tamamlandıktan sonra ilgili kaydın kilidini kaldırır |
## 🎯 Proje Kapsamında Kazanılan Yetkinlikler

## 🎯 Proje Kapsamında Kazanılan Yetkinlikler

| Konu | Açıklama |
|------|----------|
| Open SQL | Birden fazla SAP tablosundan veri çekme ve JOIN işlemlerini gerçekleştirme |
| SALV ALV | Filtrelenebilir ve kullanıcı dostu raporlama ekranları oluşturma |
| Function Module | Tekrar kullanılabilir iş mantıkları geliştirme |
| Para Birimi Dönüşümü | Uçuş fiyatlarını farklı para birimlerine çevirme |
| Rezervasyon Yönetimi | Rezervasyon iptal ve veri güncelleme süreçlerini yönetme |
| Lock Object | Eş zamanlı güncellemelerde veri bütünlüğünü koruma |
| Package Yapısı | SAP geliştirme nesnelerini ana ve alt package yapısıyla düzenleme |
| abapGit | SAP nesnelerini GitHub üzerinde versiyon kontrolüne alma |

## 💱 Kur Çevirme
Uçuş fiyatlarının farklı para birimlerine dönüştürülmesi amacıyla
`Z_CONVERT_FLIGHT_PRICE` isimli özel Function Module geliştirilmiştir.

Fonksiyon; orijinal fiyat, kaynak para birimi, hedef para birimi ve kur tarihi
bilgilerini parametre olarak almaktadır. Para birimi dönüşüm işlemi sırasında
SAP standart fonksiyonlarından `CONVERT_TO_LOCAL_CURRENCY` kullanılmaktadır.

### Kullanılan Function Module'ler

| Function Module | Tür | Açıklama |
|---|---|---|
| `Z_CONVERT_FLIGHT_PRICE` | Özel geliştirme | Uçuş fiyatının kaynak para biriminden hedef para birimine dönüştürülmesini yönetir |
| `CONVERT_TO_LOCAL_CURRENCY` | SAP standart | Belirtilen tarih ve döviz kuru bilgisine göre tutarı yerel para birimine dönüştürür |

<img width="500" height="250" alt="image" src="https://github.com/user-attachments/assets/cfeb2d35-533e-4152-a72e-331e53ae8e99" />

## 📄 Excel'e Aktarma

Geliştirilen SALV ALV raporu, SAP'nin standart dışa aktarma (Export) özelliğini desteklemektedir. Kullanıcılar rapor sonuçlarını tek tıklama ile Microsoft Excel formatına aktararak analiz, paylaşım ve raporlama işlemlerini kolaylıkla gerçekleştirebilmektedir.

Bu özellik, ALV nesnesi üzerinden standart fonksiyonların aktif edilmesi ile sağlanmıştır.
```abap
DATA(lo_functions) = lo_alv->get_functions( ).

lo_functions->set_all( abap_true ).
```

Yukarıdaki kod ile SALV ALV'nin tüm standart fonksiyonları (Excel'e Aktarma, Yazdırma, Filtreleme, Sıralama, Toplam Alma vb.) aktif hale getirilmiştir.


<img width="500" height="250" alt="image" src="https://github.com/user-attachments/assets/957b62c2-879c-4a3c-8daf-840f623a0ad9" />

👨‍💻 Geliştirici	- Nursena Çamkömürü
🎓 Staj Kurumu	- Akedaş Elektrik Dağıtım A.Ş.
📚 Konu	 -SAP ABAP


