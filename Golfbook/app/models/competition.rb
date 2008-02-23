class Competition < ActiveRecord::Base
  belongs_to :user
  belongs_to :course
  has_many :competitors
  has_many :users, :through => :competitors

    def user_in_competition? user
    ids = [ self.user.id ]
    self.users.each do |u|
      ids << u.id
    end
    ids.include? user.id
  end

end
