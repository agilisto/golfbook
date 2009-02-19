class EzgraphicsController < ApplicationController

  skip_before_filter :adjust_format_for_facebook, :load_user, :require_facebook_install

  def my_handicap
    #getting the friends and their names - passed in via params[:id]
    friend_array = params[:id].split("/")
    names = []
    uids = []
    friend_array.each_with_index do |x,i|
      if i.even?
        names << x
      else
        uids << x
      end
    end
    @friends = User.find_all_by_facebook_uid(uids)

    #charting stuff from here on down
    @handicap_chart = Ezgraphix::Graphic.new(:w => 700, :h => 300, :c_type => 'msline', :div_name => 'friend_handicap', :multiple => "true",
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
