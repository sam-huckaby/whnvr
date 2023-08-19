# WHNVR
A place to scream into the void _socially_.

This is an open source project built using OCaml for the server, Htmx for the templates, and Petrol for Database management.

## Setup

### Database
Currently the only tested database is PostgreSQL, but in theory SQLite should work as well.

You will need to set the following environment varibales before starting WHNVR:
`DB_HOST` -> The host of the database instance
`DB_PORT` -> The port that the database is using
`DB_NAME` -> The name of the database
`DB_PASS` -> the password of the database user
`DB_USER` -> The username of the database user


### Tailwind
This project uses tailwind, but does not install it via npm. You may choose to do so, but the preferred solution
is to download the [Tailwind CLI](https://tailwindcss.com/blog/standalone-cli) and run it that way.

With the Tailwind CLI, you will use `www/static/global.css` as the input and `www/static/build.css` as the output.

