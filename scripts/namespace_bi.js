import "@beyondidentity/bi-sdk-js";
import { Embedded } from "@beyondidentity/bi-sdk-js";

// We have to initialize the embedded SDK every time we want to use it, so that seems a little weird. Can I pass this around?
window.byndid = {
  Embedded,
  initialized: Embedded.initialize(),
  sdk: false,
}

window.byndid.initialized.then((embedded) => {
  window.byndid.sdk = embedded;
});
