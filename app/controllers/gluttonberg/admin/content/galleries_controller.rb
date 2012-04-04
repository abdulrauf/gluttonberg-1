
# encoding: utf-8

module Gluttonberg
  module Admin
    module Content    
      class GalleriesController < Gluttonberg::Admin::BaseController
        drag_tree GalleryImage , :route_name => :admin_gallery_move
        
        before_filter :is_gallery_enabled
        before_filter :find_gallery, :only => [:edit, :update, :delete, :destroy]
        before_filter :authorize_user , :except => [:destroy , :delete]  
        before_filter :authorize_user_for_destroy , :only => [:destroy , :delete]
        
        def index
          @galleries = Gallery.paginate(:per_page => Gluttonberg::Setting.get_setting("number_of_per_page_items"), :page => params[:page])
        end
        
        def new
          @gallery = Gallery.new
        end
        
        def create
          @gallery = Gallery.new(params[:gluttonberg_gallery])
          if @gallery.save
            save_collection_images
            flash[:notice] = "The gallery was successfully created."
            redirect_to edit_admin_gallery_path(@gallery)
          else
            render :edit
          end
        end
        
        def edit
        end
        
        def update
          if @gallery.update_attributes(params[:gluttonberg_gallery])
            save_collection_images
            flash[:notice] = "The gallery was successfully updated."
            redirect_to edit_admin_gallery_path(@gallery)
          else
            flash[:error] = "Sorry, The gallery could not be updated."
            render :edit
          end
        end
                
        def delete
          display_delete_confirmation(
            :title      => "Delete gallery '#{@gallery.name}'?",
            :url        => admin_gallery_path(@gallery),
            :return_url => admin_galleries_path, 
            :warning    => ""
          )
        end
        
        def destroy
          if @gallery.delete
            flash[:notice] = "The gallery was successfully deleted."
            redirect_to admin_galleries_path
          else
            flash[:error] = "There was an error deleting the gallery."
            redirect_to admin_galleries_path
          end
        end
        
        def remove_image
          item =GalleryImage.find(params[:id])
          item.delete
          render :text => "{success:true}"
        end
        
        def add_image
          @gallery =Gallery.find(params[:id])
          max_position = @gallery.gallery_images.length
          @gallery_item = @gallery.gallery_images.create(:asset_id => params[:asset_id] , :position => (max_position )  )
          @gallery_images = @gallery.gallery_images.order("position ASC")
          render :layout => false
        end
                
        protected
          
          def is_gallery_enabled 
            unless Rails.configuration.enable_gallery == true
              raise ActiveRecord::RecordNotFound
            end  
          end  
          
          def find_gallery
            @gallery = Gallery.find(params[:id])
            @gallery_images = @gallery.gallery_images.order("position ASC")
          end
          
          def authorize_user
            authorize! :manage, Gluttonberg::Gallery
          end

          def authorize_user_for_destroy
            authorize! :destroy, Gluttonberg::Gallery
          end
          
          def save_collection_images
            unless params[:collection_id].blank?
              collection_images = AssetCollection.find(params[:collection_id]).images
              max_position = @gallery.gallery_images.length
              collection_images.each_with_index do |image , index|
                @gallery.gallery_images.create(:asset_id => image.id , :position => (max_position + index)  )
              end
              @gallery.update_attributes(:collection_imported => true)
            end  
          end
          
      end
    end
  end
end
