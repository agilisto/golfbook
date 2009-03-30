class PingdomController < ApplicationController

  skip_before_filter :require_facebook_install, :adjust_format_for_facebook, :set_active_menu, :set_active_submenu, :load_user

  def index
    number_of_courses = Course.count
    render :text => "The number of courses in the database is " + number_of_courses.to_s, :layout => false
  end

end
