import Vue from 'vue'
import VueApollo from 'vue-apollo'

import { ApolloClient } from 'apollo-client'
import { createHttpLink } from 'apollo-link-http'
import { InMemoryCache } from 'apollo-cache-inmemory'

// Install the vue plugin
Vue.use(VueApollo)

// IMPORTANT => ENV variables: https://cli.vuejs.org/guide/mode-and-env.html
console.log(process.env)

// TODO : replace with user token (non-admin)
const AUTH_TOKEN = process.env.VUE_APP_HASURA_GRAPHQL_ADMIN_SECRET

// Http endpoint
const httpEndpoint = process.env.VUE_APP_GRAPHQL_HTTP || 'http://localhost:8080/v1/graphql'

const httpLink = new createHttpLink({
  uri: httpEndpoint,
  headers: {
    'content-type': 'application/json',
    'x-hasura-admin-secret': AUTH_TOKEN
  }
})

export function createProvider () {
  const apolloClient = new ApolloClient({
    link: httpLink,
    cache: new InMemoryCache()
  });
  
  Vue.use(VueApollo);

  const apolloProvider = new VueApollo({
    defaultClient: apolloClient,
    defaultOptions: {
      $loadingKey: 'loading'
    }
  });

  return apolloProvider
}
