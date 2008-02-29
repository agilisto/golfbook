class CoursesController < ApplicationController
    
  DEFAULT_RADIUS = 20
  
  # GET /courses
  # GET /courses.xml
  def index
    @user = current_user
    @courses_count = Course.count
    @courses = Course.paginate :all, :page => params[:page], :order => :name #, :include => [:ratings]
     
    @action = :courses    
    
    respond_to do |format|
      format.fbml # index.html.erb
      format.xml  { render :xml => @courses }
    end
     
  end
   
  def course_played
    @course = Course.find(params[:id])
    current_user.has_played @course
    flash[:notice] = "#{@course.name} added to your list of played courses."
    redirect_to :action => :courses_played
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
    RAILS_DEFAULT_LOGGER.debug "Location: #{@location}"
    courses = Course.find :all, :origin => @location, :within => DEFAULT_RADIUS
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
    @courses_count = @courses.length
    request.format = :fbml
    render :action => 'filter_by_loc_unrated', :layout => false
  end
  
  def filter_by_loc
    @user = current_user
    @location = params["location"]
    RAILS_DEFAULT_LOGGER.debug "Location: #{@location}"
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
         
    respond_to do |format|
      format.fbml # show.html.erb
      format.xml  { render :xml => @course }
    end  
   
  end

  # GET /courses/new
  # GET /courses/new.xml
  def new
    @course = Course.new

    respond_to do |format|
      format.fbml # new.html.erb
      format.xml  { render :xml => @course }
    end
  end

  # GET /courses/1/edit
  def edit
    @course = Course.find(params[:id])
  end

  # POST /courses
  # POST /courses.xml
  def create
    @course = Course.new(params[:course])
    
    respond_to do |format|
      if @course.save
        flash[:notice] = 'Course was successfully created.'
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
   
    @course = Course.find(params[:id])

    respond_to do |format|
      if @course.update_attributes(params[:course])
        flash[:notice] = 'Course was successfully updated.'
        format.fbml { redirect_to(:action => :index) }
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
    course_name = params["course_filter"]
    RAILS_DEFAULT_LOGGER.debug "Course name: #{course_name}"
    @courses = Course.find :all, :conditions => ["name like :name", {:name => course_name + "%"}] #, :include => [:ratings]
    
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
    @courses = Course.find :all, :conditions => ["name like :name", {:name => course_name + "%"}] #, :include => [:ratings]
    
    @user = current_user
    @courses_count = @courses.length
    @courses = Course.paginate @courses, :page => params[:page], :order => :name
    @action = :search
    
    respond_to do |format|
      format.fbml # index.html.erb
      format.xml  { render :xml => @courses }
    end
  end
  
  def lookup
    RAILS_DEFAULT_LOGGER.debug "Search string: #{params[:suggest_typed]} .. length: #{params[:suggest_typed].length}"
    if params[:suggest_typed].nil? || params[:suggest_typed].blank? || params[:suggest_typed].length == 0
      return
    else
      search_string = params[:suggest_typed] + "%"
      @courses = Course.find :all, :conditions => ["name like :name", {:name => search_string}]
      @count = @courses.length
      RAILS_DEFAULT_LOGGER.debug "Courses: #{@count}"
      names = @courses.map {|course| course.name }
      RAILS_DEFAULT_LOGGER.debug "Names: #{names}"
      render :text => "{fortext:#{params[:suggest_typed].to_json},results:#{names.to_json}}"
    end
  end
  
end
