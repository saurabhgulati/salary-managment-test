require 'benchmark'

countries = [
  "United States", "Canada", "United Kingdom", "Germany", "France",
  "India", "Japan", "Australia", "Brazil", "Nigeria",
  "South Africa", "Mexico", "Singapore", "Netherlands", "Sweden"
]

job_titles = [
  "Software Engineer", "Senior Software Engineer", "Staff Engineer",
  "Engineering Manager", "Product Manager", "Senior Product Manager",
  "UX Designer", "Senior UX Designer", "Data Analyst", "Data Scientist",
  "DevOps Engineer", "QA Engineer", "Technical Lead", "Solutions Architect",
  "Frontend Developer", "Backend Developer", "Full Stack Developer",
  "Mobile Developer", "Cloud Engineer", "Security Engineer",
  "Marketing Manager", "Sales Representative", "Account Executive",
  "HR Coordinator", "Finance Analyst", "Operations Manager"
]

elapsed = Benchmark.realtime do
  Seed::EmployeeSeeder.new(count: 10_000, countries: countries, job_titles: job_titles).call
end

puts "[Seed] Completed in #{elapsed.round(2)}s"
