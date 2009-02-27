class EzgraphicsController < ApplicationController

  skip_before_filter :adjust_format_for_facebook, :load_user, :require_facebook_install

  def my_handicap
    #getting the friends and their names - passed in via params[:id]
    @user = User.find(params[:id])
    friend_array = params[:friend_ids]
    names = []
    uids = []
    #there was some last minute refatoring happening here...hence the horrible code.
    friend_array.keys.each do |k|
      names << k
      uids << friend_array[k]
    end

    @friends = User.find_all_by_facebook_uid(uids)

    #charting stuff from here on down
    @round_chart = Ezgraphix::Graphic.new(:w => 700, :h => 300, :c_type => 'msline', :caption => "Recent Rounds", :div_name => 'round_differentials', :multiple => "true",
                                              :rotate => 1, :values => 1, :y_name => 'Rounds', :precision => 0)

    rounds = @user.rounds.find(:all, :order => 'date_played desc', :limit => 10)
    rounds.reverse!
    @round_chart.categories = rounds.collect{|x|x.date_played}
    data = []
    data << {:options => {:seriesname => "Scores"}, :series => rounds.collect{|x|x.score}}
    data << {:options => {:seriesname => "Course Ratings"}, :series => rounds.collect{|x|x.course_rating}}


    @round_chart.data = data

    @handicap_chart = Ezgraphix::Graphic.new(:w => 700, :h => 300, :c_type => 'msline', :caption => "Handicaps", :div_name => 'friend_handicap', :multiple => "true",
                                              :rotate => 1, :values => 1, :y_name => 'Handicap', :precision => 0, 'yaxisminvalue' => -8, 'yaxismaxvalue' => 38)
    categories = get_dates
    @handicap_chart.categories = categories
    data = []
    @friends.each do|friend|
      data << {:options => {:seriesname => (names[uids.index(friend.facebook_uid.to_s)])}, :series => categories.collect{|x|(friend.handicap_on(x).value rescue nil)}}
    end
    @handicap_chart.data = data

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
