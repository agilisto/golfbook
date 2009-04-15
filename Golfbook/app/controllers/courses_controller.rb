class CoursesController < ApplicationController

  DEFAULT_RADIUS = 20

  # GET /courses
  # GET /courses.xml
  def index
    sidebar :course_main
    @recently_rated_courses = Course.recently_rated(3)  #courses that have recently been rated
    @recently_reviewed_courses = Course.recently_reviewed(3)  #courses that have recently beed reviewed

    friends_uids = fbsession.friends_get.uid_list rescue nil
    @friends_recent_courses = Course.recently_played_by_friends(friends_uids,3)  #courses where your friends had recently played/reviewed/rated

    @action = :courses

    respond_to do |format|
      format.fbml # index.html.erb
#      format.xml  { render :xml => @courses }
    end
  end

  def list
    sidebar :course_main
    @courses = Course.paginate :all, :conditions => 'awaiting_review = false', :page => params[:page], :order => :name #, :include => [:ratings]
    @action = :courses

    respond_to do |format|
      format.fbml
    end
  end

  def quicksearch
    sidebar :course_main
    @what = params[:what]
    @user = current_user

    case @what
    when "score"
      @round = Round.new
      @search_desc = "Post a Score"
      @course_partial = "course_postscore"
    when "schedule"
      @game = Game.new(:user => @user)
      @search_desc = "Schedule a Game"
      @course_partial = "course_schedule"
    when "rate"
      @search_desc = "Rate a Course"
      @course_partial = "course_rate"
    end

    @courses = @user.home_course.nil? ? [] : [ @user.home_course ]
    @user.rounds.recent(5).each do |round|
      @courses << round.course
    end
    @courses.uniq!
  end

  def quicksearch_filter
    @search = params[:course_filter]
    @what = params[:what]
    RAILS_DEFAULT_LOGGER.debug "Quick search: #{@search}"
    @courses = search_by_name(@search)
    names = []
    @courses.each { |course| names << course.name }
    RAILS_DEFAULT_LOGGER.debug "Courses: #{names.join(', ')}"
    @courses_count = @courses.length
    RAILS_DEFAULT_LOGGER.debug "Quick search complete!"
    
    case @what
    when "score"
      @round = Round.new
      @search_desc = "Post a Score"
      @course_partial = "course_postscore"
    when "schedule"
      @game = Game.new(:user => @user)
      @search_desc = "Schedule a Game"
      @course_partial = "course_schedule"
    end
    
    request.format = :fbml
    render :layout => false
  end

  def set_home_course
    home_course = Course.find params[:id]
    current_user.home_course = home_course
    current_user.save!
#    message = "has set <a href='#{url_for(:controller=>:courses,:action=>:show,:id=>home_course.id)}'>#{home_course.name}</a> as his home course."
#    fbsession.feed_publishActionOfUser(:title => "<fb:name /> " + message)
    redirect_to :action => :show, :id => current_user.home_course_id
  end
    
  def players
    @course = Course.find params[:id]
    @players = User.paginate @course.users, :page => params[:page]
  end
  
  def rounds
    @course = Course.find params[:id]
    @rounds = Round.paginate :all, :conditions => [ "course_id = ?", @course.id ], :order => "score asc", :page => params[:page]
  end
  
  def review
    @courses_count = Course.count
    @courses = Course.paginate :all, :conditions => 'awaiting_review = true', :page => params[:page], :order => :name #, :include => [:ratings]
    @action = :review
    render :action => :index
  end

  def review_course
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

  #My Courses
  def courses_played
    @user = User.find(params[:id]) rescue current_user
    sidebar :course_main
    name = %{<fb:name uid="#{@user.facebook_uid}" capitalize="true" possessive="true" linked="false"/>}
    @courses_results_title = "#{name} Courses"
    @courses_count = @user.courses.count
    @courses = @user.courses.paginate(:page => params[:page])
    @action = :courses_played

    respond_to do |format|
      format.fbml { render :action => :list}
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

  def top_rated
    sidebar :course_main
    @courses_results_title = "Top Rated"
    @courses = Course.find(:all, :within => DEFAULT_RADIUS, :origin => @user)
    @courses = @courses.sort_by{|x|x.rating}
    @courses = @courses.paginate(:page => params[:page])

    respond_to do |format|
      format.fbml {render :action => :list}
    end
  end

  def highest_rated_loc
    sidebar :course_main
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
    render :action => :list
  end

  def filter_by_loc_unrated
    sidebar :course_main
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
    sidebar :course_main
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
    @course = Course.find(params[:id])
    @photos = PhotoAsset.photos_for(@course, 8)
    # @geolocations = @course.calc_geolocations(true)
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

    sidebar :course_specific
    respond_to do |format|
      format.fbml # show.html.erb
      format.xml  { render :xml => @course }
    end
  end

  def caddies
    @course = Course.find(params[:id], :include => :caddies)
    @caddy = Caddy.new(:course_id => @course.id)
    sidebar :course_specific
  end

  def add_caddy
    @caddy = Caddy.new(params[:caddy])
    if @caddy.save
      Activity.log_activity(@caddy, Activity::ADDED, @current_user.id)
      flash[:notice] = 'The caddie was successfully added.'
      redirect_to :action => :caddies, :id => @caddy.course_id
    else
      @course = Course.find(params[:caddy][:course_id], :include => :caddies)
      @recent_rounds = @course.rounds.recent_rounds(10)
      flash[:error] = 'The caddie could not be added.'
      sidebar :course_specific
      render :action => :caddies
    end
  end


  def new_map
    sidebar :course_main
    @course = Course.new
  end

  # GET /courses/new
  # GET /courses/new.xml
  def new
    sidebar :course_main
    @course = Course.new(:latitude=>params[:lat],:longitude=>params[:lng])
    @nearby_courses = Course.find :all, :origin => [params[:lat],params[:lng]], :within => DEFAULT_RADIUS
    respond_to do |format|
      format.fbml # new.html.erb
      format.xml  { render :xml => @course }
    end
  end

  # GET /courses/1/edit
  def edit
    @course = Course.find(params[:id])
    sidebar :course_specific
  end

  # POST /courses
  # POST /courses.xml
  def create
    @course = Course.new(params[:course])
    @course.awaiting_review = true
    @course.added_by = @user

    respond_to do |format|
      if @course.save
        Activity.log_activity(@course, Activity::ADDED, @current_user.id)
        publish_course_added_action(@course.id)
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
        sidebar :course_main
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
        sidebar :course_specific
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
    sidebar :courses_main
    @action = :search
    @courses_count = current_user.courses.count

    respond_to do |format|
      format.fbml
      format.xml  { render :xml => @courses }
    end
  end

  def search_by_name name
    RAILS_DEFAULT_LOGGER.debug "Search course name: #{name}"
    Course.find :all, :conditions => ["name like :name and awaiting_review = false", {:name => "%#{name}%"}]
  end

  # Facebook don't pass the proper format for async requests
  # hence the additional search overload
  def filter_by_name
    @search = params["course_filter"]
    @courses = search_by_name(@search)
    @courses_count = @courses.length
    @courses = Course.paginate @courses, :page => params[:page], :order => :name
    request.format = :fbml
    sidebar :course_main
    render :layout => false
  end

  def search_results
    sidebar :courses_main
    course = params[:course]
    course_name = course["course_name"]
    #@courses = Course.find :all, :conditions => ["name like :name and awaiting_review = false", {:name => "%" + course_name + "%"}] #, :include => [:ratings]
    @courses = search_by_name(course_name)
    @courses_count = @courses.length
    @courses = Course.paginate @courses, :page => params[:page], :order => :name
    @action = :search

    respond_to do |format|
      format.fbml # index.html.erb
      format.xml  { render :xml => @courses }
    end
  end

  def schedule_game
    @course = Course.find params[:id]
    sidebar :course_specific
    @game = Game.new(:user => @user, :course => @course)
    @recent_rounds = @course.rounds.recent_rounds(10)
  end

  def schedule_game_notify
    @game = Game.find params[:game_id]
    @course = @game.course
    email_body =  render_to_string :partial => 'emails/schedule_game_invite', :locals => {:game => @game}

    unless params[:ids].blank?
      fbsession.notifications_sendemail :recipients => params[:ids], :subject => "Golfbook Game Invite",
        :fbml => email_body
      flash[:notice] = "Your friends have been invited"
    else
      flash[:notice] = "You did not invite any friends to join you."
    end
    sidebar :course_specific
    redirect_to :action => :show, :id => @game.course.id
  end

  def save_game
    @game = Game.new(params[:game])
    if @game.course.nil? && params[:course_id]
      @game.course = Course.find(params[:course_id])
    end
    @game.save!
    update_profile_box(@user.id)
    redirect_to :action => :schedule_game_invite, :id => @game.id
  end

  def schedule_game_invite
    @game = Game.find params[:id]
    @course = @game.course
    sidebar :course_specific

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
    sidebar :course_specific
  end

  def report_proc
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
    #RAILS_DEFAULT_LOGGER.debug "Search string: #{params[:suggest_typed]} .. length: #{params[:suggest_typed].length}"
    if params[:suggest_typed].nil? || params[:suggest_typed].blank? || params[:suggest_typed].length == 0
      return
    else
      search_string = params[:suggest_typed] + "%"
      @courses = Course.find :all, :conditions => ["name like :name and awaiting_review = false", {:name => "%#{search_string}%"}]
      @count = @courses.length
      #RAILS_DEFAULT_LOGGER.debug "Courses: #{@count}"
      names = @courses.map {|course| course.name }
      #RAILS_DEFAULT_LOGGER.debug "Names: #{names}"
      render :text => "{fortext:#{params[:suggest_typed].to_json},results:#{names.to_json}}"
    end
  end

#  private
#  def rescue_action(exception)
#    puts "=================="
#    puts exception.message
#    puts exception.backtrace.join("\n")
#    puts "=================="
#    throw exception
#  end


end

