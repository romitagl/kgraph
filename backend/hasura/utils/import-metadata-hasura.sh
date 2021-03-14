#!/bin/bash

if [ $# != 1 ]; then
  printf "error: missing Hasura metadata input file. E.g.: bash ./utils/import-metadata-hasura.sh ./schema/hasura-metadata-dump.json"
  exit 1
else
  printf "installing the following metadata:\n%s\n" "$( cat "$1" )"
fi

# replace_metadata is used to replace/import metadata into Hasura. Existing metadata will be replaced with the new one.
JSON_METADATA=$( cat "$1" )
CURL_DATA='{"type" : "replace_metadata", "args": '$JSON_METADATA' }'

curl -v -H "X-Hasura-Admin-Secret:$HASURA_GRAPHQL_ADMIN_SECRET" -H 'Content-Type: application/json' \
-d "$CURL_DATA" \
http://localhost:8080/v1/query
