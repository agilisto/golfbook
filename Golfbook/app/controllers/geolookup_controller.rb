require 'geonames'

class GeolookupController < ApplicationController
  
  skip_filter :require_facebook_login, :handle_facebook_login, :persist_fbsession
  MAX_ROWS = 10
  
  def city
    criteria = Geonames::ToponymSearchCriteria.new
    criteria.name_starts_with = params[:suggest_typed]
    criteria.max_rows = '10'
    results = Geonames::WebService.search(criteria).toponyms
    names = results.map {|n| n.name << ', ' << n.country_name }
    puts names
    render :text => "{fortext:#{params[:suggest_typed].to_json},results:#{names.to_json}}"
  end  
end
