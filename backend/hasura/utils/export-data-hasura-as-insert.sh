#!/bin/bash

docker-compose exec -T postgres pg_dump -U postgres -a --data-only --column-inserts -f /shared/schema/hasura-data-exported-as-insert.sql -n kgraph postgres
