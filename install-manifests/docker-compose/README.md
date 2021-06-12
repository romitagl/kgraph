# Local KGraph setup on Docker

This Docker Compose setup runs [Hasura GraphQL Engine](https://github.com/hasura/graphql-engine) along with Postgresql, the authentication service and the Frontend using `docker-compose`.

## Pre-requisites

- [Docker](https://docs.docker.com/install/)
- [Docker Compose](https://docs.docker.com/compose/install/)

## Usage

- Clone this repo on a machine where you'd like to run the entire project
- Set the required environment variables:

```bash
# pick a release version from: https://github.com/romitagl/kgraph/releases
export KGRAPH_VERSION="v0.1"
```

- to start: `docker-compose up -d frontend`
- to stop: `docker-compose down`
- to remove the volume containing the database: `docker volume rm -f docker-compose_postgres_data`

All the enviroment variables required to operate the services are defined in the [env.local](./env.local) file.

### Services

- Web portal will be available at: `http://localhost:80`
- Hasura Console (if enabled) will be available at: `http://localhost:8080/console`
