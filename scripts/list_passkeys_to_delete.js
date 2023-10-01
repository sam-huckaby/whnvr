import "@beyondidentity/bi-sdk-js";
import { Embedded } from "@beyondidentity/bi-sdk-js";

htmx.remove(htmx.find("#password_destroyer_link"));
htmx.remove(htmx.find("#login_error_msg"));

Embedded.initialize().then(async (embedded) => {
  // Get passkeys that are already bound to the current device
  const passkeys = await embedded.getPasskeys();

  // Hide the spinner
  htmx.remove(htmx.find("#passkey_loader"));

  // Grab the container that passkeys will live in, so we can fill it
  const container = document.getElementById("passkey_container");

  // If the user has never enrolled a passkey before, we need to provide them with a route to create their first
  if ( passkeys.length === 2 ) {
    const noPasskeysMsg = document.createElement("div");
    noPasskeysMsg.setAttribute("class", "text-4xl lg:text-base w-full p-4 lg:p-2 flex flex-row justify-center items-center rounded border border-solid border-whnvr-500");
    noPasskeysMsg.innerText = "No passkeys to delete";
    container.append(noPasskeysMsg);
    return;
  }

  // Look, Ma! I made a functor!
  const deleter = (embeddedBI, passkeyId) => {
    return () => {
      embeddedBI.deletePasskey(passkeyId).then(() => {
        window.location.reload();
      });
    };
  };

  // Build the picklist of passkey tiles
  for( const passkey of passkeys ) {
    // Create the displayable contents for a passkey
    const passkeyDisplayName = document.createElement("span");
    passkeyDisplayName.setAttribute("class", "text-6xl lg:text-xl");
    passkeyDisplayName.innerText = passkey.identity.displayName;
    const passkeyEmail = document.createElement("span");
    passkeyEmail.setAttribute("class", "text-3xl lg:text-base text-whnvr-500");
    passkeyEmail.innerText = passkey.identity.primaryEmailAddress ?? "No Email Provided";

    // Create a container to display a given passkey's items
    const passkeyTile = document.createElement("button");
    passkeyTile.setAttribute("id", "passkey-"+passkey.id);
    passkeyTile.setAttribute("class", "w-full p-4 lg:p-2 mb-4 lg:mb-2 flex flex-row justify-between items-center ease-in duration-200 rounded border border-solid border-whnvr-500 hover:border-red-800 hover:bg-red-800/25");

    const passkeyInfo = document.createElement("div");
    passkeyInfo.setAttribute("class", "flex flex-col justify-center items-start");
    passkeyInfo.append(passkeyDisplayName);
    passkeyInfo.append(passkeyEmail);

    const passkeyDeleter = document.createElement("div");
    passkeyDeleter.setAttribute("class", "text-4xl lg:text-base flex flex-col justify-center items-center w-[50px] h-[50px]");
    passkeyDeleter.innerText = "🗑️";

    // Give the tile the info section and the delete icon
    passkeyTile.append(passkeyInfo);
    passkeyTile.append(passkeyDeleter);
    passkeyTile.addEventListener("click", deleter(embedded, passkey.id));

    // I think you know what this does.
    container.append(passkeyTile);

    // Hide the other bottom links... I think I want to do this somewhere else though, this feels weird
    const loginLinks = document.getElementById("login_links");
    loginLinks.classList.add("hidden");
    htmx.removeClass(htmx.find("#delete_links"), "hidden");
  }
});

