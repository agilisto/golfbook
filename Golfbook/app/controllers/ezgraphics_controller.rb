class EzgraphicsController < ApplicationController

  skip_before_filter :adjust_format_for_facebook, :load_user, :require_facebook_install

  def my_handicap
#    @fbuser = fbuser
    @user = User.find(params[:id])  #current_user ||

    @my_handicap = Ezgraphix::Graphic.new(:w => 500, :h => 400, :c_type => 'line', :div_name => 'my_handicap',
                                          :rotate => 1, :values => 1, :y_name => 'Handicap', :caption => 'My Handicap', :precision => 0, 'yaxisminvalue' => -8, 'yaxismaxvalue' => 38)
    my_handicap_data = []
    get_dates.each_with_index do |d,i|
      my_handicap_data << {d => (@user.handicap_on(d).value rescue nil)}
#      my_handicap_data["#{i}. #{d}"] = (@user.handicap_on(d).value rescue nil)
    end
    @my_handicap.data = my_handicap_data

    render :layout => false
  end

  def friends_handicap
    users = User.find(:all, :conditions => ["id IN (?)",params[:id].split("/")])
    fql =  "SELECT uid, name FROM user WHERE uid IN (#{users.collect{|x|x.facebook_uid}.join(',')})" + " AND has_added_app = 1"
    xml_friends = fbsession.fql_query :query => fql

    logger.info xml_friends + "\n\n\nivorivorivor"
    @friend_handicap = Ezgraphix::Graphic.new(:w => 500, :h => 400, :c_type => 'msline', :div_name => 'friend_handicap', :multiple => "true",
                                              :rotate => 1, :values => 1, :y_name => 'Handicap', :caption => "Friend Handicaps", :precision => 0, 'yaxisminvalue' => -8, 'yaxismaxvalue' => 38)
    categories = get_dates
    @friend_handicap.categories = categories
    data = []
    xml_friends.search("//user").map do|usrNode|
      user = users.detect{|x|x.facebook_uid.to_s == (usrNode/"uid").inner_html.to_s}
      data << {:options => {:seriesname => (usrNode/"name").inner_html}, :series => categories.collect{|x|(user.handicap_on(x).value rescue nil)}}
    end
#    users.each do |u|
#      data << {:options => {:seriesname => u.id}, :series => (categories.collect{|x|(u.handicap_on(x).value rescue nil)})}
#    end
    @friend_handicap.data = data
    render :layout => false
  end

  private
  def get_dates
    dates = []
    today = Date.today
    12.times do |d|
      dates[d] = (today - d.months)
    end
    dates.reverse!
  end

  def rescue_action(exception)
     puts "=================="
     puts exception.message
     puts exception.backtrace.join("\n")
     puts "=================="
     throw exception
  end

end
