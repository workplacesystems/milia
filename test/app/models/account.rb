class Account < ActiveRecord::Base
  acts_as_universal_and_determines_account

  has_many :members, dependent: :destroy
  has_many :posts, dependent: :destroy
  has_many :zines, dependent: :destroy
  has_many :teams, dependent: :destroy
  has_many :team_assets, dependent: :destroy

  # ------------------------------------------------------------------------
  # ------------------------------------------------------------------------
  # ------------------------------------------------------------------------
    def self.create_new_account(account_params, user_params, coupon_params)

      account = Account.new(:name => account_params[:name])

      if new_signups_not_permitted?(coupon_params)

        raise ::Milia::Control::MaxAccountExceeded, "Sorry, new accounts not permitted at this time" 

      else 
        account.save    # create the account
      end
      return account
    end

  # ------------------------------------------------------------------------
  # new_signups_not_permitted? -- returns true if no further signups allowed
  # args: params from user input; might contain a special 'coupon' code
  #       used to determine whether or not to allow another signup
  # ------------------------------------------------------------------------
  def self.new_signups_not_permitted?(params)
    return false
  end

  # ------------------------------------------------------------------------
  # account_signup -- setup a new account in the system
  # CALLBACK from devise RegistrationsController (milia override)
  # AFTER user creation and current_account established
  # args:
  #   user  -- new user  obj
  #   account -- new account obj
  #   other  -- any other parameter string from initial request
  # ------------------------------------------------------------------------
    def self.account_signup(user, account, other = nil)
      #  StartupJob.queue_startup( account, user, other )
      # any special seeding required for a new organizational account
      #
      Member.create_org_admin(user)
      #
    end

  
end
