window.byndid.initialized.then(async (embedded) => {
  // Grab the ID of the passkey selected by the user
  const passkey_id = document.getElementById("passkey_id").value;
  const state = document.getElementById("state").value;

  const auth_url = `https://auth-us.beyondidentity.com/v1/tenants/${window.config.tenantId}/realms/${window.config.realmId}/applications/${window.config.appId}/authorize?response_type=code&client_id=${window.config.clientId}&redirect_uri=${window.config.redirectURI}&scope=openid&state=${state}`;

  let response = await fetch(auth_url, {
    method: 'GET',
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
