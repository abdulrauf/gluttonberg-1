module Gluttonberg
  module Middleware
    class Locales
      def initialize(app)
        @app = app
      end

      def call(env)
        path = env['PATH_INFO']
        unless path =~ /^#{Gluttonberg::Engine.config.admin_path}/ || path.start_with?("/stylesheets")  || path.start_with?("/javascripts")   || path.start_with?("/images")  || path.start_with?("/asset") 
          case Gluttonberg::Engine.config.identify_locale
            when :subdomain
              # return the sub-domain
            when :prefix
              locale= path.split('/')[1]
              result = Gluttonberg::Locale.find_by_locale(locale)
              if result
                env['PATH_INFO'].gsub!("/#{locale}", '')
                env['gluttonberg.locale'] = result
              end
            when :domain
              env['SERVER_NAME']
          end
        end  
        @app.call(env)
      end
    end # Locales
  end # Middleware
end # Gluttonberg

