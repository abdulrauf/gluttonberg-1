// This file is specifically for the Log In screen.

$(document).ready(function() {  

	if($('#login').length > 0){
		init_login_tabs();
	}
  
});

// Tabs on Log In form
function init_login_tabs(){
	
	var login_tab = $('#login_tab');
	var login_section = $('#login_tab_section');
	var password_tab = $('#password_tab');
	var password_section = $('#password_reset_tab_section');
	
	login_tab.click(function(){
		login_tab.addClass('active');
		password_tab.removeClass('active');
		login_section.addClass('active');
		password_section.removeClass('active');
	});
	
	password_tab.click(function(){
		password_tab.addClass('active');
		login_tab.removeClass('active');
		password_section.addClass('active');
		login_section.removeClass('active');
	});
	
}