Rails.application.routes.draw do
  
  mount_at = Gluttonberg::Engine.config.mount_at
  
  scope :module => 'Gluttonberg' do
    namespace :admin do
      root :to => "main#index"
      
      # Help
      match("/help/:module_and_controller/:page" => "help#show", :module_and_controller => %r{\S+} , :as => :help)
      
      scope :module => 'Content' do
        match "/flagged_contents" => "flag#index" , :as => :flagged_contents
        get '/flagged_contents/moderation/:id/:moderation' => "flag#moderation", :as => :flagged_contents_moderation 
        match 'content' => "main#index",      :as => :content
        resources :pages do
          get 'delete', :on => :member
          resources :page_localizations
          get 'edit_home' => "pages#edit_home", :as =>  :edit_home
          post 'update_home' => "pages#update_home", :as =>  :update_home        
        end
        
        get "pages_list_for_tinymce" => "pages#pages_list_for_tinymce" , :as => :pages_list_for_tinymce
        resources :blogs do
          get 'delete', :on => :member
          resources :articles do
            get 'delete', :on => :member
            resources :comments do
              get 'delete', :on => :member
              get 'moderation', :on => :member
            end
          end
        end
        
        match "/pages/move(.:format)" => "pages#move_node" , :as=> :page_move
        resources :galleries do
          get 'delete', :on => :member
          get 'add_image', :on => :member
          get 'remove_image' , :on => :member
        end  
        match "/galleries/move(.:format)" => "galleries#move_node" , :as=> :gallery_move
        
      end
      
      # Settings
      scope :module => 'Settings' do
        match 'settings' => "main#index",      :as => :settings
        resources :locales do 
          get 'delete', :on => :member
        end
        
        resources :users do
          get 'delete', :on => :member
        end
        
        resources :generic_settings do 
          get 'delete', :on => :member
        end      
        
        resources :stylesheets do
          get 'delete', :on => :member
        end
        match "/stylesheets/move(.:format)" => "stylesheets#move_node" , :as=> :stylesheet_move 
      end  
      
      namespace :membership do
        root :to =>  "main#index"
        match "/groups/move(.:format)" => "groups#move_node" , :as=> :group_move
        match "members/export" => "members#export" , :as => :members_export
        match 'members/new_bulk'  => "members#new_bulk" , :as => :members_import
        match 'members/create_bulk'  => "members#create_bulk" , :as => :members_bulk_create
        resources :members do
          get 'delete', :on => :member
          get 'welcome' , :on => :member
        end
        resources :groups do
          get 'delete', :on => :member
        end
      end
      
      
      scope :module => 'AssetLibrary' do
        # asset library related routes
          resources :assets do 
            get 'delete', :on => :member
            get 'crop', :on => :member
            post 'save_crop', :on => :member
          end
          match "library" => "assets#index" , :as => :library
          match "search_assets" => "assets#search" , :as => :library_search
          match "add_asset_using_ajax"  => "assets#ajax_new" , :as => :add_asset_using_ajax
          match "add_assets_in_bulk"  => "assets#add_assets_in_bulk" , :as => :add_assets_in_bulk
          match "create_assets_in_bulk"  => "assets#create_assets_in_bulk" , :as => :create_assets_in_bulk
          match "browser"  => "assets#browser" , :as => :asset_browser
          match "browse/:category/page/:page"  => "assets#category" , :as => :asset_category
          match "collections/:id/page/:page"  => "collections#show" , :as => :asset_collection
          resources :collections  do 
            get 'delete', :on => :member
          end       
      end
      
      resources :password_resets
      
      get "login" => "user_sessions#new"
      post "login" => "user_sessions#create"
      match "logout" => "user_sessions#destroy"
    end
    
    scope :module => 'Public' do
      match "/user_asset/:hash/:id(/:thumb_name)" => "public_assets#show" , :as => :public_asset
      match "/_public/page" => "pages#show"
      match "/restrict_site_access" => "pages#restrict_site_access" , :as => :restrict_site_access
      match "sitemap" => "pages#sitemap" , :as => :sitemap
      # Blog Stuff
      
      scope "(/:locale)" do
        resources :blogs do      
          resources :articles do
            resources :comments
            get "preview"
          end
        end
      end
      
        
      match "/mark_as_flag/:flaggable_type/:flaggable_id" => "flag#new" , :as => :mark_as_flag
      match "/save_mark_as_flag" => "flag#create" , :as => :save_mark_as_flag
      match "/articles/tag/:tag" => "articles#tag" , :as => :articles_by_tag
      match "/articles/unsubscribe/:reference" => "articles#unsubscribe" , :as => :unsubscribe_article_comments      
      get "(/:locale)/member/login" => "member_sessions#new" , :as => :member_login
      post "(/:locale)/member/login" => "member_sessions#create"  , :as => :member_login
      match "(/:locale)/member/logout" => "member_sessions#destroy", :as => :member_logout
      get "(/:locale)/member/confirm/:key" => "members#confirm", :as => :member_confirmation
      get "(/:locale)/member/resend_confirmation" => "members#resend_confirmation", :as => :member_resend_confirmation
      put "(/:locale)/member/profile" => "members#update" 
      get "(/:locale)/member/profile" => "members#show", :as => :member_profile
      match "(/:locale)/member/profile/edit" => "members#edit", :as => :member_profile_edit
      
      scope "(/:locale)" do
        resources :members
        resources :member_password_resets
      end
      
      get 'stylesheets/:id' => "pages#stylesheets", :as =>  :stylesheets
    end
    
    
  end
  
  scope :module => 'Gluttonberg' do
    scope :module => 'Public' do
      get "*a" => "pages#error_404"
    end
  end
end
