class ApplicationController < ActionController::API
  include ApiResponse # to handle response standard
  include ApiExceptionHandler # to handle exceptions
end
