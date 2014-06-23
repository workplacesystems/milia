module Milia

  class SessionsController < Devise::SessionsController

    skip_before_action :authenticate_account!, :only => [:new, :create, :destroy]

    def destroy
      __milia_reset_account!   # clear accounting
      super
    end

  end  # class
end # module
