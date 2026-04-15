<script setup>
import { ref, onMounted } from 'vue'
import { useEmployeeStore } from '@/stores/employees'
import EmployeeTable from '@/components/EmployeeTable.vue'
import EmployeeForm from '@/components/EmployeeForm.vue'
import SalaryWidget from '@/components/SalaryWidget.vue'

const store = useEmployeeStore()

const showForm = ref(false)
const editingEmployee = ref(null)
const viewingEmployee = ref(null)
const showDeleteConfirm = ref(false)
const deletingEmployee = ref(null)
const deleteLoading = ref(false)
const saveError = ref(null)

onMounted(() => {
  store.fetchEmployees(1)
})

function openAddForm() {
  editingEmployee.value = null
  showForm.value = true
  saveError.value = null
}

function openEditForm(employee) {
  editingEmployee.value = employee
  showForm.value = true
  saveError.value = null
}

function closeForm() {
  showForm.value = false
  editingEmployee.value = null
  saveError.value = null
}

async function handleSave(formData, id) {
  saveError.value = null
  try {
    if (id) {
      await store.updateEmployee(id, formData)
    } else {
      await store.createEmployee(formData)
    }
    closeForm()
  } catch (err) {
    saveError.value = err.response?.data?.errors || 'Failed to save employee'
  }
}

function confirmDelete(employee) {
  deletingEmployee.value = employee
  showDeleteConfirm.value = true
}

async function handleDelete() {
  if (!deletingEmployee.value) return
  deleteLoading.value = true
  try {
    await store.deleteEmployee(deletingEmployee.value.id)
    showDeleteConfirm.value = false
    deletingEmployee.value = null
  } catch (err) {
    // keep dialog open on failure
  } finally {
    deleteLoading.value = false
  }
}

function viewEmployee(employee) {
  viewingEmployee.value = employee
}

function editFromView() {
  const emp = viewingEmployee.value
  viewingEmployee.value = null
  openEditForm(emp)
}

function formatSalary(salary, currency) {
  const num = Number(salary)
  if (isNaN(num)) return salary
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: currency || 'USD',
    maximumFractionDigits: 0
  }).format(num)
}

function typeBadgeClass(type) {
  const map = {
    'full-time': 'bg-primary',
    'part-time': 'bg-warning text-dark',
    'contract': 'bg-info text-dark'
  }
  return `badge ${map[type] || 'bg-secondary'}`
}

function statusBadgeClass(status) {
  return `badge ${status === 'active' ? 'bg-success' : 'bg-danger'}`
}
</script>

<template>
  <div>
    <SalaryWidget />

    <div class="d-flex align-items-center justify-content-between mb-3">
      <h5 class="fw-semibold mb-0">Employees</h5>
      <button class="btn btn-primary" @click="openAddForm">+ Add Employee</button>
    </div>

    <div v-if="store.error" class="alert alert-danger">{{ store.error }}</div>

    <EmployeeTable
      :employees="store.employees"
      :pagination="store.pagination"
      :loading="store.loading"
      @edit="openEditForm"
      @delete="confirmDelete"
      @view="viewEmployee"
      @page-change="store.fetchEmployees"
    />

    <EmployeeForm
      :visible="showForm"
      :employee="editingEmployee"
      @close="closeForm"
      @save="handleSave"
    />

    <!-- View Employee Modal -->
    <Teleport to="body">
      <div v-if="viewingEmployee">
        <div class="modal-backdrop fade show"></div>
        <div class="modal fade show d-block" tabindex="-1" @click.self="viewingEmployee = null">
          <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
              <div class="modal-header">
                <h5 class="modal-title">Employee Details</h5>
                <button type="button" class="btn-close" @click="viewingEmployee = null"></button>
              </div>
              <div class="modal-body">
                <table class="table table-borderless mb-0">
                  <tbody>
                    <tr>
                      <td class="text-muted" style="width: 150px;">Full Name</td>
                      <td class="fw-semibold">{{ viewingEmployee.first_name }} {{ viewingEmployee.last_name }}</td>
                    </tr>
                    <tr>
                      <td class="text-muted">Email</td>
                      <td>{{ viewingEmployee.email }}</td>
                    </tr>
                    <tr>
                      <td class="text-muted">Job Title</td>
                      <td>{{ viewingEmployee.job_title }}</td>
                    </tr>
                    <tr>
                      <td class="text-muted">Department</td>
                      <td>{{ viewingEmployee.department }}</td>
                    </tr>
                    <tr>
                      <td class="text-muted">Country</td>
                      <td>{{ viewingEmployee.country }}</td>
                    </tr>
                    <tr>
                      <td class="text-muted">Salary</td>
                      <td class="fw-semibold">{{ formatSalary(viewingEmployee.salary, viewingEmployee.currency) }}</td>
                    </tr>
                    <tr>
                      <td class="text-muted">Currency</td>
                      <td>{{ viewingEmployee.currency }}</td>
                    </tr>
                    <tr>
                      <td class="text-muted">Employment Type</td>
                      <td><span :class="typeBadgeClass(viewingEmployee.employment_type)">{{ viewingEmployee.employment_type }}</span></td>
                    </tr>
                    <tr>
                      <td class="text-muted">Status</td>
                      <td><span :class="statusBadgeClass(viewingEmployee.status)">{{ viewingEmployee.status }}</span></td>
                    </tr>
                    <tr>
                      <td class="text-muted">Hire Date</td>
                      <td>{{ viewingEmployee.hire_date || '—' }}</td>
                    </tr>
                  </tbody>
                </table>
              </div>
              <div class="modal-footer">
                <button class="btn btn-secondary" @click="viewingEmployee = null">Close</button>
                <button class="btn btn-primary" @click="editFromView">Edit</button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </Teleport>

    <!-- Delete Confirmation Modal -->
    <Teleport to="body">
      <div v-if="showDeleteConfirm">
        <div class="modal-backdrop fade show"></div>
        <div class="modal fade show d-block" tabindex="-1" @click.self="showDeleteConfirm = false">
          <div class="modal-dialog modal-dialog-centered modal-sm">
            <div class="modal-content">
              <div class="modal-header">
                <h5 class="modal-title">Delete Employee</h5>
                <button type="button" class="btn-close" @click="showDeleteConfirm = false"></button>
              </div>
              <div class="modal-body">
                <p class="mb-0">
                  Are you sure you want to delete
                  <strong>{{ deletingEmployee?.first_name }} {{ deletingEmployee?.last_name }}</strong>?
                  This action cannot be undone.
                </p>
              </div>
              <div class="modal-footer">
                <button class="btn btn-secondary" @click="showDeleteConfirm = false" :disabled="deleteLoading">Cancel</button>
                <button class="btn btn-danger" @click="handleDelete" :disabled="deleteLoading">
                  {{ deleteLoading ? 'Deleting...' : 'Delete' }}
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </Teleport>
  </div>
</template>
