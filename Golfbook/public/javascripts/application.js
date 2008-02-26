// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
function submitForm(url, form_id, target_id) {
	Animation(document.getElementById(target_id)).to('height', '0px').to('opacity', 0).hide().go();
	
	// Retrieve element handles, and populate request parameters.
	var form = document.getElementById(form_id);
	var target = document.getElementById(target_id);
	var params = form ? form.serialize() : null;

	// Set up an AJAX object.  Typically, an FBML response is desired.
	var ajax = new Ajax();
	ajax.responseType = Ajax.FBML;
	ajax.requireLogin = true;

	ajax.ondone = function(data) {
		// When the FBML response is returned, populate the data into the target element.
		if (target) target.setInnerFBML(data);
		Animation(document.getElementById(target_id)).to('height', 'auto').from('0px').to('width', 'auto').from('0px').to('opacity', 1).from(0).blind().show().go();
		
	}
	ajax.onerror = function() {
	    console.log("there was an error");
	 }
	
	ajax.post(url, params);
};


function rateCourse(source, url, form_id, target_id) {
	submitForm(url, form_id, target_id);
};

//function trim(str) {  
//    return str.replace(/^\s+|\s+$/g, '');  
//}  
//  
//function clearInput(e, compare) {  
//    e.removeClassName('inputblank');   // remove grayed out color  
//    if (e.getValue() == compare) {  
//        e.setValue('');                // clear default text when clicked  
//    }  
//}  
//  
//function restoreInput(e, value) {  
//    if (trim(e.getValue()) == '') {  
//        e.setValue(value);             // reset default text when unclicked  
//        e.addClassName('inputblank');  // display grayed out color  
//    }  
//}
