class HandicapsController < ApplicationController

  def index
    logger.info "AAAAAAAAAAAAAAAAAAAAAA"
    logger.info params.inspect
    logger.info "AAAAAAAAAAAAAAAAAAAAAA"
    @fbuser = fbuser
    @user = User.find(params[:id]) rescue current_user
    @my_rounds = @user.rounds.find(:all, :order => 'rounds.date_played desc', :limit => 15, :include => [:course, :handicap])
    if Hpricot::XML(@fbuser.raw_xml).search("//uid").first.inner_html == @user.facebook_uid.to_s #show user and all their friends on graph
      @fql_friends = get_friends_for_facebook_uid(@user.facebook_uid)
      users = User.find_all_by_facebook_uid(@fql_friends.collect{|x|x[1]}).compact.uniq

      if params["friends"]
        #limit the friends to display to these
#        new_users = []
#        params[:friends].each do |f|
#          new_users << users.detect{|x|x.id.to_s == f}
#          logger.info "BBB" + f.inspect + "BBB" + new_users.inspect + "BBB"
#        end
        users.delete_if{|x|!( params["friends"].include?(x.id.to_s) ) }
        @fql_friends.delete_if{|y| !( users.collect{|z|z.facebook_uid.to_s}.include?(y[1]) ) }
      end

      logger.info "CCCCCCCCCCCCCCCCCCCCCCC fql_friends:" + @fql_friends.inspect + "CCCCCCCCCCCCCCCCCCCCCCC users:" + users.inspect + "CCCCCCCCCCCCCCCCCCCCCCC"
      
      @uids = users.collect{ |u| u.id } # + [@user.id]
      @friends_rounds = Round.find(:all, :order => 'rounds.date_played desc', :conditions => ["rounds.user_id IN (?)",@uids], :limit => 15)

    else  #only show user and the user bein viewed on the graph
      @fql_friends = get_me_and_friend_info(current_user.facebook_uid, @user.facebook_uid)
    end
  end

  def friends
    @user = User.find(params[:id]) rescue current_user
    @fql_friends = get_friends_for_facebook_uid(@user.facebook_uid)
    @friends = User.find_all_by_facebook_uid(@fql_friends.collect{|x|x[1]}).compact.uniq
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
