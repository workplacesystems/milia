class TeamAsset < ActiveRecord::Base
  acts_as_account
  
  belongs_to :member
  belongs_to :team
end
