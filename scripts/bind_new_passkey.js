// Binding script, runs immediately, should only be loaded on a page that has a binding_url field from the server
// TODO: It might be worthwhile to convert this flow to make an HTTP call, rather than depending on a populated field, but this is easier to start
window.byndid.initialized.then(async (embedded) => {
  const bindingUrl = htmx.values(htmx.find("#binding_url")).binding_url;

  if (embedded.isBindPasskeyUrl(bindingUrl)) {
    await embedded.bindPasskey(bindingUrl);

    // Allow the user to continue on
    htmx.remove(htmx.find("#bind_passkey_loader"));
    htmx.removeClass(htmx.find("#bind_passkey_continue"), "hidden");
  }
});


