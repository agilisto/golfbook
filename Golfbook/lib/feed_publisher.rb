module FeedPublisher

  @@template_config = YAML.load(File.read('config/facebook_feed_templates.yml'))
  @@feelings = {5 => 'really liked', 4 => 'liked', 3 => 'rated', 2 => 'was unimpresed by', 1 => "really didn't like"}


  #ADDING A NEW COURSE
  #http://wiki.developers.facebook.com/index.php/Feed.registerTemplateBundle
  def register_course_added_bundle
    bundle_id = @@template_config[RAILS_ENV]['course_added']
    if bundle_id.blank?
      one_line_story_templates = [ '{*actor*} added the course, {*course*}, to {*application*}', '{*actor*} added a course to {*application*}' ]
      response = fbsession.feed_registerTemplateBundle( :one_line_story_templates => one_line_story_templates.to_json)
      bundle_id = response.to_s
      @@template_config[RAILS_ENV]['course_added'] = bundle_id
      File.open("#{RAILS_ROOT}/config/facebook_feed_templates.yml",'w') do |file|
        file.write @@template_config.to_yaml
      end
    end
    return bundle_id
  end

  def publish_course_added_action(course_id)
    bundle_id = register_course_added_bundle
    @course = Course.find(course_id)
    course = %{<a href="#{url_for(:controller => 'courses', :action => 'show', :id => @course.id)}">#{@course.name}</a>}
    application = %{<a href="#{url_for(:controller => 'home')}">#{(RAILS_ENV == 'production') ? 'Social Golf' : 'Golf Development'}</a>}
    response = fbsession.feed_publishUserAction(:template_bundle_id => bundle_id, :template_data => {:course => course, :application => application}.to_json)
  end
  #END OF ADDING A NEW COURSE

  #RATING A COURSE
  def register_course_rated_bundle
    bundle_id = @@template_config[RAILS_ENV]['course_rated']
    if bundle_id.blank?
      one_line_story_templates = [ '{*actor*} rated the course, {*course*}, {*rating*}/5 on {*application*}', '{*actor*} rated the course, {*course*} on {*application*}', '{*actor*} rated a course on {*application*}' ]
      short_story_templates = [ { :template_title => '{*actor*} {*feeling*} {*course*}', :template_body => '{*actor*} rated the course {*rating*}/5 on {*application*}' },
                                { :template_title => '{*actor*} rated {*course*}', :template_body => '{*actor*} rated the course on {*application*}' }
                              ]
      response = fbsession.feed_registerTemplateBundle( :one_line_story_templates => one_line_story_templates.to_json, :short_story_templates => short_story_templates.to_json)
      bundle_id = response.to_s
      @@template_config[RAILS_ENV]['course_rated'] = bundle_id
      File.open("#{RAILS_ROOT}/config/facebook_feed_templates.yml",'w') do |file|
        file.write @@template_config.to_yaml
      end
    end
    return bundle_id
  end

  def publish_course_rated_action(course_id, rating)
    bundle_id = register_course_rated_bundle
    @course = Course.find(course_id)
    course = %{<a href="#{url_for(:controller => 'courses', :action => 'show', :id => @course.id)}">#{@course.name}</a>}
    application = %{<a href="#{url_for(:controller => 'home')}">#{(RAILS_ENV == 'production') ? 'Social Golf' : 'Golf Development'}</a>}
    feelings = @@feelings[rating.to_i]
    feeling = feelings[rating.to_i]
    response = fbsession.feed_publishUserAction(:template_bundle_id => bundle_id, :template_data => {:course => course, :application => application, :rating => rating, :feeling => feeling}.to_json)
  end
  #END OF RATING A COURSE

  #RATING A CADDY
  def register_caddy_rated_bundle
    bundle_id = @@template_config[RAILS_ENV]['caddy_rated']
    if bundle_id.blank?
      one_line_story_templates = [ '{*actor*} rated a caddy, {*caddy_name*}, {*rating*}/5 on {*application*}', '{*actor*} rated a caddy, {*caddy_name*} on {*application*}', '{*actor*} rated a caddy on {*application*}' ]
      short_story_templates = [ { :template_title => '{*actor*} {*feeling*} a caddy, {*caddy_name*}', :template_body => '{*actor*} rated {*caddy_name*} {*rating*}/5 on {*application*}' },
                                { :template_title => '{*actor*} rated {*caddy_name*}', :template_body => '{*actor*} rated a caddy on {*application*}' }
                              ]
      response = fbsession.feed_registerTemplateBundle( :one_line_story_templates => one_line_story_templates.to_json, :short_story_templates => short_story_templates.to_json)
      bundle_id = response.to_s
      @@template_config[RAILS_ENV]['caddy_rated'] = bundle_id
      File.open("#{RAILS_ROOT}/config/facebook_feed_templates.yml",'w') do |file|
        file.write @@template_config.to_yaml
      end
    end
    return bundle_id
  end

  def publish_caddy_rated_action(caddy_id, rating)
    bundle_id = register_caddy_rated_bundle
    @caddy = Caddy.find(caddy_id)
    caddy_name = %{<a href="#{url_for(:controller => 'caddies', :action => 'index')}">#{@caddy.name}</a>}
    application = %{<a href="#{url_for(:controller => 'home')}">#{(RAILS_ENV == 'production') ? 'Social Golf' : 'Golf Development'}</a>}
    feeling = @@feelings[rating.to_i]
    response = fbsession.feed_publishUserAction(:template_bundle_id => bundle_id, :template_data => {:caddy_name => caddy_name, :application => application, :rating => rating, :feeling => feeling}.to_json)
  end
  #END OF RATING A CADDY

  #ADDING A NEW CADDY
  def register_caddy_added_bundle
    bundle_id = @@template_config[RAILS_ENV]['caddy_added']
    if bundle_id.blank?
      one_line_story_templates = [ '{*actor*} added a caddy, {*caddy_name*}, to {*application*}', '{*actor*} added a caddy to {*application*}' ]
      response = fbsession.feed_registerTemplateBundle( :one_line_story_templates => one_line_story_templates.to_json)
      bundle_id = response.to_s
      @@template_config[RAILS_ENV]['caddy_added'] = bundle_id
      File.open("#{RAILS_ROOT}/config/facebook_feed_templates.yml",'w') do |file|
        file.write @@template_config.to_yaml
      end
    end
    return bundle_id
  end

  def publish_caddy_added_action(caddy_id)
    bundle_id = register_caddy_added_bundle
    @caddy = Caddy.find(course_id)
    caddy_name = %{<a href="#{url_for(:controller => 'caddies', :action => 'index')}">#{@caddy.name}</a>}
    application = %{<a href="#{url_for(:controller => 'home')}">#{(RAILS_ENV == 'production') ? 'Social Golf' : 'Golf Development'}</a>}
    response = fbsession.feed_publishUserAction(:template_bundle_id => bundle_id, :template_data => {:caddy_name => caddy_name, :application => application}.to_json)
  end
  #END OF ADDING A NEW CADDY

  #POSTING A NEW ROUND
  def register_round_posted_bundle
    bundle_id = @@template_config[RAILS_ENV]['round_posted']
    if bundle_id.blank?
      one_line_story_templates = [ '{*actor*} posted a {*round*} of {*score*} at {*course*} on {*application*}', '{*actor*} posted a {*round*} of {*score*} on {*application*}', '{*actor*} posted a round on {*application*}']
      short_story_templates = [ { :template_title => '{*actor*} posted a {*round*} of {*score*} on {*application*}', :template_body => '{*actor*} played the {*round*} at {*course*}. This {*effect*} his unofficial handicap which is currently {*handicap*}. <br />Comment: "{*comment*}"' },
                                { :template_title => '{*actor*} posted a {*round*} on {*application*}', :template_body => 'The score of {*score*} {*effect*} his unofficial handicap. <br />Comment: {*comment*}' },
                                { :template_title => '{*actor*} posted a {*round*} of {*score*}', :template_body => '{*comment*}' }
                                
                              ]
      response = fbsession.feed_registerTemplateBundle( :one_line_story_templates => one_line_story_templates.to_json, :short_story_templates => short_story_templates.to_json)
      bundle_id = response.to_s
      @@template_config[RAILS_ENV]['round_posted'] = bundle_id
      File.open("#{RAILS_ROOT}/config/facebook_feed_templates.yml",'w') do |file|
        file.write @@template_config.to_yaml
      end
    end
    return bundle_id
  end

  def publish_round_posted_action(round_id)
    bundle_id = register_round_posted_bundle
    @round = Round.find(round_id)
    @course = Course.find(@round.course_id)
    round = %{<a href="#{url_for(:controller => 'round', :action => 'show', :id => @round.id)}">round</a>}
    comment = @round.comments || " "
    course = %{<a href="#{url_for(:controller => 'courses', :action => 'show', :id => @course.id)}">#{@course.name}</a>}
    application = %{<a href="#{url_for(:controller => 'home')}">#{(RAILS_ENV == 'production') ? 'Social Golf' : 'Golf Development'}</a>}
    score = @round.score
    handicap = @round.handicap.value
    effect = if @round.handicap.change < 0
              "lowered"
            elsif @round.handicap.change > 0
              "raised"
            else
              "did not change"
            end
    response = fbsession.feed_publishUserAction(:template_bundle_id => bundle_id, :template_data => {:course => course, 
                                                                                                      :application => application,
                                                                                                      :score => score,
                                                                                                      :handicap => handicap,
                                                                                                      :effect => effect,
                                                                                                      :round => round,
                                                                                                      :comment => comment}.to_json)
  end
  #END OF POSTING A NEW ROUND


end
