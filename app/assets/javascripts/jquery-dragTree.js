/*
 *
 * jQuery dragTree Plugin 1.0. Built for Gluttonberg CMS system
 * 
 * 
 * Orginal treetable code based onjQuery treeTable Plugin 2.1 -
 * http://ludo.cubicphuse.nl/jquery-plugins/treeTable/
 * The orginal code has been significantly modified.
 *
 *
 * Call dragTreeManager.init() in your Javaascript once to initialise all
 * Drag Trees
 *
 * To make a table into a DragTree you need to do the following:
 *  - set the CSS class of the table to "drag-tree"
 *  - set the CSS of the element in the cell that is to be used for
 *    dragging to drag-node
 *
 *  - during drag operations the following CSS classes are applied
 *    to the tr of the target row:
 *    "insert_child": when mouse if over the row and the source will be made a child of the target
 *    "insert_before": when mouse is at the "top" part of the target row and source will be insert before this row
 *    "insert_after": when mouse id at the "bottom" part of the target row and source will be inserted after (or as child) of this row
 *
 *  - Set each tr in the table to have a CSS ID of
 *    "node-<x>" where <x> is a unique integer value
 *
 *  - To make a tree set a row's css to the following class
 *     "child-of-<x>" where <x> is the number assigned to the
 *     nodes parent in the CSS ID "node-<x>"
 *
 */

(function($) {
	// Helps to make options available to all functions
	// TODO: This gives problems when there are both expandable and non-expandable
	// trees on a page. The options shouldn't be global to all these instances!
	var options;
	
	$.fn.treeTable = function(opts) {
		options = $.extend({}, $.fn.treeTable.defaults, opts);
		
		return this.each(function() {
			$(this).addClass("treeTable").find("tbody tr").each(function() {
				// Initialize root nodes only whenever possible
				if(!options.expandable || $(this)[0].className.search("child-of-") == -1) {
					initialize($(this));
				}
			});
		});
	};
	
	$.fn.treeTable.defaults = {
		childPrefix: "child-of-",
		expandable: true,
		indent: 19,
		initialState: "collapsed",
		treeColumn: 0
	};
	
	// Recursively hide all node's children in a tree
	$.fn.collapse = function() {
		$(this).addClass("collapsed");

		childrenOf($(this)).each(function() {
			if(!$(this).hasClass("collapsed")) {
				$(this).collapse();
			}
			
			$(this).hide();
		});
		
		return this;
	};
	
	// Recursively show all node's children in a tree
	$.fn.expand = function() {
		$(this).removeClass("collapsed").addClass("expanded");
		
		childrenOf($(this)).each(function() {
			initialize($(this));
						
			if($(this).is(".expanded.parent")) {
				$(this).expand();
			}
			
			$(this).show();
		});
		
		return this;
	};
	
	// Add an entire branch to +destination+
	$.fn.appendBranchTo = function(destination, success_callback) {
		var node = $(this);
		var parent = parentOf(node);
		
		var ancestorNames = $.map(ancestorsOf($(destination)), function(a) { return a.id; });
			
		// Conditions:
		// 1: +node+ should not be inserted in a location in a branch if this would
		//    result in +node+ being an ancestor of itself.
		// 2: +node+ should not have a parent OR the destination should not be the
		//    same as +node+'s current parent (this last condition prevents +node+
		//    from being moved to the same location where it already is).
		// 3: +node+ should not be inserted as a child of +node+ itself.
		if($.inArray(node[0].id, ancestorNames) == -1 && (!parent || (destination.id != parent[0].id)) && destination.id != node[0].id) {
			indent(node, ancestorsOf(node).length * options.indent * -1); // Remove indentation
			
			if(parent) { node.removeClass(options.childPrefix + parent[0].id); }
			
			node.addClass(options.childPrefix + destination.id);
			move(node, destination); // Recursively move nodes to new location
			indent(node, ancestorsOf(node).length * options.indent);

      if (success_callback) {
        success_callback.call();
      }
		}

		return this;
	};

  $.fn.insertBranchAfter = function(destination, success_callback) {
    insertBranchBeforeOrAfter(this, destination, false, success_callback);
  }

  $.fn.insertBranchBefore = function(destination, success_callback) {
    insertBranchBeforeOrAfter(this, destination, true, success_callback);
  }
	
	// Add reverse() function from JS Arrays
	$.fn.reverse = function() {
	  return this.pushStack(this.get().reverse(), arguments);
	};

	// Toggle an entire branch
	$.fn.toggleBranch = function() {
		if($(this).hasClass("collapsed")) {
			$(this).expand();
		}	else {
			$(this).removeClass("expanded").collapse();
		}

		return this;
	};
	
	// === Private functions

  insertBranchBeforeOrAfter = function(source, destination, before, success_callback) {
		var sourceNode = $(source);
    var targetNode = $(destination);
    var targetParent = undefined;

    // if we are inserting after a node and that node has children, we are actually
    // reparenting to that node.
    if (!before && hasChildren(targetNode)){
      targetParent = targetNode;
    } else {
      targetParent = parentOf(targetNode);
    }

		var sourceParent = parentOf(sourceNode);    
    var needsIndenting = false;

    if(nodeNotInDestinationAncestry(sourceNode, targetNode) && nodesDifferent(targetNode, sourceNode)) {
      if (nodesDifferent(sourceParent, targetParent)){
        // The nodes have different parents so reparent the node
        indent(sourceNode, ancestorsOf(sourceNode).length * options.indent * -1); // Remove indentation
        needsIndenting = true;
        if (sourceParent) {sourceNode.removeClass(options.childPrefix + sourceParent[0].id); }
        if (targetParent) {sourceNode.addClass(options.childPrefix + targetParent[0].id);}
      }

      // move node
      if (before) {
        moveBefore(sourceNode, destination); // Recursively move nodes to new location
      } else {
        move(sourceNode, destination); // Recursively move nodes to new location
      }

      if (needsIndenting){
        // the parent was changed so re-apply indentation
        indent(sourceNode, ancestorsOf(sourceNode).length * options.indent);
      }

      if (success_callback) {
        success_callback.call();
      }
		}
    return this;
  }

  function nodeNotInDestinationAncestry(node, destination){
    var ancestorNames = $.map(ancestorsOf(destination), function(a) { return a.id; });
    return $.inArray(node[0].id, ancestorNames) == -1;
  }

  function nodesSame(nodeA, nodeB){
    if (nodeA && nodeB){
      return (nodeA[0].id == nodeB[0].id);
    } else {
      return (nodeA == nodeB)
    }
  }

  function nodesDifferent(nodeA, nodeB){
    return !(nodesSame(nodeA, nodeB));
  }
	
	function ancestorsOf(node) {
		var ancestors = [];
		while(node = parentOf(node)) {
			ancestors[ancestors.length] = node[0];
		}
		return ancestors;
	};
	
	function childrenOf(node) {
		return $("table.treeTable tbody tr." + options.childPrefix + node[0].id);
	};

	function indent(node, value) {
		var cell = $(node.children("td")[options.treeColumn]);
		var padding = parseInt(cell.css("padding-left"), 10) + value;

		cell.css("padding-left", + padding + "px");
		
		childrenOf(node).each(function() {
			indent($(this), value);
		});
	};

  function hasChildren(node){
    var childNodes = childrenOf(node);
    return childNodes.length > 0;
  }

	function initialize(node) {
		if(!node.hasClass("initialized")) {
			node.addClass("initialized");

			var childNodes = childrenOf(node);
		
			if(!node.hasClass("parent") && childNodes.length > 0) {
				node.addClass("parent");
			}

			if(node.hasClass("parent")) {
				var cell = $(node.children("td")[options.treeColumn]);
				var padding = parseInt(cell.css("padding-left"), 10) + options.indent;

				childNodes.each(function() {
					$($(this).children("td")[options.treeColumn]).css("padding-left", padding + "px");
				});
			
				if(options.expandable) {
					cell.prepend('<span style="margin-left: -' + options.indent + 'px; padding-left: ' + options.indent + 'px" class="expander"></span>');
					$(cell[0].firstChild).click(function() { node.toggleBranch(); });
				
					// Check for a class set explicitly by the user, otherwise set the default class
					if(!(node.hasClass("expanded") || node.hasClass("collapsed"))) {
					  node.addClass(options.initialState);
					}

					if(node.hasClass("collapsed")) {
						node.collapse();
					} else if (node.hasClass("expanded")) {
						node.expand();
					}
				}
			}
		}
	};
	
	function move(node, destination) {
		node.insertAfter(destination);
		childrenOf(node).reverse().each(function() { move($(this), node[0]); });
	};

	function moveBefore(node, destination) {
		node.insertBefore(destination);
		childrenOf(node).reverse().each(function() { move($(this), node[0]); });
	};
	
	function parentOf(node) {
		var classNames = node[0].className.split(' ');
		
		for(key in classNames) {
			if(classNames[key].match("child-of-")) {
				return $("#" + classNames[key].substring(9));
			}
		}
	};
})(jQuery);

DM_NONE          = null;
DM_INSERT_BEFORE = {};
DM_INSERT_AFTER  = {};
DM_INSERT_CHILD  = {};

var dragTreeManager = {
  init: function(){

    var dragManager = {
      dropSite: null,
      dragMode: DM_NONE
    };

    // Look for all tables with a class of 'drag_tree' and make them
    // into dragtrees
    $(".drag-tree").each(function(index){

      var dragTree = $(this);

      var dragFlat = $(this).hasClass('drag-flat');
      
      try{
        dragTree.treeTable({expandable: false});
      }catch(e){
        console.log("---- exception --- ");
        console.log(e);
      }  
      
      
      var remote_move_node = function(source, destination, mode){
        
        var ids = get_sorted_element_ids(".drag-tree").toString();
        $.ajax({
            type: "POST",
            url: dragTree.attr("rel"),
            data: "element_ids=" + ids,
            beforeSend: function(jqXHR, settings){
              showOverlay()
            },
            success: function(html){
              hideOverlay()
            },
            error: function(html){
              
              $("#assetsDialogOverlay").html(html.responseText);
              // window.location.reload(); 
              window.setTimeout(function(){
                hideOverlay()
              },10000) 
              
              
            }
        });
        
        
      }
    
    // Configure draggable rows
    try{
      dragTree.find(".drag-node").draggable({
        helper: "clone",
        opacity: .75,
        revert: "invalid",
        revertDuration: 300,
        scroll: true,
        drag: function(e, ui){
          if (dragManager.dropSite) {
            //var top = dragManager.dropSite.offset({padding: true, border: true, margin: true}).top;
            var top = dragManager.dropSite.offset().top ;
            var height = dragManager.dropSite.outerHeight({padding: false, border: false, margin: true});
                        
            
            var mouseTop = e.pageY;
            var topOffset = 10;
            var bottomOffset = 10;

            if (dragFlat) {
              topOffset = height / 2;
              bottomOffset = height / 2;
            }
            
            $("#"+$(this).attr('rel')).addClass("ui-draggable-dragging")
            

            if( dragManager.dropSite.attr('id') != $(this).attr('rel')){
              if (mouseTop < (top + topOffset)){
                dragManager.dropSite.addClass("insert_before").removeClass("insert_child insert_after");
                dragManager.dragMode = DM_INSERT_BEFORE;
              } else if (mouseTop > (top + height - bottomOffset)) {
                dragManager.dropSite.addClass("insert_after").removeClass("insert_before insert_child");
                dragManager.dragMode = DM_INSERT_AFTER;
              } else {
                if (!dragFlat){
                  dragManager.dropSite.addClass("insert_child").removeClass("insert_after insert_before");
                  dragManager.dragMode = DM_INSERT_CHILD;
                }
              }
            }else{//self node check  
              dragManager.dropSite.removeClass("insert_child insert_after insert_before");
            }
          }
        }
      });
      
    }catch(e){
      console.log("---- exception2 --- ");
      console.log(e);
    }  

    
    try{
      // Configure droppable rows
      dragTree.find(".drag-node").each(function() {
        $(this).parents("tr").droppable({
          accept: ".drag-node:not(selected)",
          drop: function(e, ui) {
            
            
            var sourceNode = $(ui.draggable).parents("tr")
            var targetNode = this;
            
            sourceNode.removeClass("ui-draggable-dragging")

            if ((dragManager.dragMode == DM_INSERT_CHILD) && (!dragFlat)) {
              $(sourceNode).appendBranchTo(targetNode,
                function(){
                  remote_move_node(sourceNode, targetNode, 'INSERT');
                }
              );
            }
            if (dragManager.dragMode == DM_INSERT_BEFORE) {
              $(sourceNode).insertBranchBefore(targetNode,
                function(){
                  remote_move_node(sourceNode, targetNode, 'BEFORE');
                }
              );
            }
            if (dragManager.dragMode == DM_INSERT_AFTER) {
              $(sourceNode).insertBranchAfter(targetNode,
                function(){
                  remote_move_node(sourceNode, targetNode, 'AFTER');
                }
              );
            }

            $(sourceNode).effect("highlight", {}, 2000);
            dragTree.find("tr").removeClass("insert_child insert_before insert_after");
            dragManager.dropSite = null;
            dragManager.dragMode = DM_NONE;
          },
          hoverClass: "accept",
          over: function(e, ui) {
            
            element = $(this); //ui.draggable.parent();
            
            if (element.parents("tr") != dragManager.dropSite) {
              dragManager.dropSite = element;
            }
            // Make the droppable branch expand when a draggable node is moved over it.
            if(this.id != ui.draggable.parents("tr")[0].id && !$(this).is(".expanded")) {
              $(this).expand();
            }
          },
          out: function(e, ui){
            element = $(this);
            element.removeClass("insert_child insert_before insert_after");
            if (dragManager.dropSite == element) {
              dragManager.dropSite = null;
              dragManager.dragMode = DM_NONE;
            }
          }
        });
      });
    
    }catch(e){
      console.log("---- exception 3--- ");
      console.log(e);
    }  

      // Make visible that a row is clicked
      dragTree.find("tbody tr").mousedown(function() {
          $("tr.selected").removeClass("selected"); // Deselect currently selected rows
          $(this).addClass("selected");           
      });

      // Make sure row is selected when span is clicked
      dragTree.find("tbody tr span").mousedown(function() {
        $($(this).parents("tr")[0]).trigger("mousedown");
      });
    });

  }
}

// it take ids of all ".orderable-list-item" inside container (wrapper_id)
// and returns array of all ids
function get_sorted_element_ids(wrapper_id)
{	
	 try{	
			var items = $(wrapper_id).find("tbody tr");
			items = $.map(items, function(value){
				return value.id.replace("node-","");
			});
			return items;
	 }catch(e){}		
}


function showOverlay() {
    if ($("#assetsDialogOverlay").length == 0) {
        var height = $('#wrapper').height() + 50;
        AssetBrowser.overlay = $('<div id="assetsDialogOverlay">&nbsp <img class="dialogue_spinner" src="/assets/spinner_for_dialouge.gif" /> </div>');
        $("body").append(AssetBrowser.overlay);
    }
    else {
        $("#assetsDialogOverlay").css({
            display: "block"
        });
    }
    set_height = wrapper_height = $("body").height();
    window_height = $(window).height() + $(window).scrollTop()
    if(set_height < window_height)
      set_height = window_height;
    $("#assetsDialogOverlay").height(  set_height )
    
}

function hideOverlay(){
  $("#assetsDialogOverlay").remove();
}