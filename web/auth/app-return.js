/**
 * E-posta doğrulama / şifre sıfırlama sonrası Toldya mobil uygulamasına dönüş.
 * Android: Intent URL. App Links doğrulandıysa https linki de uygulamayı açar.
 */
(function () {
  const APP_PACKAGE = 'com.casycorporate.toldya';
  const HOST = 'casy-570c4.web.app';

  const PATH_EMAIL_VERIFIED = '/email-verified';
  const PATH_PASSWORD_RESET_DONE = '/password-reset-done';

  function isAndroid() {
    return /Android/i.test(navigator.userAgent);
  }

  function httpsReturnUrl(path) {
    return 'https://' + HOST + path;
  }

  function androidIntentUrl(path) {
    const fallback = encodeURIComponent(httpsReturnUrl(path));
    return (
      'intent://' +
      HOST +
      path +
      '#Intent;scheme=https;package=' +
      APP_PACKAGE +
      ';S.browser_fallback_url=' +
      fallback +
      ';end'
    );
  }

  function resolvePath(context) {
    if (context === 'passwordReset') return PATH_PASSWORD_RESET_DONE;
    return PATH_EMAIL_VERIFIED;
  }

  window.ToldyaAppReturn = {
    PATH_EMAIL_VERIFIED: PATH_EMAIL_VERIFIED,
    PATH_PASSWORD_RESET_DONE: PATH_PASSWORD_RESET_DONE,
    httpsReturnUrl: httpsReturnUrl,
    androidIntentUrl: androidIntentUrl,
    isAndroid: isAndroid,
    bestReturnUrl: function (context) {
      const path = resolvePath(context);
      return isAndroid() ? androidIntentUrl(path) : httpsReturnUrl(path);
    },
    applyToElement: function (element, label, context) {
      if (!element) return;
      element.href = this.bestReturnUrl(context || 'emailVerified');
      if (label) element.textContent = label;
      element.removeAttribute('hidden');
      element.style.display = '';
    }
  };
})();
