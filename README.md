# KGraph

Knowledge Graph Project

## Developer Notes

All the pull requests to `master` have to pass the CI check [Super-Linter](https://github.com/github/super-linter).

### Super Linter

To setup locally the Super Linter follow [these instructions](https://github.com/github/super-linter/blob/main/docs/run-linter-locally.md).

Run check on the local folder:

```bash
docker run -e RUN_LOCAL=true -e FILTER_REGEX_EXCLUDE=".*backend/hasura/schema/.*" -v `pwd`:/tmp/lint github/super-linter:v3.14.3
```
