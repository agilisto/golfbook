class ToursController < ApplicationController
  
  def test
    @user = current_user
    @tour = Tour.find params[:id]
    #fbsession.notifications_send :to_ids => [@user.facebook_uid].join(","), :notification => "Hi <fb:name />, this is a test notification."
    message = render_to_string :partial => "tour_accept_invite_request"
    fbsession.notifications_send :to_ids => [@user.facebook_uid].join(","), :notification => message
    flash[:notice] = message
    redirect_to :action => :index
  end
  
  def index
    @user = current_user
    @tours = Tour.paginate @user.tours, :page => params[:page], :order => :name
    
    @upcoming_tours = TourDate.upcoming_tours
    
#    @upcoming_tours = []
#    @user.tours.upcoming.each { |t| @upcoming_tours << t }
#    @user.tour_entries.upcoming.each { |t| @upcoming_tours << t }
    
    @action = :tours
    respond_to do |format|
      format.fbml # index.html.erb
      format.xml  { render :xml => @tours }
    end
  end
  
  def friends_tours
    @user = current_user
    #xml_friends_get = fbsession.friends_get
    #friends_uids = xml_friends_get.search("//uid").map{|uidnode| uidnode.inner_html.to_i}
    friends_uids = fbsession.friends_get.uid_list
    users = User.find_all_by_facebook_uid friends_uids
    uids = []
    users.each { |u| uids << u.id }
    @tours = Tour.paginate Tour.find_all_by_user_id(uids), :page => params[:page], :order => :name
    @upcoming_tours = TourDate.upcoming_tours
    
    @action = :friends_tours
    render :action => :index
  end
  
  def new
    @user = current_user
    @tour = Tour.new(:user => @user)
    @action = :newtour
  end
  
  def create
    @user = current_user
    @tour = Tour.new(params[:tour])
    @user.tours << @tour
    @user.save!

    redirect_to :action => :show, :id => @tour.id
  end
  
  def show
    @user = current_user
    @tour = Tour.find params[:id]
    @action = :show
  end
  
  def edit
    @user = current_user
    @tour = Tour.find params[:id]
    @action= :edit
  end
  
  def update
    @tour = Tour.find params[:tour][:id]
    @tour.update_attributes(params[:tour])
    @tour.save!
    redirect_to :action => :show, :id => @tour.id
  end
  
  def search_for_course_by_name
    @user = current_user
    @tour = Tour.find params[:id]
  end
  
  def search_for_course_by_location
    @user = current_user
    @tour = Tour.find params[:id]
  end
  
  def search_results
    @tour = Tour.find params[:id]
    course = params[:course]
    course_name = course["course_name"]
    RAILS_DEFAULT_LOGGER.debug "Course name: #{course_name}"
    @courses = Course.find :all, :conditions => ["name like :name and awaiting_review = false", {:name => course_name + "%"}]
    
    @tourdates = []
    @courses.each do |c|
      @tourdates << TourDate.new(:tour => @tour, :course => c)
    end
    
    @user = current_user
    @courses_count = @tourdates.length
    #@tourdates = TourDate.paginate @tourdates, :page => params[:page]#, :order => :course.name
  end
  
  def search_results_by_loc
    @tour = Tour.find params[:id]
    location = params[:course][:location]
    @courses = Course.find :all, :conditions => 'awaiting_review = false', :origin => location, :within => 10
    @tourdates = []
    @courses.each do |c|
      @tourdates << TourDate.new(:tour => @tour, :course => c)
    end
    
    @user = current_user
    @courses_count = @tourdates.length
    render :action => :search_results
  end
  
  def add_course
    @user = current_user
    @tour_date = TourDate.new params[:tour_date]
    @tour_date.save!
    @tour = @tour_date.tour
    @course = @tour_date.course
    uids = []
    @tour.users.each do |u|
      uids << u.facebook_uid
    end
    message = render_to_string :partial => "tour_course_added"
    fbsession.notifications_send :to_ids => uids.join(","), :notification => message
    redirect_to :action => "courses", :id => @tour_date.tour.id
  end
  
  def add_course_to_tour
    @user = current_user
    @course = Course.find params[:course_id]
    @tours = @user.tours
  end
  
  def add_course_to_tour_proc
    @user = current_user
    @course = Course.find params[:course_id]
    @tour = Tour.find params[:tour_id]
    @tourdates = []
    @tourdates << TourDate.new(:tour => @tour, :course => @course)
    @courses_count = @tourdates.length
    render :action => :search_results
  end
  
  def addplayers
    @user = current_user
    @tour = Tour.find params[:id]
    
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
    
    #exclude friends already on the tour
    @tour.users.each do |u|
      @friend_ids << u.facebook_uid
    end    
    
    #now exclude friends who don't have the app
    @friends.each do |uid, name|
      if !@friend_ids.include? uid
        @friend_ids << uid
      end
    end

    @friend_ids = @friend_ids.join(',')
  end
  
  def invite
    @user = current_user
    @tour = Tour.find params[:id]
  end
  
  def accept_invite
    @tour = Tour.find params[:id]
    if params[:response] == "Accept"
      @user = current_user
      if !@tour.user_on_tour? @user
        @tour.users << @user
        @tour.save!
      end
      message = render_to_string :partial => "tour_accept_invite"
      fbsession.notifications_send :to_ids => [@tour.user.facebook_uid].join(","), :notification => message
      redirect_to :action => :show, :id => @tour.id
    else
      redirect_to :controller => :home, :action => :index
    end
  end
  
  def requestinvite
    flash[:notice] = "Your request has been sent."
    redirect_to :action => :show, :id => params[:id]
  end
  
  def acceptplayer
    @user = current_user
    @tour = Tour.find params[:id]
    @player = User.find params[:player_id]
    if !@tour.user_on_tour? @player
      @tour.users << @player
      @tour.save!
    end
    message = render_to_string :partial => "tour_accept_invite_request"
    fbsession.notifications_send :to_ids => [@player.facebook_uid].join(","), :notification => message
    redirect_to :action => :players, :id => @tour.id
  end
  
  def courses
    @user = current_user
    @tour = Tour.find params[:id]
    @tour_dates = TourDate.paginate @tour.tour_dates, :page => params[:page], :order => :to_play_at
    #@courses = Course.paginate @tour.courses, :page => params[:page], :order => :name
    @action = :courses
  end
  
  def players
    @user = current_user
    @tour = Tour.find params[:id]
    @players = [ @tour.user ]
    @tour.users.each do |u|
      @players << u
    end
    @action = :players
  end
  
  def close_entries
    @tour = Tour.find params[:id]
    @tour.open_for_entry = false
    @tour.save!
    flash[:notice] = "Tour is closed for entries."
    redirect_to :action => :show, :id => @tour.id
  end
  
  def open_entries
    @tour = Tour.find params[:id]
    @tour.open_for_entry = true
    @tour.save!
    flash[:notice] = "Tour is open for entries."
    redirect_to :action => :show, :id => @tour.id
  end
end

