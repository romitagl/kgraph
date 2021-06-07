# Local KGraph setup on Docker

This Docker Compose setup runs [Hasura GraphQL Engine](https://github.com/hasura/graphql-engine) along with Postgresql, the authentication service and the Frontend using `docker-compose`.

## Pre-requisites

- [Docker](https://docs.docker.com/install/)
- [Docker Compose](https://docs.docker.com/compose/install/)

## Usage

- Clone this repo on a machine where you'd like to run the entire project
- Set the required environment variables:

```bash
# set the admin secret for Hasura - can be generated random: `openssl rand -base64 32`
export HASURA_GRAPHQL_ADMIN_SECRET="hasura-admin-secret"
# set the Hasura JWT secret as described at: https://hasura.io/docs/latest/graphql/core/auth/authentication/jwt.html, https://hasura.io/docs/latest/graphql/core/actions/codegen/python-flask.html#actions-codegen-python-flask
export HASURA_GRAPHQL_JWT_SECRET_TYPE='HS256'
# set the JWT secret key for Hasura - can be generated random: `openssl rand -base64 68`
export HASURA_GRAPHQL_JWT_SECRET_KEY=$(openssl rand -base64 68)
export HASURA_GRAPHQL_JWT_SECRET="{ \"type\": \"${HASURA_GRAPHQL_JWT_SECRET_TYPE}\", \"key\": \"${HASURA_GRAPHQL_JWT_SECRET_KEY}\" }"
# Set to "true" to enable the Hasura GraphQL console (development). Set to "false" for production.
export HASURA_GRAPHQL_ENABLE_CONSOLE="true"
# pick a release version from: https://github.com/romitagl/kgraph/releases
export KGRAPH_VERSION="v0.1"
```

- run Docker Compose: `docker-compose up -d frontend`

### Services

- Web portal will be available at: `http://localhost:80`
- Hasura Console (if enabled) will be available at: `http://localhost:8080/console`
