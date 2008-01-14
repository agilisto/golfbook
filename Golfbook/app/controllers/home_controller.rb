class HomeController < ApplicationController
 
  def index
    @fbuser = fbuser
    @user = user
  end
  
end
