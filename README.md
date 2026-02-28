# Bendemistim

Sosyal tahmin uygulaması (Flutter + Firebase). Tahminler statu değerleriyle yaşam döngüsünden geçer; Cloud Functions içindeki batch’ler belirli statu’deki kayıtları işleyip başka statu’lere taşır veya dağıtım yapar.

## Statu değerleri

| Değer | İsim | Açıklama |
|-------|------|----------|
| 0 | Yayında (Live) | Tahmin yayında, bahis alınabiliyor. |
| 1 | Beklemede (Pending) | Admin insan incelemesi bekliyor. |
| 2 | Onaylanan (Ok) | Sonuçlandı; feedResult set. Kazanç dağıtılabilir. |
| 3 | Reddedilen (Denied) | Admin tarafından reddedildi. |
| 4 | Tamamlanan (Complete) | İşlem tamamlandı. |
| 5 | Kilitli (Locked) | Bahisler kapandı, sonuç bekleniyor. |
| 6 | İncelemede (Pending AI Review) | Yapay zeka incelemesi bekliyor. |
| 7 | AI reddi (Rejected by AI) | Yapay zeka tarafından reddedildi. |

## Batch’ler: Hangi statu’deki kitle → Ne yapılıyor

- **runAiModeration**  
  - **Aldığı kitle:** `statu = 6` (İncelemede).  
  - **Yaptığı:** AI moderasyonu; onaylananları **0** (Yayında), reddedilenleri **7** (AI reddi) yapar.

- **runLockPredictions**  
  - **Aldığı kitle:** `statu = 0` (Yayında) ve `endDate` geçmiş olanlar.  
  - **Yaptığı:** Bu kayıtların statu’sünü **5** (Kilitli) yapar.

- **runOracleResolution**  
  - **Aldığı kitle:** `statu = 5` (Kilitli) veya `statu = 1` (Beklemede), `resolutionDate` geçmiş, henüz sonuçlanmamış.  
  - **Yaptığı:** Oracle API veya AI ile sonuç belirler; `feedResult` (1=Evet, 2=Hayır) yazar ve statu’yü **2** (Onaylanan) yapar.

- **runDistributeWinnings**  
  - **Aldığı kitle:** `statu = 2` (Onaylanan), `feedResult` set, `distributionDone` yok.  
  - **Yaptığı:** Kazançları kazananlara dağıtır; tahminin statu’sünü değiştirmez, sadece `distributionDone = true` ve profil güncellemeleri yapar.

- **runStashDrip**  
  - **Aldığı kitle:** Tahmin statu’su ile ilgili değil; kullanıcı profilleri (stash bakiyesi).  
  - **Yaptığı:** Stash’ten günlük payı hesaplayıp kullanılabilir bakiyeye (peg) aktarır; tahmin statu’su değişmez.
