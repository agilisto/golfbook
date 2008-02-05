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
    @tour_date = TourDate.new params[:tour_date]
    @tour_date.save!
    redirect_to :action => "show", :id => @tour_date.tour.id
  end
  
  def addplayers
    @user = current_user
    @tour = Tour.find params[:id]
  end
end

