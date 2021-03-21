#!/bin/bash

# https://docs.hasura.io/1.0/graphql/manual/api-reference/schema-metadata-api/manage-metadata.html

mkdir -p schema
curl -o ./schema/hasura-metadata-dump-exported.json -H "X-Hasura-Admin-Secret:$HASURA_GRAPHQL_ADMIN_SECRET" -H  'Content-Type: application/json' \
-d '{"type" : "export_metadata", "args": {} }' \
http://127.0.0.1:8080/v1/query
