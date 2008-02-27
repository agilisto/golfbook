# Include hook code here
require 'acts_as_reviewable'
ActiveRecord::Base.send(:include, Agilisto::Acts::Reviewable)
