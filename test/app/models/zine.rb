class Zine < ActiveRecord::Base
  acts_as_account

  belongs_to  :team
  has_many    :posts
  has_many    :members, :through => :posts

end
