module Gluttonberg
  module Admin
    module Content
      class PageLocalizationsController < Gluttonberg::Admin::BaseController
        before_filter :find_localization, :exclude => [:index, :new, :create]
        before_filter :authorize_user 
        
        def edit
          
          @page_localization.navigation_label = @page_localization.page.navigation_label if @page_localization.navigation_label.blank?
          @page = @page_localization.page
           if(!(Gluttonberg.localized? && @page.localizations &&  @page.localizations.length > 1) )
             @page_localization.slug = @page_localization.page.slug  if @page_localization.slug.blank?
             @page_localization.save!
           end
          @version = params[:version]  unless params[:version].blank?
          prepare_to_edit
        end

        def update
          # update localization updated_at value so that all contents have same version number.
          @page_localization.contents.each do |content|
            content.updated_at = Time.now
          end
          page_attributes = params["gluttonberg_page_localization"].delete(:page)
          
          if params[:commit] && params[:commit] == "Publish"
            page_attributes["state"] = "published"
            page_attributes["published_at"] = Time.now
          else
            page_attributes["state"] = "draft"
            page_attributes["published_at"] = nil
          end
          
          if @page_localization.update_attributes(params["gluttonberg_page_localization"]) || !@page_localization.changed?            
            
            @page_localization.page.update_attributes(page_attributes)
            
            flash[:notice] = "The page was successfully updated."
            redirect_to edit_admin_page_page_localization_path( :page_id => params[:page_id], :id =>  @page_localization.id)
          else
            flash[:error] = "Sorry, The page could not be updated."
            prepare_to_edit
            render :edit
          end
        end

        private
          def find_localization
            @page_localization = PageLocalization.find(params[:id])
            raise ActiveRecord::RecordNotFound  unless @page_localization
          end
          
          def authorize_user
            authorize! :manage, Gluttonberg::Page
          end
          
          def prepare_to_edit
            @pages  = Page.find(:all , :conditions => [ "id  != ? " , @page.id ] ) 
            @descriptions = []
            Gluttonberg::PageDescription.all.each do |name, desc|
                @descriptions << [desc[:description], name]
            end        
          end
          
      end #class  
    end
  end  
end
