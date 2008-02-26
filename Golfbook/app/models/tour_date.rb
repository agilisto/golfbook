class TourDate < ActiveRecord::Base
  belongs_to :course
  belongs_to :tour
  
#  def initialize(tour, course, play_date)
#    self.tour = tour
#    self.course = course
#    self.to_play_at = play_date
#  end
  
  def self.upcoming_tours
    TourDate.find(:all,
      :conditions => ["to_play_at >= :to_play_at", {:to_play_at => Date.today}],
      :limit => 10, :order => 'to_play_at ASC' )
  end
  
end
