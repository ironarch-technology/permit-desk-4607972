(function () {
  var heads = document.querySelectorAll('[data-toggle-correction]');

  Array.prototype.forEach.call(heads, function (head) {
    head.addEventListener('click', function () {
      var body = head.parentNode.querySelector('.correction-body');
      body.hidden = !body.hidden;
      head.querySelector('.correction-chevron').innerHTML = body.hidden ? '&#9662;' : '&#9652;';
    });
  });
})();
