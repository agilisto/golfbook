class Round < ActiveRecord::Base
  belongs_to :user
  belongs_to :course
  
  validates_numericality_of :score, :only_integer => true
end
