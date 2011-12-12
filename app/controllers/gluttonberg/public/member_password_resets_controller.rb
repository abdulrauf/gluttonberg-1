module Gluttonberg
  module Public
    class MemberPasswordResetsController < Gluttonberg::Public::BaseController  
      skip_before_filter :require_member
      before_filter :load_member_using_perishable_token, :only => [:edit, :update]
      
      layout 'public'
      
      def new
      end
      
      def create
        @member = Member.find_by_email(params[:gluttonberg_member][:email])
        if @member
          @member.deliver_password_reset_instructions!(current_localization_slug)
          flash[:notice] = "Instructions to reset your password have been emailed to you. " +
          "Please check your email."
          redirect_to root_path
        else
          flash[:notice] = "No member was found with that email address"
          redirect_to root_path
        end
      end
      
      def edit
        
      end
      
      def update
        @member.password = params[:gluttonberg_member][:password]
        @member.password_confirmation = params[:gluttonberg_member][:password_confirmation]
        if @member.save
          flash[:notice] = "Password successfully updated"
          redirect_to root_path
        else
          render root_path
        end
      end
      
      private
      
        def load_member_using_perishable_token
          @member = Member.find_using_perishable_token(params[:id])
          unless @member
            flash[:notice] = "We're sorry, but we could not locate your account. " +
            "If you are having issues try copying and pasting the URL " +
            "from your email into your browser or restarting the " +
            "reset password process."
            redirect_to root_path
          end
        end
    
    end
  end
end