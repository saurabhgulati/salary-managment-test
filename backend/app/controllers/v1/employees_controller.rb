class V1::EmployeesController < V1::ResourceController
  
  private

  def permitted_resource_params
    params.require(:employee).permit(:full_name, :email, :job_title, :department,
                                     :country, :salary, :currency, :employment_type, :status, :hire_date)
  end
end
