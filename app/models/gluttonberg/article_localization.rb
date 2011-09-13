module Gluttonberg  
  class ArticleLocalization < ActiveRecord::Base
    set_table_name "gb_article_localizations"
    belongs_to :article  , :class_name => "Gluttonberg::Article"
    belongs_to :locale
    
    belongs_to :featured_image , :foreign_key => :featured_image_id , :class_name => "Gluttonberg::Asset"
    
    is_versioned :non_versioned_columns => ['state' , 'disable_comments' , 'published_at' , 'article_id' , 'locale_id']
    
    validates_presence_of :title
    
    clean_html [:excerpt , :body]
    
    def name
      title
    end
  end
end