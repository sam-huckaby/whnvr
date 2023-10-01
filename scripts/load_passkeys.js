import "@beyondidentity/bi-sdk-js";
import { Embedded } from "@beyondidentity/bi-sdk-js";

// We have to initialize the embedded SDK every time we want to use it, so that seems a little weird. Can I pass this around?
Embedded.initialize().then(async (embedded) => {
  // Get passkeys that are already bound to the current device
  const passkeys = await embedded.getPasskeys();

  // Hide the spinner
  htmx.remove(htmx.find("#passkey_loader"));

  // Grab the container that passkeys will live in, so we can fill it
  const container = document.getElementById("passkey_container");

  // If the user has never enrolled a passkey before, we need to provide them with a route to create their first
  if ( passkeys.length === 0 ) {
    htmx.remove(htmx.find("#delete_passkey_link"));
    const noPasskeyTile = document.createElement("div");
    noPasskeyTile.setAttribute("class", "text-4xl lg:text-base w-full p-4 lg:p-2 mb-2 flex flex-col justify-center items-center rounded border-2 lg:border border-solid border-whnvr-500");
    const noPasskeyText = document.createElement("span");
    noPasskeyText.setAttribute("class", "my-2 italic font-bold");
    noPasskeyText.innerText = "No Passkeys Found";

    noPasskeyTile.append(noPasskeyText);
    container.append(noPasskeyTile);
    return;
  }

  if (passkeys.length > 4) {
    container.classList.add("border-b");
    container.classList.add("border-b-whnvr-900");
    container.classList.add("dark:border-b-whnvr-100");
  }

  // Build the picklist of passkey tiles
  for( const passkey of passkeys ) {
    // Create the displayable contents for a passkey
    const passkeyDisplayName = document.createElement("span");
    passkeyDisplayName.setAttribute("class", "text-6xl lg:text-xl");
    passkeyDisplayName.innerText = passkey.identity.displayName;
    const passkeyEmail = document.createElement("span");
    passkeyEmail.setAttribute("class", "text-3xl lg:text-base text-whnvr-500 dark:text-whnvr-400");
    passkeyEmail.innerText = passkey.identity.primaryEmailAddress ?? "No Email Provided";

    // Create a container to display a given passkey's items
    const passkeyTile = document.createElement("button");
    passkeyTile.setAttribute("id", "passkey-"+passkey.id);
    // TODO: Can I make these shine on hover?
    passkeyTile.setAttribute("class", "w-full p-2 mb-8 lg:mb-2 flex flex-col justify-center items-center lg:items-start rounded border-2 lg:border border-solid border-whnvr-500 ease-in duration-200 hover:dark:bg-whnvr-950/75 hover:bg-whnvr-300/50");
    passkeyTile.setAttribute("hx-get", `/authenticate?id=${passkey.id}`);
    passkeyTile.setAttribute("hx-trigger", "click");
    passkeyTile.setAttribute("hx-target", "#passkey_container");
    passkeyTile.setAttribute("hx-swap", "outerHTML");
    htmx.process(passkeyTile);

    // Giving the tile some kids
    passkeyTile.append(passkeyDisplayName);
    passkeyTile.append(passkeyEmail);

    // I think you know what this does.
    container.append(passkeyTile);
  }
});

