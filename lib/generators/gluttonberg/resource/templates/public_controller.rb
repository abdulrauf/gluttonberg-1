class <%= plural_class_name %>Controller < Gluttonberg::Public::BaseController

  def index
    @<%= plural_name %> = <%= class_name %>.published
  end

  def show
    @<%= singular_name %> = <%= class_name %>.published.find(params[:id])
  end

end