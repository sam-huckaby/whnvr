# WHNVR
A place to scream into the void _socially_.

This is an open source project built using OCaml for the server, Htmx for the templates, and Petrol for Database management.

Ultimately, this project is a proof-of-concept OCaml app that I took from beginning (knowing no OCaml) to production deployment.
At the core, WHNVR wants to be a simple messaging service, not unlike many other social networks, but with a goal of providing
people with a place to anonymously state things they may not be comfortably just saying otherwise. All messages are designed to
live only 24 hours, before the database drops them. Users are not able to use passwords in the conventional sense because we
believe that passwords are fundamentally flawed. Instead, WHNVR opts to use passphrases, and eventually passkeys, which gives
a user the ability to interact without the pain of remembering the street they lived on when they were 7 years old. WHNVR does
not cater to influencers because you have no followers. Every person, every message, every thought can be evaluated for what it
is, rather than who is saying it. You don't know if 5 people or 5 million people are seeking out the messages you read. This
should urge the common reader to enjoy but investigate - take nothing at face value.

## Development Setup

### Step 1: Database
Currently the only tested database is PostgreSQL, but in theory SQLite should work as well.

You will need to set the following environment varibales before starting WHNVR:
- `DB_HOST` -> The host of the database instance
- `DB_PORT` -> The port that the database is using
- `DB_NAME` -> The name of the database
- `DB_PASS` -> the password of the database user
- `DB_USER` -> The username of the database user


### Step 2: Tailwind
This project uses tailwind, but does not install it via npm. You may choose to do so, but the preferred solution
is to download the [Tailwind CLI](https://tailwindcss.com/blog/standalone-cli) and run it that way.

With the Tailwind CLI, you will use `www/static/global.css` as the input and `www/static/build.css` as the output like so:

```
./tailwindcss -i www/static/global.css -o www/static/build.css --watch
```

The `--watch` flag will keep the process running and update the CSS in the background as you swap tailwind classes in and out.

### Step 3: Dune
You can start WHNVR via dune:
```
dune exec whnvr
```

This will start the app on port 8080
