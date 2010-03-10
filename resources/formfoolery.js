/*
* Form Foolery
* Version 2 - http://www.alexwelch.com/formfoolery/
* 6/7/07
* By Alex Welch 
* Licensed under the Creative Commons Attribution-Share Alike 3.0 License - http://creativecommons.org/licenses/by-sa/3.0/
*/

// function for auto tabbing - requires lowpro - http://svn.danwebb.net/external/lowpro/trunk/dist/lowpro.js
// Note that I coppied this autotab from someone else
Event.addBehavior({
  'input.autotab:keyup' : function(e) {
    if(e.keyCode != 9 && e.keyCode != 16) {
      if(e.target.value.length == e.target.size) {
        e.target.next().focus();  
      }      
    }
  }
});


//type = textarea, input, select, option

function resetFields() {
	//give inputs a class
	$$('input[type="text"]').each(function(el) { el.addClassName('textInput'); });
	$$('input[type="checkbox"]').each(function(el) { el.addClassName('checkboxInput'); });
	$$('input[type="radio"]').each(function(el) { el.addClassName('radioInput'); });
	
	var inputs = $A(document.getElementsByTagName('input'));	
	var textareas = $A(document.getElementsByTagName('textarea'));
	var selects = $A(document.getElementsByTagName('select'));
	var options = $A(document.getElementsByTagName('option'));
	var elements = inputs.concat(textareas).concat(selects).concat(options);
  // for (var i=0; i<whichform.elements.length; i++) {
	for (var i = 0; i<elements.length; i++) {
  // var element = whichform.elements[i];
		var element = elements[i];
    if (element.type == "submit") continue;
    	
			$(element).addClassName("default");
			element.onfocus = function() {
				$(this).addClassName('focus');
				if ($(this).up('fieldset').hasClassName('with_groups')) {
					$(this).up('li.field_group').addClassName('focused');
				}
				
				if ($(this).className.match(/new/)) {
					$(this).addClassName('default');
					if (this.value == this.defaultValue) {
					this.value = '';					
					}
				}
			}
		
    element.onblur = function() {	
				$(this).removeClassName("focus");
				if ($(this).up('fieldset')) {
					if ($(this).up('fieldset').hasClassName('with_groups')) {
						$(this).up('li.field_group').removeClassName("focused");
					}
				}
				$(this).removeClassName("default");
				if ($(this).className.match(/new/)) {
					if (this.value == '') {
						this.value = this.defaultValue;
						$(this).addClassName('default');
					}
				}
		}
  }
}


document.observe("dom:loaded", resetFields);