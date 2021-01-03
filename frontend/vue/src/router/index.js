import Vue from 'vue'
import VueRouter from 'vue-router'
import Home from '../views/Home.vue'
import KGraph from '../components/KGraph'

Vue.use(VueRouter)

const routes = [
  {
    path: '/',
    name: 'Home',
    component: Home
  },
  {
    path: '/kgraph',
    name: 'KGraph',
    component: KGraph
  }
]

const router = new VueRouter({
  routes
})

export default router
