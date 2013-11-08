class UsersController < ApplicationController
  before_filter :require_admin
  respond_to :json
  def show
    @record = BannerRecord.find_by_osu_id(params[:id])
    respond_with(@record)
  end

  private

  def require_admin
    respond_with({:error => "Unauthorized to access resource"}, :status => :unauthorized) unless can?(:read, BannerRecord)
  end
end
