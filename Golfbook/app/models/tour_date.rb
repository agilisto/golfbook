class TourDate < ActiveRecord::Base
  belongs_to :course
  belongs_to :tour
  
#  def initialize(tour, course, play_date)
#    self.tour = tour
#    self.course = course
#    self.to_play_at = play_date
#  end
end
