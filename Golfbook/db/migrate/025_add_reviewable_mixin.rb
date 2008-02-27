class AddReviewableMixin < ActiveRecord::Migration
  def self.up
     create_table "reviews", :force => true do |t|
       t.column "review", :string, :limit => 5000
       t.column "created_at", :datetime, :null => false
       t.column "reviewable_type", :string, :limit => 15, :default => "", :null => false
       t.column "reviewable_id", :integer, :default => 0, :null => false
       t.column "user_id", :integer, :default => 0, :null => false
     end

     add_index "reviews", ["user_id"], :name => "fk_reviews_user"
   end

   def self.down
     drop_table :reviews
   end
end
