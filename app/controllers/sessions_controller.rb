class SessionsController < ApplicationController
  before_filter RubyCAS::Filter
  def new
    redirect_to root_path
  end
end
