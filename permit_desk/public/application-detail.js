(function () {
  var dialog = document.getElementById('withdraw-dialog');
  var opener = document.querySelector('[data-open-withdraw]');

  if (dialog && opener) {
    opener.addEventListener('click', function () {
      dialog.showModal();
    });
    dialog.addEventListener('close', function () {
      opener.focus();
    });
  }

  var pay = document.getElementById('pay-now');
  if (!pay) return;

  var status = document.getElementById('pay-status');
  var token = document.querySelector('meta[name="csrf-token"]');

  pay.addEventListener('click', function () {
    pay.disabled = true;
    status.textContent = 'Sending you to cashiering...';

    fetch('/graphql', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': token ? token.content : ''
      },
      body: JSON.stringify({
        query: 'mutation Pay($reference: String!, $amountCents: Int!, $quoteReference: String!) {' +
               '  initiatePayment(reference: $reference, amountCents: $amountCents, quoteReference: $quoteReference) {' +
               '    captureReference errors } }',
        variables: {
          reference: pay.dataset.reference,
          amountCents: parseInt(pay.dataset.amountCents, 10),
          quoteReference: pay.dataset.quoteReference
        }
      })
    })
      .then(function (response) { return response.json(); })
      .then(function (payload) {
        var result = payload.data && payload.data.initiatePayment;
        if (result && result.captureReference) {
          status.textContent = 'Cashiering has the payment. This page updates when they confirm it.';
          window.setTimeout(function () { window.location.reload(); }, 6000);
        } else {
          pay.disabled = false;
          status.textContent = (result && result.errors[0]) || 'Cashiering did not accept that.';
        }
      })
      .catch(function () {
        pay.disabled = false;
        status.textContent = 'We could not reach cashiering.';
      });
  });
})();
