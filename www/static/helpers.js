const prettify_dates = () => {
  var whnvrDates = document.getElementsByClassName("whnvr-time");

  for (var i = 0; i < whnvrDates.length; i++) {
    whnvrDates[i].innerHTML = (new Date(whnvrDates[i].innerHTML)).toLocaleString();
  }
};

document.addEventListener('htmx:afterSettle', prettify_dates);
//document.addEventListener('htmx:afterRequest', prettify_dates);

