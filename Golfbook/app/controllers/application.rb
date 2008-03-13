# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  before_filter :require_facebook_install, :adjust_format_for_facebook, :set_active_menu, :set_active_submenu
  
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  #protect_from_forgery # :secret => 'ab3cdc368e4e352eebd96b713dae6028'

  DEFAULT_FIELDS =  ["first_name", "last_name"]

  def fbuser(fields = [])
    fields = DEFAULT_FIELDS | fields
    
    if @fbuser.nil?      
      @fbuser = fbsession.users_getInfo(:uids => fbsession.session_user_id, :fields => fields)
    end
  end
  
  def current_user
    if @user.nil?
      @user = User.find_or_create_by_facebook_uid(fbsession.session_user_id)
      update_profile_box(@user.id)
    end
    @user
  end
  
  private
  def adjust_format_for_facebook  
    if in_facebook_canvas? 
      request.format = :fbml        
    end
  end
      
  def finish_facebook_login
  end
  
  protected
  def set_active_menu
    # Current sets the body id which sets the context to enable the right selected tab 
    # in the pandemic bar
    @current = "#{controller_name}_selected"
  end
  
  def set_active_submenu
  end
  
  def update_profile_box user_id
    user = User.find user_id
    recent_rounds = user.rounds.recent(3)
    upcoming_games = user.games.upcoming
    profile_box = render_to_string(:partial => 'shared/profile_box', :locals => { :user => user, :recent_rounds => recent_rounds, :upcoming_games => upcoming_games })
    fbsession.profile_setFBML({:profile => profile_box, :uid => user.facebook_uid})
  end
  
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
     
  def geocode_location location
    res=MultiGeocoder.geocode(location)
    latitude, longitude = 0, 0
    
    if res.success
      latitude, longitude = res.lat, res.lng 
    else
      criteria = Geonames::ToponymSearchCriteria.new
      criteria.name_equals = location
      criteria.max_rows = '1'

      results = Geonames::WebService.search(criteria).toponyms

      if results.length == 1 
        latitude, longitude = results[0].latitude, results[0].longitude
      end
      
      [latitude, longitude]
    end
  end
  
end
