# encoding: utf-8

module Gluttonberg
  module Admin
    module Settings    
      class StylesheetsController < Gluttonberg::Admin::BaseController
        drag_tree Stylesheet , :route_name => :admin_stylesheet_move
        before_filter :find_stylesheet, :only => [:edit, :update, :delete, :destroy]
        before_filter :authorize_user , :except => [:destroy , :delete]  
        before_filter :authorize_user_for_destroy , :only => [:destroy , :delete]
        
        def index
          @stylesheets = Stylesheet.order("position ASC")
        end
        
        def new
          @stylesheet = Stylesheet.new
        end
        
        def create
          @stylesheet = Stylesheet.new(params[:gluttonberg_stylesheet])
          if @stylesheet.save
            flash[:notice] = "The stylesheet was successfully created."
            redirect_to admin_stylesheets_path
          else
            render :edit
          end
        end
        
        def edit
          unless params[:version].blank?
            @version = params[:version]  
            @stylesheet.revert_to(@version)
          end
        end
        
        def update
          if @stylesheet.update_attributes(params[:gluttonberg_stylesheet])
            flash[:notice] = "The stylesheet was successfully updated."
            redirect_to admin_stylesheets_path
          else
            flash[:error] = "Sorry, The stylesheet could not be updated."
            render :edit
          end
        end
                
        def delete
          display_delete_confirmation(
            :title      => "Delete Stylesheet '#{@stylesheet.name}'?",
            :url        => admin_stylesheet_path(@stylesheet),
            :return_url => admin_stylesheets_path, 
            :warning    => ""
          )
        end
        
        def destroy
          if @stylesheet.delete
            flash[:notice] = "The stylesheet was successfully deleted."
            redirect_to admin_stylesheets_path
          else
            flash[:error] = "There was an error deleting the stylesheet."
            redirect_to admin_stylesheets_path
          end
        end
        
                
        protected
        
          def find_stylesheet
            @stylesheet = Stylesheet.find(params[:id])
          end
          
          def authorize_user
            authorize! :manage, Gluttonberg::Stylesheet
          end

          def authorize_user_for_destroy
            authorize! :destroy, Gluttonberg::Stylesheet
          end
          
      end
    end
  end
end
