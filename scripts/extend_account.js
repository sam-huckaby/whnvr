const redeemHandler = (embeddedSdk, url) => {
  return async () => {
    const otp = document.getElementById("otp").value;

    const { passkeyBindingToken, redirectUrl } = await embeddedSdk.redeemOtp(
      url,
      otp
    );

    /** Use a trigger to fire an event that can then be used to pass the bindingToken */
    htmx.trigger("#otp_completion_form", "completeOTP", { passkeyBindingToken });
  };
}

window.byndid.initialized.then(async (embedded) => {
  // Saving the email in a hidden field seems easiest here. Maybe I could swap to something else later...
  const email = document.getElementById("email").value;
  const state = document.getElementById("state").value;
  // Build the auth URL which is used to initiate the authentication flow
  const auth_url = `https://auth-us.beyondidentity.com/v1/tenants/${window.config.tenantId}/realms/${window.config.realmId}/applications/${window.config.appId}/authorize?response_type=code&client_id=${window.config.clientId}&redirect_uri=${window.config.redirectURI}&scope=openid&state=${state}`;

  let response = await fetch(auth_url, {
    method: 'GET',
  });
  const { authenticate_url } = await response.json();

  // Begin the OTP flow
  const { url } = await embedded.authenticateOtp(authenticate_url, email);

  document.getElementById("otp_url").setAttribute("value", url);
  
  // Once I have all of the pieces and parts, I can hook OTP redemption to the button
  document.getElementById("verify_button").onclick = redeemHandler(embedded, url);
});
