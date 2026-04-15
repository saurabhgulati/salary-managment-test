import { defineStore } from 'pinia'
import { ref } from 'vue'
import { employeeApi } from '@/api/employees'

export const useEmployeeStore = defineStore('employees', () => {
  const employees = ref([])
  const pagination = ref(null)
  const loading = ref(false)
  const error = ref(null)

  async function fetchEmployees(page = 1) {
    loading.value = true
    error.value = null
    try {
      const result = await employeeApi.getAll(page)
      employees.value = result.data
      pagination.value = result.pagination
    } catch (err) {
      error.value = err.response?.data?.errors || err.message
    } finally {
      loading.value = false
    }
  }

  async function createEmployee(data) {
    const employee = await employeeApi.create(data)
    await fetchEmployees(pagination.value?.current_page || 1)
    return employee
  }

  async function updateEmployee(id, data) {
    const updated = await employeeApi.update(id, data)
    const index = employees.value.findIndex(e => String(e.id) === String(id))
    if (index !== -1) employees.value[index] = updated
    return updated
  }

  async function deleteEmployee(id) {
    await employeeApi.delete(id)
    await fetchEmployees(pagination.value?.current_page || 1)
  }

  return {
    employees,
    pagination,
    loading,
    error,
    fetchEmployees,
    createEmployee,
    updateEmployee,
    deleteEmployee
  }
})
