# encoding: utf-8
# Do not remove above encoding line utf-8, its required for ruby 1.9.2. We are using some special chars in this file.

module Gluttonberg
  class Page < ActiveRecord::Base
    include Content::Publishable
    include Content::SlugManagement
    belongs_to :user
    has_many :localizations, :class_name => "Gluttonberg::PageLocalization"   , :dependent => :destroy 
    has_and_belongs_to_many :groups, :class_name => "Group" , :join_table => "gb_groups_pages"
    
    # Generate the associations for the block/content classes
    Content::Block.classes.each do |klass| 
      has_many klass.association_name, :class_name => klass.name, :dependent => :destroy
    end
    
    validates_presence_of :name , :description_name
    
    set_table_name "gb_pages"
    
    after_save   :check_for_home_update

    is_drag_tree :scope => :parent_id, :flat => false , :order => "position"
    
    attr_accessor :current_localization, :locale_id, :paths_need_recaching
    
    
    # A custom finder used to find a page + locale combination which most
    # closely matches the path specified. It will also optionally limit it's
    # search to the specified locale, otherwise it will fall back to the
    # default.
    def self.find_by_path(path, locale = nil)
      path = path.match(/^\/(\S+)/)
      if( !locale.blank? && !path.blank?)
        path = path[1]
        page = joins(:localizations).where("locale_id = ? AND gb_page_localizations.path LIKE ? ", locale.id, path).first
        unless page.blank? 
          page.current_localization = page.localizations.where("locale_id = ? AND path LIKE ? ", locale.id, path).first
        end  
        page
      elsif path.blank?
        locale = Gluttonberg::Locale.first_default if locale.blank?
        pages = joins(:localizations).where("locale_id = ? AND home = ?", locale.id, true)
        page = pages.first unless pages.blank?
        unless page.blank? 
          page.current_localization = page.localizations.where("locale_id = ? AND path LIKE ? ", locale.id, path).first
        end
        page
      else # default locale
         path = path[1]
         locale = Gluttonberg::Locale.first_default
         page = joins(:localizations).where("locale_id = ? AND gb_page_localizations.path LIKE ? ", locale.id, path).first
         unless page.blank? 
           page.current_localization = page.localizations.where("locale_id = ? AND path LIKE ? ", locale.id, path).first
         end  
         page 
      end  
    end

    # Indicates if the page is used as a mount point for a public-facing
    # controller, e.g. a blog, message board etc.
    def rewrite_required?
      self.description.rewrite_required?
    end
    
    # Takes a path and rewrites it to point at an alternate route. The idea
    # being that this path points to a controller.
    def generate_rewrite_path(path) 
      path.gsub(current_localization.path, self.description.rewrite_route)
    end
            
    # Returns the PageDescription associated with this page.
    def description
      @description = PageDescription[self.description_name.to_sym] if self.description_name
      @description
    end
    
    # Returns the name of the view template specified for this page —
    # determined via the associated PageDescription
    def view
      self.description if @description.blank? 
      @description[:view] if @description
    end
    
    # Returns the name of the layout template specified for this page —
    # determined via the associated PageDescription
    def layout
      self.description if @description.blank? 
      @description[:layout] if @description
    end
    
    # Returns the localized navigation label, or falls back to the page for a
    # the default.
    def nav_label
      if current_localization.blank?
        if navigation_label.blank?
          name
        else
          navigation_label
        end
      else
        if current_localization.navigation_label.blank?
          current_localization.name
        else
          current_localization.navigation_label
        end
      end
    end

    # Returns the localized title for the page or a default
    def title
      (current_localization.blank? || current_localization.name.blank?) ? self.name : current_localization.name
    end
    
    # Delegates to the current_localization
    def path
      unless current_localization.blank?
        current_localization.path
      else
        localizations.first.path
      end  
    end
    
    def public_path
      unless current_localization.blank?
        current_localization.public_path
      else
        localizations.first.public_path
      end  
    end
    

    def paths_need_recaching?
      @paths_need_recaching
    end

    # Just palms off the request for the contents to the current localization
    def localized_contents
      @contents ||= begin
        Content.content_associations.inject([]) do |memo, assoc|
          memo += send(assoc).all_with_localization(:page_localization_id => current_localization.id)
        end
      end
    end

    
    # Load the matching localization as specified in the options
    # TODO Write spec for it
    def load_localization(locale = nil)
      if locale.blank?
         @current_localization = load_default_localizations
      else  
        @current_localization = localizations.where("locale_id = ? AND path LIKE ?", locale.id, "#{path}%").first
      end   
    end

    def home=(state)
      write_attribute(:home, state)
      @home_updated = state
    end
    
    def self.home_page
      Page.find( :first ,  :conditions => [ "home = ? " , true ] )
    end
    
    def self.home_page_name
      home_temp = self.home_page
      if home_temp.blank?
        "Not Selected"
      else
        home_temp.name
      end
    end
    
    # if page type is not redirection.
    # then create default view files for all localzations of the page. 
    # file will be created in host appliation/app/views/pages/template_name.locale-slug.html.haml
    def create_default_template_file
      unless self.description.redirection_required?
        self.localizations.each do |page_localization|
          file_path = File.join(Rails.root, "app", "views" , "pages" , "#{self.view}.#{page_localization.locale.slug}.html.haml"  )
          unless File.exists?(file_path)
            file = File.new(file_path, "w")
        
            page_localization.contents.each do |content|
              file.puts("= render_content_for(:#{content.section_name})")
            end
            file.close
          end  
        end  
      end  
    end
    
    def self.repair_pages_structure
      pages = Page.all

      pages.each do |page|
        
        if page.description.blank?
          puts "Page description '#{page.description_name}' for '#{page.name}' page  does not exist in page descriptions file. #{page.id}"
        elsif !page.description.sections.blank?
          puts("Generating stubbed content for new page #{page.id}")
          
          [PlainTextContent , HtmlContent , ImageContent].each do |klass|   
            list = klass.find(:all , :conditions => { :page_id => page.id})
            list.each do |item|
              found = page.description.contains_section?(item.section_name , item.class.to_s.demodulize.underscore)
              puts found
              if(!found)
                  item.destroy
              end
            end
          end
          

          page.description.sections.each do |name, section|
            # Create the content
                association = page.send(section[:type].to_s.pluralize)
                content = association.find(:first , :conditions => {:section_name => name})
                if content.blank?
                  content = association.create(:section_name => name)
                end
                # Create each localization
                 if content.class.localized?
                     page.localizations.all.each do |localization|
                       if content.localizations.find(:first , :conditions => { "#{section[:type]}_id" => content.id, :page_localization_id => localization.id }).blank?
                         content.localizations.create(:parent => content, :page_localization => localization)
                       end 
                     end
                end
          end
        end
      end # pages loop end  
      puts "completed"
    end
    
    def is_public?
      groups.blank?
    end  
    
    def load_default_localizations
      self.current_localization = Gluttonberg::PageLocalization.find(:first , :conditions => { :page_id => id , :locale_id => Gluttonberg::Locale.first_default.id } )
    end
        
    private

      

      # Checks to see if this page has been set as the homepage. If it has, we 
      # then go and 
      def check_for_home_update
        if @home_updated && @home_updated == true
          previous_home = Page.find( :first ,  :conditions => [ "home = ? AND id <> ? " , true ,self.id ] )
          previous_home.update_attributes(:home => false) if previous_home
        end
      end
    
  end
end


