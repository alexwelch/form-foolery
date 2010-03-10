# You can't see it here, but I loop through <tt>ActionView::Helpers::FormBuilder::field_helpers</tt>
# and redefine the <tt>field_helpers</tt>, plus <tt>datetime_select</tt> and <tt>date_select</tt>, 
# minus the <tt>check_box</tt> and <tt>radio_button</tt>:
# - +text_field+
# - +file_field+
# - +password_field+
# - +hidden_field+
# - +text_area+
# - +datetime_select+
# - +date_select+
# use them like you normally would, but I add two booleans to the options hash:
# <tt>disable_behavior</tt>:: reverts to normal behavior, inside of +labeled_form_for+
# <tt>required</tt>:: marks the field as required with an asterisk and css class name
# [for example]
#   <tt>f.text_field :first_name</tt>
# [will produce]
#     <tt><dl></tt>
#       <dt>
#         <label for="user_first_name">First Name</label>
#       </dt>
#       <dd>
#         <input id="user_first_name" type="text" size="30" name="user[first_name]" accesskey="f"/>  
#       </dd>
#     <tt><dl></tt>

class LabeledFormBuilder < ActionView::Helpers::FormBuilder  
  ((field_helpers - %w(check_box radio_button)) + %w(datetime_select date_select)).each do |selector|
    src = <<-END_SRC
    def #{selector}(field, options = {})
      options[:accesskey] = field.to_s.split("")[0] # TODO - these need to be uniq
      required = options.delete :required     
      unless options.delete :disable_behavior
        field_label, info, example = get_label(field, options)
        field_to_html( field_label, field, super, false, info, example, nil, required )
      else
        super
      end
    end
    END_SRC
    class_eval src, __FILE__, __LINE__
  end
  
  # additional options include:
  # <tt>:required</tt> :: gives an astrisk and a +.required+ class
  # <tt>:disable_behavior</tt> :: turn off behavior
  # other than that use it like you would <tt>ActionView::Helpers::FormOptionsHelper::select</tt>
  def select( field, choices, options = {}, html_options = {})
    required = options.delete :required
    unless options.delete :disable_behavior
      field_label, info, example = get_label(field, options)
      field_to_html( field_label, field, super, false, info, example, nil, required )
    else
      super
    end
  end
  
  # creates a 3 box phone field
  # uses lowpro for tabbing, and will need some stuff in your model to work properly
  #   before_save :save_phone
  # 
  #   # Phone stuff for splitting phone numbers into 3 little boxes
  #   @@phone_list = %w(phone) # list out each field_name for example %w(home_phone work_phone mobile_phone)
  # 
  #   @@phone_list.each do |phone_type|
  #     (1..3).to_a.each do |num|
  #       attr_accessible "#{phone_type}_#{num}".to_sym
  #       attr_accessor "#{phone_type}_#{num}".to_sym
  #     end
  #   end
  # 
  #   def save_phone
  #     @@phone_list.each do |phone_type|
  #       self["#{phone_type}"] = instance_variable_get("@#{phone_type}_1").to_s + "-" + instance_variable_get("@#{phone_type}_2").to_s + "-" + instance_variable_get("@#{phone_type}_3").to_s
  #     end
  #   end
  # 
  #   # define the phone getter methods
  #   @@phone_list.each do |phone_type|
  #     (1..3).to_a.each_with_index do |num, i|
  #       define_method "#{phone_type}_#{num}" do
  #         if self[phone_type.to_sym]
  #           self[phone_type.to_sym].split('-')[i]
  #         end
  #       end
  #     end
  #   end
  # ==== TODO
  # - add ability to turn off auto-tabbing
  # * move the above model code into the plugin
  def phone_field(prefix)    
    phone_field = "<dl><dt><label for='#{@object_name}_#{prefix}_1'>#{prefix.to_s.humanize.titleize}</label></dt>"
    phone_field += "<dd>"
    phone_field += self.text_field("#{prefix}_1", :disable_behavior => true, :size => "3", :maxlength => "3", :class => "autotab") + " - "
    phone_field += self.text_field("#{prefix}_2", :disable_behavior => true, :size => "3", :maxlength => "3", :class => "autotab") + " - "
    phone_field += self.text_field("#{prefix}_3", :disable_behavior => true, :size => "4", :maxlength => "4" )
    phone_field += "</dd></dl>"
    phone_field
  end
  
  # additional options include:
  # <tt>:required</tt> :: gives an astrisk and a +.required+ class
  # <tt>:disable_behavior</tt> :: turn off behavior
  def check_box(field, options = {}, checked_value = "1", unchecked_value = "0")
    required = options.delete :required
    unless options.delete :disable_behavior
      field_label, info, example = get_label(field, options)
      field_to_html( field_label, field, super, true, info, example, nil, required )
    else
      super
    end
  end
  
  # additional options include:
  # <tt>:required</tt> :: gives an astrisk and a +.required+ class
  # <tt>:disable_behavior</tt> :: turn off behavior  
  def radio_button(field, tag_value, options = {})
    required = options.delete :required
    unless options.delete :disable_behavior
      field_label, info, example = get_label(tag_value, options)
      field_to_html( field_label, field, super, true, info, example, tag_value, required )
    else
      super
    end
  end
  
  # see LabeledFormHelper::form_button_group
  def button_group(options={}, &block)
    @template.form_button_group(options, &block)
  end
  
  def field_group(options={}, &block)
    @template.form_field_group(options, &block)
  end
  
  def field_set(options={}, &block)
    @template.form_field_set(options, &block)
  end
  
protected
  
  def field_to_html(label, field, field_html, is_checkbox=false, info=nil, example=nil, tag_value=nil, required=false )
    if is_checkbox
      field_name = "#{@object_name}_#{field.to_s.underscore}#{(tag_value ? '_' + tag_value : '')}"
    else
      field_name = "#{@object_name}_#{field.to_s.underscore}"
    end
    is_required = (required ? 'required' : 'optional' )
    info_html = (info.nil?) ? '' : @template.content_tag( 'span', info, :class=>'info' )
    example_html = (example.nil?) ? '' : @template.content_tag('dd', example, :class=>'example' )
    unless is_checkbox
      # TODO figure out how to use error_message_on...
      @template.content_tag('dl', @template.content_tag('dt', @template.content_tag( 'label', label + (required ? " *" : ""), :for=>field_name, :class => is_required ) + info_html ) + @template.content_tag('dd', field_html ) + example_html )
    else
      @template.content_tag('dl', @template.content_tag('dd', field_html + @template.content_tag('label', label, :for=>field_name, :class => "sm_label") + info_html ) + example_html)
    end
  end
  
  def get_label(field, options)
    info = options.delete :info
    example = options.delete :example
    label = options.has_key?(:label) ? options.delete(:label) : field.to_s.humanize.titleize
    return [label, info, example]
  end
end