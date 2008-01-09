module BuilderHelper
  def editor_form_for(object_name, *args, &block)
    raise ArgumentError, "Missing block" unless block_given?
     options = args.last.is_a?(Hash) ? args.pop : {}
     options = options.merge(:builder => EditorBuilder)
     concat(editor_tag(options.delete(:url) || {}, options.delete(:html) || {}), proc.binding)
     fields_for(object_name, *(args << options), &proc)
     concat('</fb:editor>', proc.binding)
  end
  
  # File action_view/helpers/form_helper.rb, line 145
  def fields_for(object_name, *args, &block)
    raise ArgumentError, "Missing block" unless block_given?
    options = args.last.is_a?(Hash) ? args.pop : {}
    object  = args.first

    builder = options[:builder] || ActionView::Base.default_form_builder
    yield builder.new(object_name, object, self, options, block)
  end
  
  # Copied from File action_view/helpers/form_tag_helper.rb, line 36
  def editor_tag(url_for_options = {}, options = {}, *parameters_for_url, &block)
    html_options = html_options_for_editor(url_for_options, options, *parameters_for_url)
    if block_given?
      editor_tag_in_block(html_options, &block)
    else
      editor_tag_html(html_options)
    end
  end
  
  # File action_view/helpers/form_tag_helper.rb, line 390
  def html_options_for_editor(url_for_options, options, *parameters_for_url)
    returning options.stringify_keys do |html_options|
      html_options["enctype"] = "multipart/form-data" if html_options.delete("multipart")
      html_options["action"]  = url_for(url_for_options, *parameters_for_url)
    end
  end
  
  # File action_view/helpers/form_tag_helper.rb, line 411
  def editor_tag_html(html_options)
    tag("fb:editor", html_options, true) 
  end
  
  # File action_view/helpers/form_tag_helper.rb, line 416
  def editor_tag_in_block(html_options, &block)
    content = capture(&block)
    concat(editor_tag_html(html_options), block.binding)
    concat(content, block.binding)
    concat("</fb:editor>", block.binding)
  end
end