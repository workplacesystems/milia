class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :authenticate_account!

  ##    milia defines a default max_accounts, invalid_account exception handling
  ##    but you can override these if you wish to handle directly
  rescue_from ::Milia::Control::MaxAccountExceeded, :with => :max_accounts
  rescue_from ::Milia::Control::InvalidAccountAccess, :with => :invalid_account

end
