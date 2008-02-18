class CompetitionsController < ApplicationController
  def index
    @user = current_user
    @competitions = Competition.paginate @user.competitions, :page => params[:page], :order => :name
    @action = :competitions
    respond_to do |format|
      format.fbml # index.html.erb
      format.xml  { render :xml => @competitions }
    end

  end

  def new
    @user = current_user
    @competition = Competition.new(:user => @user)
    @action = :new_competition
  end
  
  def create
    @user = current_user
    @competition = Competition.new(params[:competition])
    @user.competitions << @competition
    @user.save!

    redirect_to :action => :show, :id => @competition.id
  end
  
  def show
    @user = current_user
    @competition = Competition.find params[:id]
    @action = :competition
    
    respond_to do |format|
      format.fbml # show.html.erb
      format.xml  { render :xml => @course }
    end  

  end
   
  def edit
    @user = current_user
    @competition = Competition.find params[:id]
    @action= :edit
  end
  
  def update
    @competition = Competition.find params[:competition][:id]
    @competition.update_attributes(params[:competition])
    @competition.save!
    redirect_to :action => :show, :id => @competition.id
  end

  def select_course
    @user = current_user

    @action = :select_course
    @courses_count = current_user.courses.count
    
    respond_to do |format|
      format.fbml
      format.xml  { render :xml => @courses }
    end
  end
   
  def course_selected
    @user = current_user

    course = params[:course]
    course_name = course["course_name"]
    RAILS_DEFAULT_LOGGER.debug "Course name: #{course_name}"
    @courses = Course.find :all, :conditions => ["name like :name", {:name => course_name + "%"}]
    
    @user = current_user
    @courses_count = @courses.length
    @courses = Course.paginate @courses, :page => params[:page], :order => :name
    @action = :new
    
    respond_to do |format|
      format.fbml # index.html.erb
      format.xml  { render :xml => @courses }
    end
  end
 
  def invite_friends
    @user = current_user
    @competition = Competition.find params[:id]
    
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
    
    #exclude friends already on the competition
    @competition.users.each do |u|
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
 

  # place holder function
  def add_course
    @user = current_user
    redirect_to :action => :show, :id => @competition.id
  end
 
  def friends_competitions
    @user = current_user
    #xml_friends_get = fbsession.friends_get
    #friends_uids = xml_friends_get.search("//uid").map{|uidnode| uidnode.inner_html.to_i}
    friends_uids = fbsession.friends_get.uid_list
    users = User.find_all_by_facebook_uid friends_uids
    uids = []
    users.each { |u| uids << u.id }
    @competitions = Competition.paginate Competition.find_all_by_user_id(uids), :page => params[:page], :order => :name
    @action = :friends_competitions
    render :action => :index
  end
  
  def courses
    @user = current_user
    @competition = Competition.find params[:id]
    @courses = Course.paginate @competition.courses, :page => params[:page], :order => :name
    @action = :courses
  end
  
  def players
    @user = current_user
    @competition = Competition.find params[:id]
    @players = [ @competition.user ]
    @competition.users.each do |u|
      @players << u
    end
    @action = :players
  end

end
