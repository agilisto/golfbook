require File.dirname(__FILE__) + '/../test_helper'

require 'Course'

class UserTest < ActiveSupport::TestCase

  def setup
    @arnold = users(:arnold_palmer)
    @gansbaai = courses(:gansbaai)
  end
  
  def test_post_score
    round = Round.new(
        :course => @gansbaai,
        :score => 81)

    @arnold.post_score(round)
    
    assert(@gansbaai.players.count == 4) #include users from fixture
    assert_equal(@arnold, @gansbaai.players[3])
    assert(@arnold.rounds.count == 1)
  end
  
  def test_has_played_and_post_score
    round = Round.new(
        :course => @gansbaai)

    
    @arnold.post_score(round)
    
    assert(1, @gansbaai.players.count)
    assert(1, @gansbaai.users.count)
    
    round2 = Round.new(
        :course => @gansbaai)

    @arnold.post_score(round2)

    assert(1, @gansbaai.players.count)
    assert(2, @gansbaai.users.count)
  end
  
  def test_has_played
    @arnold.has_played(@gansbaai)
    assert(1, @gansbaai.users.count)
    
    @arnold.has_played(@gansbaai)
    puts @gansbaai.inspect
    assert(1, @gansbaai.users.count)
  end
  
end
