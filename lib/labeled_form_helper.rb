# this is mixed into ActionView::Base on init
module LabeledFormHelper
    
  def labeled_form_for( name, *args, &block )
    raise ArgumentError, "Missing block" unless block_given?
    options = (args.last.is_a?(Hash) ? args.pop : {}).merge(:builder=>LabeledFormBuilder)
    form_for( name, *(args << options), &block )
  end

  def remote_labeled_form_for( name, *args, &block )
    raise ArgumentError, "Missing block" unless block_given?
    options = (args.last.is_a?(Hash) ? args.pop : {}).merge(:builder=>LabeledFormBuilder)
    remote_form_for( name, *(args<< options), &block )
  end
  alias :labeled_form_remote_for :remote_labeled_form_for
  
  def labeled_fields_for( name, *args, &block )
    raise ArgumentError, "Missing block" unless block_given?
    options = (args.last.is_a?(Hash) ? args.pop : {}).merge(:builder=>LabeledFormBuilder)
    fields_for( name, *(args<< options), &block )
  end
  
  def input_wrapper(options={}, &block)
    concat( "<dl><dt><label for='#{options[:field_name]}'>#{options[:title] || options[:field_name].to_s.humanize.titleize}</label></dt><dd>", block.binding)
    concat( capture(&block), block.binding)
    concat( "</dd></dl>", block.binding)
  end

  def form_button_group(options={}, &block)
    raise ArgumentError, "Missing block" unless block_given?
    class_name = options.has_key?(:class) ? options.delete(:class) : 'button-group'
    concat( %Q|<dl><dd class="#{class_name}">|, block.binding )
    concat( capture( &block ), block.binding )
    concat( '</dd></dl>', block.binding )
  end
  
  # make sure you set :with_groups => true in the form_field_set method
  # TODO id only to show up if it is given - no empty ids
  def form_field_group(options={}, &block)
    raise ArgumentError, "Missing block" unless block_given?
    id = "id='#{options[:id]}'" if options[:id]
    title = "<h3 class='fg_title'>#{options[:title]}</h3>" if options[:title]
    concat( %Q|<li class="field_group" #{id}>#{title}|, block.binding )
    concat( capture( &block ), block.binding )
    concat( '</li>', block.binding )
  end
  
  # set :with_groups => true if you plan on using form_field_group
  # TODO id only to show up if it is given - no empty ids
  def form_field_set(options={}, &block)
    with_groups = options[:with_groups] || false    
    id = "id='#{options[:id]}'" if options[:id]
    # wish I could do > field_set_tag(options[:legend]) { content_tag('dl', :class => "field_set", &block) } ... Just not smart enough...
    concat( "<fieldset class='#{options[:with_groups] ? "with_groups" : "without_groups"}' #{id}>", block.binding )
    concat( "<legend>#{options[:legend]}</legend>", block.binding ) if options[:legend]
    concat( "<ul class='field_set'>", block.binding) if with_groups
    concat( capture( &block ), block.binding )
    concat( "</ul>", block.binding) if with_groups
    concat( "</fieldset>", block.binding)
  end

end