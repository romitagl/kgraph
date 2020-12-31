#!/bin/bash

docker-compose exec -T postgres pg_dump -U postgres -a -f /shared/schema/hasura-data-exported.sql -n kgraph postgres
