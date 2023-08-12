# WHNVR
A place to scream into the void _socially_.

This is an open source project built using OCaml for the server, Htmx for the templates, and Petrol for Database management.

## Setup

### Database
You will need to configure a database with the name "whnvr" and create a user "dream" which has access to it.
Currently that database will need to be running on port 5432, but that will hopefully be configurable eventually.
You will need to export an environment variable `DB_PASS` which contains the password for the dream user in the DB.

### Tailwind
This project uses tailwind, but does not install it via npm. You may choose to do so, but the preferred solution
is to download the [Tailwind CLI](https://tailwindcss.com/blog/standalone-cli) and run it that way.

