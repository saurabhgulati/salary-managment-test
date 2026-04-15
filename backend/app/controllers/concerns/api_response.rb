module ApiResponse
  def json_response(object, status = :ok, serializer_klass = nil, options = {})
    render json: serialized_response(object, serializer_klass, options), status: status
  end

  def serialized_response(obj, serializer_klass, options)
    if serializer_klass.present?
      serializer_klass.new(
        obj,
        options.merge({
          include: include_params,
          include_fields: include_fields,
          params: { include: include_params, 
            include_fields: include_fields }.merge(serializer_params)
        })
      ).serializable_hash
    else
      obj
    end
  end

  def render_json data
    render json: { data: data }, status: :ok
  end

  def include_params
    params[:include].is_a?(Array) ? params[:include] : params[:include].try(:split,',')
  end

  def serializer_params
    {}
  end

  def include_fields
    params[:include_fields].is_a?(Array) ? params[:include_fields] : params[:include_fields].try(:split,',')
  end
end
