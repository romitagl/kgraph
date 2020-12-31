#!/bin/bash

# https://docs.hasura.io/1.0/graphql/manual/api-reference/schema-metadata-api/manage-metadata.html

mkdir -p schema
curl -o ./schema/hasura_metadata_dump_exported.json  --request POST -H "X-Hasura-Admin-Secret:$HASURA_GRAPHQL_ADMIN_SECRET" -H  'Content-Type: application/json' -H "X-Hasura-Role: admin" \
-d '{"type" : "export_metadata", "args": {} }' \
http://localhost:8080/v1/query
