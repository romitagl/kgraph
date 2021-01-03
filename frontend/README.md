# Frontend Components

## Vue.js

Vue 2 Template was created with [Vue CLI](https://cli.vuejs.org/) `vue-cli` v4.5 tool:

```bash
npm install vue@next

npm install -g @vue/cli

vue create vue

# (optional) to upgrade
cd vue ; vue upgrade --next

# to add Apollo Graphql integration: https://apollo.vuejs.org/guide/installation.html#vue-cli-plugin
vue add apollo
npm install --save vue-apollo graphql apollo-client apollo-link apollo-link-http apollo-cache-inmemory graphql-tag
```

🎉  Successfully created project vue.
👉  Get started with the following commands:

 $ cd vue
 $ npm run serve

 To change the default port from 8080 to 5000: `npm run serve -- --port 5000` or configure the file `vue.config.js`:

```javascript
module.exports = {
  devServer: {
    port: 5000
  }
}
```

Remember also to set the values for the environment variables in the `.env` file. Example `export HASURA_GRAPHQL_ADMIN_SECRET="hasura-admin-secret"` as explained in the [Hasura README](../backend/hasura/README.md).

### Cypress testing

You can open Cypress by running: `node_modules/.bin/cypress open`

More info at: <https://on.cypress.io/installing-cypress>
