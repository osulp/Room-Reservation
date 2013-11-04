require 'spec_helper'

describe AutoLogin do
  subject {build(:auto_login)}
  describe "validations" do
    it {should validate_presence_of(:username)}
    it {should have_many(:ip_addresses)}
  end
end
