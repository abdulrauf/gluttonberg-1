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

    acts_as_taggable_on :article_category , :tag
    attr_accessor :name
    delegate :title , :body , :excerpt , :featured_image_id , :featured_image  , :to => :current_localization
    
    def commenting_disabled?
      !disable_comments.blank? && disable_comments
    end
    
    
    def current_localization
      if @current_localization.blank?
        load_default_localizations
      end
      @current_localization
    end
    
    # Load the matching localization as specified in the options
    def load_localization(locale = nil)
      if locale.blank? || locale.id.blank?
        @current_localization = load_default_localizations
      else  
        @current_localization = localizations.where("locale_id = ?", locale.id).first
      end   
      @current_localization
    end
    
    def load_default_localizations
      @current_localization = localizations.where(:locale_id => Locale.first_default.id).first
    end
    
  end
end