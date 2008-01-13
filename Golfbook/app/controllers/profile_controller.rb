class ProfileController < ApplicationController

  def set_active_menu
     @current = 'profile'
  end
   
  def index
    
    @fbuser = fbsession.users_getInfo(
      :uids => [fbsession.session_user_id],
      :fields => ['first_name','last_name','current_location','hometown_location']).user_list[0]
    
    p @fbuser.inspect  
    p @fbuser.first_name
    #User.find_or_create_by_facebook_uid(fbsession.session_user_id)
  end

  def location
  end
end
