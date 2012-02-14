class VideoJob < Struct.new(:video)
  
  def perform
    asset = Gluttonberg::Asset.find(video)
    commands = []
    paths = []
    if Gluttonberg::Setting.get_setting("video_assets") == "Enable"
      ffmpeg_gb_setting = Gluttonberg::VideoSetting.all
      unless ffmpeg_gb_setting.blank?
        ffmpeg_gb_setting.each_with_index do |s, i|
          paths << "#{save_asset_to(asset)}/#{asset.filename_without_extension}_#{s.file_postfix}"
          commands << "#{s.command} #{paths[i]}"
        end
        options = {:file => asset.absolute_file_path}
        commands.each_with_index do |command, i|
          begin
            puts "Starting to encode #{command}"
            puts "path #{asset.absolute_file_path}"
            transcoder = RVideo::Transcoder.new
            result = transcoder.execute(command, options)
            #asset.duration = transcoder.processed.duration
            asset.processed = true
            asset.save
            system("qtfaststart #{paths[i]}")
          rescue => e
            asset.processed = true
            #asset.error = true
            asset.save
            puts "Unable to transcode file: #{e.class} - #{e.message}"
            system("qtfaststart #{paths[i]}")
          end
        end
        if !Gluttonberg::Setting.get_setting("s3_key_id").blank? && !Gluttonberg::Setting.get_setting("s3_access_key").blank? && !Gluttonberg::Setting.get_setting("s3_server_url").blank? && !Gluttonberg::Setting.get_setting("s3_bucket").blank?
          asset.copy_videos_to_s3
        end  
      end #empty settings  
    end #setting enabled  
  end
  
  def save_asset_to(asset)
    Rails.root.to_s + "/public" + asset.asset_folder_path
  end
  
end
