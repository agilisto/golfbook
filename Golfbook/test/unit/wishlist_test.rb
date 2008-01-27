require File.dirname(__FILE__) + '/../test_helper'

class WishlistTest < ActiveSupport::TestCase
  
  def setup
    @arnold = users(:arnold_palmer)
    @gansbaai = courses(:gansbaai)
    @ixopo = courses(:ixopo)
  end
  
  def test_user_wants_to_play_course
    wish_list = Wishlist.new
    wish_list.user = @arnold
    wish_list.course = @gansbaai
    
    wish_list.save
    
    assert(@arnold.courses_want_to_play.include?(@gansbaai))
    assert(!@arnold.courses_want_to_play.include?(@ixopo))
    
    @arnold.add_to_wishlist(@ixopo)
    assert(@arnold.courses_want_to_play.include?(@ixopo))    
    
    assert_equal(@arnold, @gansbaai.players_want_to_play[0])
    assert_equal(1, @gansbaai.players_want_to_play.count)
  end
  
  def test_multiple_wishlist_adds
    @arnold.add_to_wishlist(@ixopo)
    @arnold.add_to_wishlist(@ixopo)
    
    assert_equal(1, Wishlist.count)
  end
  
  def test_wish_list_course_played
    @arnold.add_to_wishlist(@gansbaai)
    @arnold.add_to_wishlist(@ixopo)
    @arnold.has_played(@ixopo)
    
    assert_equal(2,@arnold.courses_want_to_play.count)
    assert_equal(1,@arnold.courses_want_to_play.completed.length)
    assert_equal(1,@arnold.courses_want_to_play.outstanding.length)

    assert_equal(@ixopo, @arnold.courses_want_to_play.completed.first)
    assert_equal(@gansbaai, @arnold.courses_want_to_play.outstanding.first)
  end
  
end
