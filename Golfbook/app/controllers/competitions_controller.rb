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
    @course = Course.find(params[:id])
    @competition = Competition.new(:user => @user, :course_id => @course.id)
    @action = :new_competition
  end

  def create
    @user = current_user
    @competition = Competition.new(params[:competition])
    @competition.save
    @user.competitions << @competition
    @user.save!
    title = "<fb:name /> has created a new golf competition: <a href='#{url_for(:action => :show, :id => @competition.id)}'>#{@competition.name}</a>."
    fbsession.feed_publishActionOfUser(:title => title)

    redirect_to :action => :show, :id => @competition.id
  end

  def show
    @user = current_user
    @competition = Competition.find params[:id]
    @action = :show
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
    title = "<fb:name /> has updated his golf competition: <a href='#{url_for(:action => :show, :id => @competition.id)}'>#{@competition.name}</a>."
    fbsession.feed_publishActionOfUser(:title => title)
    redirect_to :action => :show, :id => @competition.id
  end

  def search_course
    @courses_count = Course.count

    @user = current_user
    @action = :new_competition

    respond_to do |format|
      format.fbml
      format.xml  { render :xml => @courses }
    end

  end

  def search_results 
    course = params[:course]
    course_name = course["course_name"]
    RAILS_DEFAULT_LOGGER.debug "Course name: #{course_name}"
    @courses = Course.find :all, 
      :conditions => ["name like :name and awaiting_review = false", {:name => course_name + "%"}]

    @user = current_user
    @courses_count = @courses.length
    @courses = Course.paginate @courses, :page => params[:page], :order => :name
    @action = :new_competition
    
    respond_to do |format|
      format.fbml # index.html.erb
      format.xml  { render :xml => @courses }
    end
  end
 
  def invite_players
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
    @scores = {}
    @competition.rounds.each do |r|
      @scores[r.user] = r
    end
  end

  def invite
    @user = current_user
    @competition = Competition.find params[:id]
  end
  
  def accept_invite
    @competition = Competition.find params[:id]
    if params[:response] == "Accept"
      @user = current_user
      if !@competition.user_in_competition? @user
        @competition.users << @user
        @competition.save!
      end
      message = render_to_string :partial => "comp_accept_invite"
      fbsession.notifications_send :to_ids => [@competition.user.facebook_uid].join(","), :notification => message
      redirect_to :action => :show, :id => @competition.id
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
    @competition = Competition.find params[:id]
    @player = User.find params[:player_id]
    if !@competition.user_in_competition? @player
      @competition.users << @player
      @competition.save!
    end
    message = render_to_string :partial => "comp_accept_invite_request"
    fbsession.notifications_send :to_ids => [@player.facebook_uid].join(","), :notification => message
    redirect_to :action => :players, :id => @competition.id
  end
  
  def new_round
    @user = current_user
    @competition = Competition.find params[:id]
    @round = Round.new(:course_id => @competition.course)
    @action = :players
  end

  def add_round
    @user = current_user
    @competition = Competition.find params[:competition_id]
    @round = Round.new(params[:round])
    @round.user = @user
    @round.course = @competition.course
    @competition_round = CompetitionRound.new :competition => @competition, :round => @round
    @competition_round.save!
    
    title = "<fb:name /> has posted a score of #{@round.score} in the <a href='#{url_for(:action => :show, :id => @competition.id)}'>#{@competition.name}</a> golf competition."
    fbsession.feed_publishActionOfUser(:title => title)
    
    redirect_to :action => :players, :id => @competition.id
  end
  
  def confirm_cancel
    @competition = Competition.find params[:id]
  end
  
  def cancel
    @user = current_user
    @competition = Competition.find params[:id]
    uids = [@user.facebook_uid]
    @competition.users.each { |u| uids << u.facebook_uid }
    message = "has cancelled the #{@competition.name} golf competition."
    fbsession.notifications_send :to_ids => uids.join(","), :notification => message
    title = "<fb:name /> " << message
    fbsession.feed_publishActionOfUser(:title => title)
    @competition.destroy
    flash[:success] = "Competition has been cancelled."    
    redirect_to :action => :index
  end
  
  def select_winner
    @competition = Competition.find params[:id]
    if @competition.open
      if @competition.rounds.length > 0
        @user = current_user
        @players = [ @competition.user ]
        @competition.users.each do |u|
          @players << u
        end
        @scores = {}
        @competition.rounds.each do |r|
          @scores[r.user] = r
        end
      else
        flash[:error] = "No rounds have been posted for this competition."
        redirect_to :action => :show, :id => @competition.id
      end
    else
      flash[:error] = "Competition is already closed."
      redirect_to :action => :show, :id => @competition.id
    end
  end
  
  def close
    @competition = Competition.find params[:id]
    if @competition.open
      @round = Round.find params[:winner]
      @competition_round = CompetitionRound.find :first, :conditions => ["competition_id = :cid and round_id = :rid",
        {:cid => @competition.id, :rid => @round.id}]
      @competition_round.winning_round = true;
      @competition.open = false
      @competition_round.save!
      @competition.save!
      
      title = "<fb:name uid='#{@round.user.facebook_uid}' /> has won the <a href='#{url_for(:action => :show, :id => @competition.id)}'>#{@competition.name}</a> golf competition with a score of #{@round.score}."
      fbsession.feed_publishActionOfUser(:title => title)
    else
      flash[:error] = "Competition is already closed."
    end
    
    redirect_to :action => :show, :id => @competition.id
  end
  
  def close_entries
    @competition = Competition.find params[:id]
    @competition.open_for_entry = false
    @competition.save!
    flash[:notice] = "Competition is closed for entries."
    redirect_to :action => :show, :id => @competition.id
  end
  
  def open_entries
    @competition = Competition.find params[:id]
    @competition.open_for_entry = true
    @competition.save!
    flash[:notice] = "Competition is open for entries."
    redirect_to :action => :show, :id => @competition.id
  end
end
