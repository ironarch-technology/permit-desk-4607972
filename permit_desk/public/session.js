(function () {
  if (!window.PORTAL_SESSION_ENDS) return;

  function check() {
    var remaining = window.PORTAL_SESSION_ENDS - Math.floor(Date.now() / 1000);
    if (remaining <= 0) {
      window.location.href = '/portal/sign-in';
    }
  }

  window.setInterval(check, 15000);
  check();
})();
