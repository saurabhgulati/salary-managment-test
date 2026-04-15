# frozen_string_literal: true

module Seed
  class EmployeeSeeder
    BATCH_SIZE = 1_000
    SALARY_MIN = 30_000
    SALARY_MAX = 250_000

    DEPARTMENTS = %w[Engineering Product Design Marketing Sales Finance HR Operations Legal Support].freeze

    EMPLOYMENT_TYPES = %w[full-time part-time contract].freeze

    CURRENCY_MAP = {
      "United States" => "USD",
      "Canada" => "CAD",
      "United Kingdom" => "GBP",
      "Germany" => "EUR",
      "France" => "EUR",
      "India" => "INR",
      "Japan" => "JPY",
      "Australia" => "AUD",
      "Brazil" => "BRL",
      "Nigeria" => "NGN",
      "South Africa" => "ZAR",
      "Mexico" => "MXN",
      "Singapore" => "SGD",
      "Netherlands" => "EUR",
      "Sweden" => "SEK"
    }.freeze

    def initialize(count: 10_000, countries:, job_titles:)
      @count = count
      @countries = countries
      @job_titles = job_titles
      @first_names = load_names("first_names.txt")
      @last_names = load_names("last_names.txt")
    end

    def call
      Rails.logger.info "[EmployeeSeeder] Clearing existing employees..."
      Employee.delete_all

      Rails.logger.info "[EmployeeSeeder] Seeding #{@count} employees in batches of #{BATCH_SIZE}..."
      now = Time.current
      seq = 0
      hire_date_range = 5.years.ago.to_date..Date.current

      @count.times.each_slice(BATCH_SIZE) do |batch|
        records = batch.map do
          seq += 1
          first_name = @first_names.sample
          last_name = @last_names.sample
          country = @countries.sample

          {
            first_name: first_name,
            last_name: last_name,
            email: "#{first_name.downcase}_#{last_name.downcase}_#{seq}@test-email.com",
            job_title: @job_titles.sample,
            department: DEPARTMENTS.sample,
            country: country,
            salary: rand(SALARY_MIN..SALARY_MAX).to_s,
            currency: CURRENCY_MAP.fetch(country, "USD"),
            employment_type: EMPLOYMENT_TYPES.sample,
            status: "active",
            hire_date: rand(hire_date_range),
            created_at: now,
            updated_at: now
          }
        end

        Employee.insert_all!(records)
      end

      Rails.logger.info "[EmployeeSeeder] Done. #{Employee.count} employees seeded."
    end

    private

    def load_names(filename)
      path = Rails.root.join("db", "seed_data", filename)
      File.readlines(path, chomp: true).reject(&:blank?)
    end
  end
end
