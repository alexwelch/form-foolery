module ActionView::Helpers::ActiveRecordHelper
  def error_messages_for(*params)
    options = params.extract_options!.symbolize_keys
    if object = options.delete(:object)
      objects = [object].flatten
    else
      objects = params.collect {|object_name| instance_variable_get("@#{object_name}") }.compact
    end
    count   = objects.inject(0) {|sum, object| sum + object.errors.count }
    unless count.zero?
      html = {}
      [:id, :class].each do |key|
        if options.include?(key)
          value = options[key]
          html[key] = value unless value.blank?
        else
          html[key] = 'errorExplanation'
        end
      end
      options[:object_name] ||= params.first
      options[:header_message] = "#{pluralize(count, 'error')} prohibited this #{options[:object_name].to_s.gsub('_', ' ')} from being saved" unless options.include?(:header_message)
      options[:message] ||= 'There were problems with the following fields:' unless options.include?(:message)
      # rails way -> error_messages = objects.map {|object| object.errors.full_messages.map {|msg| content_tag(:li, msg) } }
      # my way - with an anchor link
      error_messages = ""
      objects.each do |object|
        object.errors.each do |e, d|
          error_messages += content_tag('li', link_to_function(e.capitalize + " " + d, "$('#{object.class.to_s.downcase}_#{e}').scrollTo().activate();"))
        end
      end
      contents = ''
      contents << content_tag(options[:header_tag] || :h2, options[:header_message]) unless options[:header_message].blank?
      contents << content_tag(:p, options[:message]) unless options[:message].blank?
      contents << content_tag(:ul, error_messages)
  
      content_tag(:div, contents, html)
    else
      ''
    end
  end
end

ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
  "<span class='fieldWithErrors'>#{html_tag}</span>"  
  # error_message_on instance.object_name.to_sym, instance.method_name.to_sym
end