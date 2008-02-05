class EditorBuilder < ActionView::Helpers::FormBuilder
  #<fb:editor action="?do-it" labelwidth="100">
  #  <fb:editor-text label="Title" name="title" value=""/>  
  #  <fb:editor-text label="Author" name="author" value=""/>  
  # <fb:editor-custom label="Status">  
  #    <select name="state">
  #        <option value="0" selected>have read</option>
  #   </select>  
  # </fb:editor-custom>
  # <fb:editor-textarea label="Comment" name="comment"/>  
  #      <fb:editor-buttonset>
  #          <fb:editor-button value="Add"/>
  #              <fb:editor-button value="Recommend"/>
  #              <fb:editor-cancel />
  #      </fb:editor-buttonset>
  #     </fb:editor>
  
  def text_field(label, *args)
    options = args.extract_options!
    options["value"] = object.send(label)
    options["name"] = tag_name(label)
    options["label"] = label.to_s.humanize
    @template.tag "fb:editor-text", options
  end
  
  def text_area(label, *args)
    options = args.extract_options!
    options["name"] = tag_name(label)
    options["label"] = label.to_s.humanize
    @template.content_tag("fb:editor-textarea", object.send(label), options)
  end
  
  def submit_tag(value = "Save changes", options = {})
    @template.tag("fb:editor-button", 
      :name => 'commit', :value => value.to_s.humanize)
  end
  
  private
  
  def tag_name(label)
    "#{@object_name}[#{label}]"
  end
  
end