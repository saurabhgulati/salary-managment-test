class Employee < ApplicationRecord
  def self.ransackable_attributes(auth_object = nil)
    ["country", "created_at", "currency", "department", "email", "employment_type", "first_name", "hire_date", "id", "id_value", "job_title", "last_name", "salary", "status", "updated_at"]
  end
end
