#!/bin/bash

curl --request POST -H "Content-Type: application/json"  -d  '@/schema/schema.graphql' http://localhost:8080/admin/schema
