class TourPlayer < ActiveRecord::Base
  belongs_to :user
  belongs_to :tour
end
