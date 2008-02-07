class ToursController < ApplicationController
  def index
    @user = current_user
    @tours = Tour.paginate @user.tours, :page => params[:page], :order => :name
    @action = :tours
    respond_to do |format|
      format.fbml # index.html.erb
      format.xml  { render :xml => @tours }
    end
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
  
  def search_for_course
    @user = current_user
    @tour = Tour.find params[:id]
  end
  
  def search_results
    @tour = Tour.find params[:id]
    course = params[:course]
    course_name = course["course_name"]
    RAILS_DEFAULT_LOGGER.debug "Course name: #{course_name}"
    @courses = Course.find :all, :conditions => ["name like :name", {:name => course_name + "%"}]
    
    @tourdates = []
    @courses.each do |c|
      @tourdates << TourDate.new(:tour => @tour, :course => c)
    end
    
    @user = current_user
    @courses_count = @tourdates.length
    #@tourdates = TourDate.paginate @tourdates, :page => params[:page]#, :order => :course.name
  end
  
  def add_course
    @user = current_user
    @tour_date = TourDate.new params[:tour_date]
    @tour_date.save!
    redirect_to :action => "show", :id => @tour_date.tour.id
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
      @ids = [ @tour.user.id ]
      @tour.users.each do |u|
        @ids << u.id
      end
      if !@ids.include? @user.id
        @tour.users << @user
        @tour.save!
      end
      redirect_to :action => :show, :id => @tour.id
    else
      redirect_to :controller => :home, :action => :index
    end
  end
  
  def courses
    @user = current_user
    @tour = Tour.find params[:id]
    @courses = Course.paginate @tour.courses, :page => params[:page], :order => :name
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
end

