module Gluttonberg
  module Public
    class MembersController < Gluttonberg::Public::BaseController
      before_filter :is_members_enabled
      
      before_filter :require_member , :only => [ :edit, :update, :show ]
      layout 'public'
      
      def new
        @page_title = "Register"
        @member = Member.new
      end
  
      def create
        @member = Member.new(params[:gluttonberg_member])
        if Member.does_email_verification_required
          @member.confirmation_key = Digest::SHA1.hexdigest(Time.now.to_s + rand(12341234).to_s)[1..24]
        else  
          @member.profile_confirmed = true
        end
        if @member && @member.save
          if Member.does_email_verification_required
            MemberNotifier.confirmation_instructions(@member.id,current_localization_slug).deliver
            flash[:notice] = "Please check your email for a confirmation."
          else
            flash[:notice] = "Your registration is now complete."
          end
          redirect_to root_path
        else
          @page_title = "Register"
          render :new
        end
      end
  
  
      def confirm
        @member = Member.where(:confirmation_key => params[:key]).first
        if @member
          @member.profile_confirmed = true
          @member.save
          flash[:notice] = "Your registration is now complete."
          redirect_to root_url
        else
          flash[:notice] = "We're sorry, but we could not locate your account. " +
          "If you are having issues try copying and pasting the URL " +
          "from your email into your browser."
          redirect_to root_url
        end
      end
  
      def resend_confirmation
        if current_member.confirmation_key.blank?
          confirmation_key = Digest::SHA1.hexdigest(Time.now.to_s + rand(12341234).to_s)[1..24]
          current_member.update_attributes(:confirmation_key => confirmation_key)
        end
        MemberNotifier.confirmation_instructions(current_member.id,current_localization_slug).deliver if current_member && !current_member.profile_confirmed
        flash[:notice] = "Please check your email for a confirmation."
        redirect_to member_profile_url
      end
  
      def update
        @member = current_member
        if @member.update_attributes(params[:gluttonberg_member])
          @member.save
          if params[:gluttonberg_member][:return_url]
            redirect_to params[:gluttonberg_member][:return_url]
          else
            redirect_to root_path
          end
        end
      end
  
      def show
        @member = current_member
      end
  
      def edit
        @member = current_member
      end
  
  
  
      protected
  
    end
  end
end