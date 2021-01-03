import Vue from 'vue'
import VueRouter from 'vue-router'
import Home from '../views/Home.vue'
import KGraphAdmin from '../components/KGraphAdmin'
import KGraphUser from '../components/KGraphUser'

Vue.use(VueRouter)

const routes = [
  {
    path: '/',
    name: 'Home',
    component: Home
  },
  {
    path: '/kgraphadmin',
    name: 'KGraphAdmin',
    component: KGraphAdmin
  },
  {
    path: '/kgraphuser',
    name: 'KGraphUser',
    component: KGraphUser
  }
]

const router = new VueRouter({
  routes
})

export default router
