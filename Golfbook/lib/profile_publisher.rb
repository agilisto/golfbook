# To change this template, choose Tools | Templates
# and open the template in the editor.

module ProfilePublisher

  def update_profile_box(user_id)
    user = User.find(user_id, :include => 'current_handicap')
    recent_rounds = user.rounds.recent(3)
    upcoming_games = user.games.upcoming
    boxes_content = render_to_string(:partial => 'shared/profile_box', :locals => { :user => user, :recent_rounds => recent_rounds, :upcoming_games => upcoming_games })
    wall_content = boxes_content
    mobile_content = render_to_string(:partial => 'shared/mobile_profile_box', :locals => {:user => user, :recent_rounds => recent_rounds})
    response = fbsession.profile_setFBML({:profile => boxes_content, :profile_main => wall_content, :mobile_profile => mobile_content, :uid => user.facebook_uid})
  end

end
