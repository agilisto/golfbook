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
    @recent_competitions = Competition.find_all_by_user_id uids, :order => :created_at, :limit => 3
    
    # causing "stack level too deep" exception
    #@recent_ratings = Course.find_last_rated 3
    @recent_ratings = Rating.find :all, :order => "ratings.created_at desc", :limit => 3#, :include => [:user]
  end
  
end
