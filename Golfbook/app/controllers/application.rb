# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  before_filter :require_facebook_login, :adjust_format_for_facebook    
  
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'ab3cdc368e4e352eebd96b713dae6028'
  
  private
      def adjust_format_for_facebook  
        if in_facebook_canvas? 
          request.format = :fbml        
        end
      end
      
      
end
