module Gluttonberg
  module DragTree
    module ActionView
      module Helpers
        

        def drag_tree_url(klass = self.class)          
          controller_class = controller.class          
          if controller_class.respond_to?(:drag_tree_route_name) then
            url_for(controller_class.drag_tree_route_name)
          else
            ''
          end          
        end
        

        def drag_tree_table_class(klass = self.class)
          # drag-tree treeTable
          controller_class = controller.class
          css_class_str = ''
          if controller_class.respond_to?(:drag_class) then
            if controller_class.drag_class then
              if controller_class.drag_class.respond_to?(:behaves_as_a_drag_tree) then
                css_class_str = 'drag-tree'
                if controller_class.drag_class.behaves_as_a_flat_drag_tree then
                  css_class_str = css_class_str + ' drag-flat'
                end
              end
            end
          end
          css_class_str
        end

        def drag_tree_row_class(model)
          css_class_str = ''
          if model.class.respond_to?(:behaves_as_a_drag_tree) then
            css_class_str = 'node-pos-' + model.position.to_s
            if !model.class.behaves_as_a_flat_drag_tree then
              if model.parent_id then
                css_class_str = css_class_str + ' child-of-node-' + model.parent_id.to_s
              end
            end
          end
          css_class_str
        end

        def drag_tree_drag_point_class
          'drag-node'
        end

        def drag_tree_row_id(model)
          "node-#{model.id}"
        end
        
      
      end
    
    end
  end #DragTree
end  #Gluttonberg