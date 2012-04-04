class User < ActiveRecord::Base
  attr_accessible :first_name , :last_name , :email , :password , :password_confirmation , :bio , :image_id
  
  set_table_name "gb_users"
  belongs_to :images , :foreign_key => "image_id" , :class_name => "Gluttonberg::Asset"
  
  validates_presence_of :first_name , :email , :role
  validates_format_of :password, :with => /^(?=.*\d)(?=.*[a-zA-Z])(?!.*[^\da-zA-Z]).{6,}$/ , :if => :require_password?, :message => "must be a minimum of 6 characters in length, contain at least 1 letter and at least 1 number"
  
  
  clean_html [:bio]
  
  acts_as_authentic do |c|
    c.login_field = "email"
  end
  
  def full_name
    self.first_name = "" if self.first_name.blank?
    self.last_name = "" if self.last_name.blank?
    self.first_name + " " + self.last_name
  end
  
  def deliver_password_reset_instructions!  
    reset_perishable_token!
    Notifier.password_reset_instructions(self.id).deliver  
  end
  
  def super_admin?
    self.role == "super_admin"
  end
  
  def admin?
    self.role == "admin"
  end
  
  def self.user_roles
    @roles ||= (["super_admin" , "admin" , "contributor"] << (Rails.configuration.user_roles) ).flatten
  end
  
  def user_valid_roles(user)
    if user.id == self.id
      []
    else  
      roles = (["super_admin" , "admin" , "contributor"] << (Rails.configuration.user_roles) ).flatten
      roles.delete("super_admin") unless self.super_admin? 
      roles.delete("contributor") if !self.super_admin? && !self.admin?
      roles 
    end  
  end
  
  def have_backend_access?
    ["super_admin" , "admin" , "contributor"].include?(self.role)
  end
  
end