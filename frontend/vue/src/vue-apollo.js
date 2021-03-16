import Vue from 'vue'
import VueApollo from 'vue-apollo'

import { ApolloClient } from 'apollo-client'
import { createHttpLink } from 'apollo-link-http'
import { InMemoryCache } from 'apollo-cache-inmemory'

// Install the vue plugin
Vue.use(VueApollo)

// IMPORTANT => ENV variables: https://cli.vuejs.org/guide/mode-and-env.html
console.log(process.env)

// Http endpoint
const httpEndpoint = process.env.VUE_APP_GRAPHQL_HTTP || 'http://localhost:8080/v1/graphql'

const getHeaders = () => {
  const headers = {'content-type': 'application/json'};
   const token = window.localStorage.getItem('auth_token');
   if (token) {
     headers.authorization = `Bearer ${token}`;
   }
   return headers;
 };

// https://hasura.io/learn/graphql/vue/apollo-client/
const httpLink = new createHttpLink({
  uri: httpEndpoint,
  headers: getHeaders()
})

export function createProvider () {
  const apolloClient = new ApolloClient({
    link: httpLink,
    cache: new InMemoryCache({ addTypename: true })
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
