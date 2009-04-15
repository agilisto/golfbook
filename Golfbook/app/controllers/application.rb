# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include HoptoadNotifier::Catcher
  include FeedPublisher
  include ProfilePublisher

  helper :all # include all helpers, all the time
  before_filter :require_facebook_install, :adjust_format_for_facebook, :set_active_menu, :set_active_submenu, :load_user
  
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  #protect_from_forgery # :secret => 'ab3cdc368e4e352eebd96b713dae6028'

  DEFAULT_FIELDS =  ["first_name", "last_name", "uid","sex"]

  def fbuser(fields = [])
    fields = DEFAULT_FIELDS | fields
    
    if @fbuser.nil?      
      @fbuser = fbsession.users_getInfo(:uids => fbsession.session_user_id, :fields => fields)
    end
  end
  
  def current_user
#    if @user.nil?
#      @user =
     @current_user ||= User.find_or_create_by_facebook_uid(fbsession.session_user_id)
#    end
#    @user
  end
  
  private
  def adjust_format_for_facebook  
    if in_facebook_canvas? 
      request.format = :fbml        
    end
  end
      
  def finish_facebook_login
  end

  #overriding the rfacebook rescue_action so that I can include hoptoad notification
  def rescue_action(exception)
    # render a special backtrace for canvas pages
    puts notify_hoptoad(exception).inspect
    if in_facebook_canvas?
      render(:text => "#{facebook_debug_panel}#{facebook_canvas_backtrace(exception)}")

    # all other pages get the default rescue behavior
    else
      rescue_action_without_rfacebook(exception)
    end
  end
  
  protected
  def set_active_menu
    # Current sets the body id which sets the context to enable the right selected tab 
    # in the pandemic bar
    @current = "#{controller_name}_selected"
  end
  
  def set_active_submenu
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
    end
    
    [latitude, longitude]
  end

  def get_friends_for_facebook_uid(facebook_uid)
    fql = "SELECT uid, name FROM user WHERE uid IN (SELECT uid2 FROM friend WHERE uid1 = #{facebook_uid}) AND has_added_app = 1 OR uid = #{facebook_uid}"
    friends_xml = fbsession.fql_query :query => fql
    Hpricot.XML(friends_xml.to_s).search("//user").collect{|node|[node.search("/name").inner_html,node.search("/uid").inner_html]}
  end

  def get_me_and_friend_info(my_facebook_uid, friends_facebook_uid)
    fql = "SELECT uid, name FROM user WHERE uid IN (#{my_facebook_uid},#{friends_facebook_uid})"
    friends_xml = fbsession.fql_query :query => fql
    Hpricot.XML(friends_xml.to_s).search("//user").collect{|node|[node.search("/name").inner_html,node.search("/uid").inner_html]}
  end
  
  private
  def load_user
    @user = current_user
  end

  def sidebar(sidebar_symbol)
    old_format = request.format
    request.format = :fbml
    case sidebar_symbol
    when :home
      @news = {}
      rss = SimpleRSS.parse open('http://www.pga.com/rss/latest.rss')
      for i in 0..4
        @news[rss.items[i].title] = rss.items[i].link
      end
      load_user if @user.blank?
      @recent_courses = Course.recent_additions
      @recent_ratings = Rating.find :all, :order => "ratings.created_at desc", :limit => 10 #, :include => [:user]
      @sidebar_photos = Photo.find(:all, :limit => 6, :order => 'created_at desc')
      @sidebar_content = render_to_string(:partial => 'shared/home_sidebar')
    when :course_main
      @courses_count = Course.count
      load_user if @user.blank?
      request.format = :fbml
      @sidebar_content = render_to_string(:partial => 'shared/courses_main_sidebar')
    when :course_specific
      @course ||= Course.find(params[:id])
      @recent_rounds = @course.rounds.recent_rounds(10)
      @sidebar_content = render_to_string(:partial => 'shared/course_specific_sidebar')
    when :profile
      load_user if @user.blank?
      @viewer = current_user
      @sidebar_content = render_to_string(:partial => 'shared/profile_sidebar')
    else
      raise "Tried to call sidebar with #{sidebar_symbol}"
    end
    request.format = old_format
    true
  end

  def tab_user
    User.find_by_facebook_uid(fbparams['profile_id'])
  end

#  def tab_fbuser(fields = [])
#    fields = DEFAULT_FIELDS | fields
#
#    if @tab_fbuser.nil?
#      @tab_fbuser = tab_fbsession.users_getInfo(:uids => fbsession.session_user_id, :fields => fields)
#    end
#  end
#
#
#  def tab_fbsession
#    facebookUserId = fbparams['profile_user']
#    facebookSessionKey = fbparams['profile_session_key']
#    expirationTime = fbparams['expires']
#
#    if (facebookUserId and facebookSessionKey and expirationTime)
#      fbsession_holder.activate_with_previous_session(facebookSessionKey, facebookUserId, expirationTime)
#      RAILS_DEFAULT_LOGGER.debug "** RFACEBOOK INFO: Activated session from inside the canvas (user=#{facebookUserId}, session_key=#{facebookSessionKey}, expires=#{expirationTime})"
#    end
#
#    RAILS_DEFAULT_LOGGER.debug fbsession_holder.inspect
#    return fbsession_holder
#  end

  def fbsession

    # do a check to ensure that we nil out the fbsession_holder in case there is a new user visiting
    if session[:_rfacebook_fbsession_holder] and fbparams["session_key"] and session[:_rfacebook_fbsession_holder].session_key != fbparams["session_key"]
      session[:_rfacebook_fbsession_holder] = nil
    end

    # if we have verified fb_sig_* params, we should be able to activate the session here
    if (!fbsession_holder.ready? and facebook_platform_signature_verified?)
      # then try to activate the session somehow (or retrieve from previous state)
      # these might be nil
      facebookUserId = fbparams["user"] || fbparams['profile_user']
      facebookSessionKey = fbparams["session_key"] || fbparams['profile_session_key']
      expirationTime = fbparams["expires"]

      # activate the session if we got all the pieces of information we needed
      if (facebookUserId and facebookSessionKey and expirationTime)
        fbsession_holder.activate_with_previous_session(facebookSessionKey, facebookUserId, expirationTime)
        RAILS_DEFAULT_LOGGER.debug "** RFACEBOOK INFO: Activated session from inside the canvas (user=#{facebookUserId}, session_key=#{facebookSessionKey}, expires=#{expirationTime})"

      # warn that we couldn't get a valid Facebook session since we were missing data
      else
        RAILS_DEFAULT_LOGGER.debug "** RFACEBOOK WARNING: Tried to get a valid Facebook session from POST params, but failed"
      end
    end

    # if we still don't have a session, check the Rails session
    # (used for external and iframe apps when fb_sig POST params weren't present)
    if (!fbsession_holder.ready? and session[:_rfacebook_fbsession_holder] and session[:_rfacebook_fbsession_holder].ready?)
      RAILS_DEFAULT_LOGGER.debug "** RFACEBOOK INFO: grabbing Facebook session from Rails session"
      @fbsession_holder = session[:_rfacebook_fbsession_holder]
      @fbsession_holder.logger = RAILS_DEFAULT_LOGGER
    end

    # if all went well, we should definitely have a valid Facebook session object
    return fbsession_holder
  end

end
