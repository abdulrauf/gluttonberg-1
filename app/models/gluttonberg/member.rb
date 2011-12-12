module Gluttonberg
  class Member < ActiveRecord::Base
  
    set_table_name "gb_members"
    
    has_and_belongs_to_many :groups, :class_name => "Group" , :join_table => "gb_groups_members"
    has_attached_file :image, :styles => { :profile => ["600x600"], :thumb => ["142x95#"] , :thumb_for_backend => ["100x75#"]}
    
  
    validates_presence_of :first_name , :email 
    attr_accessor :return_url , :term_and_conditions
    
    attr_accessor :image_delete
    
  
    clean_html [:bio]
  
    acts_as_authentic do |c|
      c.session_class = MemberSession
      c.login_field = "email"
    end
  
    def full_name
      self.first_name = "" if self.first_name.blank?
      self.last_name = "" if self.last_name.blank?
      self.first_name + " " + self.last_name
    end
  
    def deliver_password_reset_instructions!(current_localization_slug = "")  
      reset_perishable_token!
      MemberNotifier.password_reset_instructions(self.id,current_localization_slug).deliver  
    end
    
    def groups_name(join_str=", ")
      unless groups.blank?
        groups.map{|g| g.name}.join(join_str)
      else
        ""  
      end
    end
    
    def can_login?
      !respond_to?(:can_login) || self.can_login == true
    end
    
    def self.enable_members
      if Rails.configuration.enable_members == true || Rails.configuration.enable_members.kind_of?(Hash)
        true
      else
        false
      end  
    end
    
    def self.does_email_verification_required
      if Rails.configuration.enable_members == true
        true
      elsif Rails.configuration.enable_members.kind_of? Hash
        if Rails.configuration.enable_members.has_key?(:email_verification)
          Rails.configuration.enable_members[:email_verification]
        else
          true
        end    
      else
        false
      end  
    end
    
    def self.generateRandomString(length=10)
      chars = ("A".."Z").to_a + ("0".."9").to_a
      similar_chars = %w{ i I 1 0 O o 5 S s }
      chars.delete_if {|x| similar_chars.include? x} 
      newpass = ""
      1.upto(length) { |i| newpass << chars[rand(chars.size-1)] }
      newpass
    end
    
    def does_member_have_access_to_the_page?( page)
      self.have_group?(page.groups)
    end
    
    def have_group?(groups)
      if groups.find_all{|g| self.group_ids.include?(g.id)  }.blank?
        false
      else
        true
      end
    end
    
    ###############################
    # takes complete path to csv file. 
    # and returns successfull_users , failed_users and updated_users arrays that contains user objects
    # if user exist with given email then update its information
    # otherwise create a new user for it
    # returns [successfull_users , failed_users , updated_users , ]
    # if csv format is incorrect then it will return a string "CSV file format is invalid"
    def self.importCSV(file_path , invite , group_ids )
      begin
        if RUBY_VERSION >= "1.9"
          require 'csv'
          csv_table = CSV.read(file_path)
        else
          csv_table = FasterCSV.read(file_path)
        end
      rescue => e
        return "Please provide a valid CSV file with correct column names."
      end  
      first_name_column_num =   self.find_column_position(csv_table , Rails.configuration.member_csv_metadata[:first_name] )
      last_name_column_num =   self.find_column_position(csv_table ,  Rails.configuration.member_csv_metadata[:last_name]  )
      email_column_num =   self.find_column_position(csv_table , Rails.configuration.member_csv_metadata[:email] )
      groups_column_num =   self.find_column_position(csv_table , Rails.configuration.member_csv_metadata[:groups] )
      other_columns = {}
      
      Rails.configuration.member_csv_metadata.each do |key , val|
        if ![:first_name, :last_name , :email, :groups].include?(key) 
          other_columns[key] = self.find_column_position(csv_table , val )
        end  
      end
      
      successfull_users = []
      failed_users = []
      updated_users = []


      if first_name_column_num && last_name_column_num  && email_column_num
        csv_table.each_with_index do |row , index |
            if index > 0 # ignore first row because its meta data row
              #user information hash 
              user_info = {
                :first_name => row[first_name_column_num] , 
                :last_name => row[last_name_column_num] , 
                :email => row[email_column_num],
                :group_ids => []
              }
              other_columns.each do |key , val|
                if !val.blank? && val >= 0
                  user_info[key] = row[val]
                end
              end
              
              #attach user to an industry if its valid
              unless groups_column_num.blank? || row[groups_column_num].blank?
                group_names = row[groups_column_num].split(";")
                temp_group_ids = []
                group_names.each do |group_name|
                  group = Group.find(:first,:conditions=>{:name => group_name.strip})
                  temp_group_ids << group.id unless group.blank?
                end
                user_info[:group_ids] = temp_group_ids
              end
              
              unless group_ids.blank?
                if user_info[:group_ids].blank?
                  user_info[:group_ids] = group_ids
                else
                  user_info[:group_ids] << group_ids
                end
              end
              
              user = self.find(:first , :conditions => { :email => row[email_column_num] } )
              if user.blank?          
                # generate random password
                temp_password = self.generateRandomString
                password_hash = {  
                  :password => temp_password ,
                  :password_confirmation => temp_password
                }

                # make user object
                user = self.new(user_info.merge(password_hash))

                #if its valid then save it send an email and also add it to successfull_users array            
                if user.valid?
                  user.save
                  if invite == "1"   
                    # we will regenerate password and send it member
                    MemberNotifier.delay.welcome(user)
                  end
                  successfull_users << user
                else # if failed then add it to failed list
                  failed_users << user                      
                end
              else
                if  !self.contains_user?(user , successfull_users) and !self.contains_user?(user , updated_users)
                    if user.update_attributes(user_info)
                      updated_users << user
                    else
                      failed_users << user
                    end
                end
              end    
            end # if csv row index > 0   

        end #loop   
      else
        return "Please provide a valid CSV file with correct column names"   
      end #if
      [successfull_users , failed_users , updated_users ]
    end
    
    def self.contains_user?(user , list)
      list.each do |record|
        return true if record.id == user.id || record.email == user.email      
      end
      false
    end
    
    # csv_table is two dimentional array
    # col_name is a string.
    # if structure is proper and column name found it returns column index from 0 to n-1
    # otherwise nil
    def self.find_column_position(csv_table  , col_name)
      if csv_table.instance_of?(Array) && csv_table.count > 0 && csv_table.first.count > 0
        csv_table.first.each_with_index do |table_col , index|
          return index if table_col.to_s.upcase == col_name.to_s.upcase
        end
        nil
      else  
        nil
      end  
    end
    
    #############################
    #export to a csv
    def self.exportCSV
      all_records = self.all
      csv_class = nil
      if RUBY_VERSION >= "1.9"
        require 'csv'
        csv_class = CSV
      else
        csv_class = FasterCSV
      end
      other_columns = {}
      csv_string = csv_class.generate do |csv|
          header_row = ["DATABASE ID",Rails.configuration.member_csv_metadata[:first_name],Rails.configuration.member_csv_metadata[:last_name], Rails.configuration.member_csv_metadata[:email], Rails.configuration.member_csv_metadata[:groups]]
          
          index = 0
          Rails.configuration.member_csv_metadata.each do |key , val|
            if ![:first_name, :last_name , :email , :groups].include?(key) 
              other_columns[key] = index + 5
              header_row << val
              index += 1
            end  
          end
          csv << header_row
          
          all_records.each do |record|
            data_row = [record.id, record.first_name, record.last_name , record.email , record.groups_name("; ")]
            other_columns.each do |key , val|
              if !val.blank? && val >= 0
                data_row[val] = record.send(key)
              end  
            end
            csv << data_row
          end        
      end

      csv_string
    end
    
    
  end
end  