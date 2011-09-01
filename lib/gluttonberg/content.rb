content = Pathname(__FILE__).dirname.expand_path

require File.join(content, 'content', 'slug_management')
require File.join(content, "content", "block")
require File.join(content, "content", "block_localization")
require File.join(content, "content", "localization")
require File.join(content, "content", "publishable")
require File.join(content, "content", "versioning")
require File.join(content, "content", "clean_html")
require File.join(content, "content", "import_export_csv")

module Gluttonberg
  # The content module contains a whole bunch classes and mixins related to the 
  # pages, localizations, content models and helpers for rendering content
  # inside of views.
  module Content
    @@content_associations = nil
    @@non_localized_associations = nil
    @@localizations = {}
    @@localization_associations = nil
    @@localization_classes = nil
    
    # This is called after the application loads so that we can define any
    # extra associations or do house-keeping once everything is required and
    # running
    def self.setup
      # Store the names of the associations in their own array for convenience
      @@localization_associations = @@localizations.keys
      @@localization_classes = @@localizations.values
      @@content_associations = Block.classes.collect { |k| k.association_name }
    end
        
    # For each content class that is registered, a corresponding association is
    # declared against the Page model. We need to keep track of these, which
    # is what this method does. It just returns an array of the association 
    # names.
    def self.non_localized_associations
      @@non_localized_associations ||= begin
        non_localized = Block.classes.select {|c| !c.localized? }
        non_localized.collect {|c| c.association_name }
      end
    end
    
    # Return the collection of content association names.
    def self.content_associations
      @@content_associations
    end
    
    # If a content class has the is_localized declaration, this method is used 
    # to register it so we can keep track of all localized content.
    def self.register_localization(assoc_name, klass)
      @@localizations[assoc_name] = klass
    end
    
    # Returns a hash of content classes that are localized, keyed to the 
    # association name.
    def self.localizations
      @@localizations
    end
    
    # Returns an array of the localization association names.
    def self.localization_associations
      @@localization_associations
    end
  end
end
