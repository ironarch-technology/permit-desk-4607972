(function () {
  var form = document.querySelector('[data-wizard]');
  if (!form) return;

  var steps = Array.prototype.slice.call(form.querySelectorAll('.step'));
  var indicators = Array.prototype.slice.call(form.querySelectorAll('#step-indicator li'));
  var back = form.querySelector('[data-wizard-back]');
  var next = form.querySelector('[data-wizard-next]');
  var submit = form.querySelector('[data-wizard-submit]');
  var summary = form.querySelector('#summary-readout');

  var VALUATION_CEILING = 5000000;
  var current = 0;

  function show(index) {
    current = index;
    steps.forEach(function (step, i) {
      step.hidden = i !== index;
    });
    indicators.forEach(function (item, i) {
      item.classList.toggle('current', i === index);
    });
    back.hidden = index === 0;
    next.hidden = index === steps.length - 1;
    submit.hidden = index !== steps.length - 1;
    if (index === steps.length - 1) {
      renderSummary();
    }
  }

  function value(name) {
    var field = form.querySelector('[name="' + name + '"]');
    return field ? field.value : '';
  }

  function renderSummary() {
    var rows = [
      ['Address', value('parcel_address')],
      ['Work', value('work_type').replace(/_/g, ' ')],
      ['Scope', value('scope_narrative')],
      ['Value', value('valuation') ? '$' + value('valuation') : ''],
      ['Name', value('applicant_name')],
      ['Email', value('applicant_email')],
      ['Phone', value('applicant_phone')],
      ['Licence', value('contractor_licence')]
    ];

    summary.textContent = '';
    var list = document.createElement('dl');
    list.className = 'detail';
    rows.forEach(function (row) {
      if (!row[1]) return;
      var dt = document.createElement('dt');
      dt.textContent = row[0];
      var dd = document.createElement('dd');
      dd.textContent = row[1];
      list.appendChild(dt);
      list.appendChild(dd);
    });
    summary.appendChild(list);
  }

  next.addEventListener('click', function () {
    var valuation = parseFloat(value('valuation'));
    if (current === 1 && valuation > VALUATION_CEILING) {
      window.alert('Projects over $' + VALUATION_CEILING.toLocaleString() + ' go through Major Projects.');
      return;
    }
    if (current < steps.length - 1) show(current + 1);
  });

  back.addEventListener('click', function () {
    if (current > 0) show(current - 1);
  });

  show(0);
})();
