# encoding: utf-8

module Gluttonberg
  module Admin
    module Content    
      class PagesController < Gluttonberg::Admin::BaseController
        drag_tree Page , :route_name => :admin_page_move
        before_filter :find_page, :only => [:show, :edit, :delete, :update, :destroy]
        before_filter :authorize_user , :except => [:destroy , :delete]  
        before_filter :authorize_user_for_destroy , :only => [:destroy , :delete]
        
        def index
          @pages = Page.find(:all , :conditions => { :parent_id => nil } , :order => 'position' )
        end

        def show
        end
            
        def new
          @page = Page.new
          @page_localization = PageLocalization.new
          prepare_to_edit
        end
       
        def delete
          default_localization = Gluttonberg::PageLocalization.find(:first , :conditions => { :page_id => @page.id , :locale_id => Gluttonberg::Locale.first_default.id } )
          display_delete_confirmation(
            :title      => "Delete “#{default_localization.name}” page?",
            :url        => admin_page_url(@page),
            :return_url => admin_pages_path , 
            :warning    => "Children of this page will also be deleted."
          )
        end
         
        def create
          @page = Page.new(params["gluttonberg_page"])
          if params[:commit] && params[:commit] == "Publish"
            @page.state = "published"
            @page.published_at = Time.now
          else
            @page.state = "draft"
            @page.published_at = nil
          end
          @page.user_id = current_user.id
          if @page.save
            @page.create_default_template_file
            flash[:notice] = "The page was successfully created."
            redirect_to admin_pages_path
          else
            prepare_to_edit
            render :new
          end
        end

        # def update
        #           if @page.update_attributes(params["gluttonberg_page"]) || !@page.changed?
        #             flash[:notice] = "The page was successfully updated."
        #             redirect_to edit_admin_page_url(@page)
        #           else
        #             flash[:error] = "Sorry, The page could not be updated."
        #             prepare_to_edit
        #             render :edit
        #           end
        #         end
        
        def destroy
          if @page.destroy
            flash[:notice] = "The page was successfully deleted."
            redirect_to admin_pages_path
          else            
            flash[:error] = "There was an error deleting the page."
            redirect_to admin_pages_path
          end
        end
        
        def edit_home
          @current_home_page_id  = Page.home_page.id unless Page.home_page.blank?
          @pages = Page.all
        end
        
        def update_home
          @new_home = Page.find(:first , :conditions => { :id => params[:home] })
          unless @new_home.blank?
            @new_home.update_attributes(:home => true)
          else
              @old_home = Page.find(:first , :conditions => { :home => true })
              @old_home.update_attributes(:home => false)
          end
          render :text => "Home page is changed"
        end
        
        def pages_list_for_tinymce
          @pages = Page.published.find(:all , :conditions => "not(description_name = 'top_level_page')"  , :order => 'position' )
          render :layout => false
        end

        private

        def prepare_to_edit
          @pages  = params[:id] ? Page.find(:all , :conditions => [ "id  != ? " , params[:id] ] ) : Page.all
          @descriptions = []
          Gluttonberg::PageDescription.all.each do |name, desc|
              @descriptions << [desc[:description], name]
          end        
        end

        def find_page
          @page = Page.find( params[:id])
          raise ActiveRecord::RecordNotFound unless @page
        end      
        
        def authorize_user
          authorize! :manage, Gluttonberg::Page
        end
        
        def authorize_user_for_destroy
          authorize! :destroy, Gluttonberg::Page
        end
        
      end
    end #content  
  end #admin
end  #gluttonberg
