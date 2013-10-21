require 'spec_helper'

describe Role do
  subject {create(:role)}
  describe "validations" do
    it {should validate_presence_of :role}
    it {should validate_presence_of :onid}
  end
end
