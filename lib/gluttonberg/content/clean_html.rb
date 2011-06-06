module Gluttonberg
  module Content
    
    module CleanHtml
      
      def self.setup
        ::ActiveRecord::Base.send :include, Gluttonberg::Content::CleanHtml
      end
      
      def self.included(klass)
        klass.class_eval do
          extend  ClassMethods
          include InstanceMethods
          before_validation :clean_all_html_content
          
          cattr_accessor :non_versioned_columns
        end
      end
      
      module ClassMethods
        def clean_html(cols)
          self.non_versioned_columns = cols 
        end
        
        def clean_tags(str)
          if !str.blank? && str.instance_of?(String)
            str = self.removeStyle(str)
            str = self.removeMetaTag(str)
            str = removeEmptyTag(str)
          end  
          str
        end

        def removeEmptyTag(str)
          removeList = [/<blockquote>[\s]*<\/blockquote>/, /<p>[\s]*<\/p>/,/<div>[\s]*<\/div>/,/<span>[\s]*<\/span>/, /<h1>[\s]*<\/h1>/, /<h2>[\s]*<\/h2>/, /<h3>[\s]*<\/h3>/, /<h4>[\s]*<\/h4>/, /<h5>[\s]*<\/h5>/, /<h6>[\s]*<\/h6>/]
          removeList.each do |r|
            str = str.gsub(r,"")
          end

          str
        end

        def removeStyle(str)
          removeList = [/style=\"[\sA-Za-z0-9.,-;:]*\"/]
          removeList.each do |r|
            str = str.gsub(r,"")
          end

          str
        end

        def removeMetaTag(str)
           removeList = [ "<meta charset=\"utf-8\">", "</meta>" ]
           removeList.each do |r|
            str = str.gsub(r,"")
          end

          str
        end
      end
      
      module InstanceMethods
        def clean_all_html_content
          unless self.class.non_versioned_columns.blank?
            self.class.non_versioned_columns.each do |field|
              write_attribute(field , self.class.clean_tags(read_attribute(field)) )
            end
          end  
        end
      end
      
    end
  end
end