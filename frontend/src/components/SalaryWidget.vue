<script setup>
import { ref, watch, computed } from 'vue'
import { employeeApi } from '@/api/employees'

const COUNTRIES = [
  'United States', 'Canada', 'United Kingdom', 'Germany', 'France',
  'India', 'Japan', 'Australia', 'Brazil', 'Nigeria',
  'South Africa', 'Mexico', 'Singapore', 'Netherlands', 'Sweden'
]

const selectedCountry = ref('')
const selectedJobTitle = ref('')
const countryEmployees = ref([])
const loading = ref(false)
const error = ref(null)

const jobTitles = computed(() => {
  const titles = new Set(countryEmployees.value.map(e => e.job_title))
  return Array.from(titles).sort()
})

const countryStats = computed(() => {
  if (!countryEmployees.value.length) return null
  const salaries = countryEmployees.value.map(e => Number(e.salary)).filter(s => !isNaN(s) && s > 0)
  if (!salaries.length) return null
  return {
    min: Math.min(...salaries),
    max: Math.max(...salaries),
    avg: Math.round(salaries.reduce((a, b) => a + b, 0) / salaries.length),
    count: salaries.length,
    currency: countryEmployees.value[0]?.currency || 'USD'
  }
})

const jobTitleStats = computed(() => {
  if (!selectedJobTitle.value || !countryEmployees.value.length) return null
  const filtered = countryEmployees.value.filter(e => e.job_title === selectedJobTitle.value)
  const salaries = filtered.map(e => Number(e.salary)).filter(s => !isNaN(s) && s > 0)
  if (!salaries.length) return null
  return {
    avg: Math.round(salaries.reduce((a, b) => a + b, 0) / salaries.length),
    count: salaries.length,
    currency: filtered[0]?.currency || 'USD'
  }
})

function formatCurrency(amount, currency) {
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: currency || 'USD',
    maximumFractionDigits: 0
  }).format(amount)
}

async function fetchCountryData() {
  if (!selectedCountry.value) {
    countryEmployees.value = []
    return
  }
  loading.value = true
  error.value = null
  try {
    const result = await employeeApi.getFiltered(
      { country_eq: selectedCountry.value },
      1000
    )
    countryEmployees.value = result.data
  } catch (err) {
    error.value = 'Failed to load salary data'
    countryEmployees.value = []
  } finally {
    loading.value = false
  }
}

watch(selectedCountry, () => {
  selectedJobTitle.value = ''
  fetchCountryData()
})
</script>

<template>
  <div class="card shadow-sm mb-4">
    <div class="card-body">
      <h5 class="card-title fw-semibold mb-3">Salary Insights</h5>

      <div class="row mb-3">
        <div class="col-md-6 mb-2 mb-md-0">
          <label class="form-label small fw-semibold">Country</label>
          <select v-model="selectedCountry" class="form-select">
            <option value="">Select a country</option>
            <option v-for="c in COUNTRIES" :key="c" :value="c">{{ c }}</option>
          </select>
        </div>
        <div class="col-md-6">
          <label class="form-label small fw-semibold">Job Title (optional)</label>
          <select v-model="selectedJobTitle" class="form-select" :disabled="!selectedCountry">
            <option value="">All job titles</option>
            <option v-for="jt in jobTitles" :key="jt" :value="jt">{{ jt }}</option>
          </select>
        </div>
      </div>

      <div v-if="loading" class="text-center py-3 text-muted">
        <div class="spinner-border spinner-border-sm me-2" role="status"></div>
        Loading salary data...
      </div>

      <div v-else-if="error" class="alert alert-danger py-2">{{ error }}</div>

      <div v-else-if="!selectedCountry" class="text-center text-muted py-3">
        Select a country to view salary statistics
      </div>

      <template v-else-if="countryStats">
        <div class="row g-3">
          <div class="col-6 col-md-3">
            <div class="card bg-light border-0 text-center">
              <div class="card-body py-3">
                <div class="text-muted small text-uppercase fw-semibold">Min Salary</div>
                <div class="fs-5 fw-bold text-primary">{{ formatCurrency(countryStats.min, countryStats.currency) }}</div>
              </div>
            </div>
          </div>
          <div class="col-6 col-md-3">
            <div class="card bg-light border-0 text-center">
              <div class="card-body py-3">
                <div class="text-muted small text-uppercase fw-semibold">Max Salary</div>
                <div class="fs-5 fw-bold text-primary">{{ formatCurrency(countryStats.max, countryStats.currency) }}</div>
              </div>
            </div>
          </div>
          <div class="col-6 col-md-3">
            <div class="card bg-primary text-white border-0 text-center">
              <div class="card-body py-3">
                <div class="small text-uppercase fw-semibold opacity-75">Avg Salary</div>
                <div class="fs-5 fw-bold">{{ formatCurrency(countryStats.avg, countryStats.currency) }}</div>
              </div>
            </div>
          </div>
          <div class="col-6 col-md-3">
            <div class="card bg-light border-0 text-center">
              <div class="card-body py-3">
                <div class="text-muted small text-uppercase fw-semibold">Employees</div>
                <div class="fs-5 fw-bold text-primary">{{ countryStats.count }}</div>
              </div>
            </div>
          </div>
        </div>

        <div v-if="jobTitleStats" class="mt-3">
          <div class="card bg-primary text-white border-0" style="max-width: 320px;">
            <div class="card-body py-3 text-center">
              <div class="small text-uppercase fw-semibold opacity-75">Avg for {{ selectedJobTitle }}</div>
              <div class="fs-5 fw-bold">{{ formatCurrency(jobTitleStats.avg, jobTitleStats.currency) }}</div>
              <div class="small opacity-75">{{ jobTitleStats.count }} employees</div>
            </div>
          </div>
        </div>
      </template>

      <div v-else class="text-center text-muted py-3">
        No salary data available for this country
      </div>
    </div>
  </div>
</template>
