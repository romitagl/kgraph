# KGraph

**-- WIP --** Knowledge Graph Project **-- WIP --**

## Description

This project aims at creating a knowledge database with hierarchical topic modelling.

## Dependencies

- [Docker](https://www.docker.com)
- [GNU Make](https://www.gnu.org/software/make/)
- [Docker Compose](https://docs.docker.com/compose/).

## Project Structure

- `backend` : backend services
  - `hasura` : GraphQL Server + PostgreSQL Database
- `frontend` : frontend services - WIP

## GitHub Actions

![Lint Code Base](https://github.com/romitagl/kgraph/workflows/Lint%20Code%20Base/badge.svg?branch=master)

![CI](https://github.com/romitagl/kgraph/workflows/CI/badge.svg?branch=master)

## Developer Notes

All the pull requests to `master` have to pass the CI check [Super-Linter](https://github.com/github/super-linter).

### Naming Conventions

File & Folder names are separated by `-`, not `_`.

### Super Linter

To setup locally the Super Linter follow [these instructions](https://github.com/github/super-linter/blob/main/docs/run-linter-locally.md).

Run check on the local folder:

```bash
docker run -e RUN_LOCAL=true -e FILTER_REGEX_EXCLUDE=".*backend/hasura/schema/.*" -v `pwd`:/tmp/lint github/super-linter:v3.14.3
```
