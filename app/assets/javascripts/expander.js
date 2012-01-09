
// Automatically create expanders
$(document).ready(function(){
  
  $(".expandable").each(function(){
		var expandable = new Expander( $(this) );
  });
  
});

var Expander = function( expandable ){
  
  var DEBUG_MODE = false;
  var SLIDE_TIME = 300;
  
  var thisExpandable = this;
  
  var expandButton = $(expandable);
  if( expandButton.length <= 0 ){
    if( DEBUG_MODE ){
      window.alert("Expander: No expand button found.");
    }
    return false;
  }
  if( expandButton.length > 1 ){
    if( DEBUG_MODE ){
      window.alert("Expander: More than one expand button found.");
    }
    return false;
  }
  
  var toggledElements = $("" + expandButton.attr("rel"));
  if( toggledElements <= 0 ){
    if( DEBUG_MODE ){
      window.alert("Expander: No expandable elements linked to the expand button.");
    }
    return false;
  }
  
  this.collapse = function( time ){
    
    if( time < 0 ){
      time = SLIDE_TIME;
    }
    expandButton.removeClass("expanded");
    expandButton.addClass("collapsed");
    toggledElements.hide();//slideUp( time );
  }
  
  this.expand = function( time ){
    
    if( time < 0 ){
      time = SLIDE_TIME;
    }
    expandButton.addClass("expanded");
    expandButton.removeClass("collapsed");
    toggledElements.show();//slideDown( time );
  }
  
  if( expandButton.hasClass("expanded") ){
    expandButton.removeClass("collapsed");
    this.expand(0);
  }
  
  if( expandButton.hasClass("collapsed") ){
    this.collapse(0);
  }
  
  if( !expandButton.hasClass("expanded") &&
      !expandButton.hasClass("collapsed") ){
    this.collapse(0);
  }
  
  expandButton.click( function(){
    if( expandButton.hasClass("expanded") ){
      thisExpandable.collapse();
    }else{
      thisExpandable.expand();
    }
  });
}