module Admin
  class <%= plural_class_name %>Controller < Gluttonberg::Admin::BaseController
    before_filter :authorize_user , :except => [:destroy , :delete]  
    before_filter :authorize_user_for_destroy , :only => [:destroy , :delete]
    <%if draggable? %>
    drag_tree <%= class_name %> , :route_name => :admin_<%= singular_name %>_move
    <%else%>
    helper_method :sort_column, :sort_direction
    <%end%>
    
    def index
      <%if draggable? %>
      @<%= plural_name %> = <%= class_name %>.order("position ASC ")
      <% else %>
      @<%= plural_name %> = <%= class_name %>.order(sort_column + " " + sort_direction)
      @<%= plural_name %> = @<%= plural_name %>.paginate(:page => params[:page], :per_page => Gluttonberg::Setting.get_setting("number_of_per_page_items"))
      <% end %>
    end
  
    def show
      @<%= singular_name %> = <%= class_name %>.find(params[:id])
    end
  
    def new
      @<%= singular_name %> = <%= class_name %>.new
    end
  
    def edit
      @<%= singular_name %> = <%= class_name %>.find(params[:id])
    end
  
    def create
      @<%= singular_name %> = <%= class_name %>.create(params[:<%= singular_name %>])
      if @<%= singular_name %>.save
        flash[:notice] = "The <%= singular_name.titleize.downcase %> was successfully created."
        redirect_to admin_<%= plural_name %>_path
      else
        render :edit
      end  
    end
  
    def update
      @<%= singular_name %> = <%= class_name %>.find(params[:id])
      if @<%= singular_name %>.update_attributes(params[:<%= singular_name %>])
        flash[:notice] = "The <%= singular_name.titleize.downcase %> was successfully updated."
        redirect_to admin_<%= plural_name %>_path
      else
        flash[:error] = "Sorry, The <%= singular_name.titleize.downcase %> could not be updated."
        render :edit
      end
    end
  
    def delete
      @<%= singular_name %> = <%= class_name %>.find(params[:id])
      display_delete_confirmation(
        :title      => "Delete <%= class_name %> '#{@<%= singular_name %>.id}'?",
        :url        => admin_<%= singular_name %>_path(@<%= singular_name %>),
        :return_url => admin_<%= plural_name %>_path, 
        :warning    => ""
      )
    end
  
    def destroy
      @<%= singular_name %> = <%= class_name %>.find(params[:id])
      if @<%= singular_name %>.delete
        flash[:notice] = "The <%= singular_name.titleize.downcase %> was successfully deleted."
        redirect_to admin_<%= plural_name %>_path
      else
        flash[:error] = "There was an error deleting the <%= singular_name.titleize.downcase %>."
        redirect_to admin_<%= plural_name %>_path
      end
    end
    
    private 
      
      def authorize_user
        authorize! :manage, <%= class_name %>
      end

      def authorize_user_for_destroy
        authorize! :destroy, <%= class_name %>
      end
      
      <%unless draggable? %>
      def sort_column
        <%= class_name %>.column_names.include?(params[:sort]) ? params[:sort] : "created_at"
      end

      def sort_direction
        %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
      end
      <%end%>

  end
end