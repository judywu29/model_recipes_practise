class Subscription < ActiveRecord::Base
  belongs_to :reader
  belongs_to :magzine
  
  scope :annual_subscriptions, ->{ where length_in_issues: 12 }
  
  scope :subscribed_before, ->(time) { where 'last_renewal_on < ? ', time }
  
  
end
