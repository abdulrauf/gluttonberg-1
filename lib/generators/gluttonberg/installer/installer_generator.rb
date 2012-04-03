require 'rails/generators'
require 'rails/generators/migration'    

class Gluttonberg::InstallerGenerator < Rails::Generators::Base
  include Rails::Generators::Migration
  
  def self.source_root
    @source_root ||= File.join(File.dirname(__FILE__), 'templates')
  end
  
  def self.next_migration_number(dirname)
    if ActiveRecord::Base.timestamped_migrations
      Time.now.utc.strftime("%Y%m%d%H%M%S")
    else
      "%.3d" % (current_migration_number(dirname) + 1)
    end
  end
  
  def create_delayed_job_script_file
    template 'delayed_job_script', 'script/delayed_job'
    chmod 'script/delayed_job', 0755
  end
  
  def create_migration_file
    migration_template 'gluttonberg_migration.rb', 'db/migrate/gluttonberg_migration.rb'
  end
  
  def create_page_descriptions_file
    copy_file 'page_descriptions.rb', 'config/page_descriptions.rb'
  end
  
  def create_sitemaprb_file
    copy_file 'sitemap.rb', 'config/sitemap.rb'
  end
  
  def create_default_public_layout
    #create pages folder
    path = File.join(Rails.root, "app", "views" , "pages" )
    FileUtils.mkdir(path) unless File.exists?(path)
    #copy layout into host app
    template "public.html.haml", File.join('app/views/layouts', "public.html.haml")    
  end
  
  def run_migration
    rake("db:migrate")
  end
  
  def bootstrap_data
    rake("gluttonberg:library:bootstrap")
    rake("gluttonberg:generate_default_locale")
    rake("gluttonberg:generate_or_update_default_settings")
  end
  
  def localization_config
    
    application %{
     # Gluttonberg Related config
     
     
     # config.cms_based_public_css = false   
     # config.custom_js_for_cms = false 
     config.localize = false  
     # By Default gluttonberg applications are localized. If you do not want localized application then uncomment following line.
     
     # By default membership system is disabled. uncommenting following line make it enabled. 
     # if email_verification is true then newly registered members have to verify their email address
     # config.enable_members = {:email_verification => true}
    
     # By default photo gallery is not visible in backend. 
     # config.enable_gallery = true  
       
     # You can customize your thumbnails. For geometry values please read ImageMagick documentation
     config.thumbnails = { 
       :jwysiwyg_image => {:label => "Thumb for jwysiwyg", :filename => "_jwysiwyg_image", :geometry => "250x200"} 
     }
     
      
    }
    
  end
  
  def add_memory_store_config_in_production
    data = []
    file_path = File.join(Rails.root, "config", "environments" , "production.rb" )
    file = File.new(file_path)

    file.each_line do |line| 
      data << line
    end

    file.close

    file = File.new(file_path , "w" )
    data.reverse.each_with_index do |line, index|
      if line.include?("end")
        data[data.length-index-1] = "  config.cache_store = :memory_store\nend\n"
        break
      end
    end
    file.puts(data.join(""))
    file.close
  end
    
end

