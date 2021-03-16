import Vue from 'vue'
import VueRouter from 'vue-router'
import Login from '../views/Login.vue'
import KGraphAdmin from '../components/KGraphAdmin'
import KGraphUser from '../components/KGraphUser'

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
  }
]

const router = new VueRouter({
  routes
})

export default router
