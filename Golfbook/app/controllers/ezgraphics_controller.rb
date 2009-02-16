class EzgraphicsController < ApplicationController

  skip_before_filter :adjust_format_for_facebook, :load_user #, :require_facebook_install

  def my_handicap
#    @fbuser = fbuser
    @fbuser = fbuser
    @user = current_user || User.find(params[:id])

    @my_handicap = Ezgraphix::Graphic.new(:w => 400, :h => 300, :c_type => 'line', :div_name => 'my_handicap')
    my_handicap_data = {}
    get_dates.each do |d|
      my_handicap_data[d] = (@user.handicap_on(d).value rescue nil)
    end
    @my_handicap.data = my_handicap_data

    @g = Ezgraphix::Graphic.new
    @g.data = {:ruby => 1, :perl => 2, :smalltalk => 3}
    render :layout => false
  end

  def friends_handicap
    @fbuser = fbuser
    @user = current_user

    friends_uids = fbsession.friends_get.uid_list
    users = User.find_all_by_facebook_uid friends_uids

    @friend_handicap = Ezgraphix::Graphic.new(:w => 400, :h => 300, :c_type => 'msline', :div_name => 'friend_handicap', :multiple => "true")
    categories = get_dates
    @friend_handicap.categories = categories
    data = []
    users.each do |u|
      data << {:options => {:seriesname => u.id}, :series => (categories.collect{|x|(u.handicap_on(x).value rescue 0) + 1000})}
    end
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
