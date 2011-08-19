class MemberNotifier < ActionMailer::Base
  
  default :from => "#{Gluttonberg::Setting.get_setting("title")} <#{Gluttonberg::Setting.get_setting("from_email")}>"
  default_url_options[:host] = Rails.configuration.host_name 
  
  def password_reset_instructions(member_id)
    member = Gluttonberg::Member.find(member_id)
    setup_email
    @subject += "Password Reset Instructions"
    @recipients = member.email  
    @edit_password_reset_url = edit_member_password_reset_url(member.perishable_token)
  end
  
  def confirmation_instructions(member_id)
    member = Gluttonberg::Member.find(member_id)
    setup_email
    @subject += "Confirmation Instructions"
    @recipients = member.email  
    @member_confirmation_url = member_confirmation_url(:key => member.confirmation_key)
  end
  
  # welcome email will be sent to member when admin user will create member. 
  # this member will be automatically verified 
  # purpose of this email is to provide login details to the member
  def welcome(member_id)
    @member = Gluttonberg::Member.find(member_id)
    setup_email
    @subject += "Confirmation Instructions"
    @recipients = @member.email  
    @password = Gluttonberg::Member.generateRandomString
    password_hash = {  
        :password => @password ,
        :password_confirmation => @password ,
        :welcome_email_sent => true
    }
    @member.update_attributes(password_hash)
    @login_url = member_login_url
  end
  
  
  protected
  
    def setup_email
      @from        = "#{Gluttonberg::Setting.get_setting("title")} <#{Gluttonberg::Setting.get_setting("from_email")}>"
      @subject     = "[#{Gluttonberg::Setting.get_setting("title")}] "
      @sent_on     = Time.now
      @content_type = "text/html"
    end
    
end