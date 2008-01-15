# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  before_filter :require_facebook_install, :adjust_format_for_facebook, :set_active_menu   
  
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
  
  def user
    if @user.nil?
      @user = User.find_or_initialize_by_facebook_uid(fbsession.session_user_id)
    end
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
    @current = 'overview_selected'
  end
      
end
