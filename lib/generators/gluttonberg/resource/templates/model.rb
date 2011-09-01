class <%= class_name %> < ActiveRecord::Base
  include Gluttonberg::Content::Publishable
  import_export_csv(<%=attributes.collect{|attr| "#{attr.name}"} %>)
  <%if draggable? %>
  is_drag_tree :flat => true , :order => "position"
  <%end%>
  def title_or_name?
    <% if attributes.find{|attr| attr.name == "name"}.blank?  %>
      <% if attributes.find{|attr| attr.name == "title"}.blank?  %>  
      id
      <%else%>
      title
      <%end%>  
    <%else%>
    name
    <%end%>  
  end
  
end