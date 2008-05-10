class UserCourseReport
  
  attr_reader :user, :options
  
  def initialize(user, options)
    @user = user
    @options = options || {}
  end
  
  #TODO - Combine the various aspects of courses into a report relevant for the user
    
end
