class HomeController < ApplicationController
  
  NEAR_ME = 'near_user'
  
  def event_map_large
    @user = current_user
    @id = @user.id
    @fbuser = fbuser
  end

  def index
    sidebar :home

    @fbuser = fbuser
    @user = current_user
    @id = @user.id
    @action = NEAR_ME   #ivor - ?
    @recent_rounds = Round.find(:all, :order => 'rounds.created_at desc', :limit => 12, :include => [:course, :user])
    
    friends_uids = fbsession.friends_get.uid_list
    users = User.find_all_by_facebook_uid friends_uids
    uids = users.collect{ |u| u.id } + [@user.id]
    @friends_count = users.compact.size
    @recent_friends_rounds = Course.find(:all, :limit => 3, :include => :last_four_rounds, :order => 'rounds.date_played desc', :conditions => ["rounds.user_id IN (?)",uids])

    @recent_courses_played = Course.find(:all, :limit => 3, :include => :last_four_rounds, :order => 'rounds.date_played desc', :conditions => ["rounds.user_id NOT IN (?)",uids])
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
    sidebar :profile
  end
  
  def friends
    @user = current_user
    fql =  "SELECT uid, name FROM user WHERE uid IN" +
      "(SELECT uid2 FROM friend WHERE uid1 = #{@user.facebook_uid}) " +
      "AND has_added_app = 1"
    friends_xml = fbsession.fql_query :query => fql
    @fql_friends = friends_xml.user_list
    @users = User.find_all_by_facebook_uid(@fql_friends.collect{|x|x.uid}, :include => :last_round, :order => 'rounds.created_at DESC')
    @fql_friends.each do |f|
      (user = @users.detect{|x|x.facebook_uid.to_s == f.uid})
      user.name = f.name unless user.nil?
    end
    @users
    sidebar :home
  end
  
  private
  def rescue_action(exception)
    puts "=================="
    puts exception.message
    puts exception.backtrace.join("\n")
    puts "=================="
    throw exception
  end


end
