require File.dirname(__FILE__) + '/../test_helper'

require 'Course'

class UserTest < ActiveSupport::TestCase
  
  def test_post_score
    arnold = users(:arnold_palmer)
    gansbaai = courses(:gansbaai)
    round = Round.new()
    round.course = gansbaai
    round.score = 81
    
    arnold.post_score(round)
    
    gansbaai.reload
    
    assert(gansbaai.players.count == 1)
    assert_equal(arnold, gansbaai.players[0])
    assert(arnold.rounds.count == 1)
    
  end
  
end
