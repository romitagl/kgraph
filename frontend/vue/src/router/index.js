import Vue from 'vue'
import VueRouter from 'vue-router'
import Login from '../views/Login.vue'
import KGraphAdmin from '../views/KGraphAdmin'
import KGraphUser from '../views/KGraphUser'
import Dashboard from '../views/Dashboard'

Vue.use(VueRouter)

const routes = [
  {
    path: '/',
    name: 'Login',
    component: Login
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
  },
  {
    path: '/dashboard',
    name: 'Dashboard',
    component: Dashboard
  }
]

const router = new VueRouter({
  routes
})

export default router
