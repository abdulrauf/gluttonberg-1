# encoding: utf-8

module Gluttonberg
  module  Admin
    module Settings
      class VideoSettingsController < Gluttonberg::Admin::BaseController
        before_filter :find_setting, :only => [:delete, :edit, :update, :destroy]        
        before_filter :authorize_user
        
        def index
          @video_settings = VideoSetting.all
        end

        def new
          @video_setting   = VideoSetting.new
        end

        def edit
        end

        def delete
          display_delete_confirmation(
            :title      => "Delete “#{@video_setting.name}” video setting?",
            :url        => admin_video_setting_path(@video_setting),
            :return_url => admin_video_settings_path , 
            :warning    => ""
          )        
        end

        def create
          @video_setting = VideoSetting.new(params["gluttonberg_video_setting"])
          if @video_setting.save
            flash[:notice] = "The video setting was successfully created."
            redirect_to admin_video_settings_path
          else
            render :new
          end
        end

        def update
          if @video_setting.update_attributes(params["gluttonberg_video_setting"]) || !@video_setting.dirty?
            flash[:notice] = "The video setting was successfully updated."
            redirect_to admin_video_settings_path
          else
            flash[:error] = "Sorry, The video setting could not be updated."
            render :edit
          end
        end

        def destroy
          if @locale.destroy
            flash[:notice] = "The video setting was successfully deleted."
            redirect_to admin_video_settings_path
          else
            flash[:error] = "There was an error deleting the video setting."
            redirect_to admin_video_settings_path
          end
        end

        private
      
          def find_setting
            @video_setting = VideoSetting.find(params[:id])
            raise ActiveRecord::RecordNotFound  unless @video_setting
          end
          
          def authorize_user
            authorize! :manage, Gluttonberg::VideoSetting
          end
      
      end
    end
  end
end
