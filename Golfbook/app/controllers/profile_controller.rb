class ProfileController < ApplicationController

  def set_active_menu
     @current = 'profile'
  end
   
  def index
    @fbuser = fbsession.users_getInfo(
      :uids => [fbsession.session_user_id],
      :fields => ['first_name','last_name','current_location','hometown_location']).user_list[0]
  
    @user = User.find_or_initialize_by_facebook_uid(fbsession.session_user_id)
    unless @user.location_set? 
      geocode_user
    end
  end

  def location
    @user = User.find_or_initialize_by_facebook_uid(fbsession.session_user_id)
  end
  
  def process_location
    @user = User.find_or_initialize_by_facebook_uid(fbsession.session_user_id)
    @user.update_attributes(params[:user])
    if @user.geocode then
      @user.save!
      flash[:notice] = "Your location has been saved"
      redirect_to :action => :index
    else
      flash[:error] = "We can't resolve your location"
      render :action => :location
    end
  end
  
  private 
  def geocode_user
    address = @fbuser.current_location.city.concat(', ').concat(@fbuser.current_location.country)
    @user.address = address
    if @user.save then
      flash[:notice] = "Successfully auto-geocoded current location"
    else
      flash[:error] = "Please set location manually, we failed to auto-geocode it based on the #{@user.address} values from your profile"
    end
  end
end
