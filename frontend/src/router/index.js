import { createRouter, createWebHistory } from 'vue-router'
import EmployeesView from '@/views/EmployeesView.vue'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'employees',
      component: EmployeesView
    }
  ],
})

export default router
