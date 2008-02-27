# ActsAsReviewable
module Agilisto
  module Acts #:nodoc:
    module Reviewable #:nodoc:

      def self.included(base)
        base.extend ClassMethods  
      end

      module ClassMethods
        def acts_as_reviewable
          has_many :reviews, :as => :reviewable, :dependent => :destroy
          include Agilisto::Acts::Reviewable::InstanceMethods
          extend Agilisto::Acts::Reviewable::SingletonMethods
        end
      end
      
      # This module contains class methods
      module SingletonMethods
        # Helper method to lookup for ratings for a given object.
        # This method is equivalent to obj.ratings
        def find_reviews_for(obj)
          reviewable = ActiveRecord::Base.send(:class_name_of_active_record_descendant, self).to_s
         
          Review.find(:all,
            :conditions => ["revieable_id = ? and reviewable_type = ?", obj.id, reviewable],
            :order => "created_at DESC"
          )
        end
        
        # Helper class method to lookup reviews for
        # the mixin review type written by a given user.  
        # This method is NOT equivalent to Review.find_reviews_for_user
        def find_reviews_by_user(user) 
          reviewable = ActiveRecord::Base.send(:class_name_of_active_record_descendant, self).to_s
          
          Review.find(:all,
            :conditions => ["user_id = ? and reviewable_type = ?", user.id, reviewable],
            :order => "created_at DESC"
          )
        end
      
      end
      
      # This module contains instance methods
      module InstanceMethods
        # Helper method that defaults the current time to the submitted field.
        def add_review(review)
          reviews << review
        end
       
      end
    end
  end
end
