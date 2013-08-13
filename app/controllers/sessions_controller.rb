class SessionsController < ApplicationController
  before_filter RubyCAS::Filter, :except => :logout
  def new
    redirect_to root_path
  end
  def logout
    RubyCAS::Filter.logout(self)
    #redirect_to root_path
  end
end
