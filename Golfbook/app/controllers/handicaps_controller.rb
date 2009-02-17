class HandicapsController < ApplicationController

  def index

    @fbuser = fbuser
    @user = User.find(params[:id]) rescue current_user

    @my_rounds = @user.rounds.find(:all, :order => 'date_played desc', :limit => 15)
    if (@user.facebook_uid.to_s == current_user.facebook_uid.to_s)
      @fql_friends = get_friends_for_facebook_uid(@user.facebook_uid)
      users = User.find_all_by_facebook_uid(@fql_friends).compact.uniq
      @uids = users.collect{ |u| u.id } + [@user.id]
      @friends_rounds = Round.find(:all, :order => 'rounds.date_played desc', :conditions => ["rounds.user_id IN (?)",@uids], :limit => 15)
    end
  end

#  private
#  def rescue_action(exception)
#    puts "=================="
#    puts exception.message
#    puts exception.backtrace.join("\n")
#    puts "=================="
#    throw exception
#  end


end
