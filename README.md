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

🔒 Lock Object

Bu projede rezervasyon iptal işlemi sırasında veri bütünlüğünü korumak amacıyla Lock Object kullanılmıştır. İşlem başlamadan önce ilgili rezervasyon kaydı kilitlenmekte (ENQUEUE), güncelleme tamamlandıktan sonra kilit kaldırılmaktadır (DEQUEUE). Böylece aynı kaydın birden fazla kullanıcı tarafından eş zamanlı olarak değiştirilmesi engellenmektedir.

Kullanılan SAP Nesneleri
Nesne	Açıklama
Lock Object (EZSBOOK)	Rezervasyon kaydını işlem süresince kilitleyerek veri tutarlılığını sağlar.
ENQUEUE Function Module	İşlem öncesinde kaydı kilitler.
DEQUEUE Function Module	İşlem tamamlandıktan sonra kilidi kaldırır.
## 🎯 Proje Kapsamında Kazanılan Yetkinlikler

| Konu | Açıklama |

| Open SQL | Birden fazla SAP tablosundan veri çekme ve JOIN işlemleri gerçekleştirme |
| SALV ALV | Filtrelenebilir ve kullanıcı dostu raporlama ekranları oluşturma |
| Function Module | Tekrar kullanılabilir iş mantıkları geliştirme |
| Para Birimi Dönüşümü | Uçuş fiyatlarını farklı para birimlerine çevirme |
| Rezervasyon Yönetimi | Rezervasyon iptal ve veri güncelleme süreçlerini yönetme |
| Lock Object | Eş zamanlı güncellemelerde veri bütünlüğünü koruma |
| Package Yapısı | SAP geliştirme nesnelerini ana ve alt package yapısıyla düzenleme |
| abapGit | SAP nesnelerini GitHub üzerinden versiyon kontrolüne alma |

👨‍💻 Geliştirici	- Nursena Çamkömürü
🎓 Staj Kurumu	- Akedaş Elektrik Dağıtım A.Ş.
📚 Konu	 -SAP ABAP


