#!/bin/bash

docker-compose exec -T postgres psql -U postgres postgres < ./schema/hasura-data-exported.sql
