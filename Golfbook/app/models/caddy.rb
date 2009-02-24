class Caddy < ActiveRecord::Base
  belongs_to :course
  
  validates_presence_of :first_name, :course_id

  validates_uniqueness_of :last_name, :scope => [:first_name, :course_id]

  cattr_reader :per_page
  @@per_page = 20


  acts_as_rateable

  def name
    "#{first_name} #{last_name}"
  end

end
