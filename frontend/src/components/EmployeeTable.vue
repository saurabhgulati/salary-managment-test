<script setup>
import { computed } from 'vue'

const props = defineProps({
  employees: { type: Array, required: true },
  pagination: { type: Object, default: null },
  loading: { type: Boolean, default: false }
})

const emit = defineEmits(['edit', 'delete', 'page-change', 'view'])

function formatSalary(salary, currency) {
  const num = Number(salary)
  if (isNaN(num)) return salary
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: currency || 'USD',
    maximumFractionDigits: 0
  }).format(num)
}

function fullName(employee) {
  return `${employee.first_name} ${employee.last_name}`
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

const pageNumbers = computed(() => {
  if (!props.pagination) return []
  const current = props.pagination.current_page
  const total = props.pagination.total_pages
  const pages = []
  const start = Math.max(1, current - 2)
  const end = Math.min(total, current + 2)
  if (start > 1) {
    pages.push(1)
    if (start > 2) pages.push('...')
  }
  for (let i = start; i <= end; i++) {
    pages.push(i)
  }
  if (end < total) {
    if (end < total - 1) pages.push('...')
    pages.push(total)
  }
  return pages
})
</script>

<template>
  <div class="card shadow-sm">
    <div class="card-body">
      <div v-if="loading" class="text-center py-5 text-muted">
        <div class="spinner-border spinner-border-sm me-2" role="status"></div>
        Loading employees...
      </div>

      <template v-else-if="employees.length">
        <div class="table-responsive">
          <table class="table table-hover align-middle mb-0">
            <thead class="table-light">
              <tr>
                <th>Full Name</th>
                <th>Email</th>
                <th>Job Title</th>
                <th>Department</th>
                <th>Country</th>
                <th>Salary</th>
                <th>Type</th>
                <th>Status</th>
                <th>Hire Date</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="emp in employees" :key="emp.id">
                <td class="fw-semibold">{{ fullName(emp) }}</td>
                <td>{{ emp.email }}</td>
                <td>{{ emp.job_title }}</td>
                <td>{{ emp.department }}</td>
                <td>{{ emp.country }}</td>
                <td class="text-nowrap">{{ formatSalary(emp.salary, emp.currency) }}</td>
                <td><span :class="typeBadgeClass(emp.employment_type)">{{ emp.employment_type }}</span></td>
                <td><span :class="statusBadgeClass(emp.status)">{{ emp.status }}</span></td>
                <td>{{ emp.hire_date || '—' }}</td>
                <td>
                  <div class="d-flex gap-1">
                    <button class="btn btn-sm btn-outline-secondary" title="View" @click="emit('view', emp)">👁</button>
                    <button class="btn btn-sm btn-outline-primary" title="Edit" @click="emit('edit', emp)">✎</button>
                    <button class="btn btn-sm btn-outline-danger" title="Delete" @click="emit('delete', emp)">✕</button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <div v-if="pagination" class="mt-3">
          <nav>
            <ul class="pagination justify-content-center mb-1">
              <li class="page-item" :class="{ disabled: !pagination.prev_page }">
                <a class="page-link" href="#" @click.prevent="emit('page-change', pagination.prev_page)">‹ Prev</a>
              </li>
              <template v-for="page in pageNumbers" :key="page">
                <li v-if="page === '...'" class="page-item disabled">
                  <span class="page-link">...</span>
                </li>
                <li v-else class="page-item" :class="{ active: page === pagination.current_page }">
                  <a class="page-link" href="#" @click.prevent="emit('page-change', page)">{{ page }}</a>
                </li>
              </template>
              <li class="page-item" :class="{ disabled: !pagination.next_page }">
                <a class="page-link" href="#" @click.prevent="emit('page-change', pagination.next_page)">Next ›</a>
              </li>
            </ul>
          </nav>
          <p class="text-center text-muted small mb-0">
            Showing page {{ pagination.current_page }} of {{ pagination.total_pages }}
            ({{ pagination.count }} total employees)
          </p>
        </div>
      </template>

      <div v-else class="text-center py-5 text-muted">
        <p class="mb-0">No employees found</p>
      </div>
    </div>
  </div>
</template>
