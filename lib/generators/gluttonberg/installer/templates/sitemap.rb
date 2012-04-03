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
    if Gluttonberg.localized?
      Gluttonberg::Locale.all.each do |locale|
        Gluttonberg::Sitemap.add({:path => blogs_path(:locale => locale.slug ) , :title => "Blogs" } , nil , "blogs")
      end
    else
      Gluttonberg::Sitemap.add({:path => blogs_path , :title => "Blogs" } , nil , "blogs")
    end  
    
    Gluttonberg::Article.published.each do |article|
      if Gluttonberg.localized?
        article.localizations.each do |loc|
          Gluttonberg::Sitemap.add({:path => blog_article_path(:locale => loc.locale.slug , :blog_id => article.blog.slug, :id => article.slug) , :title => article.title } , article.updated_at , "article")
        end  
      else #non localized
        Gluttonberg::Sitemap.add({:path => blog_article_path(:blog_id => article.blog.slug, :id => article.slug) , :title => article.title } , article.updated_at , "article")
      end  
    end
  rescue => e
    puts e
  end
  
  if Gluttonberg::Member.enable_members == true
    if Gluttonberg.localized?
      Gluttonberg::Locale.all.each do |locale|
        Gluttonberg::Sitemap.add({:path => new_member_path(:locale => locale.slug) , :title => "Member Register" } , nil , "members")
        Gluttonberg::Sitemap.add({:path => member_login_path(:locale => locale.slug) , :title => "Member Login" } , nil , "members")
      end
    else
      Gluttonberg::Sitemap.add({:path => new_member_path , :title => "Member Register" } , nil , "members")
      Gluttonberg::Sitemap.add({:path => member_login_path , :title => "Member Login" } , nil , "members")
    end  
    
  end
  
  # add custom models
  #Gluttonberg::Sitemap.add_custom_model(Model , title_field_name_as_symbol , pages)
  #Gluttonberg::Sitemap.add_custom_model(Book , :title) 
  #Gluttonberg::Sitemap.add_custom_model(Book , :title, [:index , :show] ) # same as previous example
  #Gluttonberg::Sitemap.add_custom_model(Book , :title,  [:index ]) #only index page
  #Gluttonberg::Sitemap.add_custom_model(Book , :title , [ :show]) #only detail pages
  
  
end
