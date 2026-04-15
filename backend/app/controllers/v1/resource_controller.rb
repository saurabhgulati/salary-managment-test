## TO have consistent response and request standard added a common API controller 
## to handle crud with SEARCH and pagination

class V1::ResourceController < ApplicationController
  before_action :run_callbacks!

  def index
    handle_response(@collection, :ok, generate_pagination(@collection))
  end

  def create
    @object.attributes = permitted_create_params
    if @object.save
      handle_response(@object, :created)
    else
      error_response(@object.errors)
    end
  end

  def update
    if @object.update(permitted_update_params)
      handle_response(@object, :ok)
    else
      error_response(@object.errors)
    end
  end

  def show
    handle_response(@object, :ok)
  end

  def destroy
    if @object.destroy
      head :ok
    else
      error_response(@object.errors)
    end
  end

  def count
    hsh = { count: @collection.count }
    render json: { data: hsh }, status: :ok
  end

  def versions
    versions = @object.versions
    json_response(versions, :ok, VersionSerializer, {})
  end

  private

  def handle_response data, response, pagination={}
    json_response(data, response, serializer, pagination)
  end

  def error_response(errors, status = :unprocessable_entity)
    json_response({ errors: errors }, status)
  end

  def load_resource
    if member_action?
      @object = load_resource_instance
      instance_variable_set("@#{resource_name}", @object)
    else
      collection
    end
  end

  def load_parent
    parent
  end

  def collection
    @collection = collection_query
    if parent_data.present?
      @collection = parent.send(collection_name)
    else
      @collection = model_class
    end
    @collection = @collection.where(default_query || {})
                              .includes(include_params)
    @collection = search_query if params[:q].present?
    @collection = @collection.ransack(params[:filters]).result
    @collection = sort_query if params[:sort].present? && !(params[:action].in?([:count]))
    @collection = @collection.page(params[:page]).per(per_page_value)
    instance_variable_set("@#{controller_name}", @collection)
  end

  def collection_query
    if parent_data.present?
      return parent.send(collection_name)
    else
      return model_class
    end
  end

  def parent
    return if parent_data.blank?

    @parent ||= parent_data[:model_class]
                .send(:find_by!, parent_data[:find_by].to_s => params[parent_data[:foreign_key]])
    instance_variable_set("@#{parent_data[:model_name].to_s.split('::').last.downcase}", @parent)
  end

  class << self
    attr_accessor :parent_data, :extra_collection_actions, :extra_new_actions

    def belongs_to(model_name, options = {})
      @parent_data ||= {}
      @parent_data[:model_name] = options[:model_name] || model_name
      @parent_data[:model_class] = @parent_data[:model_name].to_s.classify.constantize
      @parent_data[:foreign_key] = options[:foreign_key] || "#{@parent_data[:model_name]}_id"
      @parent_data[:find_by] = options[:find_by] || :id
    end

    def add_collection_actions(action_names = [])
      @extra_collection_actions = action_names
    end

    def add_new_actions(action_names = [])
      @extra_new_actions = action_names
    end
  end

  def model_name
    resource_name.classify
  end

  def run_callbacks!
    load_resource
  end

  def resource_name
    controller_name.singularize
  end

  def model_class
    model_name.constantize
  end

  def search_query
    search_columns = model_class.search_columns
    query_arr = []
    search_columns.each do |col|
      query_arr << "#{col} ILIKE :q"
    end
    @collection.where([query_arr.join(' OR '), { q: "%#{params[:q]}%" }])
  end

  def collection_actions
    [:index, :count, :export] + extra_collection_actions
  end

  def member_action?
    !collection_actions.include? action
  end

  def action
    params[:action].to_sym
  end

  def new_actions
    %i[new create] + extra_new_actions
  end

  def load_resource_instance
    if new_actions.include?(action)
      build_resource
    else
      find_resource
    end
  end

  def build_resource
    if parent_data.present?
      parent.send(collection_name).new
    else
      model_class.new
    end
  end

  # NOTE: extra query to find parent first
  def find_resource
    if parent_data.present?
      parent.send(collection_name).find(params[:id])
    else
      model_class.where(default_query || {}).find_by!(id: params[:id])
    end
  end

  def parent_data
    self.class.parent_data
  end

  def collection_name
    controller_name
  end

  def extra_collection_actions
    self.class.extra_collection_actions || []
  end

  def extra_new_actions
    self.class.extra_new_actions || []
  end

  def permitted_resource_params
    if params[resource_name.to_sym].present?
      params.require(resource_name.to_sym).permit!
    else
      ActionController::Parameters.new
    end
  end

  def permitted_create_params
    permitted_resource_params
  end

  def permitted_update_params
    permitted_resource_params
  end

  def sort_query
    if params[:sort].present?
      sort_query = []

      sort_array.each do |sort|
        order = 'asc'
        field = sort
        if sort.start_with?('-')
          field = sort.gsub('-', '')
          order = 'desc'
        end
        if model_class.respond_to?(:order_alias) && model_class.order_alias[field.to_sym].present?
          model_class.order_alias[field.to_sym].each do |f|
            sort_query << "#{f} #{order}"
          end
        else
          sort_query << "#{field} #{order}"
        end
      end

      order_str = sort_query.join(', ')
      @collection = @collection.order(Arel.sql(order_str))
    end

    @collection = @collection.order(default_sort.join(', '))
  end

  def default_sort
    # add this method to child classes
    []
  end

  def serializer
    "#{model_name}Serializer".classify.constantize
  end

  def sort_array
    params[:sort].is_a?(Array) ? params[:sort] : params[:sort].split(',')
  end

  def generate_pagination(paginated_obj)
    {
      meta: {
        pagination: {
          current_page: paginated_obj.current_page,
          prev_page: paginated_obj.prev_page,
          next_page: paginated_obj.next_page,
          total_pages: paginated_obj.total_pages,
          per_page: per_page_value,
          count: paginated_obj.total_count
        }
      }
    }
  end

  def per_page_value
    params[:per_page] ? params[:per_page].to_i : 50
  end

  def default_query
    { account_id: current_account.id }
  end
end
