require 'spec_helper'

describe MyController do

  describe "GET 'index'" do
    before(:each) do
      RubyCAS::Filter.fake("bla")
    end
    it "returns http success" do
      get 'index'
      response.should be_success
    end
  end

end
