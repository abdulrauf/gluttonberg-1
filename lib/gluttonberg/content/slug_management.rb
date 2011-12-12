# encoding: utf-8
module Gluttonberg
  module Content
    # This module can be mixed into a class to provide slug management methods
    module SlugManagement

      # This included hook is used to declare the various properties and class
      # ivars we need.
      def self.included(klass)
        klass.class_eval do
          extend ClassMethods
          include InstanceMethods
          
          before_validation :slug_management
          
        end
      end
    
      module ClassMethods
        
      end
      
      module InstanceMethods
        
        
        def slug=(new_slug)
          #if you're changing this regex, make sure to change the one in /javascripts/slug_management.js too
          # utf-8 special chars are fixed for new ruby 1.9.2
          new_slug = new_slug.downcase.gsub(/\s/, '_').gsub(/[\!\*'"″′‟‛„‚”“”˝\(\)\;\:\.\@\&\=\+\$\,\/?\%\#\[\]]/, '')
          write_attribute(:slug, new_slug)
        end
        
        protected 
        # TODO fix column name
          def slug_management
            self.slug= self.name if self.slug.blank?
          end
          
      end
      
    end
  end
end
