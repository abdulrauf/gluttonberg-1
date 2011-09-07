require 'rails/generators'
require 'rails/generators/migration'
require 'rails/generators/generated_attribute'

class Gluttonberg::ResourceGenerator < Rails::Generators::Base
  include Rails::Generators::Migration

  attr_accessor :name, :type

  argument :resource_name, :type => :string, :required => true
  argument :attributes, :type => :array, :default => [], :banner => "field:type field:type"

  hook_for :draggable, :aliases => "-d" , :type => :boolean
  hook_for :importable, :aliases => "-i" , :type => :boolean

  def initialize(args, *options)
    super(args, *options)
    parse_attributes!
  end

  def self.source_root
    @source_root ||= File.join(File.dirname(__FILE__), 'templates')
  end

  def generate_migration
    migration_template "migration.rb", "db/migrate/create_#{file_name}.rb"
  end

  def generate_model
    template "model.rb", "app/models/#{file_name}.rb"
  end

  def generate_controller
    template 'admin_controller.rb', File.join('app/controllers/admin', "#{plural_name}_controller.rb")
    template 'public_controller.rb', File.join('app/controllers', "#{plural_name}_controller.rb")
  end

  def generate_views
    build_views
  end

  def add_route    
    if draggable?
      route("namespace :admin do\n match \"/#{plural_name}/move(.:format)\" => \"#{plural_name}#move_node\" , :as=> :#{singular_name}_move \n match \"/#{plural_name}/import(.:format)\" => \"#{plural_name}#import\" , :as=> :#{plural_name}_import \n match \"/#{plural_name}/export(.:format)\" => \"#{plural_name}#export\" , :as=> :#{plural_name}_export \n  resources :#{plural_name} do\n member do\n get 'delete'\n end\n end\n end")
    else
      route("namespace :admin do  \n match \"/#{plural_name}/import(.:format)\" => \"#{plural_name}#import\" , :as=> :#{plural_name}_import \n match \"/#{plural_name}/export(.:format)\" => \"#{plural_name}#export\" , :as=> :#{plural_name}_export   \n   resources :#{plural_name} do\n member do\n get 'delete'\n end\n end\n end")
    end
    route("resources :#{plural_name}")
  end
  
  def add_config
    application "Gluttonberg::Components.register(:#{plural_name}, :label => '#{plural_class_name}', :admin_url => :admin_#{plural_name})"
  end

  protected

    def build_views
      views = {
        'backend_view_index.html.haml' => File.join('app/views/admin', plural_name, "index.html.haml"),
        'backend_view_new.html.haml' => File.join('app/views/admin', plural_name, "new.html.haml"),
        'backend_view_edit.html.haml' => File.join('app/views/admin', plural_name, "edit.html.haml"),
        'backend_view_form.html.haml' => File.join('app/views/admin', plural_name, "_form.html.haml"),
        'backend_view_show.html.haml' => File.join('app/views/admin', plural_name, "show.html.haml"),
        'backend_view_import.html.haml' => File.join('app/views/admin', plural_name, "import.html.haml"),
        'public_view_index.html.haml' => File.join('app/views', plural_name, "index.html.haml"),
        'public_view_show.html.haml' => File.join('app/views', plural_name, "show.html.haml")
      }
      copy_views(views)
    end

    def copy_views(views)
      views.each do |template_name, output_path|
        template template_name, output_path
      end
    end

    def self.next_migration_number(dirname)
      if ActiveRecord::Base.timestamped_migrations
        Time.now.utc.strftime("%Y%m%d%H%M%S")
      else
        "%.3d" % (current_migration_number(dirname) + 1)
      end
    end

    def file_name
      resource_name.underscore
    end

    def class_name
      ([file_name]).map!{ |m| m.camelize }.join('::')
    end
    
    def plural_class_name
      ([plural_name]).map!{ |m| m.camelize }.join('::')
    end

    def table_name
      @table_name ||= begin
        base = pluralize_table_names? ? plural_name : singular_name
      end
    end

    def parse_attributes!
      self.attributes = (attributes || []).map do |key_value|
        name, type = key_value.split(':')
        Rails::Generators::GeneratedAttribute.new(name, type)
      end
    end

    def pluralize_table_names?
      !defined?(ActiveRecord::Base) || ActiveRecord::Base.pluralize_table_names
    end

    def singular_name
      file_name
    end

    def plural_name
      @plural_name ||= singular_name.pluralize
    end
    
    def draggable?
      !(options[:draggable].blank?) 
    end
    
    def importable?
      !(options[:importable].blank?) 
    end

end