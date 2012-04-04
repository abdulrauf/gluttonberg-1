module Gluttonberg
  class Sitemap
    @@sitemap = nil
    @@links = {}
    
    def self.add(link, lastmod , group="")
      unless @@links.has_key?(group)
        @@links[group] = [link]
      else
        @@links[group] << link
        @@links[group] = @@links[group].uniq
      end
      @@sitemap.add(link[:path] , :lastmod => Time.now)
      @@links
    end
  
    def self.links
      @@links
    end
    
    def self.sitemap=(sitemap)
      @@sitemap = sitemap
    end
    
    def self.add_custom_model(model_name,title_field_name,pages=[:index , :show])
      pl = model_name.to_s.underscore.pluralize
      last_updated_at = ""
      if pages.include?(:index)
        Gluttonberg::Sitemap.add({:path => "/#{pl}" , :title => model_name.to_s.humanize } , last_updated_at , pl)
      end
      
      if pages.include?(:show)
        model_name.published.each do |obj|
          Gluttonberg::Sitemap.add({:path => "/#{pl}/#{obj.id}" , :title => obj.send(title_field_name) } , obj.updated_at , pl)
        end
      end  
    end
  
  end
end  