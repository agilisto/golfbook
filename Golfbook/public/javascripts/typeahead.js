/* 
written by tyson malchow for the Rate Me facebook application
 */
function ajaxSuggestFbml(obj, options) {
	this.obj = obj;

	// Setup the events we're listening to
	this.obj.addEventListener('focus', this.onfocus.bind(this))
		.addEventListener('blur', this.onblur.bind(this))
		.addEventListener('keyup', this.onkeyup.bind(this))
		.addEventListener('keydown', this.onkeydown.bind(this))
		.addEventListener('keypress', this.onkeypress.bind(this));

	// Create the dropdown list that contains our suggestions
	this.list = document.createElement('div');
	try {
		this.list.setClassName('suggest_list')
			.setStyle({width: (this.obj.getOffsetWidth()-2) + 'px',
						display: 'none'});
	}
	catch(err) {
		this.list.setClassName('suggest_list')
			.setStyle({width: '300px',
						display: 'none'});
	}
	this.obj.getParentNode().appendChild(this.list);

	// Various flags
	this.focused = true;
	this.options = options == null ? {} : options;
	this.selectedindex = -1;
	this.delayTime = options.delayTime == null ? 700 : options.delayTime;
	this.preMsgTxt = options.preMsgTxt == null ? "type for suggestions" : options.preMsgTxt;
	this.normOpac = options.menuOpacity == null ? 94 : options.menuOpacity;
	this.curOpac = this.normOpac;

	this.cache = {};
	this.obj.setStyle({margin: "0px"});

	if(!options.focus) {
		this.preMsg = true;
		this.obj.setValue(this.preMsgTxt);
		this.obj.addClassName("suggest_pretext");
	} else {
		this.obj.focus();
		this.preMsg = false;
		this.update_results();
		this.show();
	}

};

// Show suggestions when the user focuses the text field
ajaxSuggestFbml.prototype.onfocus = function(event) {
	if(this.preMsg) {
		this.obj.setValue("");
		this.obj.removeClassName("suggest_pretext");
		this.preMsg = false;
	}
	this.focused = true;
	this.update_results();
	this.obj.removeClassName('suggest_found');
	this.show();
};

// ...and hide it when they leave the text field
ajaxSuggestFbml.prototype.onblur = function() {
	if(this.obj.getValue() == "") {
		this.preMsg = true;
		this.obj.setValue(this.preMsgTxt);
		this.obj.addClassName("suggest_pretext");
	}
	this.focused = false;
	this.hide();
};

// Every keypress updates the suggestions
ajaxSuggestFbml.prototype.onkeyup = function(event) {
	switch (event.keyCode) {
		case 27: // escape
			this.hide();
			this.obj.removeClassName('suggest_found');
			break;
		case 13: // enter
			if(this.options!=null && this.options.onEnter!=null) {
				this.hide();
				this.options.onEnter(event);
				
				if(this.options.clearOnEnter == true) {
					this.obj.setValue('');
					this.hide();
					this.obj.removeClassName('suggest_found');
				}
			}
			break;
		case 0:  
		case 37: // left
		case 9:  // tab
		case 38: // up
		case 39: // right
		case 40: // down
			break;
		default:
			this.selectedindex = -1;
			this.update_results();
			this.show();
			this.obj.removeClassName('suggest_found');
			break;
	}
};

// We want interactive stuff to happen on keydown to make it feel snappy
ajaxSuggestFbml.prototype.onkeydown = function(event) {
	switch (event.keyCode) {
		case 9: // tab
		case 13: // enter
			if (this.results[this.selectedindex]) {
				this.obj.addClassName('suggest_found')
					.setValue(this.results[this.selectedindex]);
				this.hide();
				event.preventDefault();
			}
			break;

		case 38: // up
			this.select(this.selectedindex - 1);
			event.preventDefault();
			break;

		case 40: // down
			this.select(this.selectedindex + 1);
			event.preventDefault();
			break;
	}
};

// Override these events so they don't actually do anything
ajaxSuggestFbml.prototype.onkeypress = function(event) {
	switch (event.keyCode) {
	    case 13: // return
		case 9:  // tab
		case 38: // up
		case 40: // down
      		event.preventDefault();
      		break;
	}
};

// Select a given index
ajaxSuggestFbml.prototype.select = function(index) {
	var children = this.list.getChildNodes();
	
	if(children != null && children.length > 0) {
		if(index<0)
			index = 0;
		if(index >= children.length)
			index = children.length - 1;
		
		if(this.selectedindex >=0 && this.selectedindex < children.length )
			children[this.selectedindex].removeClassName('suggest_selected');
		children[(this.selectedindex=index)].addClassName('suggest_selected');
	}
};

ajaxSuggestFbml.prototype.onajaxdone = function(data) {
	// save to the cache
	this.cache[data.fortext].results = data.results;
	this.cache[data.fortext].curRequest = null;
	
	// if its valid, update the UI
	if(this.get_norm_typed() == data.fortext) {
		this.draw_results(data.results, data.fortext);
		this.results = data.results;
	}
};

ajaxSuggestFbml.prototype.get_norm_typed = function() {
	return this.obj.getValue().toLowerCase();
};

ajaxSuggestFbml.prototype.getValue = function() {
	return (this.preMsg?"":this.obj.getValue());
};

ajaxSuggestFbml.prototype.draw_results = function(results, typed) {
	this.list.setTextValue('');
	if(results == null)
		return;
	for( var i = 0; i < results.length; i++ ) {
		var item = document.createElement('div').setClassName('suggest_suggestion');

		item.addEventListener('mouseover', 
					function() {
						this[0].select(this[1]); 
					}.bind([this, i]));
		item.addEventListener('mousedown', 
					function(event) {
						this.obj.addClassName('suggest_found');
	 					this.obj.setValue(this.results[this.selectedindex]);
						this.hide();  
					}.bind(this));

		var begins = results[i].toLowerCase().indexOf(typed);
		if (begins == -1) {
			var span_item = document.createElement('span').setTextValue(results[i]);
			item.appendChild(span_item);
		} else {
			if (begins > 0) {
				item.appendChild(document.createElement('span').setTextValue(results[i].substring(0, begins)));
			}
			var em_item = document.createElement('em').setTextValue(results[i].substring(begins, begins + typed.length));
			item.appendChild(em_item);

			var span_item = document.createElement('span').setTextValue(results[i].substring(begins + typed.length));
			item.appendChild(span_item);
		}
		this.list.appendChild(item);
	}
};

ajaxSuggestFbml.prototype.send_ajrequest = function(val) {
	// ajax query
	var request = new Ajax();
		
	request.requireLogin = false;
	request.responseType = Ajax.JSON;
	request.onerror = function() {/* meh */};
	request.ondone = this.onajaxdone.bind(this);

	this.cache[val] = {curRequest: request};
	this.cache[val].curRequest.post(this.options.ajaxUrl, {suggest_typed: val});
};

// This is called every keypress to update the suggestions
ajaxSuggestFbml.prototype.update_results = function() {
	// Search the list of potential results and find ones that match what we have so far
	var val = this.get_norm_typed();
	
	if(this.cache[val] != null) {
		// pull from el cache
		this.draw_results(this.cache[val].results,val);
		this.results = this.cache[val].results;
		
	} else if(this.cache[val] == null || this.cache[val].curRequest == null){
		if(this.requestTimer != null)
			clearTimeout(this.requestTimer);
		this.requestTimer = setTimeout(
			function() { 
				this.send_ajrequest(val); 
				this.requestTimer = null;
			}.bind(this), this.delayTime);
	}
};

ajaxSuggestFbml.prototype.cleanup = function() {
	this.hide();
	this.obj.setValue('');
	this.obj.removeClassName('suggest_found');
}

ajaxSuggestFbml.prototype.show = function() {
	this.list.setStyle('display', 'block');
};

ajaxSuggestFbml.prototype.hide = function() {
	this.selectedindex = -1;
	this.list.setStyle('display', 'none');
};