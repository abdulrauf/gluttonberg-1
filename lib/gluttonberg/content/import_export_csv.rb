module Gluttonberg
  module Content
    # A mixin which allows for any arbitrary model to have multiple versions. It will 
    # generate the versioning models and add methods for creating, managing and 
    # retrieving different versions of a record.
    # In reality this is behaving like a wrapper on acts_as_versioned
    module ImportExportCSV
      
      def self.setup
        ::ActiveRecord::Base.send :include, Gluttonberg::Content::ImportExportCSV
      end
      
      def self.included(klass)
        klass.class_eval do
          extend  ClassMethods
          include InstanceMethods          
        end
      end
      
      module ClassMethods
        
        def import_export_csv(import_export_columns=nil)
          if import_export_columns.blank?
            @@import_export_columns = self.new.attributes.keys
          else
            @@import_export_columns = import_export_columns
          end  
        end
        
        def import_export_columns
          @@import_export_columns
        end
        
        # takes complete path to csv file. 
        # if all records are created successfully then return true
        # otherwise returns array of feedback. each value represents the feedback for respective row in csv
        # sample feedback array : [true , true , [active_record error array...] , true]
        def importCSV(file_path , local_options = {})
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

          import_column_names = @@import_export_columns
          if local_options && local_options.has_key?(:import_columns)
            import_column_names = local_options[:import_columns]
          end
          
          if import_column_names.blank?
            raise "Please define import_export_columns property"
          end
          
          import_columns = {}

          import_column_names.each do |key|
            import_columns[key] = self.find_column_position(csv_table , key )
          end

          feedback = []
          records = []
          all_valid = true #assume all records are valid.

          csv_table.each_with_index do |row , index |
            if index > 0 # ignore first row because its meta data row
              record_info = {}
              import_columns.each do |key , val|
                if !val.blank? && val >= 0
                  record_info[key] = row[val]
                end
              end
              # make object
              record = self.new(record_info)
              records << record
              if record.valid?
                feedback << true
              else
                feedback << record.errors
                all_valid = false
              end
            end # if csv row index > 0   

          end #loop   

          if all_valid
            records.each do |record|
              record.save
            end
          end

          all_valid ? true : feedback
        end

        # csv_table is two dimentional array
        # col_name is a string.
        # if structure is proper and column name found it returns column index from 0 to n-1
        # otherwise nil
        def find_column_position(csv_table  , col_name)
          if csv_table.instance_of?(Array) && csv_table.count > 0 && csv_table.first.count > 0
            csv_table.first.each_with_index do |table_col , index|
              return index if table_col.to_s.upcase == col_name.to_s.upcase
            end
            nil
          else  
            nil
          end  
        end
        
        def exportCSV(all_records , local_options = {})
          export_column_names = @@import_export_columns
          if local_options && local_options.has_key?(:export_columns)
            export_column_names = local_options[:export_columns]
          end
          
          if export_column_names.blank?
            raise "Please define export_column_names property"
          end
          
          csv_class_name = nil
          if RUBY_VERSION >= "1.9"
            require 'csv'
            csv_class_name = CSV
          else
            csv_class_name = FasterCSV
          end
          
          csv_string = csv_class_name.generate do |csv|
              csv << export_column_names.collect{|c| c.humanize}

              all_records.each do |record|
                  row = []
                  export_column_names.each do |column|
                    row << record.send(column)
                  end
                  csv << row
              end        
          end
          
          csv_string
        end
        
      end
      
      module InstanceMethods
        
      end
      
    end
  end
end

