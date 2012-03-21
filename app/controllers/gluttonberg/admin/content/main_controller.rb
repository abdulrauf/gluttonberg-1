module Gluttonberg
  module Admin
    module Content
      class MainController < Gluttonberg::Admin::BaseController
        
        def index
          redirect_to admin_pages_path
        end
      
      end #class
    end #content
  end #admin
end #GB
