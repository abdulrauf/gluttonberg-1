module Gluttonberg
  module Public
    class PagesController < Gluttonberg::Public::BaseController
      before_filter :retrieve_page , :only => [ :show ]
      
      # If localized template file exist then render that file otherwise render non-localized template
      def show
        template = page.view
        template_path = "pages/#{template}.html.haml"
        
        if File.exists?(File.join(Rails.root,  "app/views/pages/#{template}.#{locale.slug}.html.haml" ) )
          template_path = "pages/#{template}.#{locale.slug}.html.haml"
        end  
        
        # do not render layout for ajax requests
        if request.xhr?
          render :template => template_path, :layout => false
        else
          render :template => template_path
        end
      end
      
      def restrict_site_access
        setting = Gluttonberg::Setting.get_setting("restrict_site_access")
        if setting == params[:password]
          cookies[:restrict_site_access] = "allowed"
          redirect_to( params[:return_url] || "/")
          return
        else
          cookies[:restrict_site_access] = ""  
        end
        render :layout => false
      end
      
      def stylesheets
        @stylesheet = Stylesheet.find(:first , :conditions => { :slug => params[:id] })
        unless params[:version].blank?
          @version = params[:version]  
          @stylesheet.revert_to(@version)
        end
        if @stylesheet.blank?
          render :text => ""
        else  
          render :text => @stylesheet.value
        end  
      end
      
      private 
        def retrieve_page
          @page = env['gluttonberg.page']
          unless( current_user &&( authorize! :manage, Gluttonberg::Page) )
            @page = nil unless @page.published?
          end
          raise ActiveRecord::RecordNotFound  if @page.blank?
        end
      
    end
  end
end
