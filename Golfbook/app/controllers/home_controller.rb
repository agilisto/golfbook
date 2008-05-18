class HomeController < ApplicationController
  
  NEAR_ME = 'near_user'
  
  def event_map_large
    @user = current_user
    @id = @user.id
    @fbuser = fbuser
  end

  def index
    
    @news = {}
    rss = SimpleRSS.parse open('http://www.pga.com/rss/latest.rss')
    for i in 0..4
      @news[rss.items[i].title] = rss.items[i].link
    end
    
    @fbuser = fbuser
    @user = current_user
    @id = @user.id
    @action = NEAR_ME
    @recent_rounds = Round.find(:all, :order => 'rounds.created_at desc', :limit => 12, :include => [:course, :user])
    
    friends_uids = fbsession.friends_get.uid_list
    users = User.find_all_by_facebook_uid friends_uids
    uids = [ @user.id ]
    users.each { |u| uids << u.id }

    @recent_friends_rounds = Round.find_all_by_user_id uids, :order => 'rounds.created_at desc', :limit => 12, :include => [:course, :user]
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
  
  def friends
    @user = current_user
    fql =  "SELECT uid, name FROM user WHERE uid IN" +
      "(SELECT uid2 FROM friend WHERE uid1 = #{@user.facebook_uid}) " +
      "AND has_added_app = 1" 
    friends_xml = fbsession.fql_query :query => fql
    friends = friends_xml.user_list
    @users = {}
    friends.each do |f|
      user = User.find_by_facebook_uid(f.uid)
      next if user.nil?
      @users[user] = f.name
    end
  end
  
end
