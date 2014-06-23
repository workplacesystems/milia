module Milia
  module Control

    # #############################################################################
    class InvalidAccountAccess < SecurityError; end
    class MaxAccountExceeded < ArgumentError; end
    # #############################################################################

    def self.included(base)
      base.extend ClassMethods
    end

    # #############################################################################
    # #############################################################################
    module ClassMethods

    end  # module ClassMethods
    # #############################################################################
    # #############################################################################

    public

    def __milia_change_account!( tid )
      old_id = ( Thread.current[:account_id].nil? ? '%' : Thread.current[:account_id] )
      new_id = ( tid.nil? ? '%' : tid.to_s )
      Thread.current[:account_id] = tid
      session[:account_id] = tid  # remember it going forward
      logger.debug("MILIA >>>>> [change account] new: #{new_id}\told: #{old_id}") unless logger.nil?
    end

    def __milia_reset_account!( )
      __milia_change_account!( nil )
      logger.debug("MILIA >>>>> [reset account] ") unless logger.nil?
    end

    def trace_accounting( fm_msg )
      if ::Milia.trace_on
        tid = ( session[:account_id].nil? ? "%/#{Thread.current[:account_id]}" : session[:account_id].to_s )
        uid = ( current_user.nil?  ?  "%/#{session[:user_id]}"  : "#{current_user.id}")
        logger.debug(
          "MILIA >>>>> [#{fm_msg}] stid: #{tid}\tuid: #{uid}\tus-in: #{user_signed_in?}"
        ) unless logger.nil?
      end # trace check
    end

    # set_current_account -- sets the account id for the current invocation (thread)
    # args
    #   account_id -- integer id of the account; nil if get from current user
    # EXCEPTIONS -- InvalidAccountAccess
    def set_current_account( account_id = nil )

      if user_signed_in?

        @_my_accounts ||= current_user.accounts  # gets all possible accounts for user

        account_id ||= session[:account_id]   # use session account_id ?

        if account_id.nil?  # no arg; find automatically based on user
          account_id = @_my_accounts.first.id  # just pick the first one
        else   # validate the specified account_id before setup
          raise InvalidAccountAccess unless @_my_accounts.any?{|tu| tu.id == account_id}
        end

      else   # user not signed in yet...
        account_id = nil   # an impossible account_id
      end

      __milia_change_account!( account_id )
      trace_accounting( "set_current_account" )

      true    # before filter ok to proceed
    end

    # initiate_account -- initiates first-time account; establishes thread
    # assumes not in a session yet (since here only upon new account sign-up)
    # ONLY for brand-new accounts upon User account sign up
    # arg
    #   account -- account obj of the new account
    def initiate_account( account )
      __milia_change_account!( account.id )
    end


    # authenticate_account! -- authorization & account setup
    # -- authenticates user
    # -- sets current account
    def authenticate_account!()
      unless authenticate_user!
        email = ( params.nil? || params[:user].nil?  ?  "<email missing>"  : params[:user][:email] )
        flash[:error] = "cannot sign in as #{email}; check email/password"
        logger.info("MILIA >>>>> [failed auth user] ") unless logger.nil?
        return false  # abort the before_filter chain
      end

      trace_accounting( "authenticate_account!" )

      # user_signed_in? == true also means current_user returns valid user
      raise SecurityError,"*** invalid user_signed_in  ***" unless user_signed_in?

      set_current_account   # relies on current_user being non-nil

      # successful account authentication; do any callback
      if self.respond_to?( :callback_authenticate_account, true )
        logger.debug("MILIA >>>>> [auth_account callback]")
        self.send( :callback_authenticate_account )
      end

      true  # allows before filter chain to continue
    end

    def max_accounts()
      logger.info(
        "MILIA >>>>> [max account signups] #{Time.now.to_s(:db)} - User: #{params[:user][:email]}, org: #{params[:account][:name]}"
      ) unless logger.nil?

      flash[:error] = "Sorry: new accounts not permitted at this time"

      # if using Airbrake & airbrake gem
      if ::Milia.use_airbrake
        notify_airbrake( $! )  # have airbrake report this -- requires airbrake gem
      end
      redirect_back
    end

    # invalid_account -- using wrong or bad data
    def invalid_account
      flash[:error] = "wrong account access; sign out & try again"
      redirect_back
    end

    # redirect_back -- bounce client back to referring page
    def redirect_back
      redirect_to :back rescue redirect_to root_path
    end

    # klass_option_obj -- returns a (new?) object of a given klass
    # purpose is to handle the variety of ways to prepare for a view
    # args:
    #   klass -- class of object to be returned
    #   option_obj -- any one of the following
    #       -- nil -- will return klass.new
    #       -- object -- will return the object itself
    #       -- hash   -- will return klass.new( hash ) for parameters
    def klass_option_obj(klass, option_obj)
      return option_obj if option_obj.instance_of?(klass)
      option_obj ||= {}  # if nil, makes it empty hash
      return klass.send( :new, option_obj )
    end

    # prep_signup_view -- prepares for the signup view
    # args:
    #   account: either existing account obj or params for account
    #   user:   either existing user obj or params for user
    # My signup form has fields for user's email,
    # organization's name (account model), coupon code,
    def prep_signup_view(account=nil, user=nil, coupon={coupon:''})
      @user   = klass_option_obj( User, user )
      @account = klass_option_obj( Account, account )
      @coupon = coupon #  if ::Milia.use_coupon
    end

    # Overwriting the sign_out redirect path method
    def after_sign_out_path_for(resource_or_scope)

      if ::Milia.signout_to_root
        root_path        # return to index page
      else
        # or return to sign-in page
        scope = Devise::Mapping.find_scope!(resource_or_scope)
        send(:"new_#{scope}_session_path")
      end

    end

    def after_sign_in_path_for(resource_or_scope)
      welcome_path
    end


    def after_sign_up_path_for(resource_or_scope)
      root_path
    end




    # #############################################################################
    # #############################################################################

  end  # module Control
end  # module Milia
