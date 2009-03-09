class Activity < ActiveRecord::Base
  belongs_to :target, :polymorphic => true
  belongs_to :user

  POSTED = 'posted'
  ADDED = 'added'
  RATED = 'rated'
  IDENTIFIED = 'identified'

  def self.log_activity(target, verb, user_id)
    self.create(:target_type => target.class.name, :target_id => target.id, :user_id => user_id, :verb => verb) rescue nil
  end


  def self.create_random
    target = [Photo, Round, Rating, Course, Caddy].sort_by{rand}.first.find(:first, :order => "RAND()")
    if target.class.name == "Course"
      user_id = target.added_by_id || User.find(:first, :order => "RAND()").id
      verb = Activity::ADDED
    elsif target.class.name == "Caddy"
      user_id = User.find(:first, :order => 'RAND()').id
      verb = Activity::ADDED
    elsif target.class.name == "Photo"
      user_id = target.user_id
      verb = [Activity::ADDED, Activity::IDENTIFIED, Activity::IDENTIFIED, Activity::ADDED].sort_by{rand}.first
    elsif target.class.name == "Round"
      user_id = target.user_id
      verb = Activity::POSTED
    else
      verb = Activity::RATED
    end
    user_id ||= User.find(:first, :order => "RAND()")
    Activity.log_activity(target, verb, user_id)
  end

  def self.backdate
    Round.find(:all, :order => 'created_at asc').each do |r|
      self.create(:target_type => "Round", :target_id => r.id, :created_at => r.created_at, :user_id => r.user_id, :verb => Activity::POSTED)
    end
  end

end