<template>
  <div id="app">
    <!-- <img alt="Vue logo" src="./assets/logo.png"> -->
    <KGraph msg="Welcome to Your Vue.js App"/>
  </div>
</template>

<script>
import KGraph from './components/KGraph.vue'

export default {
  name: 'App',
  components: {
    KGraph
  }
}
</script>

<style>
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: left;
  color: #2c3e50;
  margin-top: 60px;
}
</style>
