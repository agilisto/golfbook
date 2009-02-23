class Caddy < ActiveRecord::Base
  belongs_to :course
  
  validates_presence_of :first_name

  acts_as_rateable

  def name
    "#{first_name} #{last_name}"
  end

end