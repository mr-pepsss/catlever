(function () {
  var slider = document.getElementById('leverage-slider');
  var img = document.getElementById('seesaw-img');
  var status = document.getElementById('status-line');
  var canary = document.getElementById('canary');
  var caChip = document.getElementById('ca-chip');
  var caValue = document.getElementById('ca-value');

  function updateSeesaw(value) {
    var deg = ((value - 50) / 50) * 8;
    img.style.transform = 'rotate(' + deg.toFixed(2) + 'deg)';

    var state, label;
    if (value <= 15) {
      state = 'rekt';
      label = 'STATUS: TOO LIGHT. REKT.';
    } else if (value <= 40) {
      state = 'under';
      label = 'STATUS: UNDERLEVERAGED';
    } else if (value <= 60) {
      state = 'balanced';
      label = 'STATUS: BALANCED';
    } else if (value <= 85) {
      state = 'stacking';
      label = 'STATUS: STACKING';
    } else {
      state = 'rekt';
      label = 'STATUS: OVERLEVERAGED. REKT.';
    }
    status.dataset.state = state;
    status.textContent = label;
  }

  slider.addEventListener('input', function () {
    updateSeesaw(Number(slider.value));
  });

  caChip.addEventListener('click', function () {
    var ca = caChip.getAttribute('data-ca');
    if (navigator.clipboard && navigator.clipboard.writeText) {
      navigator.clipboard.writeText(ca).catch(function () {});
    }
    caChip.classList.add('copied');
    setTimeout(function () {
      caChip.classList.remove('copied');
    }, 1500);
  });

  updateSeesaw(Number(slider.value));
  canary.dataset.status = 'live';
  canary.textContent = 'SYSTEM: BALANCED';
})();
