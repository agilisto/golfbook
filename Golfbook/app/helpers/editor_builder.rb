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
    @template.tag("fb:editor-text", 
      :name => tag_name(label), :label => label.to_s.humanize)
  end
  
  private
  
  def tag_name(label)
    "#{@object_name}[#{label}]"
  end
  
end