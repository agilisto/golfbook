module MapHelper
  
  # Helper to rewrite to rfacebook even without canvas
  
   # Facebook canvas path, as parsed from the YAML file (may be nil if this application is an external app)
    def facebook_canvas_path
      FACEBOOK["canvas_path"]
    end

    # Facebook callback path, as parsed from the YAML file (may be nil if this application is an external app)
    def facebook_callback_path
      FACEBOOK["callback_path"]
    end
    
  # Copied from rfacebook 
  def url_for_canvas(path)
    # replace anything that references the callback with the
    # Facebook canvas equivalent (apps.facebook.com/*)
    if path.starts_with?(self.facebook_callback_path)
      path.sub!(self.facebook_callback_path, self.facebook_canvas_path)
      path = "http://apps.facebook.com#{path}"
    elsif "#{path}/".starts_with?(self.facebook_callback_path)
      path.sub!(self.facebook_callback_path.chop, self.facebook_canvas_path.chop)
      path = "http://apps.facebook.com#{path}"
    elsif (path.starts_with?("http://www.facebook.com") or path.starts_with?("https://www.facebook.com"))
      # be sure that URLs that go to some other Facebook service redirect back to the canvas
      if path.include?("?")
        path = "#{path}&canvas=true"
      else
        path = "#{path}?canvas=true"
      end
    elsif (!path.starts_with?("http://") and !path.starts_with?("https://"))
      # default to a full URL (will link externally)
      RAILS_DEFAULT_LOGGER.debug "** RFACEBOOK INFO: failed to get canvas-friendly URL ("+path+") for ["+options.inspect+"], creating an external URL instead"
      path = "#{request.protocol}#{request.host}:#{request.port}#{path}"
    end
  end
end
