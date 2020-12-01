# Dgraph

This folder contains the Graph database files.

The engine used is (Dgraph)[https://dgraph.io].

## How to Run

The Makefiles takes care of automating all the required speps.

```bash
# to handle the dependencies and start the Dgraph services
make

# to install the GraphQL schema
make install_schema

# to stop the Dgraph services
make stop
```

After `make start`, Dgraph Alpha will now be running and listening for HTTP requests on port 8080 and Ratel would be listening on port 8000. 

## Dependencies

All the services run in a **Docker** container and are orchestrated through [Docker Compose](https://docs.docker.com/compose/).

**GNU make** is also required for running the tests.

## Developer Notes

Dgraph serves two GraphQL endpoints:

- /graphql it serves the GraphQL API for your schema;
- /admin it serves a GraphQL schema for administering your system.

The API responds to GraphQL schema introspection, so you can consume it with anything that’s GraphQL: e.g. GraphQL Playground, Insomnia, GraphiQL and Altair.

Point your favorite tool at http://localhost:8080/graphql and schema introspection will show you what’s been generated.

Render the schema in the query [console](http://localhost:8000/?latest): `schema {}`

Dgraph Query Language:<https://dgraph.io/docs/v1.0.9/query-language>

### GraphQL query examples

```bash
# create schema
curl --request POST -H "Content-Type: application/json"  -d 'type Person { name: String }' http://localhost:8080/admin/schema
# run query on the schema
curl -X POST -H "Content-Type: application/json" -d '{"query":"query {queryUser {name}}"}' http://localhost:8080/graphql
# query with params
curl -H 'Content-Type: application/json' localhost:8080/query -d '{
  "query": "query qWithVars($name: string) { q(func: eq(name, $name)) { name } }",
  "variables": {"$name": "Alice"}
}'
```

### Graphql example queries

```text
# add topics to "user1"
mutation{
  updateUser(input: {filter:{name: {eq: "user1"}}, set: {rootTopics:
  [{name:"newTopic2", permission:Private, childTopics:[{name:"childTopic", permission:Private, childTopics:[{name:"childChildTopic", permission:Private}]}]}]}}){
    numUids
  }
}
# query user by name using variables: {"name" : "test" }
query getUser($name: String!) {getUser (name: $name) { name rootTopics { name text } }}
# add test topics
mutation{
  updateUser(input: {filter:{name: {eq: "test"}}, set: {rootTopics:
  [
    {name:"1", permission:Private, childTopics:
    [
      {name:"11", permission:Private, childTopics:
        [
          {name:"111", permission:Private}
        ]
      }
    ]
    },
    {name:"2", permission:Private, childTopics:
    [
      {name:"21", permission:Private, childTopics:
      [
        {name:"211", permission:Private},
        {name:"212", permission:Private},
        {name:"213", permission:Private,
          childTopics:[{name:"2131", permission:Private}]
        }
      ]
      }
    ]
    },
    {name:"3", permission:Private, childTopics:
    [
      {name:"31", permission:Private,
        childTopics:[{name:"311", permission:Private}]
      }
    ]
    },
    {name:"4", permission:Private, childTopics:
    [
      {name:"41", permission:Private},
      {name:"42", permission:Private},
      {name:"43", permission:Private,childTopics:
        [{name:"421", permission:Private}]
      }
    ]
    },
  ]
  }}){
    numUids
  }
}
```
