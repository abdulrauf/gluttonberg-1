module Gluttonberg
  module Public 
    class PublicAssetsController <  ActionController::Base
        def show               
          @asset = Asset.first( :conditions => "id=#{params[:id]} AND  asset_hash like '#{params[:hash]}%' ")
          if @asset.blank?        
            render :layout => "bare" , :template => 'gluttonberg/admin/exceptions/not_found.html.haml' , :status => 404
            return 
          end
          if params[:thumb_name].blank?
            redirect_to @asset.url
          else
            redirect_to @asset.url_for(params[:thumb_name].to_sym)
          end  
        end  
    end
  end  
end