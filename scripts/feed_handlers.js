// Grab the message that was sent, so we can refill the form after reloading it
const handleCSRFRetry = (evt) => {
  const message = evt.detail.value;

  htmx.trigger("#post_submit_form", "invalidCSRF_reloadForm");
  htmx.on("#post_submit_form", "htmx:afterSettle", () => {
    document.getElementById("post_message_input").value = message;
  });
  console.log(evt.detail.value);
}

document.body.removeEventListener("retryPostBadCSRF", handleCSRFRetry);
document.body.addEventListener("retryPostBadCSRF", handleCSRFRetry);

