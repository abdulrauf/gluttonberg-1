# encoding: utf-8

module Gluttonberg
  module Admin
    module Content    
      class BlogsController < Gluttonberg::Admin::BaseController
        
        before_filter :find_blog, :only => [:edit, :update, :delete, :destroy]
        
        def index
          @blogs = Blog.all
        end
        
        def new
          @blog = Blog.new
        end
        
        def create
          @blog = Blog.new(params[:gluttonberg_blog])
          if @blog.save
            redirect_to admin_blogs_path
          else
            render :edit
          end
        end
        
        def edit
        end
        
        def update
          if @blog.update_attributes(params[:gluttonberg_blog])
            redirect_to admin_blogs_path
          else
            render :edit
          end
        end
        
        def delete
          display_delete_confirmation(
            :title      => "Delete Blog '#{@blog.name}'?",
            :url        => admin_blog_path(@blog),
            :return_url => admin_blogs_path, 
            :warning    => "This will delete all the articles that belong to this blog"
          )
        end
        
        def destroy
          if @blog.delete
            flash[:notice] = "Blog deleted."
            redirect_to admin_blogs_path
          else
            flash[:error] = "There was an error deleting the Blog."
            redirect_to admin_blogs_path
          end
        end
        
        protected
        
          def find_blog
            @blog = Blog.find(params[:id])
          end
        
      end
    end
  end
end