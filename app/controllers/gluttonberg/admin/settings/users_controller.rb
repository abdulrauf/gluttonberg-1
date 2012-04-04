# encoding: utf-8

module Gluttonberg
  module Admin
    module Settings
      class UsersController < Gluttonberg::Admin::BaseController
        before_filter :find_user, :only => [:delete, :edit, :update, :destroy]
        before_filter :authorize_user , :except => [:edit , :update]    
        
        def index
          unless current_user.super_admin? || current_user.admin?
            redirect_to :action => "edit" , :id => current_user.id
          end
          if current_user.super_admin?
            unless params[:query].blank?
              @users = User.order(get_order).where("first_name LIKE '%#{params[:query]}%' OR last_name LIKE '%#{params[:query]}%' OR email LIKE '%#{params[:query]}%' OR bio LIKE '%#{params[:query]}%' " )
            else  
              @users = User.order(get_order)
            end
          else
            unless params[:query].blank?
              @users = User.order(get_order).where("role != 'super_admin' AND (first_name LIKE '%#{params[:query]}%' OR last_name LIKE '%#{params[:query]}%' OR email LIKE '%#{params[:query]}%' OR bio LIKE '%#{params[:query]}%' )" )
            else  
              @users = User.order(get_order).where( ["role != ?" , "super_admin"])
            end
          end
          
          @users = @users.paginate(:page => params[:page] , :per_page => Gluttonberg::Setting.get_setting("number_of_per_page_items") )
        end
  
        def new
          @user = User.new
        end
  
        def create
          @user = User.new(params[:user])
          @user.role = params[:user][:role] if current_user.user_valid_roles(@user).include?(params[:user][:role])
          if @user.save
            flash[:notice] = "Account registered!"
            redirect_to :action => :index
          else
            render :action => :new
          end
        end
        
        def edit          
        end
  
        def update
          @user.role = params[:user][:role] if current_user.user_valid_roles(@user).include?(params[:user][:role])
          if @user.update_attributes(params[:user])
            flash[:notice] = "Account updated!"
            if current_user.super_admin? || current_user.admin?
              redirect_to  :action => :index
            else
              redirect_to  :action => :edit
            end  
          else
            flash[:notice] = "Failed to save account changes!"
            render :action => :edit
          end 
        end
        
        def delete
          display_delete_confirmation(
            :title      => "Delete “#{@user.email}” user?",
            :url        => admin_user_path(@user),
            :return_url => admin_users_path  
          )        
        end
  
        def destroy
          if @user.destroy
            flash[:notice] = "Account deleted!"
            redirect_to :action => :index
          else
            flash[:error] = "There was an error deleting the account."
            redirect_to :action => :index
          end  
        end
  
       private
          def find_user
            if current_user.super_admin?
             @user = User.find(params[:id])
            elsif current_user.admin?
              @user = User.find(params[:id])
              if @user.super_admin?
                @user = nil
              end
            else
              @user = User.find(params[:id])
              unless @user.id == current_user.id
                @user =  nil
              end             
            end
            raise ActiveRecord::RecordNotFound  unless @user
          end
          
          def authorize_user
            authorize! :manage, User
          end
      
      end
    end
  end
end