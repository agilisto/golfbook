class Game < ActiveRecord::Base
  belongs_to :user
  belongs_to :course
  has_many :game_players
  has_many :users, :through => :game_players
end
