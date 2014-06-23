module Milia

  class PasswordsController < Devise::PasswordsController

    skip_before_action :authenticate_account!, :only => [:new, :create, :edit, :update ]

  end  # class
end # module
