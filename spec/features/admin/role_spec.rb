require 'spec_helper'

describe "role administration" do
  context "as an admin" do
    let(:user) {build(:user, :admin)}
    before(:each) do
      user
    end
  end
end