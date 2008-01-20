class CoursesController < ApplicationController

   def set_active_menu
     @current = 'courses_selected'
   end
    
   # GET /courses
   # GET /courses.xml
   def index
     @courses_count = Course.count
     @courses = Course.paginate :all, :page => params[:page], :order => :name

     
     respond_to do |format|
       format.fbml # index.html.erb
       format.xml  { render :xml => @courses }
     end
   end

   # GET /courses/1
   # GET /courses/1.xml
   def show
     @course = Course.find(params[:id])
     # @geolocations = @course.calc_geolocations(true) 

     @recent_rounds = @course.rounds.recent_rounds(10)
        
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

end
