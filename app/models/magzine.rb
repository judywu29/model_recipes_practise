class Magzine < ActiveRecord::Base
  has_many :subscriptions
  
  has_many :readers, through: :subscriptions, extend: ReaderFinder
  #or:bypassing a block:
  # has_many :readers, through: :subscriptions do
    # def below_average(age)
      # where('age < ?', age)
    # end
  # end
  
  # default_scope { where(published: true) }
  
  # has_many :annual_subscriptions, ->{ where length_in_issues: 12 }, through: :subscriptions , source: :reader
end
