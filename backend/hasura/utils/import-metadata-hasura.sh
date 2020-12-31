#!/bin/bash

# replace_metadata is used to replace/import metadata into Hasura. Existing metadata will be replaced with the new one.
JSON_METADATA=$( cat ./schema/hasura_metadata_dump.json )
CURL_DATA='{"type" : "replace_metadata", "args": '$JSON_METADATA' }'

curl -v --request POST -H "X-Hasura-Admin-Secret:$HASURA_GRAPHQL_ADMIN_SECRET"  -H  'Content-Type: application/json' -H "X-Hasura-Role: admin" \
-d "$CURL_DATA" \
http://localhost:8080/v1/query
