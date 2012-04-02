# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "http://www.example.com"

SitemapGenerator::Sitemap.create do
  Gluttonberg::Sitemap.sitemap = sitemap
  # Put links creation logic here.
  #
  # The root path '/' and sitemap index file are added automatically for you.
  # Links are added to the Sitemap in the order they are specified.
  
    
  # add all published pages to html sitemap in tree format
  def add_pages_to_sitemap_in_tree_format(parent)
    unless parent.blank?
      parent.children.published.each do |page|
        page.localizations.each do |loc|
          #page.load_default_localizations
          Gluttonberg::Sitemap.add({:path => loc.public_path , :title => page.nav_label} , page.updated_at , "page" ) 
        end
        add_pages_to_sitemap_in_tree_format(page) unless page.children.blank?  
      end
    end  
  end
  add_pages_to_sitemap_in_tree_format(Gluttonberg::Page.home_page)
  
  # Add All published Blog Articles to html and xml sitemap
  begin
    Gluttonberg::Article.published.each do |article|
      if Gluttonberg.localized?
        article.localizations.each do |loc|
          Gluttonberg::Sitemap.add({:path => blog_article_path(:locale => loc.locale.slug , :blog_id => article.blog.slug, :id => article.slug) , :title => article.title } , article.updated_at , "article")
        end  
      else
        Gluttonberg::Sitemap.add({:path => blog_article_path(:blog_id => article.blog.slug, :id => article.slug) , :title => article.title } , article.updated_at , "article")
      end  
    end
  rescue => e
    puts e
  end
  
  # add custom models
  #Gluttonberg::Sitemap.add_custom_model(Model , title_field_name_as_symbol , pages)
  #Gluttonberg::Sitemap.add_custom_model(Book , :title) 
  #Gluttonberg::Sitemap.add_custom_model(Book , :title, [:index , :show] ) # same as previous example
  #Gluttonberg::Sitemap.add_custom_model(Book , :title,  [:index ]) #only index page
  #Gluttonberg::Sitemap.add_custom_model(Book , :title , [ :show]) #only detail pages
  
  
end
