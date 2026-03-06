# Kural İhlallerini Giderme Planı

## Faz 1: Firebase – Bahis (Client yazma kaldır)
- FeedState.addLikeToToldya / addunLikeToToldya: RTDB'ye doğrudan yazmayı kaldır; metodları no-op yap veya sadece yerel güncelleme (notifyListeners). Tüm bahis placeBet Callable üzerinden.

## Faz 2: ARB – Eksik key'ler (tr, en, de)
- feedPostDetail/tweetIconsRow: closedNoSelection, tokenInsufficient, betOnOneSideOnly (zaten var – kullan)
- tweetBottomSheet: pleaseSelectBetAmount, confirmBet, confirmBetMessage, cancel, confirm (zaten var)
- Yeni key'ler: betErrorGeneric, gmsError, changesSaved, resetPasswordSent, selectProfilePhoto, selectCoverPhoto, appAvatars, exampleUsername, save, sortUserList, updateNow, alert, forIos, forAndroid, iSayYes, iSayNo, votersList, noVotesYet, voteListEmptySubtitle, commentFailed

## Faz 3: Widget’larda l10n kullanımı
- feedPostDetail: _openBet SnackBar → l10n
- tweetBottomSheet: dialog + SnackBar mesajları → l10n
- tweetIconsRow: SnackBar + dedim/demedim + for ios/Android + UsersListPage metinleri → l10n
- imageViewPage: commentAdded, commentFailed → l10n
- token_earn_page: adsComingSoon, tokensAdded, purchaseComingSoon → l10n
- EditProfilePage: tüm label/button/SnackBar → l10n
- authState: changesSaved, resetPasswordSent → l10n
- updateApp, customWidgets, unavailableTweet, routes, settings sayfaları → l10n

## Faz 4: gen-l10n + lint
- flutter gen-l10n çalıştır; gerekirse getter’ları kontrol et.
