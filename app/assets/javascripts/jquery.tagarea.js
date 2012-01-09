/**
* Description: jQuery plugin that makes a textarea/input act like the tumblr tag area
* More_info: http://bitbucket.org/leecaine/tagarea & Check Examples.html
* Author: Lee Caine -- http://filthyweasel.co.uk
* 
* License: 
* 
* 	Copyright (c) 2009 Lee Caine
*
*	Permission is hereby granted, free of charge, to any person obtaining a copy
*	of this software and associated documentation files (the "Software"), to deal
*	in the Software without restriction, including without limitation the rights
*	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
*	copies of the Software, and to permit persons to whom the Software is
*	furnished to do so, subject to the following conditions:
*
*	The above copyright notice and this permission notice shall be included in
*	all copies or substantial portions of the Software.
*
*	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
*	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
*	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
*	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
*	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
*	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
*	THE SOFTWARE.
* 
**/

(function($) {
	$.fn.tagarea = function(options) {
		/**
		 * Settings for tagarea, extended with
		 * users options
		 **/
		var settings = $.extend(true, {
			//The separator to use to create the tags
			separator: ' ',		
			content: {
				//Banned characters(user can not type them)   1234567890
				banned: '!@#$%^&*()_+=-~`<>?,./\\"\':;}{[]|',
				closeBttn: 'x', //Text of the close bttn
				//Min length of a tag(pressing separator with a tag
				//less than this will not create the tag!
				minLength: 3,
				//Once maxLength has been reached, all key presses
				//except spearator will be ignored
				maxLength: 25
			},
			animate: true, //Animate(removal of tags)
			style: { //Styles
				area: { //The 'textarea' created by the plugin
					className: '', 
					css: {
						fontSize: '14px',
						fontFamily: 'Verdana, arial',
						width: '408px',
						height: '120px',
						padding: '0px 0px 8px 8px',
						border: 'none',
						overflow: 'auto'
					}
				},
				tags: { //All the tags
					className: '',
					css: {
						'float': 'left',
						padding: '5px',
						backgroundColor: '#cdeb8b',
						margin: '8px 8px 0px 0px',
						fontFamily: 'verdana, arial',
						fontSize: '15px',
						color: '#333333',
						'-moz-border-radius': '2px'
					}
				},
				closeBttn: { //The close button
					className: '',
					css: {
						fontFamily: 'monospace',
						backgroundColor: '#999999',
						color: '#333333',
						textDecoration: 'none',
						marginLeft: '5px',
						cursor: 'pointer',
						padding: '0px 3px 0px 3px',
						'-moz-border-radius': '2px'
					}
				},
				field: { //The field is the input field created after all the tags
					className: '',
					css: {
						float: 'left',
						border: 'solid 1px',
						margin: '8px',
						fontSize: '18px' , 
						width: '50px'
					}
				}
			},
			events: { //Event handlers users can define
				area: { //The 'textarea'
					beforeRender: function(area) {},
					afterRender: function(area) {}
				},
				tags: { //Each and every tag
					beforeRender: function(tag) {},
					afterRender: function(tag) {},
					beforeRemove: function(tag) {},
					afterRemove: function(tag) {}
				},
				field: {//The text input that is created everytime the tagarea is clicked
					beforeRender: function(field) {},
					afterRender: function(field) {},
					beforeRemove: function(field) {}
				}
			}
		}, options);
		/**
		 * Updates the value of the original field to match
		 * all the current tags, separated by the specified
		 * separator
		 **/
		var updateOriginal = function(tagarea, original) {
			//Get the text from all the tags...
			var newVal = '';
			var tags = tagarea.children('span');
			tags.each(function() {
				//First span tag contains the tag text we require..
				var tag = $(this).children('span').eq(0).text();
				newVal += (tag + settings.separator);
			});
			//Remove separator from the end..
			newVal = newVal.substring(0, newVal.length - settings.separator.length);
			//Input or textarea??
			try {
				original.val(newVal);
			}catch(e) {
				original.text(newVal);
			}
		};
		/**
		* Creates a tag in the specified tagarea when the
		* separator is typed
		**/
		var createTag = function(tagarea, field, original) {
			var val = field.val();
			
			if(val == "")
				return "";
			
			var tag = $('<span>');			
			//Set user defined styles			
			tag.attr('class', settings.style.tags.className);
			tag.css(settings.style.tags.css);
			var text = $('<span>');			
			text.text(val);
			tag.append(text);
			//Invoke user defined event
			settings.events.tags.beforeRender(tag);
			//Add the 'x'(close) button to the tag..
			var close = $('<span>');
			close.css(settings.style.closeBttn.css);
			close.text(settings.content.closeBttn);
			close.click(function() {
				//Remove tag span..
				settings.events.tags.beforeRemove(tag);
				//Animate?
				if(settings.animate) {
					tag.fadeOut(1000, function() {
						tag.remove();
						//And update original field again..
						updateOriginal(tagarea, original);
						settings.events.tags.afterRemove(tag);
					});
				}else {
					tag.remove();
					//And update original field again..
					updateOriginal(tagarea, original);
					settings.events.tags.afterRemove(tag)
				}
			});
			tag.append(close);
			//Replace the field with the tag..
			settings.events.field.beforeRemove(field);
			field.replaceWith(tag);
			//Invoke user defined event
			settings.events.tags.afterRender(tag);
			//Now add a new field and give it focus..
			createInput(tagarea, original);
						
		};
		
		/**
		 * Creates a tag on init, slightly different to the 
		 * create_tag function, in tht it does not require a input
		 * field to be passed, and does not create a new input field
		 * after the tag is created
		 **/
		var createInitialTag = function(tagarea, tagtext, original) {
			var tag = $('<span>');
			//Set user defined styles
			tag.attr('class', settings.style.tags.className);
			tag.css(settings.style.tags.css);
			var text = $('<span>');
			text.text(tagtext);
			tag.append(text);
			//Invoke user defined event
			settings.events.tags.beforeRender(tag);
			//Add the 'x'(close) button to the tag..
			var close = $('<span>');
			close.css(settings.style.closeBttn.css);
			close.text(settings.content.closeBttn);
			close.click(function() {
				//Remove tag span..
				settings.events.tags.beforeRemove(tag);
				//Animate?
				if(settings.animate) {
					tag.fadeOut(1000, function() {
						tag.remove();
						//And update original field again..
						updateOriginal(tagarea, original);
						settings.events.tags.afterRemove(tag);
					});
				}else {
					tag.remove();
					//And update original field again..
					updateOriginal(tagarea, original);
					settings.events.tags.afterRemove(tag)
				}
			});
			tag.append(close);
			
			tagarea.append(tag);
			
			
			
			
			//Invoke user defined event
			settings.events.tags.afterRender(tag);
		}
		
		
		var createAddButton = function(container , original){
			
			var addButton = "<a href='javascript:;'  > <img src='/assets/icons/symbol-add.png' alt='Add' /> </a> ";
			container.append(addButton);
			
			container.find("a").click(function() {
					createInput(container, original);
					var field = null;
					container.children().filter('input[type=text]').each(function() {
						field = $(this);
					});
					if(field !== null)
					{	
						createTag(container, field, original);
						updateOriginal(container, original);
					}	
			});
			
		}
		
		/**
		 * Creates another input[type=text], placed after all the tags
		 * the field should have no border, and the same background
		 * as the 'textarea' to give the illusion of the 'textarea',
		 * which is actually a div to be that of a textarea
		 **/
		var createInput = function(tagarea, original) {
			//If a field already exists, use it, else create it..
			var field = null;
			tagarea.children().filter('input[type=text]').each(function() {
				field = $(this);
			});
			if(field == null) {
				field = $('<input type="text">');
				settings.events.field.beforeRender(field);
				tagarea.append(field);
				settings.events.field.afterRender(field);
			}
			//Style it..
			//Set the size of the field to one character..
			field.attr('size', 1);
			field.css(settings.style.field.css);
			
			if( typeof settings.tag_list != undefined && settings.tag_list != null  ){
				field.autocomplete({
					source: settings.tag_list, 
					select: function(event,ui){
					
						field.val(ui.item.value);

						if(field !== null)
						{	
								createTag(tagarea, field, original);
						 		updateOriginal(tagarea, original);
						}
						// Preventing the tag input to be update with the chosen value.
						//return false;
					}
				});
			}	
			
			
			//Listen for keypresses on the field, if the key 
			//equals the separator, then remove the field and replace
			//it with the tag..
			field.keypress(function(keyCode) {
				var key = String.fromCharCode(keyCode.which);
				if(key == settings.separator || key == 13) {
					//If the tag length does not meet requirements do nothing!
					if(field.val().length < settings.content.minLength || field.val().length > settings.content.maxLength) {
						return false;
					}
					//Separator pressed, create a tag with fields
					//value
					createTag(tagarea, field, original);
					//Update the original fields value to match..
					updateOriginal(tagarea, original);
				}else {
					//Check to see if the key is in the settings for
					//banned, if so return false, then it will not
					//be entered in the field..
					var allowed = true;
					for(var i = 0; i < settings.content.banned.length; i++) {
						if(key == settings.content.banned[i]) {
							allowed = false;
							break;
						}
					}
					//If the length of the tag is at its max do nothing
					if(field.val().length == settings.content.maxLength) {
						allowed = false;
					}
					//If the key is allowed, increase the size of the field by 1..
					if(allowed && keyCode.which != 8) {
						field.attr('size', parseInt(field.attr('size')) + 1);
						var width = parseInt(field.width() ) ;
						var reqWidth = (field.val().length + 1 )  * 10;
						
						if( width  < reqWidth)
							field.width(reqWidth);
					//Unless the key is a backspace, then decrease the size..
					}else if(allowed && keyCode.which == 8 && parseInt(field.attr('size')) > 0) {
						field.attr('size', parseInt(field.attr('size')) - 1);
					}
					return allowed;
				}
			});
			//Give the field focus
			//field.trigger('focus');
			//For some reason IE does not listen the first time :s
			//So do it again.....
			if($.browser.msie) {
				field.trigger('focus');
			}
		};
		/**
		 * In true jQuery fashion return each item
		 **/
		return this.each(function() {
			var original = $(this); //Original textarea
			var originalVal = '';
			try {
				originalVal = original.val();
			}catch(e) {
				originalVal = original.text();
			}
			
			if(typeof original.attr("rel") !=  undefined && original.attr("rel") != null && original.attr("rel") != "" )
				settings.tag_list = original.attr("rel").split(",")
			
			original.css('display', 'none'); //Hide it
			//Create a div to replace it
			var tagarea = $('<div>');
			//Set it's style
			tagarea.attr('class', settings.style.area.className);
			//Set cursor on div to text style cursor
			//making the user believe it is a textarea..
			tagarea.css('cursor', 'text');
			tagarea.css(settings.style.area.css);
			//User may have defined a function to invoke before
			//render...
			settings.events.area.beforeRender(tagarea);
			//Insert just after original area(which is hidden
			//therefore replacing it)
			tagarea.insertAfter(original);
			//Create a tag for each tag in the original field(if any)
			var tags = originalVal.split(settings.separator);
			if(tags.length > 0) {
				for(var x = 0; x < tags.length; x++) {
					if(tags[x] != '') {
						createInitialTag(tagarea, tags[x], original);
					}
				}
			}
			createAddButton(tagarea , original);
			settings.events.area.afterRender(tagarea);
					
			createInput(tagarea , original);
		});
	};
})(jQuery);
