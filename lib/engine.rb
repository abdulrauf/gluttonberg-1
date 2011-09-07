require 'gluttonberg'
require 'rails'

module Gluttonberg
  class Engine < Rails::Engine
    
    # Config defaults
    config.widget_factory_name = "default factory name"
    config.mount_at = '/'
    config.admin_path = '/admin'
    config.app_name = 'Gluttonberg 2.0'
    config.localize = true
    config.active_record.observers = ['gluttonberg/page_observer' , 'gluttonberg/page_localization_observer' , 'gluttonberg/locale_observer' ]
        
    config.thumbnails = {   }
    config.max_image_size = "1600x1200>"
    config.encoding = "utf-8"
    #config.gluttonberg = {}
    config.identify_locale = :prefix
    config.host_name = "localhost:3000"
    config.user_roles = [] # User model always concat following two roles ["superadmin" , "admin"]
    config.honeypot_field_name = "gluttonberg_honeypot"
    config.custom_css_for_cms = false
    config.custom_js_for_cms = false
    config.search_models = {
        "Gluttonberg::Page" => [:name], 
        "Gluttonberg::Blog" => [:name , :description], 
        "Gluttonberg::Article" => [:title , :body], 
        "Gluttonberg::PlainTextContentLocalization" => [:text] , 
        "Gluttonberg::HtmlContentLocalization" => [:text] 
    }
    config.multisite = false

    config.enable_members = false
    config.member_csv_metadata = { :first_name => "FIRST NAME" , :last_name => "LAST NAME" ,  :email => "EMAIL" , :groups => "GROUPS" , :bio => "BIO" }

    config.enable_gallery = false
    config.cms_based_public_css = false

    # Load rake tasks
    rake_tasks do
      load File.join(File.dirname(__FILE__), 'rails/railties/tasks.rake')
      load File.join(File.dirname(__FILE__), 'gluttonberg/tasks/asset.rake')
      load File.join(File.dirname(__FILE__), 'gluttonberg/tasks/gluttonberg.rake')
    end
    
    # Check the gem config
    initializer "check config" do |app|

      # make sure mount_at ends with trailing slash
      config.mount_at += '/'  unless config.mount_at.last == '/'
    end

    initializer "static assets" do |app|
      app.middleware.use ::ActionDispatch::Static, "#{root}/public"
    end

    initializer "middleware" do |app|
      app.middleware.use Gluttonberg::Middleware::Locales
      app.middleware.use Gluttonberg::Middleware::Rewriter
      app.middleware.use Gluttonberg::Middleware::Honeypot , config.honeypot_field_name
    end
      

    initializer "setup gluttonberg components" do |app| 
      Gluttonberg::Content::Versioning.setup
      Gluttonberg::Content::ImportExportCSV.setup 
      Gluttonberg::Content::CleanHtml.setup
      Gluttonberg::PageDescription.setup
      
      # register content class here. It is required for lazyloading environments.
      Gluttonberg::Content::Block.register(Gluttonberg::PlainTextContent)
      Gluttonberg::Content::Block.register(Gluttonberg::HtmlContent)
      Gluttonberg::Content::Block.register(Gluttonberg::ImageContent)
         
      Gluttonberg::Content.setup      
      
      Gluttonberg::CanFlag.setup
      Time::DATE_FORMATS[:default] = "%d/%m/%Y %I:%M %p" 
    end
    
    initializer "setup gluttonberg asset library" do |app| 
      Gluttonberg::Library.setup     
      require "acts-as-taggable-on"
      require 'active_link_to'
    end
    
  end
end
