import apiClient from './axios'

function normalizeEmployee(record) {
  return {
    id: record.id,
    ...record.attributes
  }
}

export const employeeApi = {
  async getAll(page = 1, perPage = 50) {
    const response = await apiClient.get('/employees', {
      params: { page, per_page: perPage }
    })
    return {
      data: response.data.data.map(normalizeEmployee),
      pagination: response.data.meta?.pagination
    }
  },

  async getById(id) {
    const response = await apiClient.get(`/employees/${id}`)
    return normalizeEmployee(response.data.data)
  },

  async create(employee) {
    const response = await apiClient.post('/employees', { employee })
    return normalizeEmployee(response.data.data)
  },

  async update(id, employee) {
    const response = await apiClient.patch(`/employees/${id}`, { employee })
    return normalizeEmployee(response.data.data)
  },

  async delete(id) {
    await apiClient.delete(`/employees/${id}`)
  },

  async getFiltered(filters = {}, perPage = 1000) {
    const params = { per_page: perPage }
    for (const [key, value] of Object.entries(filters)) {
      if (value) params[`filters[${key}]`] = value
    }
    const response = await apiClient.get('/employees', { params })
    return {
      data: response.data.data.map(normalizeEmployee),
      pagination: response.data.meta?.pagination
    }
  }
}
