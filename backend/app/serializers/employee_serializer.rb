class EmployeeSerializer < BaseSerializer
  attributes :id, :first_name, :last_name, :email, :job_title, :department,
             :country, :salary, :currency, :employment_type, :status, 
             :hire_date
end
