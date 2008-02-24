class CompetitionRound < ActiveRecord::Base
  belongs_to :competition
  belongs_to :round
end
