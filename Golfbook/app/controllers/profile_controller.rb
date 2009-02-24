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
    redirect_to :action => :show, :id => @user.id
  end
  
  def users
    @user = current_user
    @users = User.paginate :page => params[:page]
    @action = :users
  end
  
  def makeadmin
    @user = User.find params[:id]
    @user.admin = !@user.admin
    @user.save!
    redirect_to :action => :show, :id => @user.id
  end
  
  def goal
    @user = current_user
  end
  
  def set_goal
    @user = current_user
    @user.goal = params[:user][:goal]
    @user.save!
    redirect_to :action => :show, :id => @user.id
  end
  
  def update_profile_test
    update_profile_box params[:id]
  end
  
  def show
    @viewer = current_user
    @user = User.find params[:id]
    sidebar :profile
    
    if @viewer == @user
      fql =  "SELECT uid, name FROM user WHERE uid IN" +
        "(SELECT uid2 FROM friend WHERE uid1 = #{@user.facebook_uid}) " +
        "AND has_added_app = 1"
      friends_xml = fbsession.fql_query :query => fql
      @fql_friends = friends_xml.user_list
      @friends_count = @fql_friends.size
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
      @tours << t
    end
    @user.tour_entries.upcoming.each do |t|
      @tours << t
    end
    
    @rounds = @user.rounds.recent 5
    
    @action = :profile
  end
  
  def rounds
    @user = User.find params[:id]
    @rounds = Round.paginate_by_user_id @user.id, :page => params[:page], :order => 'date_played desc' 
    @action = :rounds
  end

  def location
    @user = User.find_or_initialize_by_facebook_uid(fbsession.session_user_id)
    @action = :location
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
