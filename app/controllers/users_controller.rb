class UsersController < ApplicationController
  before_filter :require_admin
  respond_to :json
  def show
    if params[:id].to_s =~ /\A[0-9]*\Z/
      params[:id] = params[:id].to_s.gsub(/\A11/,"")
    end
    begin
      @record = BannerRecord.find_by_osu_id(params[:id])
    rescue ActiveRecord::RecordNotFound
      @record = BannerRecord.where(:onid => params[:id]).first!
    end
    respond_with(@record)
  end

  private

  def require_admin
    respond_with({:error => "Unauthorized to access resource"}, :status => :unauthorized) unless can?(:read, BannerRecord)
  end
end
