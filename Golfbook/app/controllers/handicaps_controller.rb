class HandicapsController < ApplicationController

  def index

    @fbuser = fbuser
    @user = current_user

    @my_rounds = @user.rounds.find(:all, :order => 'date_played desc', :limit => 15)
    friends_uids = fbsession.friends_get.uid_list
    users = User.find_all_by_facebook_uid friends_uids
    uids = users.collect{ |u| u.id }
    @friends_rounds = Round.find(:all, :order => 'rounds.date_played desc', :conditions => ["rounds.user_id IN (?)",uids], :limit => 15)
  end
  
end
