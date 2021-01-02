import Vue from 'vue'
import VueRouter from 'vue-router'
import Home from '../views/Home.vue'
import ApolloExample from '../components/ApolloExample'

Vue.use(VueRouter)

const routes = [
  {
    path: '/',
    name: 'Home',
    component: Home
  },
  {
    path: '/apolloexample',
    name: 'ApolloExample',
    component: ApolloExample
  }
]

const router = new VueRouter({
  routes
})

export default router
