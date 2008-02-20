class HomeController < ApplicationController
  
  NEAR_ME = 'near_user'

  def index
    @fbuser = fbuser
    @user = current_user
    @id = @user.id
    @action = NEAR_ME
    @recent_rounds = Round.find(:all, :order => 'created_at desc', :limit => 3)
    
    friends_uids = fbsession.friends_get.uid_list
    users = User.find_all_by_facebook_uid friends_uids
    uids = []
    users.each { |u| uids << u.id }
    @recent_tours = Tour.find_all_by_user_id uids, :order => :created_at, :limit => 3
    
  end
  
end
