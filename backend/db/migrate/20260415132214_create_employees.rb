class CreateEmployees < ActiveRecord::Migration[8.1]
  def change
    create_table :employees do |t|
      t.string :full_name, null: false
      t.string :email, null: false
      t.string :job_title, null: false
      t.string :department, null: false
      t.string :country, null: false
      t.string :salary
      t.string :currency, null: false
      t.string :employment_type, null: false, default: 'full-time'
      t.string :status, null: false, default: 'active'
      t.date :hire_date

      t.timestamps
    end
  end
end
