class HomeController < ApplicationController
  
  NEAR_ME = 'near_user'

  def index
    
    @fbuser = fbuser
    @user = current_user
    @id = @user.id
    @action = NEAR_ME
    @recent_rounds = Round.find(:all, :order => 'rounds.created_at desc', :limit => 10, :include => [:course, :user])
    
    friends_uids = fbsession.friends_get.uid_list
    users = User.find_all_by_facebook_uid friends_uids
    uids = [ @user.id ]
    users.each { |u| uids << u.id }

    @recent_tours = Tour.find_all_by_user_id uids, :order => :created_at, :limit => 3
    @recent_competitions = Competition.find_all_by_user_id uids, :order => :created_at, :limit => 3
    @recent_friends_rounds = Round.find_all_by_user_id uids, :order => 'rounds.created_at desc', :limit => 10, :include => [:course, :user]
    @recent_courses = Course.recent_additions
    @recent_courses_played = Course.recently_played
        
    @upcoming_games = @user.games.upcoming
    @user.games_to_play.upcoming.each { |g| @upcoming_games << g }
    
    # causing "stack level too deep" exception
    #@recent_ratings = Course.find_last_rated 3
    @recent_ratings = Rating.find :all, :order => "ratings.created_at desc", :limit => 10 #, :include => [:user]
  end
  
  def invite
    @user = current_user
    fql =  "SELECT uid, name FROM user WHERE uid IN" +
      "(SELECT uid2 FROM friend WHERE uid1 = #{@user.facebook_uid}) " +
      "AND has_added_app = 1" 
    xml_friends = fbsession.fql_query :query => fql
    @friends = Hash.new
    xml_friends.search("//user").map do|usrNode| 
      @friends[(usrNode/"uid").inner_html] = (usrNode/"name").inner_html
    end
    @friend_ids = []
    @friends.each do |uid, name|
      @friend_ids << uid
    end
    @friend_ids = @friend_ids.join(',')
  end
  
end
