class Round < ActiveRecord::Base
  belongs_to :user
  belongs_to :course
  has_one :handicap
  
  validates_presence_of :score
  validates_numericality_of :score, :only_integer => true
  
  acts_as_reviewable
  
  cattr_reader :per_page
  @@per_page = 25

  after_create :create_handicap

  def holes
    read_attribute(:holes) || self.course.holes
  end

  def course_rating
    read_attribute(:course_rating) || self.course.course_rating
  end

  def create_handicap
    new_handicap_value =  HandicapCalculator.handicap_for(Round.collect_twenty_elligible_rounds_for(1))
    Handicap.create(:round_id => self.id, :user_id => self.user_id, :value => new_handicap_value, :change => ((new_handicap_value - self.user.current_handicap.value) rescue 0))
  end

  def eligible?
    holes = self.course.holes
    if holes == 18
      return true
    else
      return false if previous_round.nil?   #first round and number of holes not 18 - thus not elligable
      ((holes == 9) and (self.course_id == previous_round.course_id))   #for 9 hole rounds to be elligable you need 2 consequative rounds at the same course
    end
  end

  def previous_round
    Round.find(:first, :order => 'date_played desc', :conditions => ["user_id = ? AND id NOT IN (?) and date_played < ?",self.user_id,self.id,self.date_played])
  end

  #find 20 eligible_rounds and return in the correct format for handicap_calculator
  def self.collect_twenty_elligible_rounds_for(user_id)
    reference_round = find(:all, :conditions => ['user_id = ? AND (rounds.holes = 18 OR courses.holes = 18)',user_id], :include => :course, :limit => 20, :order => 'date_played desc').last
    candidate_rounds = find(:all, :conditions => ['user_id = ? AND date_played >= ?',user_id, reference_round.date_played]).sort_by{|x|x.date_played}.reverse
    valid_rounds = []
    nine_hole_rounds = []
    candidate_rounds.each do |round|
      if round.eligible?
        if round.holes == 9   #if round has 9 holes and is eligible it means the next round in the array is the other half of the course
          if nine_hole_rounds.blank?
            nine_hole_rounds << round
          else
            nine_hole_rounds << round
            combined_round = {:course_par => nine_hole_rounds.collect{|x|x.score}.sum, :round_score => nine_hole_rounds.collect{|x|x.score}.sum, :number_of_holes => 18}
            nine_hole_rounds.delete_at(0)
            valid_rounds << combined_round
            #we are joining these two rounds
          end
        else
          valid_rounds << {:course_par => round.course_rating, :round_score => round.score, :number_of_holes => 18}
        end
      end
    end
    valid_rounds[0..19]
  end
end
