class HomeController < ApplicationController
  skip_before_action :authenticate_account!, :only => [ :index ]

  def index
  end

  def show
  end

end
