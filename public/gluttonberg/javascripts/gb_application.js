// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
$(document).ready(function() {

  $("#tabs").tabs();
  
  setHeightForLeftNav();

  dragTreeManager.init();

  $("#wrapper p#contextualHelp a").click(Help.click);

  initClickEventsForAssetLinks($("body"));

  init_tag_area();

  initSlugManagement();

  init_sub_nav(); 

  init_setting_dropdown_ajax();

  if ($('table').length > 0) {
    $('table').find('tr:last').css('background-image', 'none !important');
  }

  $("form.validation").validate();

  init_flash_messages();
  initPublishedDateTime();

});

function setHeightForLeftNav(){
	try{
	  new_height = $("body").height();
	  if(new_height < $(window).height() )
	  	new_height = $(window).height() 
	  $("#sidebar").height(new_height);
	}catch(e){}
}

function enable_jwysiwyg_on(selector) {
  $(document).ready(function() {
    $(selector).tinymce({
      // Location of TinyMCE script
      script_url: '/gluttonberg/javascripts/tiny_mce/tiny_mce.js',

      // General options
      theme: "advanced",
      plugins: "autolink,lists,style,table,advhr,advimage,advlink,gb_assets,inlinepopups,insertdatetime,preview,paste,fullscreen,advlist,wordcount",

      // Theme options
      theme_advanced_buttons1: "gb_assets,newdocument,|,bold,italic,underline,|,justifyleft,justifyright,styleselect,formatselect,|,attribs,removeformat,cleanup,code",
      theme_advanced_buttons2: "pastetext,pasteword,|,bullist,numlist,|,blockquote,|,undo,redo,|,link,unlink,anchor,|,insertdate,inserttime|,advhr,",
      theme_advanced_buttons3: "tablecontrols,|,fullscreen,preview",
      theme_advanced_toolbar_location: "top",
      theme_advanced_toolbar_align: "left",
      theme_advanced_statusbar_location: "bottom",
      theme_advanced_resizing: true,
      plugin_insertdate_dateFormat: "%d/%m/%Y",
      plugin_insertdate_timeFormat: "%H:%M:%S",
      theme_advanced_resizing_use_cookie: false,
			width: get_wysiwyg_width(selector),

      // Example content CSS (should be your site CSS)
      content_css: "/stylesheets/user-styles.css"

    });

  });
}

function get_wysiwyg_width(selector){
	if($(selector).attr('width')){
		return $(selector).attr('width')
	} else {
		return null;
	}
}



// This method initialize slug related event on a title text box.
function initSlugManagement() {
  try {
    var pt = $('#page_title');
    var ps = $('#page_slug');

    var regex = /[\!\*'"″′‟‛„‚”“”˝\(\);:.@&=+$,\/?%#\[\]]/gim;

    var pt_function = function() {
      if (ps.attr('donotmodify') != 'true') ps.attr('value', pt.attr('value').toLowerCase().replace(/\s/gim, '_').replace(regex, ''));
    };

    pt.bind("keyup", pt_function);
    pt.bind("blur", pt_function);

    ps.bind("blur", function() {
      ps.attr('value', ps.attr('value').toLowerCase().replace(/\s/gim, '_').replace(regex, ''));
      ps.attr('donotmodify', 'true');
    });
  } catch(e) {
    console.log(e)
  }
}

// input/textarea tags with .tags class will be initlized as
function init_tag_area() {
  try {
    $('.tags').tagarea({
      separator: ','
    });
  } catch(e) {
    console.log(e)
  }
}

// if container element has class "add_to_photoseries" , it returns html of new image
function initClickEventsForAssetLinks(element) {
  element.find(".assetBrowserLink a.choose_button").click(function(e) {
    var p = $(this).parent();
    var link = $(this);
    AssetBrowser.showOverlay()
    $.get(link.attr("href"), null, function(markup) {
      AssetBrowser.load(p, link, markup);
    });
    e.preventDefault();
  });

}

// Common utility functions shared between the different dialogs.
var Dialog = {
  center: function() {
    var offset = $(document).scrollTop();
    for (var i = 0; i < arguments.length; i++) {
      arguments[i].css({
        top: offset + "px"
      });
    };
  },
  PADDING_ATTRS: ["padding-top", "padding-bottom"],
  resizeDisplay: function(object) {
    // Get the display and the offsets if we don't have them
    if (!object.display) object.display = object.frame.find(".display");
    if (!object.offsets) object.offsets = object.frame.find("> *:not(.display)");
    var offsetHeight = 0;
    object.offsets.each(function(i, node) {
      offsetHeight += $(node).outerHeight();
    });
    // Get the padding for the display
    if (!object.displayPadding) {
      object.displayPadding = 0
      for (var i = 0; i < this.PADDING_ATTRS.length; i++) {
        object.displayPadding += parseInt(object.display.css(this.PADDING_ATTRS[i]).match(/\d+/)[0]);
      };
    }
    object.display.height(object.frame.innerHeight() - (offsetHeight + object.displayPadding));
  }
};

var AssetBrowser = {
  overlay: null,
  dialog: null,
  imageDisplay: null,
  Wysiwyg: null,
  logo_setting: false,
  filter: null,
  actualLink: null,
  link_parent: null,
  load: function(p, link, markup, Wysiwyg) {
    AssetBrowser.link_parent = p;
    AssetBrowser.actualLink = link;
    // it is required for asset selector in jWysiwyg
    AssetBrowser.Wysiwyg = null;
    if (Wysiwyg != undefined) {
      AssetBrowser.Wysiwyg = Wysiwyg;
    }
    // its used for category filtering on assets and collections  
    AssetBrowser.filter = $("#filter_" + $(link).attr("rel"));

    if ($(link).is(".logo_setting")) {
      AssetBrowser.logo_setting = true;
      AssetBrowser.logo_setting_url = $(link).attr("data_url");
    } else {
      AssetBrowser.logo_setting = false;
      AssetBrowser.logo_setting_url = "";
    }
    // Set everthing up
    AssetBrowser.showOverlay();
    $("body").append(markup);
    AssetBrowser.browser = $("#assetsDialog");
    try {
      AssetBrowser.target = $("#" + $(link).attr("rel"));
      AssetBrowser.imageDisplay = $("#image_" + $(link).attr("rel"));
      AssetBrowser.nameDisplay = $("#show_" + $(link).attr("rel"));
      if (AssetBrowser.nameDisplay !== null) {
        AssetBrowser.nameDisplay = p.find("span");
      }
    } catch(e) {
      AssetBrowser.target = null;
      AssetBrowser.nameDisplay = p.find("span");
    }

    // Grab the various nodes we need
    AssetBrowser.display = AssetBrowser.browser.find("#assetsDisplay");
    AssetBrowser.offsets = AssetBrowser.browser.find("> *:not(#assetsDisplay)");
    AssetBrowser.backControl = AssetBrowser.browser.find("#back a");
    AssetBrowser.backControl.css({
      display: "none"
    });
    // Calculate the offsets
    AssetBrowser.offsetHeight = 0;
    AssetBrowser.offsets.each(function(i, element) {
      AssetBrowser.offsetHeight += $(element).outerHeight();
    });
    // Initialize
    AssetBrowser.resizeDisplay();
    $(window).resize(AssetBrowser.resizeDisplay);
    // Cancel button
    AssetBrowser.browser.find("#cancel").click(AssetBrowser.close);
    // Capture anchor clicks
    AssetBrowser.display.find("a").click(AssetBrowser.click);
    $("#assetsDialog form#asset_search_form").submit(AssetBrowser.search_submit);
    AssetBrowser.backControl.click(AssetBrowser.back);

    AssetBrowser.browser.find("#ajax_image_upload").click(function(e) {
      ajaxFileUpload(link);
      e.preventDefault();
    })

    $("#assetsDialog").css({
      position: "absolute",
      top: (($(window).scrollTop())) + "px"
    })
    try {
      $("#assetsDialog form.validation").validate();
    } catch(e) {
      console.log(e)
    }

    $(window).resize(function(e) {
      $("#assetsDialog").css({
        position: "absolute",
        top: (($(window).scrollTop())) + "px"
      })

    })
  },
  resizeDisplay: function() {
    // var newHeight = AssetBrowser.browser.innerHeight() - AssetBrowser.offsetHeight;
    // AssetBrowser.display.height(newHeight);
  },
  showOverlay: function() {
    AssetBrowser.overlay = $("#assetsDialogOverlay");
    if (!AssetBrowser.overlay || AssetBrowser.overlay.length == 0) {
      var height = $('#wrapper').height() + 50;
      AssetBrowser.overlay = $('<div id="assetsDialogOverlay">&nbsp <img class="dialogue_spinner" src="/gluttonberg/images/spinner_for_dialouge.gif" /> </div>');
      $("body").append(AssetBrowser.overlay);
    } else {
      AssetBrowser.overlay.css({
        display: "block"
      });
    }
    set_height = wrapper_height = $("body").height();
    window_height = $(window).height() + $(window).scrollTop()
    if (set_height < window_height) set_height = window_height;
    $("#assetsDialogOverlay").height(set_height)

  },
  close: function() {
    AssetBrowser.overlay.css({
      display: "none"
    });
    AssetBrowser.browser.remove();
  },
  handleJSON: function(json) {
    if (json.backURL) {
      AssetBrowser.backURL = json.backURL;
      AssetBrowser.backControl.css({
        display: "block"
      });
    }
    AssetBrowser.updateDisplay(json.markup);
  },
  updateDisplay: function(markup) {
    AssetBrowser.display.html(markup);
    AssetBrowser.display.find("a").click(AssetBrowser.click);
    $('#tabs').tabs();
    try {
      $("form.validation").validate();
    } catch(ex) {}
    AssetBrowser.browser.find("#ajax_image_upload").click(function(e) {
      ajaxFileUpload(AssetBrowser.actualLink);
      e.preventDefault();
    })
  },
  search_submit: function(e) {
    $("#progress_ajax_upload").ajaxStart(function() {
      $(this).show();
    }).ajaxComplete(function() {
      $(this).hide();
    });
    var url = $("#assetsDialog form#asset_search_form").attr("action");
    url += ".json?" + $("#assetsDialog form#asset_search_form").serialize()
    $.getJSON(url, null, AssetBrowser.handleJSON);
    e.preventDefault();
  },
  click: function() {
    var target = $(this);
    if (target.is(".assetLink")) {
      var id = target.attr("href").match(/\d+$/);
      var name = target.find("h2").html();

      // assets only
      if (AssetBrowser.target !== null) {
        AssetBrowser.target.attr("value", id);
        var image = target.find("img");

        console.log(image)
        image_url = target.find(".jwysiwyg_image").val();
        insert_image_in_wysiwyg(image_url);

        AssetBrowser.nameDisplay.html(name);
        if (AssetBrowser.link_parent.find("img").length > 0) {
          console.log("--- step1")
          AssetBrowser.link_parent.find("img").attr('src', image.attr('src'))

        } else {
          AssetBrowser.link_parent.prepend("<img src='" + image.attr('src') + "' />")
        }
        //AssetBrowser.imageDisplay.html(image);

        auto_save_asset(AssetBrowser.logo_setting_url, id); //auto save if it is required
      } else {
        if (AssetBrowser.actualLink.hasClass("add_image_to_gallery")) {

          $.ajax({
            url: AssetBrowser.actualLink.attr("data_url"),
            data: 'asset_id=' + id,
            type: "GET",
            success: function(data) {
              $("#images_container").html(data);
              initEditGalleryList();
              dragTreeManager.init();
              AssetBrowser.close();
            },
            error: function(data) {
              AssetBrowser.close();
            }
          });
          //auto_save_asset_for_gallery(AssetBrowser.actualLink.attr("data_url") , id )
        }
      }

      AssetBrowser.close();
    } else if (target.parent().is(".pagination")) {
      if (target.attr("href") != '') {
        $.getJSON(target.attr("href"), null, AssetBrowser.handleJSON);
      }
    } else if (!target.is(".tab_link")) {
      $("#progress_ajax_upload").ajaxStart(function() {
        $(this).show();
      }).ajaxComplete(function() {
        $(this).hide();
      });

      var url = target.attr("href") + ".json";
      // its collection url then add category filter for filtering assets
      if (target.hasClass("collection")) {
        url += "?filter=" + AssetBrowser.filter.val();
      }
      $.getJSON(url, null, AssetBrowser.handleJSON);
    }
    return false;
  },
  back: function() {
    if (AssetBrowser.backURL) {
      var category = "";
      var show_content = ""
      // if filter exist then apply it on backurl
      if (AssetBrowser.filter !== null) {
        if (AssetBrowser.filter == undefined || AssetBrowser.filter.length == 0) {
          if (AssetBrowser.Wysiwyg != null) category = "&filter=image";
        } else category = "&filter=" + AssetBrowser.filter.val();
      }
      $.get(AssetBrowser.backURL + category + show_content, null, AssetBrowser.updateDisplay);
      AssetBrowser.backURL = null;
      AssetBrowser.backControl.css({
        display: "none"
      });
    }
    return false;
  }

};


function insert_image_in_wysiwyg(image_url) {
  if (AssetBrowser.Wysiwyg != undefined && AssetBrowser.Wysiwyg !== null) {
    Wysiwyg = AssetBrowser.Wysiwyg;
    title = ""
    description = "";
    style = "";
    image = "<img src='" + image_url + "' title='" + title + "' alt='" + description + "'" + style + "/>";

    Wysiwyg.execCommand('mceInsertContent', false, image);

  }
}


function auto_save_asset(url, new_id) {
  // HACK FOR LOGO SETTINGS
  if (AssetBrowser.logo_setting != undefined && AssetBrowser.logo_setting != null && AssetBrowser.logo_setting == true) {
    //data_id = data_id;
    new_value = new_id;

    $.ajax({
      url: url,
      data: 'gluttonberg_setting[value]=' + new_value,
      type: "PUT",
      success: function(data) {}
    });
  }
}

// Help Browser
// Displays the help in an overlayed box. Intended to be used for contextual
// help initially.
var Help = {
  load: function(url) {
    $.get(url, null, function(markup) {
      Help.show(markup)
    });
  },
  show: function(markup) {
    this.buildFrames();
    this.frame.html(markup)
    this.frame.find("a#closeHelp").click(this.close);
    var centerFunction = function() {
      Dialog.center(Help.frame, Help.overlay);
      Dialog.resizeDisplay(Help);
    };
    $(window).resize(centerFunction);
    $(document).scroll(centerFunction);
    centerFunction();
  },
  close: function() {
    Help.display = null;
    Help.offsets = null;
    Help.displayPadding = null;
    Help.frame.hide();
    Help.overlay.hide();
    return false;
  },
  click: function(e) {
    Help.load(this.href);
    return false;
  },
  buildFrames: function() {
    if (!this.overlay) {
      this.overlay = $('<div id="overlay">&nbsp</div>');
      $("body").append(this.overlay);
      this.frame = $('<div id="helpDialog">&nbsp</div>');
      $("body").append(this.frame);
    } else {
      this.overlay.show();
      this.frame.show();
    }
  }
};

// Collapsible sub navigation functionality
function init_sub_nav() {
  if ($('#navigation ul a.active').length > 0) {
    $('#navigation ul a.active').parent().parent().parent().addClass('active_parent');
    $('#navigation ul a.active').parent().parent().parent().find('a.nav_trigger').addClass('open');
  } else {
    $('#navigation a.active').parent().addClass('active_parent');
    $('#navigation a.active').parent().find('a.nav_trigger').addClass('open');
  }
  $('#navigation a.nav_trigger').click(function() {
    $(this).next().slideToggle('fast');
    $(this).toggleClass('open');
  });
}



function init_setting_dropdown_ajax() {
  $(".setting_dropdown").change(function() {
    url = $(this).attr("rel");
    id = $(this).attr("data_id");
    new_value = $(this).val()

    $("#progress_" + id).show("fast")

    $.ajax({
      url: url,
      data: 'gluttonberg_setting[value]=' + new_value,
      type: "PUT",
      success: function(data) {
        $("#progress_" + id).hide("fast")
      }
    });

  });
  init_home_page_setting_dropdown_ajax();
}



function init_home_page_setting_dropdown_ajax() {
  $(".home_page_setting_dropdown").change(function() {
    url = $(this).attr("rel");
    id = "home_page"
    new_value = $(this).val()

    $("#progress_" + id).show("fast")

    $.ajax({
      url: url,
      data: 'home=' + new_value,
      type: "POST",
      success: function(data) {
        $("#progress_" + id).hide("fast")
      }
    });

  })

}



function ajaxFileUpload(link) {
  //starting setting some animation when the ajax starts and completes
  $("#loading").ajaxStart(function() {
    $(this).show();
  }).ajaxComplete(function() {
    $(this).hide();
  });
  link = $(link);

  $("#progress_ajax_upload").show();

  asset_name = $('input[name$="asset[name]"]').val();
  var formData = {
    "asset[name]": asset_name,
    "asset[asset_collection_ids]": $("#asset_asset_collection_ids").val(),
    "new_collection[new_collection_name]": $('input[name$="new_collection[new_collection_name]"]').val()
  }

  /*
        prepareing ajax file upload
        url: the url of script file handling the uploaded files
                    fileElementId: the file type of input element id and it will be the index of  $_FILES Array()
        dataType: it support json, xml
        secureuri:use secure protocol
        success: call back function when the ajax complete
        error: callback function when the ajax failed
        
            */
  $.ajaxFileUpload({
    url: '/admin/add_asset_using_ajax',
    secureuri: false,
    fileElementId: 'asset_file',
    dataType: 'json',
    data: formData,
    success: function(data, status) {
      if (typeof(data.error) != 'undefined') {
        if (data.error != '') {
          console.log(data.error);
        } else {
          console.log(data.msg);
        }
      }

      new_id = data["asset_id"]
      file_path = data["url"]
      jwysiwyg_image = data["jwysiwyg_image"];

      $("#" + link.attr('rel')).val(new_id);
      $("#title_thumb_" + link.attr('rel')).html("<img src='" + file_path + "' /> " + asset_name);

      insert_image_in_wysiwyg(jwysiwyg_image);

      data_id = $(this).attr("data_id");
      url = AssetBrowser.logo_setting_url;
      auto_save_asset(url, new_id); // only if autosave is required
      AssetBrowser.close();
    },
    error: function(data, status, e) {
      console.log(data);
      console.log(e);
    }
  })

  return false;

}



function initJcrop(image_type, w, h) {
  $('#' + image_type + "_image").Jcrop({
    aspectRatio: 0,
    onSelect: function(c) {
      $('#' + image_type + '_x').val(c.x);
      $('#' + image_type + '_y').val(c.y);
      $('#' + image_type + '_w').val(c.w);
      $('#' + image_type + '_h').val(c.h);
    },
    setSelect: [0, 0, w, h],
    minSize: [w, h],
    maxSize: [w, h]
  });
}



function updateCoords(c) {

};



function init_flash_messages() {
  $('#flash:empty').hide()
  setTimeout(function() {
    $('#flash_notice').fadeOut('slow');
  },
  5000);
}



function initPublishedDateTime() {

  // $('.publish_datetime').datetimepicker({
  //     dateFormat: 'dd/mm/yy',
  //     timeFormat: 'hh:mm TT',
  //     separator: ' ',
  //     ampm: true,
  //     firstDay: 1
  // 
  //   });
  $(".publishing_state").change(function(){
    updatePublishedDateField()
  })
  
  function updatePublishedDateField(){
    console.log($(".publishing_state").val())
    if($(".publishing_state").val()=="published"){
      $(".published_at").show()
    }else{
      $(".published_at").hide()
    }
  }
  updatePublishedDateField()
}



function initEditGalleryList() {
  $(".delete_gallery_item").click(delete_event_handler_for_gallery_list)

}



function delete_event_handler_for_gallery_list() {
  id = $(this).attr("rel")
  $("#progress_" + id).show("fast")
  $.ajax({
    url: $(this).attr("data-url"),
    type: "GET",
    success: function(data) {
      $("#node-" + id).remove();
    }
  });
}
