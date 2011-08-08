module Gluttonberg
  module Helpers
    module AssetLibrary
     
       #  nice and clean public url of assets
       def asset_url(asset , opts = {})
         url = ""
         if RAILS_ENV=="development"
           url = "http://#{request.host}:#{request.port}/asset/#{asset.asset_hash[0..3]}/#{asset.id}"
         else
           url = "http://#{request.host}/asset/#{asset.asset_hash[0..3]}/#{asset.id}"
         end 
         
         if opts[:thumb_name]
           url << "/#{opts[:thumb_name]}"
         end
         
         url
       end


       # Returns a link for sorting assets in the library
       def sorter_link(name, param, url)
         opts = {}
         route_opts = { :order => param , :order_type => "asc" }
         if param == params[:order] || (!params[:order] && param == 'date-added')
           opts[:class] = "current"
           unless params[:order_type].blank?
             route_opts[:order_type] = (params[:order_type] == "asc" ? "desc" : "asc" ) 
           else
             route_opts[:order_type] = "desc"
           end
           opts[:class] << (route_opts[:order_type] == "asc" ? " desc" : " asc" )          
         end
         
         link_to(name, url + "?" + route_opts.to_param , opts)
       end

       # Generates a link which launches the asset browser
       # This method operates in bound or unbound mode.
       #
       #
       # In unbound mode this method accepts name of the tag and an options hash.
       #
       # The options hash accepts the following parameters:
       #
       #   The following are required in unbound mode, not used in bound mode:
       #     :id = This is the id to use for the generated hidden field to store the selected assets id.
       #     :asset_id = The id of the currently selected asset. 
       #     :filter = Its optional. If valid filter is provided then it only brings assets of belonging to select filter type. (image,audio video)
       #     :button_class => Html class for button
       #     :button_text => Its a label for button. If its not provided then "Browse"     
       #   The following are optional in either mode:
       #     < any option accepted by hidden_field() method >
       #
       #
       # For Finding image assets
       #   asset_browser_tag( name_of_tag ,  opts = { :button_class => "" , :button_text => "Select" ,  :filter => "" ,  :id => "html_id", :asset_id => content.asset_id } )
       
       def asset_browser_tag( field_id , opts = {} )
          _asset_browser_tag( field_id , opts  )
       end
       
       def _asset_browser_tag( field_id , opts = {} )
           asset_id = nil
           asset_id = opts[:asset_id]
           filter = opts[:filter].blank? ? "all" : opts[:filter]

           if opts[:id].blank?
             rel = field_id.to_s + "_" + id.to_s
             opts[:id] = rel
           end  

          # Find the asset so we can get the name
          asset_info = "Nothing selected"
          unless asset_id.blank?
            asset = Asset.where(:id => asset_id).first
            asset_info = unless asset.blank?
              asset_tag(asset , :small_thumb).html_safe + content_tag(:span , asset.name) 
            else
              "Asset missing!"
            end    
          end

           # Output it all
          link_contents =  content_tag(:span , asset_info , :id => "title_thumb_#{opts[:id]}") 
          link_contents << hidden_field_tag("filter_" + field_id.to_s , value=filter , :id => "filter_#{opts[:id]}" )
          link_contents << link_to("Select", admin_asset_browser_url + "?filter=#{filter}" , { :class => "button choose_button #{opts[:button_class]}" , :rel => opts[:id] , :data_url => opts[:data_url] })
          link_contents << hidden_field_tag(field_id , asset_id , { :id => opts[:id] , :class => "choose_asset_hidden_field" } )  
          link_contents << clear_asset_tag( field_id , opts )
          content_tag(:span , link_contents , { :class => "assetBrowserLink" } )

      end
       
      def add_image_to_gallery_tag( button_text , add_url, gallery_id , opts = {})
          opts[:class] = "" if opts[:class].blank?
          opts[:class] << " add_image_to_gallery choose_button"
          link_contents = link_to(button_text, admin_asset_browser_url + "?filter=image" , opts.merge( :data_url => add_url ))
          content_tag(:span , link_contents , { :class => "assetBrowserLink" } )
      end
       
       def clear_asset_tag( field_id , opts = {} )
         asset_id = nil
         asset_id = opts[:asset_id]
         if opts[:id].blank?
           rel = field_id.to_s + "_" + id.to_s
           opts[:id] = rel
         end
         html_id = opts[:id]
         link_to("Remove", "Javascript:;" , { :class => "button remove" , :onclick => "$('##{html_id}').val('');$('#title_thumb_#{opts[:id]}').html('')" })
       end
      
       def asset_panel(assets, name_or_id , type )
          render :partial => "gluttonberg/admin/shared/asset_panel.html" , :locals => {:assets => assets , :name_or_id => name_or_id , :type => type}
       end

       
       def asset_tag(asset , thumbnail_type = nil)
          unless asset.blank?
            path = thumbnail_type.blank? ? asset.url : asset.url_for(thumbnail_type)
            content_tag(:img , "" , :class => asset.name , :title => asset.name , :alt => asset.name , :src => path)
          end 
       end
       
       def asset_tag_v2(asset , options = {} , thumbnail_type = nil)
           unless asset.blank?
             options[:class] = "" if options[:class].blank?
             options[:class] << " #{asset.name}"
             options[:alt] = asset.name
             options[:title] = asset.name
             options[:src] = thumbnail_type.blank? ? asset.url : asset.url_for(thumbnail_type)
             content_tag(:img , "" , options)
           end 
       end
       
       def gallery_images_ul(id , gallery_thumb_image , gallery_large_image ,html_opts_for_ul = {})
         gallery = Gluttonberg::Gallery.find(id)
         unless gallery.blank? || gallery.gallery_images.blank?
           options = "" 
           gallery.gallery_images.each do |g_image|
             li_html = link_to(asset_tag(g_image.image , gallery_thumb_image).html_safe , asset_url(g_image.image , :thumb_name => gallery_large_image) , :class => "thumb") 
             unless g_image.image.alt.blank?
               image_desc_html = content_tag(:div , g_image.image.alt  , :class => "image-desc")
               li_html << content_tag(:div , image_desc_html , :class => "caption")
             end 
             options << content_tag(:li , li_html , :id => "image_#{g_image.id}").html_safe
           end
           content_tag(:ul  , options.html_safe , html_opts_for_ul)
         end
       end
     
     
    end # Assets
  end # Helpers
end # Gluttonberg


# Luke I need your help to improve this method. 
# Ideally i should be able to call asset_browser_tag( field_id , opts = {} ) method from here.
module ActionView
  module Helpers
    class FormBuilder
        include ActionView::Helpers
        
        def asset_browser( field_id , opts = {} )
          asset_id = self.object.send(field_id.to_s)
          filter = opts[:filter].blank? ? "all" : opts[:filter]

          opts[:id] = "#{field_id}_#{asset_id}" if opts[:id].blank?
          html_id = opts[:id]

          # Find the asset so we can get the name
          asset_info = "Nothing selected"
          unless asset_id.blank?
            asset = Gluttonberg::Asset.find(asset_id)
            asset_info = if asset
              asset_tag(asset , :small_thumb).html_safe + content_tag(:span , asset.name) 
            else
              "Asset missing!"
            end    
          end
           
          #hack for url
          admin_asset_browser_url = "/admin/browser"

          # Output it all
          link_contents =  content_tag(:span , asset_info , :id => "title_thumb_#{opts[:id]}") 
          link_contents << hidden_field_tag("filter_#{html_id}"  , value=filter  )
          link_contents << link_to("Select", admin_asset_browser_url + "?filter=#{filter}" , { :class =>"button choose_button #{opts[:button_class]}" , :rel => html_id })
          link_contents << self.hidden_field(field_id , { :id => html_id , :class => "choose_asset_hidden_field" } )  
          link_contents << self.clear_asset( field_id , opts )
          content_tag(:span , link_contents , { :class => "assetBrowserLink" } )
        end
        
        def asset_tag(asset , thumbnail_type = nil)
           unless asset.blank?
             path = thumbnail_type.blank? ? asset.url : asset.url_for(thumbnail_type)
             content_tag(:img , "", :class => asset.name , :alt => asset.name , :src => path)
           end 
        end
        
        def clear_asset( field_id , opts = {} )
          asset_id = self.object.send(field_id.to_s)
          opts[:id] = "#{field_id}_#{asset_id}" if opts[:id].blank?
          html_id = opts[:id]
          button_text = opts[:button_text].blank? ? "Browse" : opts[:button_text]
          opts[:button_class] = "" if opts[:button_class].blank?  
          link_to("Remove", "Javascript:;" , { :class => opts[:button_class] , :onclick => "$('##{html_id}').val('');$('#title_thumb_#{opts[:id]}').html('')" })
        end
    end
  end
end  