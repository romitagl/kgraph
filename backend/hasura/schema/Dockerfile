# https://hasura.io/docs/latest/graphql/core/migrations/config-v2/advanced/auto-apply-migrations.html#cli-migrations-image
FROM hasura/graphql-engine:v1.3.3.cli-migrations-v2

COPY ./kgraph-migration/migrations /hasura-migrations
COPY ./kgraph-migration/metadata /hasura-metadata