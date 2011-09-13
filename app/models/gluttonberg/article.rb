module Gluttonberg  
  class Article < ActiveRecord::Base
    set_table_name "gb_articles"
    include Content::SlugManagement
    include Content::Publishable
    
    belongs_to :blog
    belongs_to :author, :class_name => "User"
    belongs_to :user #created by
    has_many :comments, :as => :commentable, :dependent => :destroy
    has_many :localizations, :class_name => "Gluttonberg::ArticleLocalization" , :foreign_key => :article_id  , :dependent => :destroy 
    #belongs_to :featured_image , :foreign_key => :featured_image_id , :class_name => "Gluttonberg::Asset"
    
    #is_versioned :non_versioned_columns => ['state' , 'disable_comments' , 'published_at' ]
    
    validates_presence_of :title
    
    #clean_html [:excerpt , :body]
    
    acts_as_taggable_on :article_category , :tag
    
    attr_reader :current_localization
    
    def commenting_disabled?
      !disable_comments.blank? && disable_comments
    end
    
    # def self.method_missing(methId, *args)
    #       method_info = methId.id2name.split('_')
    #       if method_info.length == 2 then
    #         if method_info[1] == 'category' then
    #           cat_name = method_info[0]
    #           if cat_name then
    #             return find(:first , :conditions => "name = '#{cat_name}'")
    #           end
    #         end
    #       end
    #     end
    
    def body
      current_localization.body
    end
    
    def body=(new_val)
      current_localization.body = new_val
    end
    
    def name
      self.title
    end
    
    def current_localization
      if @current_localization.blank?
        @current_localization = localizations.where(:locale_id => Locale.first_default.id).first
      end
      @current_localization
    end
    
  end
end