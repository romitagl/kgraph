# HASURA

This folder contains the Postgresql database and Graphql Engine files.

## Dependencies

All the services run in a **Docker** container and are orchestrated through  [Docker Compose](https://docs.docker.com/compose/).

**GNU make** is also required for running the tests.

## Setup

Set the required environment variables:

```bash
# set the admin secret for Hasura - can be generated random: `openssl rand -base64 32`
export HASURA_GRAPHQL_ADMIN_SECRET="hasura-admin-secret"
# Set to "true" to enable the Hasura GraphQL console (development). Set to "false" for production.
export HASURA_GRAPHQL_ENABLE_CONSOLE="true"
```

Quick Run:

```bash
# only for first setup or when re-setting the schema
make dependencies
# to start the GraphQL Server
make start
# install the PostgreSQL schema and Hasura metadata
make install_schema_and_metadata
```

The Hasura console, if enabled (*HASURA_GRAPHQL_ENABLE_CONSOLE=true*), is available at: `http://localhost:8080/console`. Remember to select the `kgraph` Database Schema.

The following scripts are used to update an existing production environment, creating the new schema an reimporting a backup of the data.

```bash
# take a dump of the Postgres DB for full backup
bash ./utils/export-dump-hasura.sh
# export data from the Postgres DB for reimporting in the new schema
bash ./utils/export-data-hasura.sh

# (optional) - if the Postgres schema/Hasura metadata have changed
bash ./utils/export-metadata-hasura.sh
bash ./utils/export-schema-hasura.sh

# stop the GraphQL engine
make stop
# remove the Postgresql folder
make dependencies

# (optional) - if the Postgres schema/Hasura metadata have changed
mv ./schema/hasura-metadata-dump-exported.json ./schema/hasura-metadata-dump.json
mv ./schema/hasura-schema-dump-exported.sql ./schema/hasura-schema-dump.sql

# import the sql schema, metadata and data
make start
make install_schema_and_metadata
bash ./utils/import-data-hasura.sh
```

## Testing

The Makefile implements all the targets required for an End-To-End testing in particular:

1. Satisfy the dependencies (create the postgresql data folder)
2. Start the graphql-engine and postgresdb
3. Install the SQL schema and the Hasura metadata
4. Run all the tests available
5. Stop the Docker containers

To run the tests: `make ci`

## Developer Notes

- Hasura Metadata export: `bash ./utils/export-metadata-hasura.sh`. Metadata are saved into the *schema/hasura-metadata-dump-exported.json* file
- SQL Schema export: run `bash ./utils/export-schema-hasura.sh`. Schema is exported to the *schema/hasura-schema-dump-exported.sql* file (folder shared as docker-compose volume)
- SQL Data export: run `bash ./utils/export-data-hasura.sh`. SQL Data is exported to the *schema/hasura-data-exported.sql* file (folder shared as docker-compose volume)
- SQL Full Dump export: run `bash ./utils/export-dump-hasura.sh`. SQL Data is exported to the *schema/hasura-dump-exported.sql* file (folder shared as docker-compose volume)
