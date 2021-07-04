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

# to add Vuetify https://vuetifyjs.com/
cd vue ; vue add vuetify
```

🎉  Successfully created project vue.
👉  Get started with the following commands:

```bash
cd vue
# check env and - npm run serve
make start

# to start the frontend in Demo mode (GitHub Pages configuration), without backend services
make start_demo
```

To change the default port from 8080 to 5000: `npm run serve -- --port 5000` or configure the file `vue.config.js`:

```javascript
module.exports = {
  devServer: {
    port: 5000
  }
}
```

Remember also to set the values for the environment variables in the `.env` file.

### Cypress testing

You can open Cypress by running: `node_modules/.bin/cypress open`

More info at: <https://on.cypress.io/installing-cypress>
