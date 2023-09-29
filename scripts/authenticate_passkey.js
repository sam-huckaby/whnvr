import "@beyondidentity/bi-sdk-js";
import { Embedded } from "@beyondidentity/bi-sdk-js";

Embedded.initialize().then(async (embedded) => {
  // Collect all the hidden treasures that OCaml sent in hidden fields
  const tenant_id = document.getElementById("tenant_id").value;
  const realm_id = document.getElementById("realm_id").value;
  const app_id = document.getElementById("app_id").value;
  const client_id = document.getElementById("client_id").value;
  const redirect_uri = document.getElementById("redirect_uri").value;
  const passkey_id = document.getElementById("passkey_id").value;
  const state = document.getElementById("state").value;

  const auth_url = `https://auth-us.beyondidentity.com/v1/tenants/${tenant_id}/realms/${realm_id}/applications/${app_id}/authorize?response_type=code&client_id=${client_id}&redirect_uri=${redirect_uri}&scope=openid&state=${state}`;

  let response = await fetch(auth_url, {
    method: 'GET',
    // TODO: Figure out why it fails CORS with Content-Type set
    //headers: {
    //  "Content-Type": "application/json",
      // 'Content-Type': 'application/x-www-form-urlencoded',
    //},
  });
  const { authenticate_url } = await response.json();

  if (embedded.isAuthenticateUrl(authenticate_url)) {
    // Pass url and selected passkey ID into the Beyond Identity Embedded SDK authenticate function
    // Parse query parameters from the 'redirectUrl' for a 'code' and then exchange that code for an access token in a server
    const { redirectUrl } = await embedded.authenticate(
      authenticate_url,
      passkey_id
    );

    window.location.assign(redirectUrl);
  }
});
