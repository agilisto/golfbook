require File.dirname(__FILE__) + '/../test_helper'

class RoundTest < ActiveSupport::TestCase

  def setup
    @arnold = users(:arnold)
    @gansbaai = courses(:gansbaai)
  end

end
