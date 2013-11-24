module Milia

  class User < ActiveRecord::Base

# ------------------------------------------------------------------------  
# save_and_invite_member -- saves the new user record thus inviting member
    # via devise
    # if password missing; gens a password
    # ensures email exists and that email is unique and not already in system
# ------------------------------------------------------------------------  
    def save_and_invite_member(  )
      if (
          self.email.blank?  ||
          User.first(conditions: [ "lower(email) = ?", self.email.downcase ])
        )
        self.errors.add(:email,"must be present and unique")
        status = nil
      else
        check_or_set_password()
        status = self.save && self.errors.empty?
      end

      return status
    end

  end  # class

private

# ------------------------------------------------------------------------  
# check_or_set_password -- if password missing, generates a password
# ASSUMES: Milia.use_invite_member
# ------------------------------------------------------------------------  
  def check_or_set_password( )

    if self.password.blank?
      self.password = 
        Milia::Password.generate(
          8, Password::ONE_DIGIT | Password::ONE_CASE
        )

        self.password_confirmation = self.password
    else
      # if a password is being supplied, then ok to skip
      # setting up a password upon confirm
      self.skip_confirm_change_password = true if ::Milia.use_invite_member
    end

  end

end # module