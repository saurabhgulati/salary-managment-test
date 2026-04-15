class EmployeeSerializer < BaseSerializer
  attributes :id, :full_name, :email, :job_title, :department,
             :country, :salary, :currency, :employment_type, :status, 
             :hire_date
end
