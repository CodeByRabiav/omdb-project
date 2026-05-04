/*
  i2i Systems - Telco Project Solutions
  Developer: Rabia Vural
  Position: Software Engineering 3rd Year Student
*/


-- 1.1: List the customers who are subscribed to the 'Kobiye Destek' tariff.
SELECT c.CUSTOMER_ID, c.NAME, t.NAME AS TARIFF_NAME
FROM CUSTOMERS c
JOIN TARIFFS t ON c.TARIFF_ID = t.TARIFF_ID
WHERE t.NAME = 'Kobiye Destek';

/* 
Açıklama:
1. Bu sorgu, müşterilerin kişisel bilgileri ile tarife detaylarını ilişkilendirmek için JOIN yapısını kullanır.
2. TARIFF_ID alanı üzerinden kurulan bu bağlantı, ilişkisel veritabanı (RDBMS) mantığının temelini oluşturur.
3. WHERE filtresi sayesinde sadece ilgili tarifeye sahip aboneler süzülerek hedeflenen veri kümesine ulaşılmıştır.
*/

-- 1.2: Find the newest customer who subscribed to this tariff.
SELECT * FROM (
    SELECT c.CUSTOMER_ID, c.NAME, c.SIGNUP_DATE
    FROM CUSTOMERS c
    JOIN TARIFFS t ON c.TARIFF_ID = t.TARIFF_ID
    WHERE t.NAME = 'Kobiye Destek'
    ORDER BY c.SIGNUP_DATE DESC
) WHERE ROWNUM = 1;

/*
Açıklama:
1. İlgili tarifeye en son katılan üyeyi bulmak için SIGNUP_DATE sütunu büyükten küçüğe sıralanmıştır.
2. Oracle veritabanına özgü ROWNUM = 1 kısıtlaması, sıralanmış listedeki ilk (en güncel) kaydı çekmemizi sağlar.
3. Bu analiz, pazarlama departmanının en yeni aboneleri takip etmesi gibi operasyonel süreçlerde kritik önem taşır.
*/

-- 2.1: Find the distribution of tariffs among the customers.
SELECT t.NAME, COUNT(c.CUSTOMER_ID) AS TOTAL_CUSTOMERS
FROM CUSTOMERS c
JOIN TARIFFS t ON c.TARIFF_ID = t.TARIFF_ID
GROUP BY t.NAME;

/*
Açıklama:
1. Bu sorgu, şirketin tarife portföyündeki doluluk oranlarını görmek için GROUP BY fonksiyonunu kullanır.
2. Her bir tarife adı için COUNT ile toplam müşteri sayısı hesaplanarak sayısal bir dağılım elde edilmiştir.
3. Elde edilen bu istatistiksel veri, tarifelerin popülerlik analizinde ve kapasite planlamasında kullanılır.
*/

-- 3.1: Identify the earliest customers to sign up.
SELECT * FROM (
    SELECT CUSTOMER_ID, NAME, SIGNUP_DATE
    FROM CUSTOMERS
    ORDER BY SIGNUP_DATE ASC
) WHERE ROWNUM <= 5;

/* 
Açıklama:
1. Sisteme ilk dahil olan müşterileri tespit etmek amacıyla SIGNUP_DATE sütunu eskiden yeniye (ASC) doğru sıralanmıştır.
2. Kimlik numaralarının (ID) kayıt sırasını her zaman yansıtmayabileceği göz önünde bulundurularak tarih bazlı bir sıralama tercih edilmiştir.
3. Bu analiz, şirketin en sadık ve en eski müşteri kitlesini belirleyerek onlara özel bağlılık programları geliştirilmesine olanak tanır.
*/

-- 3.2: Distribution of these earliest customers across different cities.
SELECT CITY, COUNT(*) AS CUSTOMER_COUNT
FROM (
    SELECT CITY FROM CUSTOMERS ORDER BY SIGNUP_DATE ASC FETCH FIRST 10 ROWS ONLY
)
GROUP BY CITY;

/*
Açıklama:
1. Şirketin ilk kullanıcılarının hangi coğrafi bölgelerde yoğunlaştığını anlamak için şehir bazlı bir gruplama yapılmıştır.
2. Belirli bir sayıdaki en eski müşteri kitlesi filtrelenmiş ve CITY sütununa göre toplam sayıları hesaplanmıştır.
3. Elde edilen veriler, şirketin başlangıç aşamasında hangi illerde daha güçlü bir pazarlama başarısı yakaladığını göstermektedir.
*/
-- 4.1: Identify the IDs of customers with missing monthly records.
SELECT c.CUSTOMER_ID
FROM CUSTOMERS c
LEFT JOIN MONTHLY_STATS m ON c.CUSTOMER_ID = m.CUSTOMER_ID
WHERE m.CUSTOMER_ID IS NULL;

/*
Açıklama:
1. Veritabanındaki veri bütünlüğünü kontrol etmek için CUSTOMERS ve USAGE tabloları LEFT JOIN ile eşleştirilmiştir.
2. MONTHLY_STATS tablosunda karşılığı olmayan, yani kullanımı bulunmayan müşteriler IS NULL kontrolü ile tespit edilmiştir.
3. Bu sorgu, sistemsel hatalar nedeniyle aylık fatura veya kullanım kaydı oluşmamış müşterilerin belirlenmesini sağlayarak gelir kaybını önler.
*/
-- 5.1: Customers who have used at least 75% of their data limit.
SELECT c.NAME, m.DATA_USAGE, t.DATA_LIMIT
FROM CUSTOMERS c
JOIN MONTHLY_STATS m ON c.CUSTOMER_ID = m.CUSTOMER_ID
JOIN TARIFFS t ON c.TARIFF_ID = t.TARIFF_ID
WHERE (m.DATA_USAGE / t.DATA_LIMIT) >= 0.75;

/* 
Açıklama:
1. MONTHLY_STATS tablosundaki güncel veri kullanımı ile TARIFFS tablosundaki limitler oranlanmıştır.
2. Veri kotasının %75 ve üzerini kullanan müşteriler matematiksel filtreleme ile belirlenmiştir.
3. Bu sorgu, yüksek kullanım yapan müşterilere ek paket sunmak için pazarlama verisi sağlar.
*/

-- 5.2: Customers who exhausted all package limits.
SELECT c.NAME
FROM CUSTOMERS c
JOIN MONTHLY_STATS m ON c.CUSTOMER_ID = m.CUSTOMER_ID
JOIN TARIFFS t ON c.TARIFF_ID = t.TARIFF_ID
WHERE m.DATA_USAGE >= t.DATA_LIMIT 
  AND m.MINUTE_USAGE >= t.MINUTE_LIMIT 
  AND m.SMS_USAGE >= t.SMS_LIMIT;

/*
Açıklama:
1. Hem internet, hem dakika hem de SMS limitlerinin tamamını dolduran en aktif kullanıcılar hedeflenmiştir.
2. Üç farklı limitin de aynı anda aşılıp aşılmadığı AND operatörü ile kontrol edilmiştir.
3. Bu veriler, müşterinin mevcut paketinin yetersiz kaldığını kanıtlar.
*/
-- 6.1: Find the customers who have unpaid fees.
SELECT c.NAME, m.PAYMENT_STATUS
FROM CUSTOMERS c
JOIN MONTHLY_STATS m ON c.CUSTOMER_ID = m.CUSTOMER_ID
WHERE m.PAYMENT_STATUS = 'Unpaid'; 

/*
Açıklama:
1. MONTHLY_STATS tablosundaki PAYMENT_STATUS sütunu üzerinden ödeme yapmayanlar filtrelenmiştir.
2. 'Unpaid' (Ödenmemiş) statüsündeki kayıtlar, şirketin bekleyen alacaklarını temsil eder.
3. Bu liste, finans departmanının tahsilat süreçlerini yönetmesi için kullanılır.
*/

-- 6.2: Distribution of payment statuses across tariffs.
SELECT t.NAME AS TARIFF_NAME, m.PAYMENT_STATUS, COUNT(*) AS TOTAL
FROM TARIFFS t
JOIN CUSTOMERS c ON t.TARIFF_ID = c.TARIFF_ID
JOIN MONTHLY_STATS m ON c.CUSTOMER_ID = m.CUSTOMER_ID
GROUP BY t.NAME, m.PAYMENT_STATUS
ORDER BY t.NAME;

/*
Açıklama:
1. Tarifeler ve ödeme durumları arasındaki ilişkiyi görmek için çoklu tablo birleştirmesi yapılmıştır.
2. GROUP BY ile her tarife grubundaki 'Paid' ve 'Unpaid' sayıları ayrı ayrı hesaplanmıştır.
3. Bu analiz, hangi tarifelerin daha yüksek ödeme riskine sahip olduğunu gösterir.
*/