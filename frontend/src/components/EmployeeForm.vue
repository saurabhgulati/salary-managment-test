<script setup>
import { ref, watch, computed } from 'vue'

const props = defineProps({
  visible: { type: Boolean, default: false },
  employee: { type: Object, default: null }
})

const emit = defineEmits(['close', 'save'])

const COUNTRIES = [
  'United States', 'Canada', 'United Kingdom', 'Germany', 'France',
  'India', 'Japan', 'Australia', 'Brazil', 'Nigeria',
  'South Africa', 'Mexico', 'Singapore', 'Netherlands', 'Sweden'
]

const CURRENCY_MAP = {
  'United States': 'USD', 'Canada': 'CAD', 'United Kingdom': 'GBP',
  'Germany': 'EUR', 'France': 'EUR', 'India': 'INR',
  'Japan': 'JPY', 'Australia': 'AUD', 'Brazil': 'BRL',
  'Nigeria': 'NGN', 'South Africa': 'ZAR', 'Mexico': 'MXN',
  'Singapore': 'SGD', 'Netherlands': 'EUR', 'Sweden': 'SEK'
}

const DEPARTMENTS = [
  'Engineering', 'Product', 'Design', 'Marketing', 'Sales',
  'Finance', 'HR', 'Operations', 'Legal', 'Support'
]

const JOB_TITLES = [
  'Software Engineer', 'Senior Software Engineer', 'Staff Engineer',
  'Engineering Manager', 'Product Manager', 'Senior Product Manager',
  'UX Designer', 'Senior UX Designer', 'Data Analyst', 'Data Scientist',
  'DevOps Engineer', 'QA Engineer', 'Technical Lead', 'Solutions Architect',
  'Frontend Developer', 'Backend Developer', 'Full Stack Developer',
  'Mobile Developer', 'Cloud Engineer', 'Security Engineer',
  'Marketing Manager', 'Sales Representative', 'Account Executive',
  'HR Coordinator', 'Finance Analyst', 'Operations Manager'
]

const defaultForm = {
  first_name: '',
  last_name: '',
  email: '',
  job_title: '',
  department: '',
  country: '',
  salary: '',
  currency: '',
  employment_type: 'full-time',
  status: 'active',
  hire_date: ''
}

const form = ref({ ...defaultForm })
const saving = ref(false)
const errors = ref({})

const isEdit = computed(() => !!props.employee)
const title = computed(() => isEdit.value ? 'Edit Employee' : 'Add Employee')

watch(() => props.visible, (val) => {
  if (val) {
    if (props.employee) {
      form.value = { ...props.employee, hire_date: props.employee.hire_date || '' }
    } else {
      form.value = { ...defaultForm }
    }
    errors.value = {}
  }
})

watch(() => form.value.country, (country) => {
  if (country && CURRENCY_MAP[country]) {
    form.value.currency = CURRENCY_MAP[country]
  }
})

function validate() {
  const errs = {}
  if (!form.value.first_name.trim()) errs.first_name = 'First name is required'
  if (!form.value.last_name.trim()) errs.last_name = 'Last name is required'
  if (!form.value.email.trim()) errs.email = 'Email is required'
  if (!form.value.job_title) errs.job_title = 'Job title is required'
  if (!form.value.department) errs.department = 'Department is required'
  if (!form.value.country) errs.country = 'Country is required'
  if (!form.value.salary || Number(form.value.salary) <= 0) errs.salary = 'Valid salary is required'
  if (!form.value.currency) errs.currency = 'Currency is required'
  errors.value = errs
  return Object.keys(errs).length === 0
}

async function handleSubmit() {
  if (!validate()) return
  saving.value = true
  try {
    emit('save', { ...form.value }, isEdit.value ? props.employee.id : null)
  } finally {
    saving.value = false
  }
}
</script>

<template>
  <Teleport to="body">
    <div v-if="visible">
      <div class="modal-backdrop fade show"></div>
      <div class="modal fade show d-block" tabindex="-1" @click.self="emit('close')">
        <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable">
          <div class="modal-content">
            <div class="modal-header">
              <h5 class="modal-title">{{ title }}</h5>
              <button type="button" class="btn-close" @click="emit('close')"></button>
            </div>
            <form @submit.prevent="handleSubmit">
              <div class="modal-body">
                <div class="row">
                  <div class="col-md-6 mb-3">
                    <label class="form-label">First Name *</label>
                    <input v-model="form.first_name" class="form-control" :class="{ 'is-invalid': errors.first_name }" />
                    <div v-if="errors.first_name" class="invalid-feedback">{{ errors.first_name }}</div>
                  </div>
                  <div class="col-md-6 mb-3">
                    <label class="form-label">Last Name *</label>
                    <input v-model="form.last_name" class="form-control" :class="{ 'is-invalid': errors.last_name }" />
                    <div v-if="errors.last_name" class="invalid-feedback">{{ errors.last_name }}</div>
                  </div>
                </div>

                <div class="mb-3">
                  <label class="form-label">Email *</label>
                  <input v-model="form.email" type="email" class="form-control" :class="{ 'is-invalid': errors.email }" />
                  <div v-if="errors.email" class="invalid-feedback">{{ errors.email }}</div>
                </div>

                <div class="row">
                  <div class="col-md-6 mb-3">
                    <label class="form-label">Job Title *</label>
                    <select v-model="form.job_title" class="form-select" :class="{ 'is-invalid': errors.job_title }">
                      <option value="">Select job title</option>
                      <option v-for="jt in JOB_TITLES" :key="jt" :value="jt">{{ jt }}</option>
                    </select>
                    <div v-if="errors.job_title" class="invalid-feedback">{{ errors.job_title }}</div>
                  </div>
                  <div class="col-md-6 mb-3">
                    <label class="form-label">Department *</label>
                    <select v-model="form.department" class="form-select" :class="{ 'is-invalid': errors.department }">
                      <option value="">Select department</option>
                      <option v-for="dept in DEPARTMENTS" :key="dept" :value="dept">{{ dept }}</option>
                    </select>
                    <div v-if="errors.department" class="invalid-feedback">{{ errors.department }}</div>
                  </div>
                </div>

                <div class="row">
                  <div class="col-md-6 mb-3">
                    <label class="form-label">Country *</label>
                    <select v-model="form.country" class="form-select" :class="{ 'is-invalid': errors.country }">
                      <option value="">Select country</option>
                      <option v-for="c in COUNTRIES" :key="c" :value="c">{{ c }}</option>
                    </select>
                    <div v-if="errors.country" class="invalid-feedback">{{ errors.country }}</div>
                  </div>
                  <div class="col-md-6 mb-3">
                    <label class="form-label">Currency *</label>
                    <input v-model="form.currency" class="form-control" :class="{ 'is-invalid': errors.currency }" readonly />
                    <div v-if="errors.currency" class="invalid-feedback">{{ errors.currency }}</div>
                  </div>
                </div>

                <div class="row">
                  <div class="col-md-6 mb-3">
                    <label class="form-label">Salary *</label>
                    <input v-model="form.salary" type="number" min="0" class="form-control" :class="{ 'is-invalid': errors.salary }" />
                    <div v-if="errors.salary" class="invalid-feedback">{{ errors.salary }}</div>
                  </div>
                  <div class="col-md-6 mb-3">
                    <label class="form-label">Hire Date</label>
                    <input v-model="form.hire_date" type="date" class="form-control" />
                  </div>
                </div>

                <div class="row">
                  <div class="col-md-6 mb-3">
                    <label class="form-label">Employment Type</label>
                    <select v-model="form.employment_type" class="form-select">
                      <option value="full-time">Full-time</option>
                      <option value="part-time">Part-time</option>
                      <option value="contract">Contract</option>
                    </select>
                  </div>
                  <div class="col-md-6 mb-3">
                    <label class="form-label">Status</label>
                    <select v-model="form.status" class="form-select">
                      <option value="active">Active</option>
                      <option value="inactive">Inactive</option>
                    </select>
                  </div>
                </div>
              </div>

              <div class="modal-footer">
                <button type="button" class="btn btn-secondary" @click="emit('close')">Cancel</button>
                <button type="submit" class="btn btn-primary" :disabled="saving">
                  {{ saving ? 'Saving...' : (isEdit ? 'Update' : 'Create') }}
                </button>
              </div>
            </form>
          </div>
        </div>
      </div>
    </div>
  </Teleport>
</template>
