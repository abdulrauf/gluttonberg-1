class Create<%= class_name %> < ActiveRecord::Migration
  
  def self.up
    create_table :<%= table_name %> do |t|
  <% attributes.each do |attribute| -%>
    t.<%= attribute.type %> :<%= attribute.name %>
  <% end -%>
    t.integer :position
    t.column :state , :string #use for publishing
    t.datetime :published_at 
    t.timestamps
    end
  end
  
  def self.down
    drop_table :<%= table_name %>
  end
  
end