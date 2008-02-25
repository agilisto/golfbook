class Competition < ActiveRecord::Base
  belongs_to :user
  belongs_to :course
  has_many :competitors
  has_many :users, :through => :competitors

  has_many :competition_rounds
  has_many :rounds, :through => :competition_rounds

  def user_in_competition? user
    ids = [ self.user.id ]
    self.users.each do |u|
      ids << u.id
    end
    ids.include? user.id
  end
  
  def winning_round
    self.competition_rounds.each do |r|
      if r.winning_round
        return r.round
      end
    end
    return nil
  end

end
