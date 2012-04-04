# encoding: utf-8

module Gluttonberg
  module Admin
    module Membership
      class MembersController < Gluttonberg::Admin::Membership::BaseController
        before_filter :find_member, :only => [:delete, :edit, :update, :destroy]
        before_filter :authorize_user , :except => [:edit , :update]
        
        
        def index
          unless params[:query].blank?
            @members = Member.order(get_order).where("first_name LIKE '%#{params[:query]}%' OR last_name LIKE '%#{params[:query]}%' OR email LIKE '%#{params[:query]}%' OR bio LIKE '%#{params[:query]}%' " ).includes(:groups)
          else  
            @members = Member.order(get_order).includes(:groups)
          end
          @members = @members.paginate(:page => params[:page] , :per_page => Gluttonberg::Setting.get_setting("number_of_per_page_items") )
        end
  
        def new
          @member = Member.new
          @member.group_ids = [Group.default_group.id] unless Group.default_group.blank?
        end
  
        def create
          @password = Gluttonberg::Member.generateRandomString
          password_hash = {  
              :password => @password ,
              :password_confirmation => @password
          }
          
          @member = Member.new(params[:gluttonberg_member].merge(password_hash))
          if !params[:gluttonberg_member][:group_ids].blank? && params[:gluttonberg_member][:group_ids].kind_of?(String)
            @member.group_ids = [params[:gluttonberg_member][:group_ids]] 
          else  
            @member.group_ids = params[:gluttonberg_member][:group_ids] 
          end
          @member.profile_confirmed = true
          
          if @member.save
            flash[:notice] = "Member account registered and welcome email is also sent to the member"
            MemberNotifier.welcome(@member.id).deliver            
            redirect_to :action => :index
          else
            render :action => :new
          end
        end
        
        def edit          
        end
  
        def update
          if params[:gluttonberg_member] && params[:gluttonberg_member]["image_delete"] == "1"
            params[:gluttonberg_member][:image] = nil
          end
          
          if !params[:gluttonberg_member][:group_ids].blank? && params[:gluttonberg_member][:group_ids].kind_of?(String)
            @member.group_ids = [params[:gluttonberg_member][:group_ids]] 
          else  
            @member.group_ids = params[:gluttonberg_member][:group_ids] 
          end
          @member.assign_attributes(params[:gluttonberg_member])
          if @member.save
            flash[:notice] = "Member account updated!"
            redirect_to  :action => :index
          else
            flash[:notice] = "Failed to save account changes!"
            render :action => :edit
          end 
        end
        
        def delete
          display_delete_confirmation(
            :title      => "Delete “#{@member.email}” member?",
            :url        => admin_membership_member_path(@member),
            :return_url => admin_membership_members_path  
          )        
        end
  
        def destroy
          if @member.destroy
            flash[:notice] = "Member deleted!"
            redirect_to :action => :index
          else
            flash[:error] = "There was an error deleting the member."
            redirect_to :action => :index
          end  
        end
        
        def export
          csv_data = Member.exportCSV
          send_data csv_data, :type => 'text/csv' , :disposition => 'attachment' , :filename => "All members at #{Time.now.strftime('%Y-%m-%d')}.csv"
        end
        
        # form for uploading csv for members
        def new_bulk    
        end
        
        # import csv and show report for successfully, failed, updated members
        def create_bulk
          if params[:csv].blank?
            flash[:error] = "Please provide a valid csv file."
            redirect_to :action => new_bulk
          else
            @successfull , @failed , @updated  = Member.importCSV(params[:csv][:file].tempfile.path , params[:invite] , params[:csv][:group_ids])
            if @successfull.kind_of? String
              flash[:error] = @successfull
              redirect_to :action => new_bulk
              return
            end
          end  
        end
        
        def welcome
           @member = Member.find(params[:id])
           MemberNotifier.welcome( @member ).deliver
           flash[:notice] = "Welcome email is successfully sent to the member."
           redirect_to :action => :index 
        end
  
       private
          def find_member
            @member = Member.find(params[:id])
            raise ActiveRecord::RecordNotFound  if @member.blank?
          end
          
          def authorize_user
            authorize! :manage, Member
          end
      
      end
    end
  end
end