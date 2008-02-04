class CoursesController < ApplicationController
    
   # GET /courses
   # GET /courses.xml
   def index
     @user = current_user
     @courses_count = Course.count
     @courses = Course.paginate :all, :page => params[:page], :order => :name
     
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

   # GET /courses/1
   # GET /courses/1.xml
   def show
     @user = current_user
     @course = Course.find(params[:id])
     # @geolocations = @course.calc_geolocations(true) 

     @recent_rounds = @course.rounds.recent_rounds(10)
     @friends_recent_rounds = @course.rounds.by_facebook_uids(fbsession.friends_get.uid_list) 
     
     @action = :course
    
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
   end
   
   def perform_search
     
   end
   
   def lookup
     @courses = Course.find :all, :conditions => ["name like ?", params[:suggest_typed]]
     @count = @courses.count
     #RAILS_DEFAULT_LOGGER.debug "Courses: #{@count}"
     names = @courses.each {|course| course.name << "," }
     #RAILS_DEFAULT_LOGGER.debug "Names: #{names}"
     render :text => "{fortext:#{params[:suggest_typed].to_json},results:#{names.to_json}}"
   end

end
