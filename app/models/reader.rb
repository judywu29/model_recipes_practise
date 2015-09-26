class Reader < ActiveRecord::Base
  has_many :subscriptions
  has_many :magzines, through: :subscriptions
end
