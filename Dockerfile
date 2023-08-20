# Shamelessly based on this Dockerfile: https://github.com/Asya-kawai/blog/blob/main/20210603/how-to-create-minimum-ocaml-docker-image-en.md
# TODO: See if it's possible to get this back to Alpine, since the current build is like 500 Mb
FROM ocaml/opam:ubuntu-22.04-ocaml-5.0 AS init-opam

RUN set -x && \
    : "Update and upgrade default package" && \
    sudo apt update && sudo apt -y upgrade && \
    sudo apt -y install postgresql libev-dev libgmp-dev pkg-config libssl-dev zlib1g-dev libpq-dev

# --- #

FROM init-opam AS ocaml-app-base
COPY . .
RUN set -x && \
    : "Install related pacakges" && \
    opam install . --deps-only --locked && \
    eval $(opam env) && \
    : "Build applications" && \
    dune build && \
    sudo cp ./_build/default/bin/main.exe /usr/bin/main.exe && \
    sudo cp -R ./www /usr/bin/www

# --- #

FROM ubuntu AS ocaml-app

COPY --from=ocaml-app-base /usr/bin/main.exe /home/app/main.exe
# All of the static web assets live in www/static
COPY --from=ocaml-app-base /usr/bin/www /home/app/www
RUN set -x && \
    : "Update and upgrade default package" && \
    DEBIAN_FRONTEND=noninteractive apt update && DEBIAN_FRONTEND=noninteractive apt -y upgrade && \
    DEBIAN_FRONTEND=noninteractive apt -y install postgresql libev-dev libgmp-dev pkg-config libssl-dev zlib1g-dev libpq-dev && \
    : "Create a user to execute application" && \
    useradd -ms /bin/bash app && \
    : "Change owner to app" && \
    chown app:app /home/app/main.exe

WORKDIR /home/app
USER app
ENTRYPOINT ["/home/app/main.exe"]
