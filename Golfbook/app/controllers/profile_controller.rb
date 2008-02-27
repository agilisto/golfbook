class ProfileController < ApplicationController

  def set_active_menu
     @current = 'profile'
  end
   
  def index
    @fbuser = fbuser(['current_location','hometown_location'])
    @user = current_user
    
    unless @user.location_set? 
      geocode_user
    end
    
    @entries = []
    @user.competitions.upcoming.each do |e|
      @entries << e if e.open
    end
    @user.competition_entries.upcoming.each do |e|
      @entries << e if e.open
    end
    
    @tours = []
    @user.tours.upcoming.each do |t|
      @tours << t # TODO: check dates
    end
    @user.tour_entries.upcoming.each do |t|
      @tours << t # TODO: check dates
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
    return false if @fbuser.current_location.city.nil? || @fbuser.current_location.country.nil? 
      
    address = @fbuser.current_location.city.concat(', ').concat(@fbuser.current_location.country)
    @user.address = address
    if @user.save then
      flash[:notice] = "Successfully auto-geocoded current location"
      true
    else
      flash[:error] = "Please set location manually, we failed to auto-geocode it based on the #{@user.address} values from your profile"
      false
    end
  end
end
