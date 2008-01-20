class Round < ActiveRecord::Base
  belongs_to :user
  belongs_to :course
  
  validates_presence_of :score
  validates_numericality_of :score, :only_integer => true
  
  cattr_reader :per_page
  @@per_page = 50
end