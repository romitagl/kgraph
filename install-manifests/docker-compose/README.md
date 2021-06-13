# Local KGraph setup on Docker

This Docker Compose setup runs [Hasura GraphQL Engine](https://github.com/hasura/graphql-engine) along with Postgresql, the authentication service and the Frontend using `docker-compose`.

## Pre-requisites

- [Docker](https://docs.docker.com/install/)
- [Docker Compose](https://docs.docker.com/compose/install/)

## Usage

- Clone this repo or, minimally, download the following files:
  - ./docker-compose.yaml
  - ./env.local

*Note* that the docker-compose.yaml is set to pull the `latest` version available of KGraph images. To pin it down to a specific version, just replace `latest` with release version from: <https://github.com/romitagl/kgraph/releases>.

- to start: `docker-compose up -d frontend`
- to stop: `docker-compose down`
- to remove the volume containing the database: `docker volume rm -f docker-compose_postgres_data`

All the environment variables required to operate the services are defined in the [env.local](./env.local) file.

### Services

- Web portal will be available at: `http://localhost:80`
- Hasura Console (if HASURA_GRAPHQL_ENABLE_CONSOLE enabled) will be available at: `http://localhost:8080/console`. Note that the *admin-secret* is defined in the HASURA_GRAPHQL_ADMIN_SECRET variable located in the [env.local](./env.local) file.
