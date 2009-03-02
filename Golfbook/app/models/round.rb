class Round < ActiveRecord::Base
  belongs_to :user
  belongs_to :course
  has_one :handicap
  
  validates_presence_of :score
  validates_numericality_of :score, :only_integer => true
  
  acts_as_reviewable
  
  cattr_reader :per_page
  @@per_page = 25

  before_save :set_holes
  before_create :set_holes
  after_create :create_handicap

  def set_holes
    if (read_attribute(:holes).blank?)
      self.holes = self.course.holes || 18
    end
  end

  def holes
    read_attribute(:holes) || self.course.holes
  end

  def course_rating
    read_attribute(:course_rating) || self.course.course_rating
  end

  def create_handicap
    elligible_rounds = Round.collect_twenty_elligible_rounds_for(self.user_id, self.id)
    if elligible_rounds.blank?
      new_handicap_value = nil
    else
      new_handicap_value =  HandicapCalculator.handicap_for(elligible_rounds, user.gender)
    end
    change = (new_handicap_value.nil? ? nil : ((new_handicap_value - self.user.handicap_on(Date.today).value) rescue nil))
    Handicap.create(:date_played => self.date_played, :round_id => self.id, :user_id => self.user_id, :value => new_handicap_value, :change => change)
  end

  def eligible?
    (holes == 18)
  end

  def previous_round
    Round.find(:first, :order => 'date_played desc', :conditions => ["user_id = ? AND id NOT IN (?) and date_played < ?",self.user_id,self.id,self.date_played])
  end

  #find 20 eligible_rounds and return in the correct format for handicap_calculator
  def self.collect_twenty_elligible_rounds_for(user_id, round_id)
    this_round = find(round_id)
    #find the first round we can use for calculating handicap - we need the most recent 20 rounds - hence the last of the date_played desc order rounds.
    if count(:conditions => ['user_id = ? AND rounds.holes = 18 AND date_played <= ?',user_id,this_round.date_played]) > 20
      reference_round = find(:all, :conditions => ['date_played <= ? AND user_id = ? AND (rounds.holes = 18 OR courses.holes = 18)',this_round.date_played, user_id], :include => :course, :limit => 20, :order => 'date_played desc').last
    else
      reference_round = find(:first, :order => 'date_played ASC', :conditions => ['user_id = ? and rounds.holes = 18', user_id]) || this_round
    end

    #find the rounds with 18 holes between the reference round and this_round
    candidate_rounds = find(:all, :conditions => ['date_played <= ? AND user_id = ? AND date_played >= ? AND (rounds.holes = 18 OR courses.holes = 18)',this_round.date_played, user_id, reference_round.date_played], :order => 'rounds.date_played DESC', :include => :course)
    valid_rounds = []
    candidate_rounds.each do |round|
      if round.eligible?    #this should always be true based on criteria.
        valid_rounds << {:course_par => round.course_rating, :round_score => round.score, :number_of_holes => 18}
      end
    end
    valid_rounds[0..19]
  end

  def self.recreate_handicaps
    Handicap.destroy_all
    find(:all, :order => 'rounds.date_played ASC', :include => [:user, :course]).each do |r|
      r.create_handicap
    end
  end
end
