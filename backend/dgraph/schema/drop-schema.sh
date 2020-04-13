#!/bin/bash

curl -X POST -d '{"drop_all": true}' localhost:8080/alter http://localhost:8080/alter
