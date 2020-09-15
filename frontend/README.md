# Web App

## react-kgraph

This folder contains the Web App code, based on React.

Template was created with the `create-react-app --template typescript --use-npm react-kgraph` command.

### Dependencies

Recent versions of Node.js and npm installed on your system

### Developer Notes

Inside the `react-kgraph` directory, you can run several commands:

- `npm start`
    Starts the development server. Go to http://localhost:3000 in your web browser to see your app up and running.

- `npm run build`
    Bundles the app into static files for production.

- `npm test`
    Starts the test runner.

- `npm run eject`
    Removes this tool and copies build dependencies, configuration files
    and scripts into the app directory. If you do this, you can’t go back!

### Graphql

npm install apollo-boost @apollo/react-hooks graphql

https://www.apollographql.com/docs/react/get-started/

### react-digraph

npm install --save react-digraph
npm install --save react react-dom

## vue-kgraph

Template was created with the `vue-cli` tool:

```bash
npm install -g @vue/cli

vue create vue-kgraph

# to add Apollo Graphql integration
vue add apollo
```

📄  Generating README.md...

🎉  Successfully created project vue-kgraph.
👉  Get started with the following commands:

 $ cd vue-kgraph
 $ npm run serve

 To change the default port from 8080 to 5000: `npm run serve -- --port 5000` or configure the file `vue.config.js`:
```javascript
module.exports = {
  devServer: {
    port: 5000
  }
}
```