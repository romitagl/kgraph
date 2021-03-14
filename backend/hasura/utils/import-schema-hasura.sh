#!/bin/bash

# import custom additional statements
docker-compose exec -T postgres psql -U postgres postgres < ./schema/hasura-schema-prerequisites.sql

# import hasura schema dump
docker-compose exec -T postgres psql -U postgres postgres < ./schema/hasura-schema-dump.sql
