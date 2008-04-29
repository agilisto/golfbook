class CoursesController < ApplicationController
    
  DEFAULT_RADIUS = 20
  
  # GET /courses
  # GET /courses.xml
  def index
    @user = current_user
    @courses_count = Course.count
    @courses = Course.paginate :all, :conditions => 'awaiting_review = false', :page => params[:page], :order => :name #, :include => [:ratings]
     
    @action = :courses    
    
    respond_to do |format|
      format.fbml # index.html.erb
      format.xml  { render :xml => @courses }
    end
     
  end
  
  def quicksearch
    @user = current_user
  end
  
  def quicksearch_filter
    
  end
  
  def set_home_course
    home_course = Course.find params[:id]
    current_user.home_course = home_course
    current_user.save!
    message = "has set <a href='#{url_for(:controller=>:courses,:action=>:show,:id=>home_course.id)}'>#{home_course.name}</a> as his home course."
    fbsession.feed_publishActionOfUser(:title => "<fb:name /> " + message)
    redirect_to :action => :show, :id => current_user.home_course_id
  end
  
  def review
    @user = current_user
    @courses_count = Course.count
    @courses = Course.paginate :all, :conditions => 'awaiting_review = true', :page => params[:page], :order => :name #, :include => [:ratings] 
    @action = :review    
    render :action => :index
  end
  
  def review_course
    @user = current_user
    @course = Course.find params[:id]
    if params[:commit] == "Approve"
      @course.awaiting_review = false
      @course.save!
      flash[:notice] = "Course addition has been approved."
      message = "has approved your course submission - <a href='#{url_for(:controller=>:courses,:action=>:show,:id=>@course.id)}'>#{@course.name}</a>"
      fbsession.notifications_send :to_ids => @course.added_by.facebook_uid, :notification => message
      redirect_to :action => :show, :id => @course.id
    else
      message = "has declined your course submission - #{@course.name}"
      fbsession.notifications_send :to_ids => @course.added_by.facebook_uid, :notification => message
      Course.delete(@course.id)
      flash[:notice] = "Course addition has been declined."
      redirect_to :action => :review
    end
  end
   
  def course_played
    @course = Course.find(params[:id])
    current_user.has_played @course
    flash[:notice] = "#{@course.name} added to your list of played courses."
    redirect_to :action => :courses_played
  end
  
  def course_played_remote
    logger.debug("RECEIVED: #{params[:id]} played for user #{current_user.id}")
    @course = Course.find params[:id]
    current_user.has_played @course
    respond_to do |format|
      format.js
    end
  end
   
  def courses_played
    @user = current_user
    @courses_count = @user.courses.count
    @courses = @user.courses.paginate(:page => params[:page])
    @action = :courses_played
     
    respond_to do |format|
      format.fbml { render :action => :index}
      format.xml  { render :xml => @courses }
    end
  end
  
  def courses_played_for
    @user = User.find(params[:user_id])
    @courses_count = @user.courses.count
    @courses = @user.courses.paginate(:page => params[:page])
    @action = :courses_played
     
    respond_to do |format|
      format.fbml { render :action => :index}
      format.xml  { render :xml => @courses }
    end
  end
  
  def highest_rated_loc
    @user = current_user
    @action = :highest_rated
    courses = Course.find(:all, :within => DEFAULT_RADIUS, :origin => @user)
    rated = {}
    courses.each do |c|
      if c.rating > 0
        rated[c] = c.rating
      end
    end
    arr = rated.sort {|a,b| -1*(a[1]<=>b[1]) }
    @courses = []
    arr.each { |a| @courses << a[0] }
    @courses_count = @courses.length
  end
  
  def filter_by_loc_unrated
    @user = current_user
    @location = params["location"]
    logger.debug "Geocoding location: #{@location}"
    @latitude, @longitude = geocode_location @location
    logger.debug "Latitude: #{@latitude}, Longitude: #{@longitude}"
    begin
      courses = Course.find :all, :origin => [@latitude, @longitude], :within => DEFAULT_RADIUS
    rescue StandardError => e
      logger.debug "ERROR: #{e.inspect}"
      courses = []
    end
    RAILS_DEFAULT_LOGGER.debug "Found #{courses.length} courses"
    rated = {}
    courses.each do |c|
      #if c.rating > 0
      rated[c] = c.rating
      #end
    end
    arr = rated.sort {|a,b| -1*(a[1]<=>b[1]) }
    @courses = []
    arr.each { |a| @courses << a[0] }
    RAILS_DEFAULT_LOGGER.debug "Sorted #{@courses.length} courses"
    if @courses.length > 0
      @courses_count = @courses.length
      request.format = :fbml
      render :action => 'filter_by_loc_unrated', :layout => false
    else
      logger.debug "Didn't find any course, checking location.."
      criteria = Geonames::ToponymSearchCriteria.new
      criteria.name_starts_with = @location.split(' ')[0]
      criteria.max_rows = '10'
      results = Geonames::WebService.search(criteria).toponyms
      @names = results.map {|n| n.name << ', ' << n.country_name }
      request.format = :fbml
      render :action => :choose_location, :layout => false
    end
  end
  
  def filter_by_loc
    @user = current_user
    @location = params["location"]
    RAILS_DEFAULT_LOGGER.debug "Checking location: #{@location}"
    courses = Course.find :all, :origin => @location, :within => DEFAULT_RADIUS
    RAILS_DEFAULT_LOGGER.debug "Found #{courses.length} courses"
    rated = {}
    courses.each do |c|
      if c.rating > 0
        rated[c] = c.rating
      end
    end
    arr = rated.sort {|a,b| -1*(a[1]<=>b[1]) }
    @courses = []
    arr.each { |a| @courses << a[0] }
    RAILS_DEFAULT_LOGGER.debug "Sorted #{@courses.length} courses"
    @courses_count = @courses.length
    request.format = :fbml
    render :action => 'filter_by_loc', :layout => false
  end

  # GET /courses/1
  # GET /courses/1.xml
  def show
    @user = current_user
    @course = Course.find(params[:id])
    # @geolocations = @course.calc_geolocations(true) 

    @recent_rounds = @course.rounds.recent_rounds(10)
    @action = :course
     
    uids = fbsession.friends_get.uid_list
    @friends_recent_rounds = @course.rounds.by_facebook_uids(uids) 
    uids << fbsession.session_user_id
    @friends_best_rounds = @course.rounds.best_rounds_by_facebook_uids(uids)
      
    @reviews = @course.reviews.paginate(:page => params[:page], :order => 'created_at DESC')     
    @review = Review.new
    
    @games = @user.games.for_course @course
    @user.games_to_play.for_course(@course).each do |g|
      @games << g
    end
    
    @home_users = User.find_all_by_home_course_id @course.id
         
    respond_to do |format|
      format.fbml # show.html.erb
      format.xml  { render :xml => @course }
    end  
   
  end
  
  def new_map
    @user = current_user
    @course = Course.new
  end

  # GET /courses/new
  # GET /courses/new.xml
  def new
    @user = current_user
    @course = Course.new(:latitude=>params[:lat],:longitude=>params[:lng])

    respond_to do |format|
      format.fbml # new.html.erb
      format.xml  { render :xml => @course }
    end
  end

  # GET /courses/1/edit
  def edit
    @user = current_user
    @course = Course.find(params[:id])
  end

  # POST /courses
  # POST /courses.xml
  def create
    @user = current_user
    @course = Course.new(params[:course])
    @course.awaiting_review = true
    @course.added_by = @user
    
    respond_to do |format|
      if @course.save
        flash[:notice] = 'Your course was submitted for review.'
        
        # send notifications to admins
        admins = User.find_all_by_admin true
        uids = []
        admins.each { |a| uids << a.facebook_uid }
        message = "has submitted a new course for review - <a href='#{url_for(:controller=>:courses,:action=>:show,:id=>@course.id)}'>#{@course.name}</a>"
        fbsession.notifications_send :to_ids => uids.join(","), :notification => message
        
        format.fbml { redirect_to :action => 'show', :id => @course.id }
        format.xml  { render :xml => @course, :status => :created, :location => @course }
      else
        format.fbml { render :action => "new" }
        format.xml  { render :xml => @course.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /courses/1
  # PUT /courses/1.xml
  def update
   
    @course = Course.find(params[:course][:id])

    respond_to do |format|
      if @course.update_attributes(params[:course])
        flash[:notice] = 'Course was successfully updated.'
        format.fbml { redirect_to(:action => :show, :id => @course.id) }
        format.xml  { head :ok }
      else
        format.fbml { render :action => "edit" }
        format.xml  { render :xml => @course.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /courses/1
  # DELETE /courses/1.xml
  def destroy
    @course = Course.find(params[:id])
    @course.destroy

    respond_to do |format|
      format.fbml { redirect_to(:action => :index) }
      format.xml  { head :ok }
    end
  end
   
  def search
    @action = :search
    @courses_count = current_user.courses.count
    
    respond_to do |format|
      format.fbml
      format.xml  { render :xml => @courses }
    end
  end
  
  # Facebook don't pass the proper format for async requests
  # hence the additional search overload
  def filter_by_name
    @search = params["course_filter"]
    RAILS_DEFAULT_LOGGER.debug "Course name: #{@search}"
    @courses = Course.find :all, :conditions => ["name like :name and awaiting_review = false", {:name => "%#{@search}%"}] #, :include => [:ratings]
    
    @user = current_user
    @courses_count = @courses.length
    @courses = Course.paginate @courses, :page => params[:page], :order => :name
    request.format = :fbml  
    render :action => 'filter_by_name', :layout => false
  end
   
  def search_results
    course = params[:course]
    course_name = course["course_name"]
    RAILS_DEFAULT_LOGGER.debug "Course name: #{course_name}"
    @courses = Course.find :all, :conditions => ["name like :name and awaiting_review = false", {:name => "%" + course_name + "%"}] #, :include => [:ratings]
    
    @user = current_user
    @courses_count = @courses.length
    @courses = Course.paginate @courses, :page => params[:page], :order => :name
    @action = :search
    
    respond_to do |format|
      format.fbml # index.html.erb
      format.xml  { render :xml => @courses }
    end
  end
  
  def schedule_game
    @user = current_user
    @course = Course.find params[:id]
    @game = Game.new(:user => @user, :course => @course)
    @recent_rounds = @course.rounds.recent_rounds(10)
  end
  
  def schedule_game_notify
    @user = current_user
    @game = Game.find params[:game_id]
    
    email_body =  render_to_string :partial => 'emails/schedule_game_invite', :locals => {:game => @game}
    
    fbsession.notifications_sendemail :recipients => params[:ids], :subject => "Golfbook Game Invite", 
      :fbml => email_body
    flash[:notice] = "Your friends have been invited"
    redirect_to :action => :show, :id => @game.course.id
  end
  
  def save_game
    @user = current_user
    @game = Game.new(params[:game])
    @game.save!
    update_profile_box(@user.id)
    redirect_to :action => :schedule_game_invite, :id => @game.id
  end
    
  def schedule_game_invite
    @user = current_user
    @game = Game.find params[:id]
    @course = @game.course
    @recent_rounds = @course.rounds.recent_rounds(10)
    
    # get all friends who DON'T have the app installed
    fql =  "SELECT uid, name FROM user WHERE uid IN" +
      "(SELECT uid2 FROM friend WHERE uid1 = #{@user.facebook_uid}) " +
      "AND has_added_app = 0" 
    xml_friends = fbsession.fql_query :query => fql
    @friends = Hash.new
    xml_friends.search("//user").map do|usrNode| 
      @friends[(usrNode/"uid").inner_html] = (usrNode/"name").inner_html
    end
    
    #create an exclusion list
    @friend_ids = []  
    
    #now exclude friends who don't have the app
    @friends.each do |uid, name|
      if !@friend_ids.include? uid
        @friend_ids << uid
      end
    end
    
    #exclude friends already playing the game
    @game.users.each do |u|
      if !@friend_ids.include? u.facebook_uid
        @friend_ids << u.facebook_uid
      end
    end

    @friend_ids = @friend_ids.join(',')
  end
  
  def join_game
    @user = current_user
    @game = Game.find params[:id]
    @game.users << @user
    @game.save!
    flash[:notice] = "You have accepted the game invitation.";
    message = "will join you for your game at <a href='#{url_for(:controller=>:courses,:action=>:show,:id=>@game.course_id)}'>#{@game.course.name}</a> on #{@game.date_to_play.to_formatted_s(:long)}."
    fbsession.notifications_send :to_ids => @game.user.facebook_uid, :notification => message
    update_profile_box(@user.id)
    redirect_to :action => :show, :id => @game.course_id
  end
  
  def cancel_game
    @user = current_user
    @game = Game.find params[:id]
    Game.delete @game.id
    message = "has cancelled his game at <a href='#{url_for(:controller=>:courses,:action=>:show,:id=>@game.course_id)}'>#{@game.course.name}</a> on #{@game.date_to_play.to_formatted_s(:long)}."
    fbsession.feed_publishActionOfUser(:title => "<fb:name /> " + message)
    uids = [ @game.user.facebook_uid ]
    @game.users.each { |u| uids << u.facebook_uid }
    fbsession.notifications_send :to_ids => uids.join(","), :notification => message
    flash[:success] = "Game has been cancelled."
    update_profile_box(@user.id)
    redirect_to :action => :show, :id => @game.course_id
  end
  
  def report_course
    @user = current_user
    @course = Course.find params[:id]
  end
  
  def report_proc
    @user = current_user
    @course = Course.find params[:course_id]
    
    # send notifications to admins
    admins = User.find_all_by_admin true
    uids = []
    admins.each { |a| uids << a.facebook_uid }
    message = "has submitted a comment for <a href='#{url_for(:controller=>:courses,:action=>:show,:id=>@course.id)}'>#{@course.name}</a>: #{params[:comments]}"
    fbsession.notifications_send :to_ids => uids.join(","), :notification => message
    flash[:notice] = "Your comment has been sent to the admins."
    redirect_to :action => :show, :id => @course.id
  end
  
  def lookup
    RAILS_DEFAULT_LOGGER.debug "Search string: #{params[:suggest_typed]} .. length: #{params[:suggest_typed].length}"
    if params[:suggest_typed].nil? || params[:suggest_typed].blank? || params[:suggest_typed].length == 0
      return
    else
      search_string = params[:suggest_typed] + "%"
      @courses = Course.find :all, :conditions => ["name like :name and awaiting_review = false", {:name => "%#{search_string}%"}]
      @count = @courses.length
      RAILS_DEFAULT_LOGGER.debug "Courses: #{@count}"
      names = @courses.map {|course| course.name }
      RAILS_DEFAULT_LOGGER.debug "Names: #{names}"
      render :text => "{fortext:#{params[:suggest_typed].to_json},results:#{names.to_json}}"
    end
  end
  
end
