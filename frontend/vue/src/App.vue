<template>
<v-app>
  <div id="app">
  
  <!-- <div id="nav">
      <router-link to="/">Login</router-link> |
      <router-link to="/kgraphadmin">KGraphAdmin</router-link> |
      <router-link to="/kgraphuser">KGraphUser</router-link>
  </div> -->
    <router-view/>
    
  </div>
</v-app>
</template>


<style>
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  align-content: center;
  align-items: center;
  align-self: center;
  justify-content: center;
  color: #2c3e50;
}

#nav {
  padding: 30px;
}

#nav a {
  font-weight: bold;
  color: #2c3e50;
}

#nav a.router-link-exact-active {
  color: #42b983;
}
</style>
