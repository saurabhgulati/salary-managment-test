module ApiExceptionHandler
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound do |e|
      json_response({ message: e.message }, :not_found)
    end

    rescue_from ActiveRecord::RecordInvalid do |e|
      json_response({ message: e.message }, :unprocessable_entity)
    end

    rescue_from ActionController::UnpermittedParameters do |exception|
      render json: { error:  { unknown_parameters: exception.params } }, status: :bad_request
    end

    rescue_from(ActionController::ParameterMissing) do |parameter_missing_exception|
      error = {}
      error[parameter_missing_exception.param] = ['parameter is required']
      response = { errors: [error] }
      render json: { error: response }, status: :unprocessable_entity
    end

    rescue_from JSONAPI::Serializer::UnsupportedIncludeError do |exception|
      render json: { error: 'Unsupported relationship included in the request.' }, status: :bad_request
    end
  end
end
